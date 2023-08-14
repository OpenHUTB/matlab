function MSVCBuild(obj)



    verobj=obj.ver;

    if isR2010aOrEarlier(verobj)

        modelName=obj.modelName;
        modelTMF=get_param(modelName,'TemplateMakefile');
        targetString=strtok(get_param(modelName,'SystemTargetFile'),'.');

        if strcmpi(modelTMF,'RTW.MSVCBuild')
            set_param(modelName,'TemplateMakefile',...
            strcat(targetString,'_default_tmf'));
        end

    end

