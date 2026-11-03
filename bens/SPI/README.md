# iCESugar v1.5 FPGA Development Workflow

## Goal

Build, simulate, synthesise and program Verilog designs onto the iCESugar v1.5 FPGA board using the open-source iCE40 toolchain.

Target FPGA:

```text
Lattice iCE40UP5K-SG48
```

Board features:

```text
- Internal 48 MHz oscillator
- iCELink programmer/debugger
- RGB LED
- PMOD connectors
- Open-source toolchain support
```

---

# Development Flow

```text
Write Verilog
    ↓
Simulation (Icarus Verilog)
    ↓
Waveform Inspection (GTKWave)
    ↓
Synthesis (Yosys)
    ↓
Place & Route (nextpnr)
    ↓
Bitstream Generation (icepack)
    ↓
Program FPGA (icesprog / drag & drop)
```

---

# Install Required Tools

## Ubuntu

Install:

```bash
sudo apt update

sudo apt install \
    iverilog \
    gtkwave \
    yosys \
    nextpnr-ice40 \
    fpga-icestorm
```

Verify installation:

```bash
iverilog -V

yosys -V

nextpnr-ice40 --version

gtkwave --version
```

---

# Project Structure

Example:

```text
fpga-project/

├── top.v
├── lcd.v
├── pins.pcf
├── spi_master_tb.v
└── build/
```

---

# Simulation

## Compile

```bash
iverilog \
    -o spi_tb \
    lcd.v \
    spi_master_tb.v
```

Produces:

```text
spi_tb
```

---

## Run Simulation

```bash
vvp spi_tb
```

Produces:

```text
spi_master.vcd
```

---

## Open Waveforms

```bash
gtkwave spi_master.vcd
```

Useful signals:

```text
state
bit_count

busy
done

spi_cs_n
spi_sclk
spi_mosi
spi_miso

tx_shift_reg
rx_shift_reg
```

---

# Creating a Top Module

Example LED test:

```verilog
module top (
    input  wire clk,
    output reg  led
);

    wire tick;

    clock_enable #(
        .DIVISOR(24_000_000)
    ) clk_en (
        .clk(clk),
        .rst(1'b0),
        .tick(tick)
    );

    always @(posedge clk) begin

        if (tick)
            led <= ~led;

    end

endmodule
```

---

# Clock Divider Notes

Your divider generates a pulse:

```text
tick_frequency = 48 MHz / DIVISOR
```

Examples:

| DIVISOR | Tick Frequency |
|----------|---------------|
| 48,000,000 | 1 Hz |
| 24,000,000 | 2 Hz |
| 4,800,000 | 10 Hz |
| 480 | 100 kHz |
| 48 | 1 MHz |
| 24 | 2 MHz |

---

# Pin Mapping

The iCE40 open-source flow uses:

```text
pins.pcf
```

Example:

```pcf
set_io clk  <CLOCK_PIN>
set_io led  <LED_PIN>
```

Later:

```pcf
set_io spi_sclk  <PIN>
set_io spi_mosi  <PIN>
set_io spi_cs_n  <PIN>
```

You must replace the placeholders with actual board pin numbers.

---

# Synthesis

Generate a JSON netlist:

```bash
yosys \
    -p "synth_ice40 -top top -json top.json" \
    top.v lcd.v
```

Produces:

```text
top.json
```

---

# Place and Route

For the iCE40UP5K-SG48:

```bash
nextpnr-ice40 \
    --up5k \
    --package sg48 \
    --json top.json \
    --pcf pins.pcf \
    --asc top.asc
```

Produces:

```text
top.asc
```

---

# Generate Bitstream

```bash
icepack top.asc top.bin
```

Produces:

```text
top.bin
```

---

# Program FPGA

Option 1:

```bash
icesprog top.bin
```

Option 2:

```text
Drag top.bin
onto the iCELink USB drive.
```

---

# First Hardware Test

Do NOT connect the LCD yet.

Verify:

```text
✓ FPGA programs successfully
✓ Clock divider works
✓ LED flashes
```

Expected result:

```text
LED OFF
↓ 0.5s
LED ON
↓ 0.5s
LED OFF
↓ 0.5s
LED ON
```

---

# Second Hardware Test

Connect a logic analyser to PMOD pins.

Output:

```text
spi_sclk
spi_mosi
spi_cs_n
```

Configure SPI master to repeatedly transmit:

```text
0xA5
```

Expected MOSI pattern:

```text
10100101
```

Expected signals:

```text
CS_N  : High → Low → High

SCLK  : 8 clock cycles

MOSI  : 10100101

DONE  : Single pulse
```

---

# Development Milestones

## Milestone 1

Blink LED.

```text
✓ FPGA configured
✓ Clock works
```

---

## Milestone 2

Generate SPI waveforms.

```text
✓ SPI clock works
✓ MOSI works
✓ CS_N works
```

---

## Milestone 3

Verify with logic analyser.

```text
✓ Physical pins correct
✓ SPI timing correct
```

---

## Milestone 4

Connect LCD.

```text
✓ RESET
✓ DC
✓ SPI commands
```

---

## Milestone 5

Fill display with one solid colour.

```text
✓ LCD initialised
✓ SPI master verified
✓ Pixel pipeline working
```

At this point the SPI infrastructure is considered complete.


# Clock Enable Module

The design uses a clock enable pulse rather than creating a second clock domain.

Advantages:

- Single clock domain
- Easier timing analysis
- Simpler FPGA design
- Reusable across peripherals

## Formula

Tick Frequency:

```text
Tick Frequency = 48 MHz / DIVISOR
```

## Examples

| DIVISOR | Tick Frequency |
|----------|---------------|
| 48,000,000 | 1 Hz |
| 24,000,000 | 2 Hz |
| 4,800,000 | 10 Hz |
| 480 | 100 kHz |
| 48 | 1 MHz |
| 24 | 2 MHz |
| 12 | 4 MHz |
| 6 | 8 MHz |

## Implementation

```verilog
module clock_enable #(
    parameter integer DIVISOR = 24
)(
    input  wire clk,
    input  wire rst,

    output reg tick
);

    reg [25:0] counter;

    always @(posedge clk) begin

        if (rst) begin
            counter <= 26'd0;
            tick    <= 1'b0;
        end
        else begin

            tick <= 1'b0;

            if (counter == (DIVISOR - 1)) begin
                counter <= 26'd0;
                tick    <= 1'b1;
            end
            else begin
                counter <= counter + 1'b1;
            end

        end
    end

endmodule
```

## Example LED Test

Generate a 1 Hz tick:

```verilog
clock_enable #(
    .DIVISOR(48_000_000)
) clk_en (
    .clk(clk),
    .rst(rst),
    .tick(tick)
);
```

Toggle LED on each tick:

```verilog
always @(posedge clk) begin

    if (rst)
        led <= 1'b0;
    else if (tick)
        led <= ~led;

end
```

Result:

```text
0s  LED OFF
1s  LED ON
2s  LED OFF
3s  LED ON
```