function varargout=fcn2optimexpr(func,varargin)









    narginchk(1,inf);


    if~isa(func,'function_handle')
        throwAsCaller(MException('shared_adlib:fcn2optimexpr:FirstArgNotFcnHdl',...
        getString(message('shared_adlib:fcn2optimexpr:FirstArgNotFcnHdl'))));
    end




    try
        nFcnInputs=nargin(func);
    catch ME





        if strcmp(ME.identifier,'MATLAB:narginout:doesNotApply')
            nFcnInputs=-1;
        else
            throwAsCaller(ME);
        end
    end


    nout=max(1,nargout);





    pnames={'Analysis','Display','OutputSize','ReuseEvaluation'};
    dflts={'on','off',[],false};
    partialMatchPriority=[0,0,0,0];
    [NumVars,Analysis,Display,OutputSize,ReuseEvaluation,supplied]...
    =matlab.internal.datatypes.reverseParseArgs(pnames,dflts,partialMatchPriority,varargin{:});


    fcnInputs=varargin(1:NumVars);

    validateFcnInputs(fcnInputs,nFcnInputs);


    warnIfAmbiguousParamName(fcnInputs,pnames)


    [OutputSize,Display,Analysis]=validateOptionalParameters(Analysis,Display,OutputSize,ReuseEvaluation,supplied,nout);


    [varargout{1:nout}]=createFunctionExpression(func,...
    fcnInputs,supplied,Analysis,Display,OutputSize,ReuseEvaluation);

end




function cellSz=checkSizes(cellSz,nout)

    if~iscell(cellSz)


        cellSz={cellSz};
    end
    nSizes=numel(cellSz);
    if nSizes<1
        throwAsCaller(MException('shared_adlib:fcn2optimexpr:OutputSizeEmptyCell',...
        getString(message('shared_adlib:fcn2optimexpr:OutputSizeEmptyCell'))));
    elseif nSizes==1

        cellSz=repmat(cellSz,1,nout);
    elseif nSizes>nout
        throwAsCaller(MException('shared_adlib:fcn2optimexpr:OutputSizeCellTooManyElts',...
        getString(message('shared_adlib:fcn2optimexpr:OutputSizeCellTooManyElts'))));
    elseif nSizes<nout
        throwAsCaller(MException('shared_adlib:fcn2optimexpr:OutputSizeCellTooFewElts',...
        getString(message('shared_adlib:fcn2optimexpr:OutputSizeCellTooFewElts'))));
    end


    for i=1:nSizes
        szI=cellSz{i};


        if~isnumeric(szI)
            throwAsCaller(MException('shared_adlib:fcn2optimexpr:OutputSizeNotNumeric',...
            getString(message('shared_adlib:fcn2optimexpr:OutputSizeNotNumeric'))));
        end


        if numel(szI)<2
            throwAsCaller(MException('shared_adlib:fcn2optimexpr:OutputSizeNotEnoughElts',...
            getString(message('MATLAB:getReshapeDims:sizeVector'))));
        end


        if~isrow(szI)
            throwAsCaller(MException('shared_adlib:fcn2optimexpr:OutputSizeNotRowVector',...
            getString(message('MATLAB:checkDimRow:rowSize'))));
        end


        if any(szI<0)
            throwAsCaller(MException('shared_adlib:fcn2optimexpr:OutputSizeMustBeNonnegative',...
            getString(message('MATLAB:checkDimCommon:nonnegativeSize'))));
        end


        if~isreal(szI)
            throwAsCaller(MException('shared_adlib:fcn2optimexpr:OutputSizeNotReal',...
            getString(message('MATLAB:checkDimCommon:complexSize'))));
        end


        if any(~isfinite(szI))||any(floor(szI)~=szI)
            throwAsCaller(MException('shared_adlib:fcn2optimexpr:OutputSizeNotInteger',...
            getString(message('MATLAB:checkDimRow:rowSize'))));
        end

    end

end

function varargout=createFunctionExpression(func,inputs,supplied,...
    Analysis,Display,OutputSize,ReuseEvaluation)









    nOutputs=nargout;
    varargout=cell(1,nOutputs);

    if strcmpi(Analysis,"on")

        try

            [varargout{:}]=optim.internal.problemdef.ast.staticAnalysis(func,inputs);
            success=true;
            successStr="Success";
        catch

            success=false;
            successStr="Fail";
        end

        assignmentError=false;
        if~success

            try
                [varargout{:}]=func(inputs{:});
                success=true;
                successStr="Success";
            catch ME
                success=false;
                successStr="Fail";


                if strcmpi(ME.identifier,'MATLAB:UnableToConvert')
                    assignmentError=true;
                end
            end
        end


        if strcmpi(Display,"on")
            msg=getString(message("shared_adlib:fcn2optimexpr:Analysis"+successStr));
            disp(msg);
            if assignmentError

                [startTag,endTag]=optim.internal.problemdef.createHotlinks(...
                'doc','initialize_problem_based','normal',true);
                disp(getString(message('shared_adlib:fcn2optimexpr:PossibleAssignmentIntoDouble',startTag,endTag)));
            end
        end



        if success&&supplied.OutputSize&&...
            any(~cellfun(@(expr,sz)isequal(size(expr),sz),varargout,OutputSize))
            warning(message('shared_adlib:fcn2optimexpr:IgnoreOutputSize'));
        end

        if success


            varargout=cellfun(@optim.problemdef.OptimizationExpression.wrapNumeric,...
            varargout,'UniformOutput',false);
            return;
        end
    end





    if~supplied.OutputSize
        evalOut=cell(1,nOutputs);
        try


            evalInputs=cellfun(@generateInputPoint,inputs,'UniformOutput',false);
            [evalOut{:}]=func(evalInputs{:});
        catch userFcn_ME

            optim_ME=MException(message('shared_adlib:fcn2optimexpr:FcnError'));
            userFcn_ME=addCause(userFcn_ME,optim_ME);
            rethrow(userFcn_ME);
        end
        OutputSize=cellfun(@size,evalOut,'UniformOutput',false);
    end


    [optimFunc,vars,depth]=optim.internal.problemdef.FunctionWrapper.createFunctionWrapper(func,inputs,nOutputs,ReuseEvaluation);


    type=optim.internal.problemdef.ImplType.Nonlinear;


    for i=1:nOutputs
        outputi=optim.problemdef.OptimizationExpression();

        outputi=createFunction(outputi,optimFunc,vars,depth,OutputSize{i},type,i);
        varargout{i}=outputi;
    end

end



function evalArg=generateInputPoint(arg)
    if~isa(arg,'optim.problemdef.OptimizationExpression')

        evalArg=arg;
    else



        vars=getVariables(arg);

        initPt=vars;
        varnames=fieldnames(vars);


        for i=1:numel(varnames)

            name=varnames{i};
            thisVar=vars.(name);





            varValue=ones(size(thisVar))+eps;

            lb=thisVar.LowerBound;
            ub=thisVar.UpperBound;
            finiteLb=isfinite(lb);
            finiteUb=isfinite(ub);
            bothFinite=finiteLb&finiteUb;
            finiteLb=finiteLb&~bothFinite;
            finiteUb=finiteUb&~bothFinite;

            varValue(finiteLb)=lb(finiteLb)+max(1,abs(lb(finiteLb)))*eps;
            varValue(finiteUb)=ub(finiteUb)-max(1,abs(ub(finiteUb)))*eps;
            varValue(bothFinite)=(lb(bothFinite)+ub(bothFinite))/2+((ub(bothFinite)-lb(bothFinite))/2)*eps;

            if strcmpi(thisVar.Type,'integer')
                varValue=ceil(varValue);
            end

            initPt.(name)=varValue;
        end
        evalArg=evaluate(arg,initPt);
    end

end

function validateFcnInputs(inps,nFcnInputs)

    FCNHASFIXEDINPUTS=nFcnInputs>-1;
    if FCNHASFIXEDINPUTS&&length(inps)>nFcnInputs
        throwAsCaller(MException('shared_adlib:fcn2optimexpr:TooManyFcnInputs',...
        getString(message('shared_adlib:fcn2optimexpr:TooManyFcnInputs',nFcnInputs,length(inps)))));
    end

end

function[OutputSize,Display,Analysis]=validateOptionalParameters(Analysis,Display,OutputSize,ReuseEvaluation,supplied,nOut)

    if supplied.Analysis
        try
            Analysis=validatestring(Analysis,["on","off"]);
        catch
            throwAsCaller(MException(message('shared_adlib:fcn2optimexpr:AnalysisNotScalarString')))
        end
    end

    if supplied.Display
        try
            Display=validatestring(Display,["on","off"]);
        catch
            throwAsCaller(MException(message('shared_adlib:fcn2optimexpr:DisplayNotScalarString')))
        end
    end

    if supplied.OutputSize
        try
            OutputSize=checkSizes(OutputSize,nOut);
        catch ME
            throwAsCaller(ME);
        end
    end

    if supplied.ReuseEvaluation

        try
            validateattributes(ReuseEvaluation,{'logical'},{'scalar'});
        catch
            throwAsCaller(MException(message('shared_adlib:fcn2optimexpr:ReuseEvaluationNotBoolean')));
        end
    end

end

function warnIfAmbiguousParamName(vars,pnames)



    for k=1:numel(vars)
        if matlab.internal.datatypes.isScalarText(vars{k})
            pNameMatch=strcmpi(vars{k},pnames);
            if any(pNameMatch)
                warning(message('shared_adlib:fcn2optimexpr:ParamNameAmbiguity',pnames{find(pNameMatch,1)}));
                break;
            end
        end
    end

end
