function result=getTargetSuffix(model,token,stf)



    cfg=Simulink.fileGenControl('getConfig');
    switch char(cfg.CodeGenFolderStructure)
    case 'ModelSpecific'
        switch(token)
        case 'ModelCode'
            result=loc_getModelSpecificTopModelTargetSuffix(model,token,stf);
        case 'ModelReferenceCode'
            result=stf;
            return;
        otherwise
            assert(false,'unknown token specified');
        end
    case 'TargetEnvironmentSubfolder'
        fileSepToken=regexptranslate('escape',filesep);
        expr=['(\w+)',fileSepToken];
        result=loc_extractTargetSuffix(model,token,stf,expr);
    otherwise
        assert(false,'unknown code gen folder structure specified');
    end
end

function result=loc_getModelSpecificTopModelTargetSuffix(model,token,stf)

    defaultBuildDir=[model,'_',stf,'_rtw'];
    aBuildDir=Simulink.packagedmodel.getCoderBuildDir(model,token);
    if strcmp(aBuildDir,defaultBuildDir)
        result=stf;
        return;
    end


    expr=[model,'_?(\w+)$'];
    result=loc_extractTargetSuffix(model,token,stf,expr);
end

function result=loc_extractTargetSuffix(model,token,stf,expr)
    aBuildDir=Simulink.packagedmodel.getCoderBuildDir(model,token);
    result=regexp(aBuildDir,expr,'tokens');
    if isempty(result)
        result=stf;
    else
        result=result{1}{1};
    end
end