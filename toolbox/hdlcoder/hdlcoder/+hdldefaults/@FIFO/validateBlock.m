function v=validateBlock(~,hC)



    v=hdlvalidatestruct;





    if hdlgetparameter('MinimizeGlobalResets')&&hdlgetparameter('MinimizeClockEnables')
        blockName=get_param(hC.SimulinkHandle,'Name');
        v(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:UnsupportedMinimizeEnablesResets',blockName));
    end