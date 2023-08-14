function out=isSLDVData(~,x)


    out=false;

    if(isstruct(x)&&numel(x)==1)
        if isfield(x,'LoggedTestUnitInfo')
            out=isfield(x,'TestCases')&&valid_dv_sim_data(x.TestCases);
        else
            if(isfield(x,'ModelInformation')&&isfield(x,'AnalysisInformation'))
                if isfield(x,'TestCases')
                    out=valid_dv_sim_data(x.TestCases);
                else
                    out=isfield(x,'CounterExamples')&&...
                    valid_dv_sim_data(x.CounterExamples);
                end
            end
        end
    end
end

function out=valid_dv_sim_data(x)

    out=false;

    if isstruct(x)
        out=isfield(x,'timeValues')&&isfield(x,'dataValues')&&...
        isfield(x,'paramValues');
    end
end
