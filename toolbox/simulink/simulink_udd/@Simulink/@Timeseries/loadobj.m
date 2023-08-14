function h=loadobj(s)







    if isstruct(s)
        h=Simulink.Timeseries;



        if isfield(s.Data_(2).LoadedData,'Metadata')
            thisMetaData=s.Data_(2).LoadedData.Metadata;
        elseif isfield(s.Data_(2).LoadedData,'MetaData')
            thisMetaData=s.Data_(2).LoadedData.MetaData;
        end
        if isa(thisMetaData,'Simulink.FrameInfo')
            h.initialize(s.Name,s.BlockPath,s.PortIndex,s.SignalName,s.ParentName,...
            data,time,timemetadata.FrameStart,timemetadata.FrameIncrement,...
            timemetadata.FrameEnd,timemetadata.Framesize,...
            [s.RegionInfo.StartIndex,s.RegionInfo.NumElements]);

        else
            if isfield(s.Data_(1).LoadedData,'Data')
                data=[];
                try
                    data=s.Data_(1).LoadedData.Data;
                end
                if isempty(data)&&isfield(s.Data_(1).LoadedData,'Dataconstructor')&&...
                    ~isempty(s.Data_(1).LoadedData.Dataconstructor)
                    data=s.Data_(1).LoadedData.Dataconstructor;
                end

            else
                data=[];
            end
            if isfield(s.Data_(2).LoadedData,'Data')
                time=s.Data_(2).LoadedData.Data;
            else
                time=[];
            end
        end
        if isfield(s,'RegionInfo')
            h.initialize(localGetField(s,'Name',''),localGetField(s,'BlockPath',''),...
            localGetField(s,'PortIndex',[]),localGetField(s,'SignalName',''),...
            localGetField(s,'ParentName',''),...
            data,time,...
            thisMetaData.Start,...
            thisMetaData.Increment,...
            thisMetaData.End,[],...
            [s.RegionInfo.StartIndex,s.RegionInfo.NumElements],...
            localGetField(s,'ValueDimensions',[]));
        else
            h.initialize(localGetField(s,'Name',''),localGetField(s,'BlockPath',''),...
            localGetField(s,'PortIndex',[]),localGetField(s,'SignalName',''),...
            localGetField(s,'ParentName',''),...
            data,time,...
            thisMetaData.Start,...
            thisMetaData.Increment,...
            thisMetaData.End,[],...
            [0,0],...
            localGetField(s,'ValueDimensions',[]));
        end


        try
            h.TsValue.TimeInfo.Units=thisMetaData.Units;
        catch
            h.TsValue.TimeInfo.Units='seconds';
        end
        try
            h.TsValue.DataInfo.Units=thisMetaData.Units;
        catch
            h.TsValue.DataInfo.Units='';
        end
    elseif isa(s,'Simulink.Timeseries')
        h=s;
    else
        h=[];
    end

    function out=localGetField(in,fieldName,default)

        if isfield(in,fieldName)
            out=in.(fieldName);
        else
            out=default;
        end

