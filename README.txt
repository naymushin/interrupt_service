COM-port – it’s a chip that allows you to transfer data to a remote computer via
a communication channel. It has two programmable registers: the transmission
register THR (accessible via port 3F8h for writing) and the receiver register RBR
(accessible via the read port 3F8h). To send data to the communication channel,
it is sufficient to write them into the register of the THR transmitter. When
data arrives from the communication channel, the COM port causes the interrupt
0Ch, in the interruption handler the processor can read the received data from
the register of the RBR receiver. The COM port has a special diagnostic mode in
which the data sent to the communication channel from the register of the THR
transmitter is instantly returned from the channel to the RBR receiver register,
also causing an interrupt. It is necessary to develop a program that calls the
subroutine for configuring the COM port for diagnostic mode operation, reset the
interrupt vector 0Ch to the user's interrupt handler, send a string of
"Hello, world!" Characters to the COM port, then returns the interrupt vector
0Ch to its original state. Each time the user handler is called, it is necessary
to read the received symbol from the receiver register and display it on the screen.