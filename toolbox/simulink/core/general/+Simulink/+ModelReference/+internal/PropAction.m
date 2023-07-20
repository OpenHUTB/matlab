classdef(Abstract)PropAction




    methods(Abstract)
        action=build()
        run()
    end

    methods(Static=true)




        function model=getModelName(blkPath)
            model='';
            if isempty(blkPath)
                return;
            end

            parent=get_param(blkPath,'Object');
            if isempty(parent)
                return;
            end

            root=parent;
            while~(isa(root,'Simulink.BlockDiagram'))
                root=root.getParent;
            end

            model=root.getFullName;
        end





        function instPrmInfo=getInstParamInfo(mdlBlkPath,argSidPath)
            instPrmInfo=[];

            try
                instParams=get_param(mdlBlkPath,'InstanceParametersInfo');
                for argIdx=1:numel(instParams)
                    if isequal(instParams(argIdx).SIDPath,argSidPath)
                        instPrmInfo=instParams(argIdx);
                        break;
                    end
                end
            catch
            end
        end
    end
end
