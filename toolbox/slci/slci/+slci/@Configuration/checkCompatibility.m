function results=checkCompatibility(aObj,varargin)

































































































    aObj.ValidateProperties();
    topIsMdlRef=~aObj.getTopModel;
    results={};


    if(slcifeature('SlciLevel1Checks')==1)

        set_param(aObj.getModelName(),'SLCodeInspector','on');
    end



    if aObj.getFollowModelLinks()


        models=find_mdlrefs(aObj.getModelName(),'MatchFilter',@Simulink.match.internal.filterOutCodeInactiveVariantSubsystemChoices);
    else
        models={aObj.getModelName()};
    end

    pb=[];
    if aObj.fViaGUI
        pb=aObj.createCheckProgressBar();
    end

    checkdata=load('slciMAConf.mat');
    numModels=numel(models);
    numSubmodels=numModels-1;
    args=varargin;
    args{end+1}='treatAsMdlRef';
    args{end+1}='off';
    treatAsMdlRefFlags={};
    results={};

    for i=1:numSubmodels
        treatAsMdlRefFlags{end+1}='on';%#ok
    end
    if topIsMdlRef
        treatAsMdlRefFlags{end+1}='on';
    else
        treatAsMdlRefFlags{end+1}='off';
    end


    if aObj.getEnableParallel
        args{end}=treatAsMdlRefFlags;
        results=ModelAdvisor.run(models,checkdata.checks,args{:},'DisplayResults','None');


    else
        for i=1:numModels
            model=models{i};
            args{end}=treatAsMdlRefFlags{i};
            result=ModelAdvisor.run(model,checkdata.checks,args{:},'DisplayResults','None');
            if~isempty(result)
                results{end+1}=result{1};%#ok
            end
        end
    end

end

