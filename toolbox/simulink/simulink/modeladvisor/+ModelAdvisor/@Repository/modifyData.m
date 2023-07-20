function modifyData(obj,ObjectIndex,varargin)
    PerfTools.Tracer.logMATLABData('MAGroup','Database ModifyData',true);
    obj.reconnect;
    if length(varargin)>1
        for i=1:length(varargin)
            if islogical(varargin{i})
                varargin{i}=int32(varargin{i});
            end
        end
        try
            PerfTools.Tracer.logMATLABData('MAGroup','sdi.Repository setProperty',true);
            obj.DatabaseHandle.setProperty(ObjectIndex,varargin{:});
            PerfTools.Tracer.logMATLABData('MAGroup','sdi.Repository setProperty',false);
        catch E %#ok<NASGU>







        end
    else
        if isstruct(varargin{1})
            propNames=fields(varargin{1});
            propValuePairs=cell(1,2*length(propNames));
            for i=1:length(propNames)
                propValuePairs{i*2-1}=propNames{i};
                propValuePairs{i*2}=varargin{1}.(propNames{i});
                if islogical(propValuePairs{i*2})
                    propValuePairs{i*2}=int32(propValuePairs{i*2});
                end
            end
            PerfTools.Tracer.logMATLABData('MAGroup','sdi.Repository setProperty',true);
            obj.DatabaseHandle.setProperty(ObjectIndex,propValuePairs{:});
            PerfTools.Tracer.logMATLABData('MAGroup','sdi.Repository setProperty',false);
        end
    end
    obj.disconnect;
    PerfTools.Tracer.logMATLABData('MAGroup','Database ModifyData',false);
end
