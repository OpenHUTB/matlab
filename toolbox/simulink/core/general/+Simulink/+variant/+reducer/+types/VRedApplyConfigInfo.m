classdef VRedApplyConfigInfo<handle




    methods
        function delete(obj)
            obj.activeMdlRefBlksPerConfig={};
            obj.activeRefMdlsPerConfig={};
            obj.allRefMdlsPerConfig={};
            obj.modelsActivePerConfigMap=containers.Map;
        end
    end
    properties
        activeMdlRefBlksPerConfig={};
        activeRefMdlsPerConfig={};
        allRefMdlsPerConfig={};
        modelsActivePerConfigMap=containers.Map;
    end
end
