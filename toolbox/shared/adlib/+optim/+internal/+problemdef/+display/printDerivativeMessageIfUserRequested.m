function[objectiveMessageStr,constraintMessageStr]=printDerivativeMessageIfUserRequested(prob,probStruct)


















    gradientsNotRequired=["linprog";"intlinprog";
    "lsqlin";"quadprog";"coneprog";
    "lsqnonneg"];

    if optim.internal.utils.hasGlobalOptimizationToolbox
        gradientsNotRequired=[gradientsNotRequired;
        "ga";"gamultiobj";"particleswarm";"patternsearch";
        "paretosearch";"simulannealbnd";"surrogateopt"];
    end

    objectiveMessageStr="";
    constraintMessageStr="";

    if(isfield(probStruct,'options')&&...
        ~optim.internal.problemdef.display.allowsDisplay(probStruct.options))


        return;

    elseif(~probStruct.userSpecifiedObjectiveGradients&&...
        ~probStruct.userSpecifiedConstraintGradients)


        return;
    end

    hasObjective=~isempty(prob.Objective);
    if isempty(prob.Constraints)
        hasConstraints=false;
    elseif isstruct(prob.Constraints)
        hasConstraints=~all(structfun(@isempty,prob.Constraints));
    else
        hasConstraints=true;
    end



    hybridFcnSet=isfield(probStruct,'options')&&...
    (isfield(probStruct.options,'HybridFcn')||...
    any(strcmpi(properties(probStruct.options),'HybridFcn')))&&...
    ~isempty(probStruct.options.HybridFcn);

    hybridFcnNeedsGradients=false;
    if hybridFcnSet
        if iscell(probStruct.options.HybridFcn)


            fcnName=probStruct.options.HybridFcn{1};
        else

            fcnName=probStruct.options.HybridFcn;
        end

        if isa(fcnName,'function_handle')
            fcnName=func2str(fcnName);
        end
        hybridFcnNeedsGradients=any(strcmpi(fcnName,["fminunc";"fmincon"]));
    end



    objectiveHybridFlag='';
    constraintHybridFlag='';

    if hybridFcnSet


        objectiveHybridFlag='Hybrid';
        constraintHybridFlag='Hybrid';
    end



    if(~hasObjective&&probStruct.userSpecifiedObjectiveGradients)
        msg=sprintf('optim_problemdef:OptimizationProblem:solve:NoDerivativesRequired%sObjectiveEmpty',objectiveHybridFlag);
        objectiveMessageStr=string(message(msg));
    end
    if(~hasConstraints&&probStruct.userSpecifiedConstraintGradients)
        if hasBounds(prob)
            msgID=sprintf('optim_problemdef:OptimizationProblem:solve:NoDerivativesRequired%sConstraintBoundsOnly',constraintHybridFlag);
        else
            msgID=sprintf('optim_problemdef:OptimizationProblem:solve:NoDerivativesRequired%sConstraintEmpty',constraintHybridFlag);
        end
        msg=sprintf(msgID,constraintHybridFlag);
        constraintMessageStr=string(message(msg));
    end




    solverNeedsGradients=~any(strcmpi(probStruct.solver,gradientsNotRequired))||hybridFcnNeedsGradients;
    if~solverNeedsGradients
        objectiveMessageStr=string(message('optim_problemdef:OptimizationProblem:solve:NoDerivativesRequired'));
        constraintMessageStr="";
    else
        objectiveClosedForm=hasObjective&&strcmpi(probStruct.objectiveDerivative,'closed-form');
        constraintsClosedForm=hasConstraints&&strcmpi(probStruct.constraintDerivative,'closed-form');

        if(objectiveClosedForm&&probStruct.userSpecifiedObjectiveGradients)


            msg=sprintf('optim_problemdef:OptimizationProblem:solve:UsingClosedFormDerivatives%sObjective',objectiveHybridFlag);
            objectiveMessageStr=string(message(msg,closedFormOrder(prob,'Objective')));
        end
        if(constraintsClosedForm&&probStruct.userSpecifiedConstraintGradients)


            msg=sprintf('optim_problemdef:OptimizationProblem:solve:UsingClosedFormDerivatives%sConstraint',constraintHybridFlag);
            constraintMessageStr=string(message(msg,closedFormOrder(prob,'Constraints')));
        end



        objDerivMethod=convertDerivativeSettingToMessageStr(probStruct.objectiveDerivative);
        constrDerivMethod=convertDerivativeSettingToMessageStr(probStruct.constraintDerivative);



        displayObjectiveDerivs=(hasObjective&&~objectiveClosedForm&&probStruct.userSpecifiedObjectiveGradients);
        displayConstraintDerivs=(hasConstraints&&~constraintsClosedForm&&probStruct.userSpecifiedConstraintGradients);



        if(displayObjectiveDerivs&&displayConstraintDerivs&&...
            strcmp(probStruct.objectiveDerivative,probStruct.constraintDerivative))


            if strcmpi(probStruct.objectiveDerivative,'finite-differences')
                msg=sprintf('optim_problemdef:OptimizationProblem:solve:UsingFiniteDifferences%s',objectiveHybridFlag);
            else
                msg=sprintf('optim_problemdef:OptimizationProblem:solve:Using%sAutomaticDifferentiation%s',objDerivMethod,objectiveHybridFlag);
            end
            objectiveMessageStr=string(message(msg));
        else
            if displayObjectiveDerivs
                if strcmpi(probStruct.objectiveDerivative,'finite-differences')
                    msg=sprintf('optim_problemdef:OptimizationProblem:solve:UsingFiniteDifferences%sObjective',objectiveHybridFlag);
                else
                    msg=sprintf('optim_problemdef:OptimizationProblem:solve:Using%sAutomaticDifferentiation%sObjective',objDerivMethod,objectiveHybridFlag);
                end
                objectiveMessageStr=string(message(msg));
            end
            if displayConstraintDerivs
                if strcmpi(probStruct.constraintDerivative,'finite-differences')
                    msg=sprintf('optim_problemdef:OptimizationProblem:solve:UsingFiniteDifferences%sConstraint',constraintHybridFlag);
                else
                    msg=sprintf('optim_problemdef:OptimizationProblem:solve:Using%sAutomaticDifferentiation%sConstraint',constrDerivMethod,constraintHybridFlag);
                end
                constraintMessageStr=string(message(msg));
            end
        end
    end

    if(strlength(objectiveMessageStr)>0&&...
        strlength(constraintMessageStr)>0)


        constraintMessageStr=newline+constraintMessageStr;
    end


    if nargout==0
        displayMessage=char(objectiveMessageStr+constraintMessageStr);
        fprintf('\n%s\n\n',displayMessage);
    end


end

function derivPrettyString=convertDerivativeSettingToMessageStr(derivType)




    derivPrettyString=replace(derivType,"auto","");
    derivPrettyString=replace(derivPrettyString,"AD","");
    derivPrettyString=replace(derivPrettyString,"-"," ");
    derivPrettyString=strip(derivPrettyString);

    if strlength(derivPrettyString)==0
        return;
    end


    stringFirstLetter=extractBefore(derivPrettyString,2);
    stringFirstLetter=upper(stringFirstLetter);
    derivPrettyString=replaceBetween(derivPrettyString,1,1,stringFirstLetter);
end


function order=closedFormOrder(prob,property)




    objOrCon=prob.(property);


    if isstruct(objOrCon)
        fnames=fieldnames(objOrCon);
        numObjects=numel(fnames);
        for k=1:numObjects



            thisobj=objOrCon.(fnames{k});
            if isempty(thisobj)
                islinear=true;
            else
                islinear=isLinear(thisobj);
            end
            if~islinear
                break
            end
        end
    else
        islinear=isLinear(objOrCon);
    end


    if islinear
        order="linear";
    else
        order="quadratic";
    end

end