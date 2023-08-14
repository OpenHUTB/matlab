function idx=varindex(p,varname)




















    narginchk(1,2);


    vars=getVariables(p);


    if nargin==1&&isempty(vars)
        idx=struct.empty;
        return
    end


    probvarnames=fieldnames(vars);


    if nargin>1
        validateVarname(varname,probvarnames);
    end


    NumVars=0;
    for i=1:numel(probvarnames)
        thisVarName=probvarnames{i};
        thisVar=vars.(thisVarName);
        thisVarOffset=1+NumVars;
        nThisVar=numel(thisVar);
        NumVars=NumVars+numel(thisVar);
        thisVarIdx=thisVarOffset+(1:nThisVar)-1;
        if nargin>1
            if strcmp(varname,thisVarName)
                idx=thisVarIdx;
                break
            end
        else
            idx.(probvarnames{i})=thisVarIdx;
        end
    end

    function validateVarname(varname,probvarnames)

        if~matlab.internal.datatypes.isScalarText(varname,false)
            throwAsCaller(MException('optim_problemdef:varindex:InvalidVarname',...
            getString(message('optim_problemdef:ProblemImpl:varindex:InvalidVarname'))));
        end

        if~any(strcmp(varname,probvarnames))
            throwAsCaller(MException('optim_problemdef:varindex:VarnameNotInProblem',...
            getString(message('optim_problemdef:ProblemImpl:varindex:VarnameNotInProblem',varname))));
        end

