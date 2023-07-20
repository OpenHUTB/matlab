function singleRate=isTBSingleRate(this,mode)




    singleRate=1;
    if strcmpi(mode,'input')
        dataSrc=this.InportSrc;
    elseif strcmpi(mode,'output')
        dataSrc=this.OutportSnk;
    else
        dataSrc=[this.InportSrc,this.OutportSnk];
    end
    if~isempty(dataSrc)
        BaseSampleTime=dataSrc(1).HDLSampleTime;
        for i=2:length(dataSrc)
            if dataSrc(i).HDLSampleTime~=BaseSampleTime
                singleRate=0;
                break;
            end
        end
    end

