function supportedHW=getSupportedHWForInstructionSet(instructionSetName)
    supportedHW={};
    processors=target.internal.get('Processor');

    num=length(processors);
    idx=0;
    for i=1:num
        if loc_containInstructionSet(processors(i),instructionSetName)
            idx=idx+1;
            supportedHW{idx}=loc_getHardwareName(processors(i));
        end
    end

    if isempty(supportedHW)
        supportedHW={'*'};
    end
end

function result=loc_containInstructionSet(tgtProcessor,tgtInstructionSetName)
    result=false;

    ISA=tgtProcessor.InstructionSetArchitecture;
    if isempty(ISA)
        return;
    else
        num=length(ISA.Extensions);
        for i=1:num
            if strcmp(ISA.Extensions(i).Name,tgtInstructionSetName)
                result=true;
                return;
            end
        end
    end

end

function hwName=loc_getHardwareName(tgtProcessor)
    assert(~isempty(tgtProcessor));
    hwName=tgtProcessor.getQualifiedParameterString;
end