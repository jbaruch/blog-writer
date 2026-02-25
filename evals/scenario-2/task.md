# Build a Writer's Voice Profile from Writing Samples

## Problem/Feature Description

Tara Okonkwo is a firmware engineer who writes a personal blog about embedded systems, hardware debugging, and the intersection of software with physical devices. She wants to set up a writing persona profile that captures her voice so that future writing assistance stays consistent with her natural style.

She's providing three of her published blog post excerpts below. Analyze these samples to identify her voice patterns, rhetorical devices, humor style, cultural references, technical depth habits, and any recurring characters or elements. Then generate a set of persona files that capture her voice.

Her basic info:
- **Name:** Tara Okonkwo
- **Role:** Senior Firmware Engineer at Lattice Systems
- **Career context:** Previously spent seven years writing embedded systems code for medical devices, where "move fast and break things" gets you investigated by the FDA
- She wants a rotating bio kicker (a dry observation that changes per post)
- She does NOT write about a specific product, so skip product context

## Output Specification

Produce the following files in a `persona/` directory:
- `persona/voice.md` -- voice profile with analysis of her writing patterns
- `persona/bio.md` -- author bio template with schema, examples, and kicker notes
- `persona/examples.md` -- catalog of the writing samples with notes on what each demonstrates about her voice

## Input Files

The following files are provided as inputs. Extract them before beginning.

=============== FILE: inputs/sample-1.txt ===============
TITLE: The LED That Blinked Wrong
SOURCE: https://tara.dev/led-blinked-wrong

I spent three days debugging an LED. Three days. For context, I have written firmware for devices that keep human beings alive. I have debugged timing issues on real-time operating systems where a missed interrupt means a ventilator doesn't cycle. I once tracked a memory corruption bug through six weeks of intermittent failures on a Class III medical device.

The LED blinked at 2Hz instead of 1Hz. And it took me three days.

The problem, if you want to call it that, was a prescaler misconfiguration on the timer peripheral. The reference manual said the default prescaler value was 0, meaning no division. The actual silicon shipped with a default of 1, meaning divide-by-two. Someone at the chip vendor had updated the silicon but not the documentation. (This happens more often than chip vendors would like you to believe.)

Dex -- our test engineer, who has the patience of someone who chose to make hardware work for a living -- asked me on day two: "Have you checked the errata sheet?" I had not checked the errata sheet. The errata sheet is the chip vendor's way of saying "we know about these problems but fixing silicon is expensive, so here's a PDF instead." The prescaler issue was item 47 on a 52-item errata. Of course it was.

I could have found this in ten minutes if I'd started with the errata instead of trusting the reference manual. But I trusted the documentation, because I have learned nothing from fifteen years of working with documentation written by people who don't use their own products.

The LED now blinks at 1Hz. You're welcome.
=============== END SAMPLE 1 ===============

=============== FILE: inputs/sample-2.txt ===============
TITLE: Why I Test Firmware on the Actual Hardware
SOURCE: https://tara.dev/test-on-hardware

Every few months someone pitches me on a new hardware simulation framework. "You can test your firmware without touching a board!" they say, like this is a selling point and not a confession that their simulator doesn't model the real hardware accurately.

I'm not against simulation. Simulation is great for algorithms, protocol logic, state machines. Simulation is terrible for the parts that actually break in production: timing, power sequencing, analog-to-digital converter noise, and that one GPIO pin that the PCB designer routed too close to the switching regulator because the board was already four layers deep and something had to give.

Last quarter we had a bug that only manifested when the ambient temperature exceeded 45 degrees Celsius. The I2C bus started throwing NAK errors because the pull-up resistor values drifted out of spec at temperature. No simulator in the world models pull-up resistor thermal drift. (If yours does, I would like to subscribe to your newsletter.)

Dex set up a thermal chamber test for us. He does this with the quiet competence of someone who has done it fifty times and still checks the thermocouple placement twice. The bug reproduced at exactly 47.2 degrees. We changed the pull-up resistors from 4.7k to 2.2k, re-ran the test, and the bus was stable to 85 degrees.

I have a rule: if the firmware touches a peripheral, it gets tested on the actual peripheral. Not a mock. Not a stub. The actual silicon, on the actual board, with the actual power supply and the actual ambient conditions. This takes longer. This costs more. This is correct.

The simulator never would have caught the pull-up issue. It would have reported all tests passing, and we would have shipped boards that failed in the field when customers put them in server racks where the ambient temperature regularly hits 50 degrees. The cost of a field recall would have dwarfed a hundred thermal chamber test sessions.

Software engineers sometimes ask me why hardware testing is "so slow." I tell them it's fast, actually. What's slow is shipping firmware that hasn't been tested on hardware and then spending three months debugging field failures from a stack trace that says "I2C timeout" with no indication that the root cause is the thermal coefficient of a resistor.
=============== END SAMPLE 2 ===============

=============== FILE: inputs/sample-3.txt ===============
TITLE: Interrupt Priorities and the Art of Saying "Not Now"
SOURCE: https://tara.dev/interrupt-priorities

The first firmware system I shipped had one interrupt priority level. Everything was urgent. Motor control, sensor sampling, serial communication, LED blinking -- all at the same priority, all fighting for the same CPU cycles. It worked about as well as you'd expect a system where blinking an LED can preempt a motor controller to work: badly, and at the worst possible moment.

(In my defense, I was twenty-three and the reference design did the same thing. In the reference design's defense, it was written by an applications engineer who had never shipped a real product.)

Interrupt priority assignment is, fundamentally, an exercise in deciding which things are allowed to interrupt which other things. A motor control loop running at 10kHz cannot be interrupted by a serial port that updates once a second. A sensor sampling routine at 1kHz should not be interrupted by an LED update at 2Hz. These seem obvious when I write them down. They were not obvious to twenty-three-year-old me.

I now start every firmware project by listing every interrupt source, its required response time, and its maximum tolerable jitter. I put them in a spreadsheet. Dex calls it "the hierarchy of needs" -- which is accurate, if you consider a motor controller's need to not burn out a winding to be at the top of Maslow's pyramid.

The practical rules I've settled on after fifteen years:

You get at most three priority levels for real-time control. If you need more, your architecture is wrong and no amount of priority tuning will save you. (I learned this at the medical device company, where we had eleven priority levels and a bug tracker full of priority inversion issues.)

Never put communication peripherals at the same level as control loops. UART, SPI, and I2C can all tolerate milliseconds of latency. Your motor controller cannot. Put communications in a DMA buffer and process it in the main loop.

Test your interrupt timing under worst-case load, not best-case. Connect a scope to a spare GPIO, toggle it in your ISR, and measure the actual response time with every peripheral active and the CPU at full load. The number you measure will be worse than the number you calculated. It always is.

Dex's thermal chamber is useful here too. Processor clock speeds vary with temperature. Your 10kHz loop might run at 9.7kHz when the processor is hot. If your control algorithm assumes exactly 10kHz, a 3% drift at temperature can cause real problems.

Twenty-three-year-old me would have just set everything to the same priority and moved on. Fifteen-years-later me spends a full day on the interrupt map before writing a single line of ISR code. The time spent on the map has never been wasted. The time spent debugging priority inversions always has been.
=============== END SAMPLE 3 ===============
