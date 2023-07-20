function defineSignalBuilderUpgradeChecks()



    checkID='mathworks.design.Sigbldr.upgradeCheck';
    check=ModelAdvisor.Check(checkID);
    check.Title=DAStudio.message('Sigbldr:upgrade:upgradeCheckTitle');
    check.setCallbackFcn(@checkSignalBuilderBlocks,'None','StyleOne');
    check.CSHParameters.MapKey='ma.simulink';
    check.CSHParameters.TopicID=checkID;


    action=ModelAdvisor.Action;
    setCallbackFcn(action,@convertSignalBuilderBlocks);
    action.Name=DAStudio.message('Sigbldr:upgrade:upgradeActionName');
    action.Description=DAStudio.message('Sigbldr:upgrade:upgradeActionDesc');
    action.Enable=false;
    check.setAction(action);


    modelAdvisor=ModelAdvisor.Root;
    modelAdvisor.register(check);
end

function results=checkSignalBuilderBlocks(system)

    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
    resultStatus=false;
    mdladvObj.setCheckResultStatus(resultStatus);


    ft=ModelAdvisor.FormatTemplate('ListTemplate');


    blockList=findSignalBuilderBlocks(system);


    if isempty(blockList)

        resultStatus=true;
        ft.setSubTitle(DAStudio.message('Sigbldr:upgrade:upgradeCheckTitle'));
        ft.setSubResultStatusText(DAStudio.message('Sigbldr:upgrade:missingSigbldrBlocks'));
    else

        ft.setSubTitle(DAStudio.message('Sigbldr:upgrade:upgradeCheckTitle'));
        ft.setSubResultStatusText(DAStudio.message('Sigbldr:upgrade:foundSigbldrBlocks'));
        ft.setSubResultStatus('Warn');
        ft.setListObj(blockList);
        mdladvObj.setActionEnable(true);
    end
    mdladvObj.setCheckResultStatus(resultStatus);
    results=ft;
end

function results=convertSignalBuilderBlocks(taskobj)


    mdladvObj=taskobj.MAobj;
    system=bdroot(mdladvObj.System);


    blockList=findSignalBuilderBlocks(system);


    root=slroot;


    ft=ModelAdvisor.FormatTemplate('TableTemplate');
    ft.setColTitles({...
    DAStudio.message('Sigbldr:upgrade:tableColBlock'),...
    DAStudio.message('Sigbldr:upgrade:tableColResult'),...
    DAStudio.message('Sigbldr:upgrade:tableColDetails')...
    });
    for k=1:length(blockList)
        blk=char(blockList(k));


        [sysPath,blkPath]=fileparts(blk);
        root.set('CurrentSystem',sysPath);
        root.getCurrentSystem.set('CurrentBlock',blkPath);


        baseFileName=blkPath;
        if~isvarname(baseFileName)
            baseFileName=matlab.lang.makeValidName(baseFileName,'ReplacementStyle','hex','Prefix','d_');
            if~isvarname(baseFileName)
                ft.addRow({blockList(k),DAStudio.message('Sigbldr:upgrade:tableFailure'),...
                DAStudio.message('Sigbldr:upgrade:invalidBlockName',blkPath)});
                continue;
            end
        end


        dataFile=[baseFileName,'.mat'];
        newBaseFileName=baseFileName;
        usedNames={};
        limit=5;
        count=0;
        while exist(dataFile,'file')&&count<limit
            usedNames{end+1}=newBaseFileName;
            newBaseFileName=matlab.lang.makeUniqueStrings(baseFileName,usedNames);
            dataFile=[newBaseFileName,'.mat'];
            count=count+1;
        end
        if count>=limit&&exist(dataFile,'file')
            ft.addRow({blockList(k),DAStudio.message('Sigbldr:upgrade:tableFailure'),...
            DAStudio.message('Sigbldr:upgrade:dataFileExists',dataFile)});
            continue;
        end


        try
            [newHandle,~,~]=signalBuilderToSignalEditor(blk,'FileName',dataFile,'Replace',true);
            if isempty(newHandle)||newHandle<=0

                ft.addRow({blockList(k),DAStudio.message('Sigbldr:upgrade:tableFailure'),...
                DAStudio.message('Sigbldr:upgrade:invalidBlockHandle',newHandle)});
            else

                ft.addRow({blockList(k),DAStudio.message('Sigbldr:upgrade:tableSuccess'),...
                DAStudio.message('Sigbldr:upgrade:createdDataFile',['./',dataFile])});
            end
        catch ME

            ft.addRow({blockList(k),DAStudio.message('Sigbldr:upgrade:tableFailure'),ME.message});
        end
    end

    results=ft;
end

function blockList=findSignalBuilderBlocks(system)

    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);


    list=find_system(...
    system,...
    'LookInsideSubsystemReference','off',...
    'LookUnderMasks','all',...
    'MatchFilter',@Simulink.match.allVariants,...
    'MaskType','Sigbuilder block'...
    );
    blockList=mdladvObj.filterResultWithExclusion(list);
end