function msg=iec61508_msg(title)



    str=DAStudio.message(['ModelAdvisor:iec61508:',title]);
    msg=['<font size=-1>IEC61508 Specification Check: ',str,' </font>'];

