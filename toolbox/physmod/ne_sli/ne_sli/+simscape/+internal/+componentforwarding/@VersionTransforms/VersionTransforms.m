classdef(Sealed)VersionTransforms<handle









    properties(Access=private)
TransformMap
    end

    methods(Access=private)
        function obj=VersionTransforms
            data=load_transforms();

            obj.TransformMap=containers.Map;

            if~isempty(data)
                for idx=1:numel(data)
                    if obj.TransformMap.isKey(data(idx).Class)
                        obj.TransformMap(data(idx).Class)=...
                        [obj.TransformMap(data(idx).Class),data(idx)];
                    else
                        obj.TransformMap(data(idx).Class)=data(idx);
                    end
                end
            end
        end
    end

    methods(Static,Access=private)
        function obj=getInstance
            persistent localObj
            if isempty(localObj)||~isvalid(localObj)
                localObj=simscape.internal.componentforwarding.VersionTransforms;
            end
            obj=localObj;
        end
    end

    methods(Static)
        function transforms=get(componentClass)
            obj=simscape.internal.componentforwarding.VersionTransforms.getInstance();
            if obj.TransformMap.isKey(componentClass)
                transforms=obj.TransformMap(componentClass);
            else
                transforms=[];
            end
        end
    end

end