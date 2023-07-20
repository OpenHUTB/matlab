classdef LibraryForwardingTransformHandler<dependencies.internal.action.RefactoringHandler




    properties(SetAccess=immutable)
        Types={dependencies.internal.analysis.simulink.LibraryForwardingTableAnalyzer.LibraryForwardingTransformType};
        RenameOnly=true;
    end

    methods

        function refactor(~,dependency,newPath)
            [~,library]=fileparts(dependency.UpstreamNode.Location{1});
            [~,oldName]=fileparts(dependency.DownstreamNode.Location{1});
            [~,newName]=fileparts(newPath);


            ft=get_param(library,'ForwardingTable');
            for n=1:numel(ft)
                if length(ft{n})>2&&strcmp(ft{n}{3},oldName)
                    ft{n}{3}=newName;
                end
            end
            set_param(library,'ForwardingTable',ft);
        end

    end

end
