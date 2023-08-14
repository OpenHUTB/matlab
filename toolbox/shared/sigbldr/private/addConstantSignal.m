function addConstantSignal(dialog,add_new)







    UD=get(dialog,'UserData');


    xNorm=[0,1];
    yNorm=[0,0];

    UD=add_nonrepeat_normalized_signal(UD,xNorm,yNorm,0,add_new);

    set(dialog,'UserData',UD);
