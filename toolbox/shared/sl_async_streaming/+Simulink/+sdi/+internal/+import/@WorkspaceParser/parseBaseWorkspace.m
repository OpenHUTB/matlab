function ret=parseBaseWorkspace(this)




    varInfo=evalin('base','whos');
    ret={};
    if~isempty(varInfo)
        numVars=length(varInfo);
        vars(numVars)=struct('VarName','','VarValue',[]);
        for idx=1:numVars
            vars(idx).VarName=varInfo(idx).name;
            vars(idx).VarValue=evalin('base',varInfo(idx).name);
        end


        ret=parseVariables(this,vars);
    end
end
