


function[mappingString,scenario,sldvVarName]=loadSldvFile(filePath,scenarioIndex,varargin)

    mappingString='';
    scenario=[];
    S=load(filePath);
    existingVars=evalin('base','who');
    sldvVarName=matlab.lang.makeUniqueStrings('stmSldvInput',existingVars);
    if nargin>2
        assignVars=varargin{1};
    else
        assignVars=true;
    end
    if assignVars
        stmSldvInput=Sldv.DataUtils.convertTestCasesToSLDataSet(S.sldvData,true);
        assignin('base',sldvVarName,stmSldvInput);
    end

    fieldToUse=getFieldToUse(S.sldvData);

    if~isempty(fieldToUse)
        field=S.sldvData.(fieldToUse);
        if scenarioIndex>numel(field)
            [~,name,ext]=fileparts(filePath);
            error(message('stm:Parameters:SldvIndexError',scenarioIndex,[name,ext],fieldToUse,numel(field)));
        end
        scenario=field(scenarioIndex);

        if assignVars
            mappingString=[sldvVarName,'.',fieldToUse,'(',int2str(scenarioIndex),').dataValues'];
        end
    end
end

function fieldToUse=getFieldToUse(sldvData)
    if isfield(sldvData,'TestCases')
        fieldToUse='TestCases';
    elseif isfield(sldvData,'CounterExamples')
        fieldToUse='CounterExamples';
    else
        fieldToUse=[];
    end
end
