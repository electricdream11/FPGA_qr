#include <stdio.h>
#include "platform.h"
#include "xil_printf.h"
#include <stdlib.h>
#include "xil_io.h"
#include "addr_params.h"



extern char buf_width[2000][3];



int imagSelectInit();
int imagSelectInfo();
int imagSelectRead();
int imagSelectWait();
int imagSelectClose();
