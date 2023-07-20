


classdef ModelRefUtil


    methods(Static)


        function paths=getModelRefPath(topModel,refModel,blk)



            import Simulink.HMI.ModelRefUtil;
            tmp=Simulink.SimulationData.ModelCloseUtil;

            paths=ModelRefUtil.getPathsToRefModel(...
            Simulink.BlockPath.empty,topModel,refModel,{},{});

            if nargin>2
                blkPath=getBlock(blk,1);
                subPath=blk.SubPath;
                for idx=1:length(paths)
                    path=paths(idx).convertToCell;
                    path{end+1}=blkPath;%#ok<AGROW>
                    paths(idx)=Simulink.BlockPath(path,subPath);
                end
            end

            delete(tmp);
        end


        function dlg=userSelectModelPath(paths,hmiBlockName,componentName,cb)

            dlg=Simulink.HMI.ModelRefInstanceDlg(...
            paths,hmiBlockName,componentName,cb);
        end

    end


    methods(Static)


        function paths=getPathsToRefModel(paths,topModel,refModel,...
            prefix,searchedMdls)

            import Simulink.HMI.ModelRefUtil;


            if strcmp(topModel,refModel)
                paths(end+1)=Simulink.BlockPath(prefix);
                return;
            end


            try
                warn_state=warning('off','all');
                tmp=onCleanup(@()warning(warn_state));
                load_system(topModel);
                [~,blks]=find_mdlrefs(topModel,...
                'AllLevels',false,...
                'IncludeProtectedModels',false,...
                'MatchFilter',@Simulink.match.allVariants,...
                'IgnoreVariantErrors',true);
            catch me %#ok<NASGU>

                return;
            end


            for idx=1:length(blks)
                if~strcmpi(get_param(blks{idx},'ProtectedModel'),'on')


                    curRefModel=get_param(blks{idx},'ModelName');
                    if any(strcmp(searchedMdls,curRefModel))
                        continue;
                    end

                    paths=ModelRefUtil.getPathsToRefModel(...
                    paths,...
                    curRefModel,...
                    refModel,...
                    [prefix;blks{idx}],...
                    [searchedMdls,{topModel}]);
                end
            end
        end

    end

end

