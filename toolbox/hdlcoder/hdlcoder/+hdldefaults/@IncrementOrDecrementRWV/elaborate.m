function newComp=elaborate(this,hN,hC)




    a=get_param(hC.SimulinkHandle,'ReferenceBlock');

    incBlk=['simulink/Additional Math',char(10),'& Discrete/Additional Math:',char(10),...
    'Increment - Decrement/Increment',char(10),'Real World'];

    decBlk=['simulink/Additional Math',char(10),'& Discrete/Additional Math:',char(10),...
    'Increment - Decrement/Decrement',char(10),'Real World'];

    if(strcmpi(a,incBlk))
        mode=1;
    elseif(strcmpi(a,decBlk))
        mode=2;
    end


    newComp=pirelab.getIncDecRWV(hN,hC.SLInputSignals,hC.SLOutputSignals,mode,hC.Name);

end



