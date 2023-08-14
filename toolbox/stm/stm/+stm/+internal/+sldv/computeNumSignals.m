
function numOutportReq=computeNumSignals(InputPortInfo,isSignalBuilderSrc)
    numOutportReq=0;
    numPorts=length(InputPortInfo);
    if~isSignalBuilderSrc


        usedSignals=Simulink.harness.internal.populateUsedSignals(InputPortInfo,{});
        numOutportReq=length(usedSignals{:});
        return;
    end
    for i=1:numPorts
        if~iscell(InputPortInfo{i})

            if InputPortInfo{i}.Used
                numData=prod(InputPortInfo{i}.Dimensions);
            else
                numData=0;
            end
        else
            arrayDim=prod(InputPortInfo{i}{1}.Dimensions);
            if arrayDim>1

                numData=0;
                for j=1:arrayDim
                    numData=numData+extractRawNumData(InputPortInfo{i});
                end
            else

                numData=extractRawNumData(InputPortInfo{i});
            end
        end
        numOutportReq=numOutportReq+numData;
    end
end

function numData=extractRawNumData(portInfo)
    numChild=length(portInfo)-1;
    isLeaf=numChild==0;
    if isLeaf
        if portInfo.Used
            numData=prod(portInfo.Dimensions);
        else
            numData=0;
        end
    else
        numData=0;
        for i=1:numChild
            numChData=extractRawNumData(portInfo{i+1});
            numData=numData+numChData;
        end
    end
end
