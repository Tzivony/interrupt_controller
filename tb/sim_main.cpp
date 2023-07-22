#include <iostream>
#include <Vinterrupt_controller.h>
#include <verilated.h>
#include <verilated_vcd_c.h>

using namespace std;

// Function signatures
void run_rst_cycle(Vinterrupt_controller* top, VerilatedVcdC* m_trace);
void run_clk_cycle(Vinterrupt_controller* top, VerilatedVcdC* m_trace, int irq, int ier, int isr_clear);
void inc_time(VerilatedVcdC* m_trace);

// Globally defined simulation time
vluint64_t sim_time = 0;

int main(int argc, char** argv, char** env) {
    int irq, ier, isr_clear;

    VerilatedContext* contextp = new VerilatedContext;
    contextp->commandArgs(argc, argv);
    Vinterrupt_controller* top = new Vinterrupt_controller{contextp};

    Verilated::traceEverOn(true);
    VerilatedVcdC* m_trace = new VerilatedVcdC;
    top->trace(m_trace, 99);
    m_trace->open("waveform.vcd");

    
    run_rst_cycle(top, m_trace);

    while (sim_time < 20) {
        if (sim_time > 0 && sim_time % 2 == 0)
        {
            printf(" --- clock cycle %d ---\n", (int)(sim_time / 2));

            cout << "Enter irq: ";
            cin >> irq;

            cout << "Enter ier: ";
            cin >> ier;

            cout << "Enter isr_clear: ";
            cin >> isr_clear;

            run_clk_cycle(top, m_trace, irq, ier, isr_clear);
        }
    }


    m_trace->close();
    delete top;
    delete contextp;
    return 0;
}

void run_rst_cycle(Vinterrupt_controller* top, VerilatedVcdC* m_trace) {
    // First rising edge
    top->clk = 1;
    top->rst_n = 0; // Activate async reset
    top->eval();

    inc_time(m_trace);

    // First falling edge
    top->clk = 0;
    top->rst_n = 1; // Deactivate async reset
    top->eval();

    inc_time(m_trace);
}

void run_clk_cycle(Vinterrupt_controller* top, VerilatedVcdC* m_trace, int irq, int ier, int isr_clear) {
    // Rising edge
    top->clk = 1;
    top->eval();

    // We want signals to take effect after rising edge (as if they come in sampled)
    top->irq = irq;
    top->ier = ier;
    top->isr_clear = isr_clear;
    top->eval();

    inc_time(m_trace);

    // Falling edge (signal change is irrelevant)
    top->clk = 0;
    top->eval();

    inc_time(m_trace);
}

void inc_time(VerilatedVcdC* m_trace) {
    // Dump into waveform
    m_trace->dump(sim_time);

    // Increment simulation time
    sim_time++;
}
