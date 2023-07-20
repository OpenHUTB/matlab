function varInfo=getVariableInfo(vars)











    varNames=fieldnames(vars);
    varInfo.NumNamedVar=length(varNames);
    varInfo.Name=cell(1,varInfo.NumNamedVar);
    varInfo.StartIdx=zeros(1,varInfo.NumNamedVar);
    varInfo.EndIdx=zeros(1,varInfo.NumNamedVar);
    varInfo.NumVars=0;
    varInfo.Size=cell(1,varInfo.NumNamedVar);
    varInfo.IndexNames=cell(1,varInfo.NumNamedVar);


    if varInfo.NumNamedVar==0
        return
    end


    for i=1:varInfo.NumNamedVar


        varInfo.Name{i}=varNames{i};


        varInfo.Size{i}=size(vars.(varNames{i}));


        varInfo.IndexNames{i}=getIndexNames(vars.(varNames{i}));
    end



    numNamedVars=numel(vars.(varNames{1}));
    varInfo.StartIdx(1)=1;
    varInfo.EndIdx(1)=numNamedVars;
    setOffset(vars.(varNames{1}),1);
    varInfo.NumVars=numNamedVars;


    for i=2:varInfo.NumNamedVar


        numNamedVars=numel(vars.(varNames{i}));



        varInfo.StartIdx(i)=varInfo.EndIdx(i-1)+1;
        varInfo.EndIdx(i)=varInfo.EndIdx(i-1)+numNamedVars;


        setOffset(vars.(varNames{i}),varInfo.StartIdx(i));


        varInfo.NumVars=varInfo.NumVars+numNamedVars;
    end
end
