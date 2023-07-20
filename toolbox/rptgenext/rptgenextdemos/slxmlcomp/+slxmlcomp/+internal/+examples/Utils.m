classdef Utils<handle



    methods(Static)

        function tempDir=createTempDir()
            dirFactory=slxmlcomp.internal.examples.Utils.getOrSetTempDirFactory();
            tempDir=dirFactory();
        end

        function varargout=getOrSetTempDirFactory(varargin)

            persistent tempDirFactory;

            if(isempty(tempDirFactory))
                tempDirFactory=@defaultTempDirFactory;
            end

            if(nargin==0)
                varargout{1}=tempDirFactory;
            else
                tempDirFactory=varargin{1};
            end
        end

        function copyAndMakeWritable(dstDir,model,copyMex)
            srcDir=fullfile(matlabroot,'toolbox','rptgenext','rptgenextdemos',...
            'slxmlcomp','models');

            srcModel=fullfile(srcDir,model);
            dstModel=fullfile(dstDir,model);

            copyfile(srcModel,dstDir);
            fileattrib(dstModel,'+w');

            if copyMex
                [~,mdlName,~]=fileparts(model);
                mexFile=fullfile(srcDir,[mdlName,'_sfun.',mexext]);
                copyfile(mexFile,dstDir);
            end
        end

    end

end

function exampleDir=defaultTempDirFactory()
    if comparisons.internal.isMOTW
        workFolder=matlab.internal.examples.getExamplesDir();


        exampleDir=tempname(fullfile(workFolder,'comparisons'));
    else
        exampleDir=tempname;
    end
    mkdir(exampleDir);
end
