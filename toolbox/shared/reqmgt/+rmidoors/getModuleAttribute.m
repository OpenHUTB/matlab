function str=getModuleAttribute(moduleIdStr,attribute,varargin)

    if nargin==3&&strcmp(varargin,'get')
        hDoors=rmidoors.comApp('get');
    else
        hDoors=rmidoors.comApp();
    end

    if isempty(hDoors)
        error(message('Slvnv:rmiref:DocCheckDoors:DoorsNotRunning'));
    end
    cmdStr=['dmiModuleGet_("',moduleIdStr,'","',attribute,'")'];
    rmidoors.invoke(hDoors,cmdStr);
    commandResult=hDoors.Result;

    if strncmp(commandResult,'DMI Error:',10)
        error(message('Slvnv:reqmgt:DoorsApiError',commandResult));

    else
        doEval=any(strcmpi(attribute,{'objectIDs','SlRefObjects','SlRefLinks','columns'}));
        if strcmpi(attribute,'last modified on')
            str=erase(commandResult,'HH:mm:ss ');
        elseif doEval
            str=eval(strrep(commandResult,char(10),' '));
        else
            str=commandResult;
        end
    end
end


