function computeMinPortSampleTime(this)



    if this.minPortSampleTime<0
        InportSrc=this.InportSrc;
        OutportSnk=this.OutportSnk;
        minPortSampleTime=this.minPortSampleTime;

        if~isempty(OutportSnk)
            minPortSampleTime=OutportSnk(1).HDLSampleTime;
        elseif~isempty(InportSrc)
            minPortSampleTime=InportSrc(1).HDLSampleTime;
        else
            minPortSampleTime=this.minPortSampleTime;
        end

        for i=1:length(OutportSnk)
            if OutportSnk(i).HDLSampleTime<minPortSampleTime
                minPortSampleTime=OutportSnk(i).HDLSampleTime;
            end
        end

        for i=1:length(InportSrc)
            if InportSrc(i).HDLSampleTime<minPortSampleTime
                minPortSampleTime=InportSrc(i).HDLSampleTime;
            end
        end
        this.minPortSampleTime=minPortSampleTime;
    end
end

