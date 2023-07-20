function emitLoadingErrorMsg(obj,modelName,msg)


%#ok<INUSL>
    stageObj=Simulink.output.Stage(getString(message('hdlcommon:workflow:ApplyModelSettings')),'ModelName',modelName,'UIMode',true);%#ok<NASGU>
    if~isempty(msg)
        if(obj.cliDisplay)
            throw(msg{1});
        else
            for i=1:length(msg)
                msle=MSLException(msg{i},'COMPONENT','HDLCoder','CATEGORY','HDL');
                MSLDiagnostic(msle).reportAsWarning;
            end
        end
    end
end
