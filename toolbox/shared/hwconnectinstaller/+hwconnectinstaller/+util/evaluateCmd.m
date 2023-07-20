function[returnCmd,CmdOutput]=evaluateCmd(cmd,tokenMap,additionalInput)%#ok































    validateattributes(cmd,{'char'},{'nonempty'},'evaluateCmd','cmd');
    validateattributes(tokenMap,{'containers.Map'},{'nonempty'},...
    'evaluateCmd','tokenMap');
    if~exist('additionalInput','var')
        additionalInput=[];%#ok
    else
        validateattributes(additionalInput,{'struct','hwconnectinstaller.internal.ThirdPartyInfo'},{'nonempty'});
    end

    commandEvaluationErrorID='hwconnectinstaller:setup:CommandEvaluationError';
    wrongCommandErrorID='hwconnectinstaller:setup:WrongCmd';

    CmdOutput=[];
    [mlst,mlend]=regexp(cmd,...
    '\<matlab:','start','end');

    if~isempty(mlst)

        fstr=cmd(mlend+1:end);
        fstr=replaceTokens(fstr,tokenMap);
        customMap=containers.Map('\$\(3PINFO\)','additionalInput');
        fstr=replaceTokens(fstr,customMap);
        splitfstr=regexp(fstr,'=','split');
        if(numel(splitfstr)==1)
            try
                eval([fstr,';']);
            catch ME
                error(message(commandEvaluationErrorID,fstr,ME.message));
            end
        elseif(numel(splitfstr)==2)
            try
                CmdOutput=eval([splitfstr{2},';']);
            catch ME
                error(message(commandEvaluationErrorID,fstr,ME.message));
            end
        else
            error(message(wrongCommandErrorID,fstr));
        end
        returnCmd=['matlab:',fstr];
    else

        cmd=replaceTokens(cmd,tokenMap);
        [status,msg]=hwconnectinstaller.internal.systemExecute(cmd);
        if(status~=0)
            error(message(commandEvaluationErrorID,cmd,msg));
        end
        returnCmd=cmd;
    end
end

function str=replaceTokens(str,tokenMap)
    if tokenMap.Count>0
        keys=tokenMap.keys();

        values=tokenMap.values(keys);
        str=regexprep(str,keys,values);
    end
end

