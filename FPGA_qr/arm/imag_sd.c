#include "imag_sd.h"

#include "xdevcfg.h"
#include "xparameters.h"
#include "ff.h"

static FATFS fatfs;

int SD_Init()
{
	FRESULT rc;
	rc = f_mount(&fatfs,"",0);
	if(rc)
	{
		return XST_FAILURE;
	}
	return XST_SUCCESS;
}

void showBmpHead(BITMAPFILEHEADER pBmpHead)
{  //定义显示信息的函数，传入文件头结构体
	printf("bfSize:%dkb\n\r",fileHeader.bfSize/1024);
	printf("bfReserved1:%d\n\r",  fileHeader.bfReserved1);
	printf("bfReserved2:%d\n\r",  fileHeader.bfReserved2);
	printf("bfOffBits:%d\n\r",  fileHeader.bfOffBits);
}

void showBmpInfoHead(BITMAPINFOHEADER pBmpinfoHead)
{//定义显示信息的函数，传入的是信息头结构体

	   printf("biSize:%d\n\r" ,infoHeader.biSize);
	   printf("biWidth:%ld\n\r" ,infoHeader.biWidth);
	   printf("biHeight:%ld\n\r" ,infoHeader.biHeight);
	   printf("biPlanes:%d\n\r" ,infoHeader.biPlanes);
	   printf("biBitCount:%d\n\r" ,infoHeader.biBitCount);
	   printf("biCompression:%d\n\r" ,infoHeader.biCompression);
	   printf("biSizeImage:%d\n\r" ,infoHeader.biSizeImage);
	   printf("biXPelsPerMeter:%ld\n\r" ,infoHeader.biXPelsPerMeter);
	   printf("biYPelsPerMeter:%ld\n\r" ,infoHeader.biYPelsPerMeter);
	   printf("biClrUsed:%d\n\r" ,infoHeader.biClrUsed);
	   printf("biClrImportant:%d\n\r" ,infoHeader.biClrImportant);
}

int readBmpHead(char*fil_name){
	FIL fil;
	FRESULT rc;
	UINT br;
	rc = f_open(&fil,fil_name, FA_OPEN_EXISTING | FA_READ);
	if(rc){
		printf("error:%x\n\r",rc);
		return 0;
	}
	rc = f_lseek(&fil, 0);
	if(rc){
		printf("error:%x\n\r",rc);
		return 0;
	}
	unsigned short  fileType;
	f_read(&fil,&fileType,sizeof(unsigned short),&br);
	if (fileType == 0x4d42){
		printf("%s is bmp filer!\n\r",fil_name);
		f_read(&fil,&fileHeader,sizeof(BITMAPFILEHEADER),&br);
		showBmpHead(fileHeader);
		f_read(&fil,&infoHeader,sizeof(BITMAPINFOHEADER),&br);
		showBmpInfoHead(infoHeader);
		rc = f_sync(&fil);
	}
	else {
		return 0;
	}
	f_close(&fil);
	int value_back;
	value_back=sizeof(unsigned short)+sizeof(BITMAPFILEHEADER)+sizeof(BITMAPINFOHEADER);
	return value_back;
}
int readBmpData(char*fil_name,int value_seek){
	FIL fil;
	FRESULT rc;
	UINT br;

	rc = f_open(&fil,fil_name, FA_OPEN_EXISTING | FA_READ);
	if(rc){
		printf("error:%x\n\r",rc);
		return 0;
	}
	rc = f_lseek(&fil, value_seek);
	if(rc){
		printf("error:%x\n\r",rc);
		return 0;
	}
	int i,j;
	for(i=0;i<infoHeader.biWidth;i++){
		for(j=0;j<3;j++){
			rc=f_read(&fil,&buf_width[i][j],1,&br);
		}
	}
    rc = f_sync(&fil);
	rc=f_close(&fil);
	if(rc){
		printf("error:%x\n\r",rc);
		return 0;
	}
	else {
//		for(i=0;i<1100;i++){
//		printf("%d0:%x\n\r",i,buf_width[i][0]);
//		}
//		printf("read data is ok\n\r");
		return 1;
	}
}
int writeBmpHead(char*fil_name){
	FIL fil;
	FRESULT rc;
	UINT br;
	unsigned short  fileType;
	fileType = 0x4d42;
	rc = f_open(&fil,fil_name, FA_CREATE_ALWAYS | FA_WRITE);
	if(rc){
		printf("error:%x\n\r",rc);
		return 0;
	}
	rc = f_lseek(&fil, 0);
    f_write(&fil,&fileType,sizeof(unsigned short),&br);
    f_write(&fil,&fileHeader,sizeof(BITMAPFILEHEADER),&br);
    f_write(&fil,&infoHeader,sizeof(BITMAPINFOHEADER),&br);
    rc = f_sync(&fil);
	rc=f_close(&fil);
	if(rc){
		printf("error:%x\n\r",rc);
		return 0;
	}
	else {
		printf("write head is ok\n\r");
		int value_back;
		value_back=sizeof(unsigned short)+sizeof(BITMAPFILEHEADER)+sizeof(BITMAPINFOHEADER);
		return value_back;
	}
}
int writeBmpData(char*fil_name,int value_seek){
	FIL fil;
	FRESULT rc;
	UINT br;

	rc = f_open(&fil,fil_name, FA_CREATE_ALWAYS | FA_WRITE);
	if(rc){
		printf("error:%x\n\r",rc);
		return 0;
	}
	rc = f_lseek(&fil, value_seek);
	if(rc || fil.fptr != value_seek){
		printf("error:%x\n\r",rc);
		return 0;
	}
	int i,j;
	for(i=0;i<infoHeader.biWidth;i++){
		for(j=0;j<3;j++){
			rc=f_write(&fil,&buf_width[i][j],1,&br);
		}
	}
    rc = f_sync(&fil);
	rc=f_close(&fil);
	if(rc){
		printf("error:%x\n\r",rc);
		return 0;
	}
	else {
//		for(i=0;i<1100;i++){
//		printf("%d0:%x\n\r",i,buf_width[i][0]);
//		}
//		printf("write data is ok\n\r");
		return 1;
	}
}

int getBmpInfoHead(int x){
	if(x==1){
		return infoHeader.biHeight;
	}
	else if(x==2){
		return infoHeader.biWidth;
	}
	else {
		return 0;
	}

}


