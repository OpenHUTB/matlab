function problemStruct=prob2struct(prob,varargin)



























    try
        [x0,objectiveFilename,constraintFilename,fileLocation,...
        objectiveDerivative,constraintDerivative,customerSolver]=iParseInputs(prob,varargin);
    catch ME
        throwAsCaller(ME);
    end



    inMemory=false;





    useParallel=false;



    options=[];


    globalSolver=[];


    problemStruct=prob2structImpl(prob,'prob2struct',x0,options,inMemory,useParallel,...
    objectiveFilename,constraintFilename,fileLocation,...
    objectiveDerivative,constraintDerivative,customerSolver,globalSolver);






    if isempty(problemStruct.options)&&~any(strcmp(problemStruct.solver,{'fzero','lsqnonneg','fminsearch','fminbnd'}))
        problemStruct.options=optimoptions(problemStruct.solver);
    end


    problemStruct=rmfield(problemStruct,...
    {'objectiveDerivative','constraintDerivative','setByUserOptions',...
    'SolveSetInitialX','SolveSetInitialObjConVals','derivativeFreeSolver'});

end

function[x0,objectiveFcnName,constraintFcnName,fileLocation,...
    objectiveDerivative,constraintDerivative,solver]=iParseInputs(prob,inputs)



    checkForIncorrectDerivativeOption(prob,inputs,"prob2struct");

    defaultX0=[];
    defaultObjectiveFcnName="generated"+prob.ObjectivePtyName;
    defaultConstraintFcnName="generated"+prob.ConstraintPtyName;
    defaultFileLocation="";
    defaultDerivative="auto";
    defaultSolver='';

    if nargin<2
        x0=defaultX0;
        objectiveFcnName=defaultObjectiveFcnName;
        constraintFcnName=defaultConstraintFcnName;
        fileLocation='';
        objectiveDerivative=defaultDerivative;
        constraintDerivative=defaultDerivative;
        solver=defaultSolver;
        return;
    end




    objectiveSingular=regexprep(prob.ObjectivePtyName,'(\w*)s','$1');
    objectiveOptionName=objectiveSingular+"FunctionName";
    constraintOptionName=regexprep(prob.ConstraintPtyName,'(\w*)s','$1')+"FunctionName";

    p=inputParser;

    ObjectiveDerivativeName=objectiveSingular+"Derivative";
    addOptional(p,'x0',defaultX0,@(s)validateX0(prob,s));
    addParameter(p,objectiveOptionName,defaultObjectiveFcnName,...
    @(s)iValidateFcnName(prob,s,objectiveOptionName));
    addParameter(p,constraintOptionName,defaultConstraintFcnName,...
    @(s)iValidateFcnName(prob,s,constraintOptionName));
    addParameter(p,'FileLocation',defaultFileLocation,@(s)iValidateFileLocation(s));
    addParameter(p,ObjectiveDerivativeName,defaultDerivative);
    addParameter(p,'ConstraintDerivative',defaultDerivative);
    addParameter(p,'Solver',defaultSolver,@(s)iValidateSolverName(prob,s));

    parse(p,inputs{:});

    x0=p.Results.x0;
    objectiveFcnName=string(p.Results.(objectiveOptionName));
    constraintFcnName=string(p.Results.(constraintOptionName));
    solver=p.Results.Solver;
    fileLocation=string(p.Results.FileLocation);
    lenFileLocation=strlength(fileLocation);
    if lenFileLocation>0
        lastEltFileLoc=extractAfter(fileLocation,lenFileLocation-1);
        if~strcmp(lastEltFileLoc,filesep)
            fileLocation=fileLocation+string(filesep);
        end
    else
        fileLocation=defaultFileLocation;
    end
    if strlength(objectiveFcnName)==0
        objectiveFcnName=defaultObjectiveFcnName;
    end
    if strlength(constraintFcnName)==0
        constraintFcnName=defaultConstraintFcnName;
    end



    objectiveDerivative=iValidateDerivative(prob,ObjectiveDerivativeName,p.Results.(ObjectiveDerivativeName));
    constraintDerivative=iValidateDerivative(prob,"ConstraintDerivative",p.Results.ConstraintDerivative);

end

function iValidateFcnName(prob,name,option)



    isEmptyName=isempty(name)||(isStringScalar(name)&&strlength(name)==0);
    if~isEmptyName&&~isvarname(name)
        error(prob.MessageCatalogID+':prob2struct:InvalidFcnName',...
        getString(message('optim_problemdef:ProblemImpl:prob2struct:InvalidFcnName',option)));
    end

end

function iValidateFileLocation(location)


    if isempty(location)||(isStringScalar(location)&&strlength(location)==0)
        return
    end



    if~matlab.internal.datatypes.isScalarText(location)
        error(message('MATLAB:string:MustBeStringScalarOrCharacterVector'));
    end


    if~exist(location,'dir')
        error('optim_problemdef:ProblemImpl:prob2struct:InvalidFileLocation',...
        getString(message('MATLAB:userpath:invalidInput')));
    end

end

function updatedDerivative=iValidateDerivative(prob,derivativeName,inputString)



    try
        updatedDerivative=validatestring(inputString,prob.ValidDerivativeValues);
    catch
        errmsg=message('optim_problemdef:ProblemImpl:solve:InvalidDerivativeInput',...
        derivativeName,createValidDerivativeList(prob));
        error(prob.MessageCatalogID+':prob2struct:InvalidDerivativeInput',getString(errmsg));
    end

end

function iValidateSolverName(prob,inputString)
    try
        validatestring(inputString,prob.getSupportedSolvers,'prob2struct','Solver');
    catch
        if ischar(inputString)||isstring(inputString)
            error(prob.MessageCatalogID+':prob2struct:InvalidSolver',...
            getString(message('optim_problemdef:ProblemImpl:solve:InvalidSolver',inputString)));
        else
            error(prob.MessageCatalogID+':prob2struct:InvalidSolverNameInput',...
            getString(message('optim_problemdef:ProblemImpl:solve:InvalidSolverNameInput')));
        end
    end
end
