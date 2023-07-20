
function bool=isArrayOfBus(sldvData)
    numPorts=length(sldvData.AnalysisInformation.InputPortInfo);
    bool=false;
    for id=1:numPorts
        if iscell(sldvData.AnalysisInformation.InputPortInfo{id})
            if isfield(sldvData.AnalysisInformation.InputPortInfo{id}{1},'hasArrayOfBuses')&&...
                sldvData.AnalysisInformation.InputPortInfo{id}{1}.hasArrayOfBuses

                bool=true;
                return;
            elseif isfield(sldvData.AnalysisInformation.InputPortInfo{id}{1},'Dimensions')

                arrayDim=prod(sldvData.AnalysisInformation.InputPortInfo{id}{1}.Dimensions);
                if arrayDim>1

                    bool=true;
                    return;
                end
            end
        end
    end
end
