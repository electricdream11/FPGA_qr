#include "imag_solve.h"

int imagSelectInit()
{
	Xil_Out32(BASE1+SLV_REG0,0x00);
	Xil_Out32(BASE1+SLV_REG0,0x10);

	printf("imag solve is wait\n\r");
	return 0;
}
int imagSelectClose()
{
	Xil_Out32(BASE1+SLV_REG0,0x00);
	printf("select is close\n\r");
	return 0;
}
int imagSelectInfo(int width,int height)
{
	int reg3;
	int k;
	int buf[10];
	buf[0]=width;
	buf[1]=height;

	for(k=0;k<2;k++){
		Xil_Out32(BASE1+SLV_REG0,0x12);
		Xil_Out32(BASE1+SLV_REG1,buf[k]);
		Xil_Out32(BASE1+SLV_REG0,0x13);
		reg3=Xil_In32(BASE1+SLV_REG3);
//		printf("1%d\n\r",reg3);
		while(reg3!=0x1){
			reg3=Xil_In32(BASE1+SLV_REG3);
		}
		Xil_Out32(BASE1+SLV_REG0,0x12);
		reg3=Xil_In32(BASE1+SLV_REG3);
//		printf("2%d\n\r",reg3);
		while(reg3!=0x0){
			reg3=Xil_In32(BASE1+SLV_REG3);
		}
	}
	//end
	Xil_Out32(BASE1+SLV_REG1,0);
	Xil_Out32(BASE1+SLV_REG0,0x13);
	reg3=Xil_In32(BASE1+SLV_REG3);
	while(reg3!=0x1){
		reg3=Xil_In32(BASE1+SLV_REG3);
	}
	Xil_Out32(BASE1+SLV_REG0,0x11);
	Xil_Out32(BASE1+SLV_REG0,0x10);
	reg3=Xil_In32(BASE1+SLV_REG3);
	while(reg3!=0x0){
		reg3=Xil_In32(BASE1+SLV_REG3);
	}
	return 0;
}
int imagSelectWait(){
	int reg3;
    reg3=Xil_In32(BASE1+SLV_REG3);
    printf("wait solve,big image is long\n\r");
    while(reg3==0x0){
    	reg3=Xil_In32(BASE1+SLV_REG3);
//    	printf("wait pl solve\n\r");
    }
    return 0;
}

int imagSelectRead(int width)
{
	int reg3;
	int i,j;
	i=0;
	j=0;
    reg3=Xil_In32(BASE1+SLV_REG3);
    while(reg3!=0){
    	reg3=Xil_In32(BASE1+SLV_REG3);
    	while(reg3!=3){
    		reg3=Xil_In32(BASE1+SLV_REG3);
    	}
    	//master valid
    	Xil_Out32(BASE1+SLV_REG0,0x11);
    	buf_width[i][j]=Xil_In32(BASE1+SLV_REG2);
    	j++;
    	if(j==3){
    		i++;
    		j=0;
    	}
    	if(i== width ){
    		i=0;
    		Xil_Out32(BASE1+SLV_REG0,0x10);
    		return 0;
    	}
    	Xil_Out32(BASE1+SLV_REG0,0x10);
    	reg3=Xil_In32(BASE1+SLV_REG3);
    	if(reg3==0){
    		return 1;
    	}
    }
    return 0;
}
