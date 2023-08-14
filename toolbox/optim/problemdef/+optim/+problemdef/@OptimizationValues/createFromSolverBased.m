function obj=createFromSolverBased(p,x,fval,cres)










    NumValues=size(x,1);


    [VariableNames,ObjectiveNames,ConstraintNames]=getQuantityNames(p);


    if nargin<4
        cres.ineqlin=[];
        cres.eqlin=[];
        cres.ineqnonlin=[];
        cres.eqnonlin=[];
    end
    if nargin<3
        fval=[];
    end


    cres.empty=[];


    conNamesByType=constraintNamesByType(p,ConstraintNames);


    [x,fval,cres]=checkEmptyData(NumValues,p,x,fval,cres,conNamesByType);


    idxVars=varindex(p);


    for i=1:numel(VariableNames)
        thisVar=VariableNames{i};
        thisIdx=idxVars.(thisVar);
        thisSize=size(p.Variables.(thisVar));
        valueStruct.(thisVar)=reshapePropertyValue(NumValues,x(:,thisIdx),thisSize);
    end


    if isstruct(p.Objective)
        for i=1:numel(ObjectiveNames)
            if isstruct(p.ObjectiveSense)
                thisObjSense=p.ObjectiveSense.(ObjectiveNames{i});
            else
                thisObjSense=p.ObjectiveSense;
            end
            if strncmpi(thisObjSense,"max",3)
                thisObjValue=-fval(:,i)';
            else
                thisObjValue=fval(:,i)';
            end
            valueStruct.(ObjectiveNames{i})=thisObjValue;
        end
    else
        thisSize=size(p.Objective);
        if strncmpi(p.ObjectiveSense,"max",3)
            thisObjValue=-fval;
        else
            thisObjValue=fval;
        end
        valueStruct.Objective=reshapePropertyValue(NumValues,thisObjValue,thisSize);
    end


    valueStruct=setConstraintDataByType(p,valueStruct,cres.empty,conNamesByType.empty,NumValues);
    valueStruct=setConstraintDataByType(p,valueStruct,cres.ineqlin,conNamesByType.linIneq,NumValues);
    valueStruct=setConstraintDataByType(p,valueStruct,cres.eqlin,conNamesByType.linEq,NumValues);
    valueStruct=setConstraintDataByType(p,valueStruct,cres.ineqnonlin,conNamesByType.nonlinIneq,NumValues);
    if isfield(cres,'eqnonlin')
        valueStruct=setConstraintDataByType(p,valueStruct,cres.eqnonlin,conNamesByType.nonlinEq,NumValues);
    end


    obj=optim.problemdef.OptimizationValues(p,valueStruct);

end


function[x,fval,cres]=checkEmptyData(NumValues,p,x,fval,cres,conNamesByType)


    if isempty(x)
        totalVars=sum(structfun(@numel,p.Variables));
        x=nan(NumValues,totalVars);
    end


    if isempty(fval)
        if isstruct(p.Objective)
            totalObj=numel(fieldnames(p.Objective));
        else
            totalObj=numel(p.Objective);
        end
        fval=nan(NumValues,totalObj);
    end


    if isempty(cres.ineqlin)
        cres.ineqlin=nan(NumValues,getNumCon(p,conNamesByType.linIneq));
    end
    if isempty(cres.eqlin)
        cres.eqlin=nan(NumValues,getNumCon(p,conNamesByType.linEq));
    end
    if isempty(cres.ineqnonlin)
        cres.ineqnonlin=nan(NumValues,getNumCon(p,conNamesByType.nonlinIneq));
    end
    if isfield(cres,'eqnonlin')&&isempty(cres.eqnonlin)
        cres.eqnonlin=nan(NumValues,getNumCon(p,conNamesByType.nonlinEq));
    end

end


function newVal=reshapePropertyValue(NumValues,thisVal,thisSize)


    if numel(thisSize)==2&&(any(thisSize==1)||all(thisSize==0))

        reshapeSize=[max(thisSize),NumValues];
    else

        reshapeSize=[thisSize,NumValues];
    end


    newVal=reshape(thisVal',reshapeSize);

end

function conNamesByType=constraintNamesByType(p,conNames)


    nLabelledCon=numel(conNames);
    isEmptyCon=false(1,nLabelledCon);
    isLinearIneq=false(1,nLabelledCon);
    isLinearEq=false(1,nLabelledCon);
    isNonlinearIneq=false(1,nLabelledCon);
    isNonlinearEq=false(1,nLabelledCon);
    for i=1:nLabelledCon


        if isstruct(p.Constraints)&&~isempty(p.Constraints)
            thisCon=p.Constraints.(conNames{i});
        else
            thisCon=p.Constraints;
        end


        if isempty(thisCon)
            isEmptyCon(i)=true;
            continue
        end


        rel=getRelation(thisCon);
        if isLinear(thisCon)
            if strcmp(rel,'==')
                isLinearEq(i)=true;
            else
                isLinearIneq(i)=true;
            end
        else
            if strcmp(rel,'==')
                isNonlinearEq(i)=true;
            else
                isNonlinearIneq(i)=true;
            end
        end

    end


    conNamesByType.empty=conNames(isEmptyCon);
    conNamesByType.linIneq=conNames(isLinearIneq);
    conNamesByType.linEq=conNames(isLinearEq);
    conNamesByType.nonlinIneq=conNames(isNonlinearIneq);
    conNamesByType.nonlinEq=conNames(isNonlinearEq);

end

function numCon=getNumCon(p,conNames)



    if isstruct(p.Constraints)&&~isempty(p.Constraints)
        numCon=0;
        for i=1:numel(conNames)
            numCon=numCon+numel(p.Constraints.(conNames{i}));
        end
    elseif~isempty(p.Constraints)
        numCon=numel(p.Constraints);
    else
        numCon=0;
    end

end

function valueStruct=setConstraintDataByType(p,valueStruct,cval,...
    ConstraintNames,NumValues)


    if isempty(ConstraintNames)
        return
    end


    if isstruct(p.Constraints)&&~isempty(p.Constraints)
        cumNumCon=0;
        for i=1:numel(ConstraintNames)
            idxStart=cumNumCon+1;
            cumNumCon=cumNumCon+numel(p.Constraints.(ConstraintNames{i}));
            idxEnd=cumNumCon;
            thisSize=size(p.Constraints.(ConstraintNames{i}));
            valueStruct.(ConstraintNames{i})=...
            reshapePropertyValue(NumValues,cval(:,idxStart:idxEnd)',thisSize);
        end
    else
        thisSize=size(p.Constraints);
        valueStruct.(ConstraintNames{1})=reshapePropertyValue(NumValues,cval,thisSize);
    end


end