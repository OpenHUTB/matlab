function toFrame(h)




    if~isa(h.TsValue.TimeInfo,'Simulink.FrameInfo')
        error(message('Simulink:Logging:SlTimeseriesNotframe'));
    end


    if strcmp(h.TsValue.TimeInfo.State,'Frames')
        return
    else
        h.TsValue.TimeInfo=setFrameState(h.TsValue.TimeInfo,'Frames');
    end




    thisData=h.TsValue.Data;
    if isempty(h.TsValue.Data_)
        h.TsValue.Storage_=[];
        h.TsValue.Data=thisData;
    end



    s=size(thisData);
    ntimes=s(1)/h.TsValue.TimeInfo.Framesize;

    h.TsValue.dataInfo.InterpretSingleRowDataAs3D=true;
    h.TsValue.Data=permute(reshape(h.TsValue.Data',[s(2),h.TsValue.TimeInfo.Framesize,ntimes]),...
    [2,1,3]);

