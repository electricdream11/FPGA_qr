/******************************************************************************
*
* Copyright (C) 2009 - 2014 Xilinx, Inc.  All rights reserved.
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
*
* Use of the Software is limited solely to applications:
* (a) running on a Xilinx device, or
* (b) that interact with a Xilinx device through a bus or interconnect.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
* XILINX  BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
* WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF
* OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
* SOFTWARE.
*
* Except as contained in this notice, the name of the Xilinx shall not be used
* in advertising or otherwise to promote the sale, use or other dealings in
* this Software without prior written authorization from Xilinx.
*
******************************************************************************/

/*
 * helloworld.c: simple test application
 *
 * This application configures UART 16550 to baud rate 9600.
 * PS7 UART (Zynq) is not initialized by this application, since
 * bootrom/bsp configures it to baud rate 115200
 *
 * ------------------------------------------------
 * | UART TYPE   BAUD RATE                        |
 * ------------------------------------------------
 *   uartns550   9600
 *   uartlite    Configurable only in HW design
 *   ps7_uart    115200 (configured by bootrom/bsp)
 */
#include <stdio.h>
#include <stdlib.h>
#include "platform.h"
#include "xil_printf.h"
#include "xdevcfg.h"

#include "imag_work.h"

#include "axi_ram.h"
#include "imag_sd.h"
#include "imag_solve.h"

int value_seek;
int height;
int width;

int loadImag(char *fil_name,char *fil2_name)
{
//    init_platform();
//    char fil_name[]="test.bmp";
//    char fil2_name[]="out.bmp";


    int i;
//    print("Hello World\n\r");
    if(SD_Init()==XST_SUCCESS){
    	printf("sd init ok\n\r");
    	value_seek=readBmpHead(fil_name);
    	if(value_seek!=0){
    		if(writeBmpHead(fil2_name)!=value_seek){
    			printf("write head error\n\r");
    		}
    		else {
    			height=getBmpInfoHead(1);
    			width=getBmpInfoHead(2);
    			//write
    			ramInit(height,width);
    			for(i=0;i<height;i++){
    				readBmpData(fil_name,value_seek+i*width*3);
    				//printf("im%d\n\r",i);
    				ramWriteData(width,i);
    				//printf("im%d\n\r",i);
    			}
    			ramReadWait();
    			printf("write is ok\n\r");
    			//read
    			for(i=0;i<height;i++){

    				ramReadData();

        			writeBmpData(fil2_name,value_seek+i*width*3);

    			}
    			ramClose();
    		}
    	}
    }
    printf("wait and close\n\r");
//    cleanup_platform();
    return 0;
}
int solveImag(char *fil_name){
	int i;
	imagSelectInit();
//	printf("x1\n\r");
	imagSelectInfo(width,height);
//	printf("x2\n\r");
	imagSelectWait();
//	printf("x3\n\r");
	if(value_seek!=0){
		if(writeBmpHead(fil_name)!=value_seek){
			printf("write head error\n\r");
		}
		for(i=0;i<height;i++){
			imagSelectRead(width);
			writeBmpData(fil_name,value_seek+i*width*3);
		}
	}
	imagSelectClose();
	printf("solve is ok\n\r");
	return 0;
}
