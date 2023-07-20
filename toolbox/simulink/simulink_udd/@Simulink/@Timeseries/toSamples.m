function toSamples(h)




    if~isa(h.TsValue.TimeInfo,'Simulink.FrameInfo')
        error(message('Simulink:Logging:SlTimeseriesNotframe'));
    end


    if strcmp(h.TsValue.TimeInfo.State,'Samples')
        return
    else
        h.TsValue.TimeInfo=setFrameState(h.TsValue.TimeInfo,'Samples');
    end






    s=size(h.TsValue.Data);
    ntimes=s(end)*h.TsValue.TimeInfo.Framesize;

    h.TsValue.dataInfo.InterpretSingleRowDataAs3D=false;
    h.TsValue.Data=reshape(permute(h.TsValue.Data,[1,3,2]),[ntimes,s(2)]);
