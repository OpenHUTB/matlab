function codeDescriptor=getCodeDescriptor(varargin)


















    if length(varargin)>1&&isnumeric(varargin{end})
        argsIn=varargin(1:length(varargin)-1);
        bypass=varargin{end};
    elseif~isempty(varargin)
        argsIn=varargin(:);
        bypass=0;
    else
        error(message('codedescriptor:core:NoArgumentProvided'));
    end

    p=inputParser;
    addOptional(p,'BuildDirOrModelName','',@isBuildDirOrModelName);
    addOptional(p,'ModelName','',@isModelName);
    addParameter(p,'IsSIL',false,@islogical);
    parse(p,argsIn{:});

    buildDirOrModelNameType=exist(p.Results.BuildDirOrModelName,'file');
    if buildDirOrModelNameType==4
        if isStringScalar(p.Results.BuildDirOrModelName)
            modelName=p.Results.BuildDirOrModelName.char;
        else
            modelName=p.Results.BuildDirOrModelName;
        end

        rtwBuildDir=RTW.getBuildDir(modelName);
        if exist(rtwBuildDir.BuildDirectory,'dir')==7
            buildDir=rtwBuildDir.BuildDirectory;
        else
            error(message('codedescriptor:core:ModelIsNotBuilt',modelName));
        end
    elseif buildDirOrModelNameType==7||buildDirOrModelNameType==2

        if isStringScalar(p.Results.ModelName)
            buildDir=p.Results.BuildDirOrModelName.char;
        else
            buildDir=p.Results.BuildDirOrModelName;
        end

        if isStringScalar(p.Results.ModelName)
            modelName=p.Results.ModelName.char;
        else
            modelName=p.Results.ModelName;
        end
    end

    [~,~,ext]=fileparts(p.Results.BuildDirOrModelName);
    if strcmp(ext,'.mat')




        if exist(p.Results.BuildDirOrModelName,'file')==2
            codeDescriptor=coder.codedescriptor.CodeDescriptor(p.Results.BuildDirOrModelName);
            codeDescriptor.setAllowMultipleHandles(p.Results.IsSIL);
            licenseCheck(bypass,codeDescriptor);
        else
            codeDescriptor=[];
        end
    else

        tempCodeDescriptor=coder.codedescriptor.CodeDescriptor(buildDir,modelName);
        tempCodeDescriptor.setAllowMultipleHandles(p.Results.IsSIL);
        licenseCheck(bypass,tempCodeDescriptor);
        if isempty(tempCodeDescriptor.ModelName)
            error(message('codedescriptor:core:CannotDetermineModelName',buildDir));
        else
            codeDescriptor=tempCodeDescriptor;
        end
    end
end

function result=isBuildDirOrModelName(arg)
    if~ischar(arg)&&~isStringScalar(arg)
        error(message('codedescriptor:core:ArgumentShouldBeString','coder.getCodeDescriptor'));
    else
        if isStringScalar(arg)
            arg=arg.char;
        end
        argType=exist(arg,'file');
        if argType==7

            result=true;
        elseif argType==4

            result=true;
        elseif argType==2

            result=true;
        else


            [~,~,ext]=fileparts(arg);
            if strcmp(ext,'.mat')
                result=true;
            else
                error(message('codedescriptor:core:BuildDirDoesNotExist',arg));
            end
        end
    end
end

function result=isModelName(arg)
    result=(ischar(arg)||isStringScalar(arg));
end

function licenseCheck(magicNumber,codeDescriptorObj)

    if isnumeric(magicNumber)&&magicNumber==247362
        return
    end
    if~builtin('license','checkout','MATLAB_Coder')
        error(message('Simulink:Engine:MATLABCoder_LicenseError'));
    end


    if~codeDescriptorObj.isMATLABCoderOnly

        if~builtin('license','checkout','Real-Time_Workshop')
            error(message('Simulink:Engine:LicenseError'));
        end

        if(codeDescriptorObj.isERTTarget)
            if~builtin('license','checkout','RTW_Embedded_Coder')
                error(message('Simulink:Engine:ECoder_LicenseError'));
            end
        end

    end

end
