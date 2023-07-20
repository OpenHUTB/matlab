function validate(obj,varargin)



    validate@hwcli.base.WorkflowBase(obj,varargin{:});





    orderedTasks={...
    'RunTaskGenerateRTLCode',...
    'RunTaskGenerateRTLCodeAndTestbench',...
    'RunTaskCreateProject',...
    'RunTaskPerformLogicSynthesis',...
    'RunTaskPerformMapping',...
    'RunTaskPerformPlaceAndRoute',...
    'RunTaskRunSynthesis',...
    'RunTaskRunImplementation',...
    'RunTaskGenerateProgrammingFile',...
    };


    sequentialTasks=intersect(orderedTasks,obj.Tasks,'stable');
    booleanVector=cellfun(@(x)obj.(x),sequentialTasks);


    firstFalse=find(~booleanVector,1,'first');
    if isempty(firstFalse)
        return;
    end


    lastTrue=find(booleanVector,1,'last');
    if lastTrue>firstFalse
        error(message('hdlcoder:workflow:SynthesisTasksMustBeRunTogether',sequentialTasks{lastTrue},sequentialTasks{firstFalse}));
    end

end