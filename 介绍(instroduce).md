本项目使用verilog语言在quartus平台上实现了FM的解调功能。(This project uses the verilog language to implement FM demodulation function on the quartus platform.)



# Chinese：

结构框图

![框图](E:\项目\FPGA解调FM\框图.png)

此次FM的信号是载波1M，调制信号频率10K，频偏10K

原理网上书上都有在此不再介绍，说一下大致流程：通过NCO产生1M的IQ信号，然后与FM信号相乘得到两路信号，然后分别进行低通滤波。之后分别延迟一个周期，在使用下面公式即可得到解调信号

![image-20221027203253665](C:\Users\jjk\AppData\Roaming\Typora\typora-user-images\image-20221027203253665.png)

一些说明：FIR滤波器的采样频率是10M，截至频率是20K，40阶。本人使用的FPGA开发板是黑金的4010，因为资源不够的问题，导致了FIR滤波不完全，载波存在的现象。所以我在最后得到解调波形后又进行了一次fir滤波。如果自己手中板子资源足够，完全可以把fir阶数提高，可以不用在进行第二次的FIR滤波。FIR的采样频率10M比较高，可以考虑使用clc抽取降低采样频率得到更好的频率效果。

仿真效果

![仿真波形](E:\项目\FPGA解调FM\仿真波形.png)

第一个是FM波形 。

第二个是最后公式出来的波形，可以看到有很多载波没有滤除。

第三个是最后在经过FIR滤波后得到的波形。

实际效果：

![实际效果](E:\项目\FPGA解调FM\实际效果.JPG)

最后如果有什么意见，以及问题可以通过邮箱1977823861@qq.com联系我。谢谢





# English：

Structural block diagram

![框图](E:\项目\FPGA解调FM\框图.png)

The signal of this FM is a carrier of 1M, a modulated signal frequency of 10K, and a frequency offset of 10K.

The principle is not introduced here in the online book, to talk about the general process: generate an IQ signal of 1M through the NCO, and then multiply it with the FM signal to obtain two signals, and then perform low-pass filtering respectively. After that, each period is delayed, and the demodulation signal can be obtained using the following formula.

![image-20221027205021165](C:\Users\jjk\AppData\Roaming\Typora\typora-user-images\image-20221027205021165.png)

Some notes: The sampling frequency of the FIR filter is 10M, and the ending frequency is 20K, 40th order. The FPGA development board I used is a black gold 4010, because of the problem of insufficient resources, resulting in incomplete FIR filtering and carrier phenomenon. So I did another FIR filter after I finally got the demodulated waveform. If you have enough board resources in your hands, you can completely increase the fir order and do not need to perform a second FIR filtering. The sampling frequency of FIR is relatively high at 10M, and you can consider using clc decimation to reduce the sampling frequency to obtain a better frequency effect.

Simulation effect：

![仿真波形](E:\项目\FPGA解调FM\仿真波形.png)

The first is the FM waveform .

The second is the waveform from the final formula, and you can see that there are many carriers that have not been filtered.

The third is the final waveform obtained after FIR filtering.

Practical results：

![实际效果](E:\项目\FPGA解调FM\实际效果.JPG)

Finally, if you have any comments and questions, you can contact me by email 1977823861@qq.com. Thank you.