


function sldvData=convertSldvData(dataLoadedFromMatFile)
    dataFields=fields(dataLoadedFromMatFile);
    if length(dataFields)==1
        sldvData=dataLoadedFromMatFile.(dataFields{1});
    else
        error(message('Simulink:Harness:unexpectedDataFormat'));
    end

    if~isSldvData(sldvData)
        error(message('Simulink:Harness:unexpectedDataFormat'));
    end


    if~isfield(sldvData,'TestCases')&&~isfield(sldvData,'CounterExamples')
        error(message('Simulink:Harness:NoSLDVTestCasesORCounterExamples'));
    end


    [sldvData,errStr]=Sldv.DataUtils.convertLoggedSldvDataToHarnessDataFormat(sldvData);
    if~isempty(errStr)
        error(message('Simulink:Harness:unexpectedDataFormat'));
    end
end

function out=valid_dv_sim_data(x)
    out=false;
    if isstruct(x)
        out=isfield(x,'timeValues')&&...
        isfield(x,'dataValues')&&...
        isfield(x,'paramValues');
    end
end

function out=isSldvData(x)




    out=false;
    if(isstruct(x)&&numel(x)==1)
        if isfield(x,'LoggedTestUnitInfo')
            if isfield(x,'TestCases')
                out=isfield(x,'TestCases')&&valid_dv_sim_data(x.TestCases);
            else
                out=true;
            end
        else
            if(isfield(x,'ModelInformation')&&isfield(x,'AnalysisInformation'))
                if isfield(x,'TestCases')
                    out=valid_dv_sim_data(x.TestCases);
                elseif isfield(x,'CounterExamples')
                    out=valid_dv_sim_data(x.CounterExamples);
                else
                    out=true;
                end
            end
        end
    end
end

