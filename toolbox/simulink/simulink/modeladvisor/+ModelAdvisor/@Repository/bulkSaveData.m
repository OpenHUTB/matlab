function bulkSaveData(obj,tablename,dataCellArray)




    PerfTools.Tracer.logMATLABData('MAGroup','Database SaveData',true);

    obj.reconnect;
    tablename=ModelAdvisor.Repository.convertTablename(tablename);
    Simulink.sdi.Instance.engine.safeTransaction(@bulk_modify,obj.DatabaseHandle,tablename,dataCellArray);
    obj.disconnect;

    PerfTools.Tracer.logMATLABData('MAGroup','Database SaveData',false);
end

function bulk_modify(db_handle,tablename,dataCellArray)
    for i=1:numel(dataCellArray)
        ObjectIndex=db_handle.createObject(tablename);
        loc_modifyData(db_handle,ObjectIndex,dataCellArray{i});
    end
end

function loc_modifyData(db_handle,ObjectIndex,varargin)
    if isstruct(varargin{1})
        propNames=fields(varargin{1});
        propValuePairs=cell(1,2*length(propNames));
        for i=1:length(propNames)
            propValuePairs{i*2-1}=propNames{i};
            propValuePairs{i*2}=varargin{1}.(propNames{i});

            if strcmpi(propValuePairs{i*2-1},'CustomData')
                propValuePairs{i*2}=propValuePairs(i*2);
            end
            if islogical(propValuePairs{i*2})
                propValuePairs{i*2}=int32(propValuePairs{i*2});
            end
        end
        PerfTools.Tracer.logMATLABData('MAGroup','sdi.Repository setProperty',true);
        db_handle.setProperty(ObjectIndex,propValuePairs{:});
        PerfTools.Tracer.logMATLABData('MAGroup','sdi.Repository setProperty',false);
    end
end