classdef MatlabFileBusHandler<dependencies.internal.action.RefactoringHandler




    properties(SetAccess=immutable)
        Types=cellstr(dependencies.internal.buses.analysis.MatlabBusNodeAnalyzer.Type.ID);
        RenameOnly=true;
    end

    methods

        function refactor(~,dependency,newName)
            file=dependency.UpstreamNode.Location{1};
            oldElement=dependency.DownstreamNode.Location{end};

            newElement=split(newName,'.');
            newElement=newElement{end};

            text=fileread(file);

            import dependencies.internal.buses.util.CodeUtils
            [text,noChange]=CodeUtils.refactorCode(text,oldElement,newElement);

            if noChange
                return;
            end

            fid=fopen(file,'w');
            cleanup=onCleanup(@()fclose(fid));
            fprintf(fid,'%s',text);
        end

    end

end
