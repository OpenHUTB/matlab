classdef EDGExtraOptions<handle




    properties(Access=private,Constant)
        fProdTargets={'Freescale->MPC5xx'};
        fCompilerTargetPair={struct('compiler','codewarrior','target','powerpc')};
    end

    properties(Access=private)
        fProdTargetOptionsMap;
    end

    methods



        function obj=EDGExtraOptions(obj)%#ok
            obj.fProdTargetOptionsMap=containers.Map(obj.fProdTargets,...
            obj.fCompilerTargetPair,'UniformValues',true);
        end
    end

    methods(Hidden)

        function out=hasTargetOptions(obj,target)
            targets=keys(obj.fProdTargetOptionsMap);

            out=any(strcmp(targets,target));
        end



        function out=getExtraOptionsForTarget(obj,target)
            out=struct('compiler','','target','');
            if obj.hasTargetOptions(target)
                out=obj.fProdTargetOptionsMap(target);
            end
        end
    end
end

