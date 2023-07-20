function isValid=isValidBlock(blockH)















    try
        isValid=false;

        if(blockH<=0)
            return;
        end
        if~isCascMcdcSupported(blockH)
            return;
        end
        if(get_param(blockH,'CoverageID')==0)
            return;
        end
        if strcmpi(get_param(blockH,'DisableCoverage'),'on')
            return;
        end
        portWidths=get_param(blockH,'CompiledPortWidths');
        if~isOutputScalar(portWidths)||~areInputsScalar(portWidths)
            return;
        end
        if~strcmpi(get_param(blockH,'BlockType'),'Logic')
            return;
        end

        switch upper(get_param(blockH,'Operator'))
        case 'XOR'
            isValid=false;
        case 'NXOR'
            isValid=false;
        case 'NOT'
            isValid=true;
        otherwise
            isValid=length(portWidths.Inport)>1;
        end
    catch
        isValid=false;
    end
end

function isSupported=isCascMcdcSupported(blockH)
    isShortCircuited=strcmpi(get_param(bdroot(blockH),'CovLogicBlockShortCircuit'),'on');
    isMasking=(SlCov.getMcdcMode(bdroot(blockH))==SlCov.McdcMode.Masking);
    isSupported=isMasking||isShortCircuited;
end

function isScalar=isOutputScalar(portWidths)
    isScalar=~isempty(portWidths)&&...
    isfield(portWidths,'Outport')&&...
    (length(portWidths.Outport)==1)&&...
    (portWidths.Outport==1);
end

function isScalar=areInputsScalar(portWidths)
    isScalar=false;
    if~isempty(portWidths)&&isfield(portWidths,'Inport')
        inports=portWidths.Inport;
        for i=1:length(inports)
            if(inports(i)~=1)
                isScalar=false;
                return;
            end
        end
        isScalar=true;
    end
end
