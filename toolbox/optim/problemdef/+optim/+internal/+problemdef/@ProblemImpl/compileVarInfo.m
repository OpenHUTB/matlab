function probStruct=compileVarInfo(prob,probStruct,x0Struct)





















    varStruct=prob.Variables;
    varNames=fieldnames(varStruct);
    nVarObjects=numel(varNames);


    probStruct.NumVars=0;
    probStruct.intcon=[];
    probStruct.lb=[];
    probStruct.ub=[];
    probStruct.x0=[];
    probStruct.subfun=struct;

    for k=1:nVarObjects

        thisVar=varStruct.(varNames{k});


        thisVarOffset=1+probStruct.NumVars;
        setOffset(thisVar,thisVarOffset);
        probStruct.NumVars=probStruct.NumVars+numel(thisVar);


        if strcmp(thisVar.Type,'integer')
            probStruct.intcon=[probStruct.intcon,thisVarOffset:probStruct.NumVars];
        end

        probStruct.lb=[probStruct.lb;thisVar.LowerBound(:)];
        probStruct.ub=[probStruct.ub;thisVar.UpperBound(:)];


        if~isempty(x0Struct)
            if isa(x0Struct,'optim.problemdef.OptimizationValues')
                numValues=numel(x0Struct);
                thisValue=x0Struct.(varNames{k});
                numVar=numel(prob.Variables.(varNames{k}));
                probStruct.x0=[probStruct.x0;reshape(thisValue,[numVar,numValues])];
            else
                probStruct.x0=[probStruct.x0;x0Struct.(varNames{k})(:)];
            end
        end
    end
