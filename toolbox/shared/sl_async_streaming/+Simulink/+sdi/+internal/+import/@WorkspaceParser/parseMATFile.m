function ret=parseMATFile(this,fname,bpath)


    ret={};


    winfo=warning('off','all');
    tmp=onCleanup(@()warning(winfo));
    varInfo=load(fname);
    varNames=fieldnames(varInfo);
    numVars=length(varNames);
    delete(tmp);


    if numVars<1
        return
    end



    timeSource='';
    if numVars<2
        timeSource='MATFile';
    end


    vars(numVars)=struct('VarName','','VarValue',[],'VarBlockPath','','TimeSourceRule',timeSource);
    for idx=1:numVars
        vars(idx).VarName=varNames{idx};
        vars(idx).VarValue=varInfo.(varNames{idx});
        if nargin>2
            vars(idx).VarBlockPath=bpath;
        end
    end


    ret=parseVariables(this,vars);
end
