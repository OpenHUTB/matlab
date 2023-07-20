classdef MasterInformation<handle




    properties(Hidden)
ReleaseMap
ModelName
    end

    methods

        function result=getModelName(obj)
            result=obj.ModelName;
        end



        function result=supportsReleaseAndPlatform(obj,release,platform)
            result=(obj.supportsRelease(release)&&...
            obj.supportsPlatform(release,platform));
        end



        function result=supportsRelease(obj,release)
            result=isKey(obj.ReleaseMap,release);
        end
    end

    methods(Access=private)


        function result=supportsPlatform(obj,release,platform)
            result=any(strcmp(platform,obj.ReleaseMap(release)));
        end
    end
end