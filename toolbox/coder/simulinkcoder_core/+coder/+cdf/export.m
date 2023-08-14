function export(modelName,varargin)




























    [checkoutSuccess,errmsg]=license('checkout','Real-Time_Workshop');
    if~checkoutSuccess
        DAStudio.error('RTW:asap2:RequiresSimulinkCoder',errmsg);
    end
    if nargin>0
        modelName=convertStringsToChars(modelName);
    else
        DAStudio.error('RTW:asap2:RequiresModelName');
    end


    argParser=inputParser;
    buildDir=RTW.getBuildDir(modelName);
    argParser.addParameter('FileName',modelName,@(x)(ischar(x)||isStringScalar(x)));
    argParser.addParameter('Folder',buildDir.BuildDirectory,@(x)(ischar(x)||isStringScalar(x)));
    argParser.addParameter('SchemaType','DTD',@(x)(any(validatestring(x,...
    {'DTD','XSD'}))));
    argParser.addParameter('UseSavedSettings',false,@(x)(isa(x,'logical')));


    systems=find_system('type','block_diagram','name',modelName);
    if isempty(systems)
        DAStudio.error('Simulink:components:discmdlMdlNotFound',modelName);
    end
    argParser.parse(varargin{:});

    if exist(buildDir.BuildDirectory,'dir')~=7
        DAStudio.error('RTW:asap2:ModelIsNotBuilt',modelName);
    end

    if exist(fullfile(buildDir.BuildDirectory,'codedescriptor.dmr'),'file')~=2
        DAStudio.error('RTW:asap2:missingCodeDescriptor',buildDir.BuildDirectory,'CDF');
    end

    noFileSeps=isempty(regexp(argParser.Results.FileName,'[/\\*:?"<>|]','once'));
    if~(noFileSeps)
        DAStudio.error('SimulinkCoderApp:ui:uiInvalidCDFFileName');
    end




    noFileSeps=isempty(regexp(argParser.Results.Folder,'[*?"<>|]','once'));
    if~(noFileSeps)
        DAStudio.error('SimulinkCoderApp:ui:uiInvalidCDFFolderName');
    end


    if isempty(argParser.Results.Folder)
        cdfFolder=string(buildDir.BuildDirectory);
    else
        cdfFolder=string(argParser.Results.Folder);
    end


    if isempty(argParser.Results.FileName)
        cdfFileName=modelName;
    else
        cdfFileName=argParser.Results.FileName;
    end
    if argParser.Results.UseSavedSettings
        s=settings;
        try
            schema=s.GenerateCalibrationFilesTool.cdf.schema.ActiveValue;
        catch
            schema=argParser.Results.SchemaType;
        end
    else
        schema=argParser.Results.SchemaType;
    end

    [isComplete,msg]=coder.cdf.generate(buildDir.BuildDirectory,cdfFileName,cdfFolder,schema);
    if~isComplete
        error(msg);
    end
end


