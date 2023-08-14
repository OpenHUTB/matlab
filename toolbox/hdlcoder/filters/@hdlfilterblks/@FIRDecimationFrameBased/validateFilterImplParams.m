function v=validateFilterImplParams(this,hC)





    v=hdlvalidatestruct;
    block=get_param(hC.SimulinkHandle,'Object');


    if strcmpi(get_param(hC.SimulinkHandle,'InputProcessing'),'Elements as channels (sample based)')
        v(end+1)=hdlvalidatestruct(1,...
        message('hdlcoder:filters:validateFrameBased:frameArchNotFrameBasedInput',block.HDLData.archSelection));
        return;
    end


    if strcmpi(get_param(hC.SimulinkHandle,'FilterSource'),'Input port')
        v(end+1)=hdlvalidatestruct(1,...
        message('hdlcoder:filters:validateFrameBased:coefInputNotSupported'));
        return;
    end


    if~strcmpi(get_param(hC.SimulinkHandle,'framing'),'Enforce single-rate processing')
        v(end+1)=hdlvalidatestruct(1,...
        message('hdlcoder:filters:validateFrameBased:singleRateProcessingFrameBased'));
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

    v=[v,validateCoefficients(this,hC)];
    v=[v,validateFullPrecision(this,hC)];

end


