classdef(Abstract)ProblemImpl<matlab.mixin.CustomDisplay&matlab.mixin.internal.Scalar










    properties
        Description=''
    end


    properties(SetAccess=protected,GetAccess=public)
        Variables=struct([]);
    end


    methods
        show(prob);
        write(prob,varargin);
        options=optimoptions(prob,varargin);
        varIndexStruct=varindex(prob,varargin);
        problemStruct=prob2struct(prob,varargin);
        [autoSolver,validSolvers]=solvers(prob);
    end

    methods(Abstract)
        varargout=solve(prob,varargin);
    end


    methods



        function prob=set.Description(prob,desc)
            optim.internal.problemdef.mustBeCharVectorOrString(desc,'Description')
            prob.Description=desc;
        end

        function desc=get.Description(prob)
            desc=char(prob.Description);
        end

        function prob=set.ObjectivesStore(prob,expr)


            objectivesStoreWarning(prob,expr);

            if isempty(expr)

                expr=prob.getDefaultObjectives();
            end


            prob.ObjectivesStore=expr;

        end

        function prob=set.ConstraintsStore(prob,constr)










            probConstr=prob.ConstraintsStore;
            emptyProbConstr=isempty(probConstr);
            structProbConstr=isstruct(probConstr);
            assignStruct=isstruct(constr);

            if~emptyProbConstr&&xor(assignStruct,structProbConstr)
                warning(message(prob.MessageCatalogID+":OverwriteConstraints"));
            end

            if isempty(constr)
                constr=prob.getDefaultConstraints();
            end



            if isstruct(constr)
                fnames=fieldnames(constr);
                for i=1:numel(fnames)
                    thisconstr=constr.(fnames{i});
                    if~isempty(thisconstr)
                        constr.(fnames{i})=upcast(thisconstr);
                    end
                end
            else
                constr=upcast(constr);
            end


            prob.ConstraintsStore=constr;

        end

    end




    properties(Hidden,SetAccess=protected,GetAccess=public)
        ProblemImplVersion=1;
    end


    properties(Hidden,Access=protected)
ObjectivesStore
ConstraintsStore
        ProblemdefOptions=struct('FromSolve',false,'FunOnWorkers',true);
    end

    properties(Hidden)


        GeneratedFileFolder=[];


        Compiler=optim.internal.problemdef.compile.ProblemCompiler();
    end

    properties(Abstract,Constant,Hidden)

SupportedSolvers

SupportedGlobalSolvers

MessageCatalogID

ObjectivePtyName
ConstraintPtyName

IntegerSolvers

ObjectiveCompileName
DerivativeCompileName

SupportsGlobalSolvers
    end

    properties(Constant,Hidden)

        ValidDerivativeValues=["auto","auto-forward","auto-reverse","finite-differences"];
    end

    methods(Hidden,Abstract)


        [solvers,varargout]=getValidSolvers(prob,varargin);


        solver=determineSolver(prob,problemStruct,caller);



        ism=isObjectiveMax(prob);
    end

    methods(Hidden)

        function prob=ProblemImpl()
        end

        showproblem(prob);
        writeproblem(prob,varargin);


        prob=subsasgn(prob,s,expr)

        function val=getVariables(obj)
            val=obj.Variables;
        end

    end

    methods(Hidden)


        varargout=mapSolution(prob,x,fval,exitflag,output,lambda,solver,varargin);


        exitflag=mapExitflag(prob,fval,exitflag,solver,varargin);


        output=mapExitMessage(prob,fval,exitflag,output,varargin);


        function boundsExist=hasBounds(prob)

            boundsExist=false;
            varNames=fieldnames(prob.Variables);
            for i=1:length(varNames)

                thisLB=prob.Variables.(varNames{i}).LowerBound;
                thisUB=prob.Variables.(varNames{i}).UpperBound;
                boundsExist=any(isfinite(thisLB(:)))||any(isfinite(thisUB(:)));
                if boundsExist
                    break;
                end
            end
        end


        tf=hasIntegerConstraints(prob,problemStruct);

    end

    methods(Abstract,Hidden,Access=protected)



        probStruct=updateProbStruct(prob,caller,probStruct,solvername);


        [x,fval,exitflag,output,lambda]=callSolver(prob,probStruct);



        probStruct=compileObjectives(prob,probStruct,inMemory,useParallel,fcnName);



        probStruct=compileConstraints(prob,probStruct,inMemory,useParallel,fcnName);


        fvalOut=mapFvalSolution(prob,fvalIn);


        lambdaOut=mapLambdaSolution(prob,lambdaIn);




        checkForIncorrectDerivativeOption(prob,nvPairs,caller);



        useFinDiff=useFiniteDifferences(obj,probStruct);

    end

    methods(Static,Abstract,Hidden,Access=protected)



        expr=getDefaultObjectives();



        constr=getDefaultConstraints();



        objectivesOut=checkValidObjectives(objectivesIn);



        constraintsOut=checkValidConstraints(constraintsIn);



        cName=className();
    end

    methods(Hidden,Access=protected)



        displayReformulationMessage(prob,probStruct);


        probStruct=updateOptions(prob,probStruct);


        str=expand2str(prob,addBolding,wrapWidth);


        prob=makeVariablesList(prob);



        probStruct=compileVarInfo(prob,probStruct,x0);


        validateX0(prob,x0);


        [problemStruct,useParallel]=prob2structImpl(prob,caller,x0,...
        options,inMemory,useParallel,objectiveFilename,constraintFilename,...
        filePath,objectiveDerivative,constraintDerivative,userSetSolver,globalSolver)


        [sol,varargout]=solveImpl(prob,caller,varargin)


        options=setSolverGradientOptionsForAD(prob,options,probStruct,GradFieldName)


        varargout=mapSolverOutputs(prob,x,fval,exitflag,output,lambda,solver,varargin);


        ism=isMultiObjective(prob);

    end

    methods(Hidden,Access=protected)


        function objectivesStoreWarning(prob,obj)








            probObj=prob.ObjectivesStore;
            emptyProbObj=isempty(probObj);
            structProbObj=isstruct(probObj);
            assignStruct=isstruct(obj);

            if~emptyProbObj&&xor(assignStruct,structProbObj)
                MessageId="Overwrite"+prob.ObjectivePtyName;
                warning(message("optim_problemdef:ProblemImpl:"+MessageId));
            end
        end

    end




    methods(Hidden,Access=protected)


        function footer=getFooter(prob)

            showHelpLocation=class(prob)+"/show";
            [startTag,endTag]=optim.internal.problemdef.createHotlinks(...
            'helpPopup',showHelpLocation);


            footer=getString(message('optim_problemdef:ProblemImpl:FooterStr',...
            startTag,endTag));

            isFormatCompact=strcmp(get(0,'FormatSpacing'),'compact');%#ok



            if isFormatCompact&&~isscalar(prob)
                footer=sprintf('\n  %s',footer);
            else
                footer=sprintf('  %s',footer);
            end
            if~isscalar(prob)||~isFormatCompact
                footer=sprintf('%s\n',footer);
            end
        end


        displayScalarObject(obj);


        objectiveStr=expandVariableNames2str(prob,addBolding,varargin);

    end

    methods(Abstract,Hidden,Access=protected)



        dispStr=customizeObjectivesProperty(prob,dispStr);



        dispStr=customizeConstraintsProperty(prob,dispStr);



        groups=getCustomPropertyGroup(prob);


        objectiveStr=expandObjectives2str(prob,addBolding,varargin);


        constraintsStr=expandConstraints2str(prob,addBolding,varargin);

    end

    methods(Hidden,Access=private)


        writeDisplay2File(prob,defaultFilename,varargin)



        validValuesString=createValidDerivativeList(prob)

    end

    methods(Static)
        checkForJacobianMultiplyFcn(probStruct,solver,helpAnchor,problemClass)
    end

    methods(Hidden=true)
        function list=getSupportedSolvers(prob)
            if optim.internal.utils.hasGlobalOptimizationToolbox
                list=[prob.SupportedSolvers,prob.SupportedGlobalSolvers];
            else
                list=prob.SupportedSolvers;
            end
        end
    end


end
