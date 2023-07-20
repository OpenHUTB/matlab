function v=validateFilterImplParams(this,hC)





    v=hdlvalidatestruct;
    slbh=hC.SimulinkHandle;
    block=get_param(slbh,'Object');


    if strcmpi(get_param(slbh,'InputProcessing'),'Elements as channels (sample based)')
        v(end+1)=hdlvalidatestruct(1,...
        message('hdlcoder:filters:validateFrameBased:frameArchNotFrameBasedInput',block.HDLData.archSelection));
        return;
    end


    if hC.PirInputSignals(1).Type.getDimensions>512
        v(end+1)=hdlvalidatestruct(1,...
        message('hdlcoder:filters:validateFrameBased:frameSizeGreaterThan512'));
        return;
    end


    if hC.PirInputSignals(1).Type.getDimensions==1
        v(end+1)=hdlvalidatestruct(2,...
        message('hdlcoder:filters:validateFrameBased:scalarInputFrameBased'));
    end


    if hC.PirInputSignals(1).Type.getLeafType.isFloatType
        v(end+1)=hdlvalidatestruct(1,...
        message('hdlcoder:filters:validateFrameBased:inputNotFixPoint'));
        return;
    end


    v=[v,validateFullPrecision(this,hC)];
    v=[v,validateControlPorts(this,hC)];
    v=[v,validateEnableSubsys(this,hC)];
    v=[v,validateCoefficients(this,hC)];

end
