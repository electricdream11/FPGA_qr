#include "qr_result.h"
#include <stdio.h>
#include "platform.h"
#include "xil_printf.h"
#include <stdlib.h>
#include "xil_io.h"


int qr_get(){
	int k;
	int reg3;
	Xil_Out32(BASE2+SLV_REG0,0x10);
	Xil_Out32(BASE2+SLV_REG0,0x12);
	reg3=Xil_In32(BASE2+SLV_REG3);
	while(reg3==0x0){
		reg3=Xil_In32(BASE2+SLV_REG3);
	}
	k=0;
	reg3=Xil_In32(BASE2+SLV_REG3);
	printf("data:\n\r");
	while(reg3!=0x0){
		reg3=Xil_In32(BASE2+SLV_REG3);

		while(reg3==0x2){
			reg3=Xil_In32(BASE2+SLV_REG3);
		}

		buf_qr[k]=Xil_In32(BASE2+SLV_REG2);
		if(k%10==0 && k!=0){
			printf("\n\r");
		}
		printf("%d",buf_qr[k]);
		Xil_Out32(BASE2+SLV_REG0,0x13);
		reg3=Xil_In32(BASE2+SLV_REG3);
		while(reg3==0x3){
			reg3=Xil_In32(BASE2+SLV_REG3);
		}
		Xil_Out32(BASE2+SLV_REG0,0x12);
		k++;
	}
	Xil_Out32(BASE2+SLV_REG0,0x10);
	Xil_Out32(BASE2+SLV_REG0,0x00);
	printf("\n\rqr is ok\n\r");
	return 0;
}


