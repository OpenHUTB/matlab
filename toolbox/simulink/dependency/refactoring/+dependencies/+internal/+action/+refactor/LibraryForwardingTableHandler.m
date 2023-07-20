classdef LibraryForwardingTableHandler<dependencies.internal.action.RefactoringHandler




    properties(SetAccess=immutable)
        Types=cellstr(dependencies.internal.analysis.simulink.LibraryForwardingTableAnalyzer.LibraryForwardingTableType.ID);
        RenameOnly=true;
    end

    methods

        function refactor(~,dependency,newPath)
            [~,library]=fileparts(dependency.UpstreamNode.Location{1});
            [~,oldName]=fileparts(dependency.DownstreamNode.Location{1});
            [~,newName]=fileparts(newPath);

            oldDownComponent=dependency.DownstreamComponent.Path;
            [~,downPath]=strtok(oldDownComponent,"/");
            newDownComponent=char(newName+downPath);


            updateSelf=strcmp(dependency.UpstreamNode.Location{1},newPath);
            if updateSelf
                library=newName;
            end


            ft=get_param(library,'ForwardingTable');
            for n=1:numel(ft)
                if length(ft{n})>1&&strcmp(ft{n}{2},oldDownComponent)
                    if strcmp(strtok(ft{n}{2},'/'),oldName)
                        ft{n}{2}=newDownComponent;
                    end
                    if updateSelf
                        [oldSelfName,oldSelfPath]=strtok(ft{n}{1},'/');
                        if strcmp(oldSelfName,oldName)
                            ft{n}{1}=[newName,oldSelfPath];
                        end
                    end
                end
            end
            set_param(library,'ForwardingTable',ft);
        end

    end

end
