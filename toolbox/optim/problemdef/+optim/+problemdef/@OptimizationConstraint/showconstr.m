function showconstr(con)














    printHeaders=true;
    conStr=optim.internal.problemdef.display.showDisplay(...
    con,printHeaders,con.objectType());


    disp(conStr);
