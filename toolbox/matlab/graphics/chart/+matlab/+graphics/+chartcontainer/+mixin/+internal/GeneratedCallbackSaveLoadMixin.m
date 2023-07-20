classdef(Hidden)GeneratedCallbackSaveLoadMixin<handle







    properties(Access=protected,Hidden,NonCopyable)
        SerializableCallbackPropertyFcns(1,1)struct;
    end

    methods
        function set.SerializableCallbackPropertyFcns(obj,s)
            props=fieldnames(s);
            for k=1:length(props)
                propName=props{k};

                try
                    obj.(propName)=s.(propName);
                catch
                end
            end
        end

        function s=get.SerializableCallbackPropertyFcns(obj)

            mc=metaclass(obj);
            metaEvents=findobj(mc.EventList,'HasCallbackProperty',true);
            s=struct;
            for k=1:length(metaEvents)
                propName=metaEvents(k).Name+"Fcn";
                if~isempty(obj.(propName))
                    s.(propName)=obj.(propName);
                end
            end
        end
    end
end
