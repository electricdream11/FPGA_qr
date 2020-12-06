#include "axi_ram.h"

static int IMAG_HEIGHT;
static int IMAG_WIDTH;

int ramInit(int height,int width){
    Xil_Out32(BASE+SLV_REG0,0x00);
    Xil_Out32(BASE+SLV_REG0,0x10);
    IMAG_HEIGHT=height;
    IMAG_WIDTH=width;

    printf("RAM is wait\n\r");
    return 0;
}
int ramClose(){
	Xil_Out32(BASE+SLV_REG0,0x00);
	printf("RAM is close\n\r");
	return 0;
}
int ramWriteData(int width,int height){
	int reg3;
	int i,j;
//	printf("x3");
	for(i=0;i<width;i++){
		for(j=0;j<3;j++){
				//get slave ok
				Xil_Out32(BASE+SLV_REG0,0x12);
				//send data
				Xil_Out32(BASE+SLV_REG1,buf_width[i][j]);
				//send ok
				Xil_Out32(BASE+SLV_REG0,0x13);
				//wait slave ok
				reg3=Xil_In32(BASE+SLV_REG3);
//				printf("x1");
				while(reg3!=0x1){
					reg3=Xil_In32(BASE+SLV_REG3);
				}
//				printf("x2");
				//go next
				if((i==width-1)&&(j==2)){
					if(height==IMAG_HEIGHT-1){
					    Xil_Out32(BASE+SLV_REG0,0x11);
					    Xil_Out32(BASE+SLV_REG0,0x10);
					}
					else {
						Xil_Out32(BASE+SLV_REG0,0x12);
					}
				}
				else {
					Xil_Out32(BASE+SLV_REG0,0x12);
				}
		}
	}
//	printf("x4");
	return 0;
}
int ramReadWait(){
	int reg3;
    reg3=Xil_In32(BASE+SLV_REG3);

    while(reg3==0){
    	reg3=Xil_In32(BASE+SLV_REG3);
    	printf("wait pl solve\n\r");
    }
    return 0;
}
int ramReadData(){
	int reg3;
	int i,j;
	i=0;
	j=0;
    reg3=Xil_In32(BASE+SLV_REG3);
    while(reg3!=0){
    	reg3=Xil_In32(BASE+SLV_REG3);
    	while(reg3!=3){
    		reg3=Xil_In32(BASE+SLV_REG3);
    	}
    	//master valid
    	Xil_Out32(BASE+SLV_REG0,0x11);
    	buf_width[i][j]=Xil_In32(BASE+SLV_REG2);
    	j++;
    	if(j==3){
    		i++;
    		j=0;
    	}
    	if(i==IMAG_WIDTH){
    		i=0;
    		Xil_Out32(BASE+SLV_REG0,0x10);
    		return 0;
    	}
    	Xil_Out32(BASE+SLV_REG0,0x10);
    	reg3=Xil_In32(BASE+SLV_REG3);
//    	printf("3:%d\n\r",reg3);
    	if(reg3==0){
    		return 1;
    	}
    }
    return 0;
}

