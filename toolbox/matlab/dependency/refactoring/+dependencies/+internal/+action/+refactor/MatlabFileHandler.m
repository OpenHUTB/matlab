classdef MatlabFileHandler<dependencies.internal.action.RefactoringHandler




    properties(SetAccess=immutable)
        Types=i_getTypes();
        RenameOnly=true;
    end

    methods

        function refactor(~,dependency,newPath)
            upFile=dependency.UpstreamNode.Location{1};

            updateSelf=strcmp(dependency.UpstreamNode.Location{1},newPath);
            if updateSelf
                upFile=newPath;
            end

            text=fileread(upFile);
            updated=dependencies.internal.action.refactor.updateMatlabCode(...
            dependency.UpstreamNode,text,dependency.DownstreamNode,newPath,updateSelf);

            fid=fopen(upFile,'w');
            fprintf(fid,'%s',updated);
            fclose(fid);
        end

    end

end

function types=i_getTypes()
    baseType=dependencies.internal.analysis.matlab.MatlabNodeAnalyzer.MATLABFileType;
    types={
    [baseType,',Name']
    [baseType,',FunctionCall']
    [baseType,',Inheritance']
    };
end
