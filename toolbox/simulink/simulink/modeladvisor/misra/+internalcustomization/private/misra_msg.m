function msg=misra_msg(title)




    str=DAStudio.message(['MISRA-C:',title]);
    msg=['<font size=-1>MISRA-C:2004 Check: ',str,' </font>'];

