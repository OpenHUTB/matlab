function out=customStepHandler(action,varargin)

    switch(action)
    case 'getCustomTaskInfo'
        out=getCustomTaskInfo(varargin{:});
    case 'getCustomStep'
        out=getCustomStep(varargin{:});
    case 'getCustomDataStep'
        out=getCustomDataStep(varargin{:});
    end

end

function customCodeStep=getCustomStep(customTaskInfo)


    customCodeStep=getCustomCodeStep;


    code=customTaskInfo.code;
    closingBrace=strfind(customTaskInfo.code,')');

    if~isempty(closingBrace)

        functionLine=code(1:closingBrace);


        code=code(closingBrace+1:end);


        comments=strfind(code,'Initialize output.');
        if~isempty(comments)
            code=code(comments+18:end);
        end


        code=[getCustomTaskCodeTemplate,code];



        [~,tok]=regexpi(functionLine,'function(.*?)=','match','tokens');
        if~isempty(tok)
            args=strtrim(tok{1}{1});


            if startsWith(args,'[')
                args=args(2:end-1);
                args=strtrim(strsplit(args,','));
                args=args{1};
            end
        end

        code=[code,newline,newline,sprintf('args.output.results = %s;',args)];
    end


    customCodeStep.customCode=code;

end

function out=getCustomTaskInfo(projectConverter,node,modelSessionID,projectVersion)

    out=struct;
    programName=getAttribute(node,'Name');

    try

        out.stopTime=getSimulationStep(node,modelSessionID);


        customSettingsNode=getField(node,'CustomSettings');


        out.code=getAttribute(customSettingsNode,'Code');


        out.dataNames=getArrayValues(customSettingsNode,'TaskData',projectVersion);


        out.name=programName;
    catch ex
        projectConverter.addError(sprintf('Unable to convert custom task: %s',programName),ex);
    end

end

function dataStep=getCustomDataStep(dataNames)


    dataStep=getCustomDataSectionStructTemplate;
    dataStep.internal.id=1;

    customProgramTableData=getCustomTaskDataTableStructTemplate();
    customProgramTableData=repmat(customProgramTableData,numel(dataNames),1);
    for i=1:numel(dataNames)
        customProgramTableData(i).name=dataNames{i};
    end

    dataStep.internal.customProgramTableData=customProgramTableData;

end

function step=getCustomCodeStep


    internalStruct=getInternalStructTemplate;
    internalStruct.id=3;


    step=struct;
    step.enabled=true;
    step.customCode='';
    step.name='Custom Code';
    step.type='Custom Code';
    step.internal=internalStruct;
    step.version=1;

end

function dataStep=getCustomDataSectionStructTemplate

    dataStep=struct;
    dataStep.enabled=true;
    dataStep.internal=getInternalStructTemplate;
    dataStep.name='DataCustom';
    dataStep.type='DataCustom';
    dataStep.version=1;
    dataStep.customProgramDataInfo=[];

end

function out=getCustomTaskDataTableStructTemplate

    out=struct;
    out.ID='';
    out.use=true;
    out.name='';

end

function out=getCustomTaskCodeTemplate

    out=['function args = runCustom(args)',newline,newline...
    ,'% Extract the input arguments',newline...
    ,'input    = args.input;',newline...
    ,'modelobj = input.model;',newline...
    ,'cs       = input.cs;',newline...
    ,'variants = input.variants.modelStep;',newline...
    ,'doses    = input.doses.modelStep;',newline,newline...
    ,'% dataInput is a structure. The names of the datasets appear as fields of',newline...
    ,'% the dataInput structure. To access the dataset use dataInput.name.',newline...
    ,'dataInput = input.data;',newline,newline...
    ,'% Perform analysis',newline];

end

function out=getArrayValues(argNode,valueProp,projectVersion)

    out={};

    if strcmp(projectVersion,'4.1')
        values=getAttribute(argNode,'Value');
        values=values(2:end-1);
        if~isempty(values)
            out=strsplit(values,',');
            out=cellfun(@strtrim,out,'UniformOutput',false);
        end
    else
        count=getAttribute(argNode,sprintf('%sCount',valueProp));
        if~isempty(count)
            out=cell(count,1);
            for i=1:count
                out{i}=getAttribute(argNode,sprintf('%s%d',valueProp,(i-1)));
            end
        end
    end

end

function out=getAttribute(node,attribute,varargin)

    out=SimBiology.web.internal.converter.utilhandler('getAttribute',node,attribute,varargin{:});

end

function out=getField(node,field)

    out=SimBiology.web.internal.converter.utilhandler('getField',node,field);

end

function out=getInternalStructTemplate

    out=SimBiology.web.internal.converter.utilhandler('getInternalStructTemplate');

end

function simulationStep=getSimulationStep(node,modelSessionID)

    simulationStep=SimBiology.web.internal.converter.simulationStepHandler('getSimulationStep',node,modelSessionID);

end
