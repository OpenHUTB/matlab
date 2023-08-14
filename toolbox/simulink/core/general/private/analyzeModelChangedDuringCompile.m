function analyzeModelChangedDuringCompile(analysisType,varargin)
































    expectedTypes={'CompileModel','CompileCustom','ExistingLog'};

    p=inputParser();
    p.addRequired('AnalysisType',@(x)any(validatestring(x,expectedTypes)));
    p.addParameter('Model','',@(x)validateattributes(x,{'char'},{'nonempty'}));
    p.addParameter('Command','',@(x)validateattributes(x,{'function_handle'},{'nonempty'}));
    p.addParameter('LogFile','',@(x)validateattributes(x,{'char'},{'nonempty'}));
    parse(p,analysisType,varargin{:});

    inputs=p.Results;

    switch(inputs.AnalysisType)
    case 'CompileModel'
        if isempty(inputs.Model)
            error('AnalyzeModelChanged:ModelNotSpecified',...
            'Required model to compile not specified.');
        end
        command=['load_system(''',inputs.Model,'''); '...
        ,inputs.Model,'([],[],[],''compile''); '...
        ,inputs.Model,'([],[],[],''term'');'];
        loc_CompileModel(command);

    case 'CompileCustom'
        if isempty(inputs.Command)
            error('AnalyzeModelChanged:FunctionNotSpecified',...
            'Required function to execute not specified');
        end
        command=func2str(inputs.Command);
        loc_CompileModel(command);

    case 'ExistingLog'
        if isempty(inputs.LogFile)||isempty(inputs.Model)
            error('AnalyzeModelChanged:LogAndModelNotSpecified',...
            'Required log file and model to search not specified.');
        end
        if~isfile(inputs.LogFile)
            error('AnalyzeModelChanged:LogNotFound',...
            'Specified LogFile %s doesn''t exist.',inputs.LogFile);
        end
        loc_Analyze(inputs.LogFile,inputs.Model);
    end
end

function loc_Analyze(logfile,model)
    analyzer=Simulink.ModelReference.internal.ChecksumAnalyzer(logfile);
    analyzer.analyze(model);
end

function loc_CompileModel(command)
    origPCI=get_param(0,'PrintChecksumInfo');
    set_param(0,'PrintChecksumInfo','on');
    oc1=onCleanup(@()set_param(0,'PrintChecksumInfo',origPCI));
    oc2=onCleanup(@()diary('off'));

    try
        file='mainLog.txt';
        if isfile(file)
            delete(file);
        end
        diary(file);
        eval(command);
        fprintf('### The command was executed successfully. No errors reported.\n');
    catch ME
        oc2.delete();
        if~strcmp(ME.identifier,...
            'Simulink:modelReference:MultiinstanceNormalModeBlockDiagramChecksumChanged')
            rethrow(ME);
        end
        model=loc_GetModelFromMessage(ME.message);
        loc_Analyze(file,model);
        return;
    end
end

function result=loc_GetModelFromMessage(msg)
    match=regexp(msg,'>(\S+)<','tokens');


    if isempty(match)
        fprintf('msg: %s\nFirst match attempt to find model from message failed. Trying again.\n',msg);
        match=regexp(msg,'''(\S+)''','tokens');
        if isempty(match)
            error('AnalyzeModelChanged:ModelNotFoundInMsg',...
            'Model not found in message: %s',msg);
        end
    end
    result=match{1}{1};
end
