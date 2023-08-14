function msg=gaminlpcreateexitmsg(efgaminlp,efgalincon,hasConstr,galinconmsg)













    switch efgaminlp
    case 5
        if hasConstr
            msg=sprintf('%s\n%s','Optimization terminated: minimum penalty fitness limit reached',...
            'and constraint violation is less than options.ConstraintTolerance.');
        else
            msg='Optimization terminated: minimum penalty fitness limit reached.';
        end
    case 3
        if hasConstr
            msg=sprintf('%s\n%s','Optimization terminated: stall generations limit exceeded',...
            'and constraint violation is less than options.ConstraintTolerance.');
        else
            msg='Optimization terminated: stall generations limit exceeded.';
        end
    case 1
        if hasConstr
            msg=sprintf('%s\n%s','Optimization terminated: average change in the penalty fitness value less than options.FunctionTolerance',...
            'and constraint violation is less than options.ConstraintTolerance.');
        else
            msg='Optimization terminated: average change in the penalty fitness value less than options.FunctionTolerance.';
        end
    case 0
        msg='Optimization terminated: maximum number of generations exceeded.';
    case-1
        msg=galinconmsg;
    case-2
        switch efgalincon
        case 5
            msg=sprintf('%s\n%s','Optimization terminated: minimum penalty fitness limit reached',...
            'but constraints are not satisfied.');
        case 3
            msg=sprintf('%s\n%s','Optimization terminated: stall generations limit exceeded',...
            'but constraints are not satisfied.');
        case 1
            msg=sprintf('%s\n%s','Optimization terminated: average change in the penalty fitness value less than options.FunctionTolerance',...
            'but constraints are not satisfied.');
        case-2
            msg=galinconmsg;
        otherwise
            error(message('globaloptim:gaminlpcreateexitmsg:noExitMsgForGalinconExitflag'));
        end
    case-4
        msg='Optimization terminated: stall time limit exceeded.';
    case-5
        msg='Optimization terminated: time limit exceeded.';
    otherwise
        error(message('globaloptim:gaminlpcreateexitmsg:noExitMsgForExitflag'));
    end
