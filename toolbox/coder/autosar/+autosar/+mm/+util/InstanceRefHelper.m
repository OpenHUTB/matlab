classdef InstanceRefHelper<handle





    methods(Static)




        function ret=getOrSetId(m3iObj)
            ret=m3iObj.getExternalToolInfo('InstanceRef').externalId;
            if isempty(ret)
                ret=autosar.mm.Model.setExternalToolInfo(m3iObj,'InstanceRef');
            end
        end
    end
end


