function tmpCell=cacheCurrentHighlightState(modelName)


















    tmpCell={};

    if Simulink.iospecification.InportProperty.checkModelName(modelName)

        [inportH,inportBlkPth,inportName,~,~]=...
        Simulink.iospecification.InportProperty.getInportProperties(modelName);


        [enableH,enableBlkPth,enableName,~]=...
        Simulink.iospecification.InportProperty.getEnableProperties(modelName);


        [triggerH,triggerBlkPth,triggerName,~]=...
        Simulink.iospecification.InportProperty.getTriggerProperties(modelName);


        [shadowH,shadowBlkPth,shadowName,~,~]=...
        Simulink.iospecification.InportProperty.getInportShadowProperties(modelName);

        allRootPortH=[inportH',enableH,triggerH,shadowH'];
        allRootPortNames=[inportName',enableName,triggerName,shadowName'];
        allBlkPathes=[inportBlkPth',enableBlkPth,triggerBlkPth,shadowBlkPth'];
        tmpCell=cell(1,length(allRootPortH));

        for kPort=1:length(allRootPortH)


            tmpVar.blockPath=allBlkPathes{kPort};


            tmpVar.hilite=get_param(allRootPortH{kPort},'HiliteAncestors');
            tmpVar.sid=Simulink.ID.getSID(allBlkPathes{kPort});

            tmpCell{kPort}=tmpVar;
        end




    end
