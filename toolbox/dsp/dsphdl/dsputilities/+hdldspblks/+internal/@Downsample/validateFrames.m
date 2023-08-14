function v=validateFrames(this,hC)



    v=hdlvalidatestruct;



    ipmode=get_param(hC.SimulinkHandle,'InputProcessing');
    if~isempty(strfind(ipmode,'Inherited'))

        smode=get_param(hC.SimulinkHandle,'smode');
        if isempty(strfind(smode,'multirate'))
            v=hdlvalidatestruct(1,...
            message('dsp:hdl:Downsample:validateFrames:singleratenotsupported'));
        end
    else
        v=this.baseValidateFrames(hC);
    end
