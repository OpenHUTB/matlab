function[resultsBucket,isValidGoal]=getDDUXObjectiveBucket(validatedStatus,objType)











    isValidGoal=true;
    switch validatedStatus
    case{'Valid','Satisfied','Falsified','Active Logic',...
        'Satisfied by coverage data',...
        'Satisfied by existing testcase'}
        resultsBucket='DEC';
    case{'Satisfied - No Test Case',...
        'Falsified - No Counterexample'}
        resultsBucket='NTC';
    case 'Valid within bound'
        resultsBucket='BOU';
    case{'Satisfied - needs simulation',...
        'Falsified - needs simulation',...
        'Active Logic - needs simulation'}
        resultsBucket='SIM';
    case{'Unsatisfiable',...
        'Dead Logic'}
        resultsBucket='USAT';
    case{'Undecided with testcase',...
        'Undecided with counterexample',...
        'Undecided due to approximations',...
        'Dead Logic under approximation',...
        'Valid under approximation',...
        'Unsatisfiable under approximation'}
        resultsBucket='APX';
    case 'Undecided due to nonlinearities'
        resultsBucket='NLR';
    case 'Undecided due to stubbing'
        resultsBucket='STUB';
    case{'Undecided due to runtime error',...
        'Undecided due to division by zero',...
        'Undecided due to array out of bounds'}
        resultsBucket='RTE';
    case 'Undecided'
        resultsBucket='UDEC';
    otherwise



        resultsBucket='';
        if strcmp('n/a',validatedStatus)&&...
            ~any(strcmp(objType,Sldv.utils.getDeadLogicObjectiveTypes))







            isValidGoal=false;
        end
    end
end


