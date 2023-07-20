function defineSFcnUpgradeChecks







    check=ModelAdvisor.Check('mathworks.design.CheckForSFcnUpgradeIssues');
    check.Title=DAStudio.message('Simulink:tools:MASFcnMexAnalyzerCheckTitle');
    check.TitleTips=DAStudio.message('Simulink:tools:MASFcnMexAnalyzerCheckTitleTips');
    check.setCallbackFcn(@ExecCheckSFcnMexUpgrade,'None','StyleOne');
    check.CallbackContext='PostCompile';
    check.CSHParameters.MapKey='ma.simulink';
    check.CSHParameters.TopicID='MATitleSFcnMexAnalyzerCheck';

    modelAdvisor=ModelAdvisor.Root;
    modelAdvisor.register(check);


end

function result=ExecCheckSFcnMexUpgrade(system)

    result={};
    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
    mdladvObj.setCheckResultStatus(false);

    model=bdroot(system);



    blockPaths=find_system(model,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'Type','Block');
    blockTypes=get_param(blockPaths,'BlockType');
    sfcnBlockHandles=get_param(blockPaths(strcmp(blockTypes,'S-Function')),'Handle');
    [mexNames,~,idxHandleFromMexName]=unique(cellfun(@(x)get_param(x,'FunctionName'),sfcnBlockHandles,'UniformOutput',false));

    diagStruct=cellfun(@(x)mex.internal.mexcheck([x,'.',mexext]),mexNames);

    ft=ModelAdvisor.FormatTemplate('TableTemplate');
    setCheckText(ft,DAStudio.message('Simulink:tools:MAInfoSFcnMexAnalyzerCheck'));
    hiliteMexFile=@(str)regexprep(str,arrayfun(@(x)"('[^']*\<"+x+"."+mexext+"')",mexNames),"<b>$1</b>");

    if(isempty(mexNames))
        mdladvObj.setCheckResultStatus(true);
        setSubResultStatus(ft,'Pass');
        setSubBar(ft,false);
        result{end+1}=ft;
        result{end+1}=ModelAdvisor.Paragraph(DAStudio.message('Simulink:tools:MANoUserSfunctions'));
    else
        summary=genReportMsg(diagStruct);
        flagHasError=any([diagStruct(:).has_error]==1);
        flagHasWarn=any([diagStruct(:).needs_upgrade]==1);
        if(~flagHasError&&~flagHasWarn)
            mdladvObj.setCheckResultStatus(true);
            setSubResultStatus(ft,'Pass');
            setSubResultStatusText(ft,DAStudio.message('Simulink:tools:MAPassSFcnMexAnalyzerCheck'));
            setSubBar(ft,false);
            result{end+1}=ft;
        else
            mdladvObj.setCheckResultStatus(false);
            if flagHasError
                mdladvObj.setCheckErrorSeverity(1);
            else
                mdladvObj.setCheckErrorSeverity(0);
            end

            for issue=summary
                [subTitle,subInfo,complaint]=lookupTitle(issue.id);
                if isempty(subTitle)
                    continue;
                end
                setSubTitle(ft,subTitle);
                setInformation(ft,subInfo);

                setColTitles(ft,{'Block Name','Issue'});
                for reason=issue.reasons


                    blockNames=lookupSFcnBlock(reason,mexNames,sfcnBlockHandles,idxHandleFromMexName);
                    for blockName=blockNames'
                        addRow(ft,{char(blockName),hiliteMexFile(char(reason))});
                    end
                end
                if~isempty(regexp(issue.id,"^E.*$","Match"))
                    setSubResultStatus(ft,'Fail');
                else
                    setSubResultStatus(ft,'Warn');
                end
                setSubResultStatusText(ft,complaint);
                setRecAction(ft,processAddtlAction(issue.action,issue.id));
                result{end+1}=ft;%#ok
                ft=ModelAdvisor.FormatTemplate('TableTemplate');
            end

            if~isempty(result)
                setSubBar(result{end},false);
            else


                mdladvObj.setCheckResultStatus(true);
                setSubResultStatus(ft,'Pass');
                setSubResultStatusText(ft,DAStudio.message('Simulink:tools:MAPassSFcnMexAnalyzerCheck'));
                setSubBar(ft,false);
                result{end+1}=ft;
            end
        end
    end
end

function blockNames=lookupSFcnBlock(reason,mexNames,sfcnBlockHandles,idxHandleFromMexName)
    aMexName=regexp(reason,"(?<='.*)\<[^/\\]*\>(?=\."+string(mexext)+"')","match");
    mskMexNames=strcmp(aMexName,mexNames);
    mskHandles=mskMexNames(idxHandleFromMexName);
    blockNames=cellfun(@(x)string(getfullname(x)),sfcnBlockHandles(mskHandles));
end

function[title,info,complaint]=lookupTitle(id)
    switch id
    case 'ENOEVER'
        title=DAStudio.message('Simulink:tools:MASubTitleENOEVER');
        info=DAStudio.message('Simulink:tools:MASubInfoENOEVER');
        complaint=DAStudio.message('Simulink:tools:MAComplaintENOEVER');
    case 'ELNKCPP'
        title=DAStudio.message('Simulink:tools:MASubTitleELNKCPP');
        info=DAStudio.message('Simulink:tools:MASubInfoELNKCPP');
        complaint=DAStudio.message('Simulink:tools:MAComplaintELNKCPP');
    case 'ELNKAPI'
        title=DAStudio.message('Simulink:tools:MASubTitleELNKAPI');
        info=DAStudio.message('Simulink:tools:MASubInfoELNKAPI');
        complaint=DAStudio.message('Simulink:tools:MAComplaintELNKAPI');
    case 'EVERAPI'
        title=DAStudio.message('Simulink:tools:MASubTitleEVERAPI');
        info=DAStudio.message('Simulink:tools:MASubInfoEVERAPI');
        complaint=DAStudio.message('Simulink:tools:MAComplaintEVERAPI');
    case 'EUNKAPI'
        title=DAStudio.message('Simulink:tools:MASubTitleEUNKAPI');
        info=DAStudio.message('Simulink:tools:MASubInfoEUNKAPI');
        complaint=DAStudio.message('Simulink:tools:MAComplaintEUNKAPI');
    case 'URECOMP'
        title=DAStudio.message('Simulink:tools:MASubTitleURECOMP');
        info=DAStudio.message('Simulink:tools:MASubInfoURECOMP');
        complaint=DAStudio.message('Simulink:tools:MAComplaintURECOMP');
    case 'ULATEST'
        title=DAStudio.message('Simulink:tools:MASubTitleULATEST');
        info=DAStudio.message('Simulink:tools:MASubInfoULATEST');
        complaint=DAStudio.message('Simulink:tools:MAComplaintULATEST');
    case 'UCOMPAT'
        title=DAStudio.message('Simulink:tools:MASubTitleUCOMPAT');
        info=DAStudio.message('Simulink:tools:MASubInfoUCOMPAT');
        complaint=DAStudio.message('Simulink:tools:MAComplaintUCOMPAT');
    case 'ULEGACY'
        title=DAStudio.message('Simulink:tools:MASubTitleULEGACY');
        info=DAStudio.message('Simulink:tools:MASubInfoULEGACY');
        complaint=DAStudio.message('Simulink:tools:MAComplaintULEGACY');
    case 'UENTRYP'
        title=DAStudio.message('Simulink:tools:MASubTitleUENTRYP');
        info=DAStudio.message('Simulink:tools:MASubInfoUENTRYP');
        complaint=DAStudio.message('Simulink:tools:MAComplaintUENTRYP');
    otherwise
        title='';
        info='';
        complaint='';
    end
end

function reportMessages=genReportMsg(diagStruct)

    msgStruct=sortBySeverity([diagStruct(:).messages]);
    msgStrcGrouped=groupByUniqueIDs(msgStruct);
    reportMessages=applyFilter(msgStrcGrouped,["ULATEST","URECOMP"]);

end

function msgStructOut=sortBySeverity(msgStructIn)




    [~,sortedIdx]=sort([msgStructIn.id]);
    msgStructOut=msgStructIn(sortedIdx);

end

function groupedStruct=groupByUniqueIDs(msgStruct)

    uniqID=unique([msgStruct.id]);
    groupedStruct=[];

    for i=1:numel(uniqID)
        msk=strcmp([msgStruct.id],uniqID(i));
        combinedReasons=[msgStruct(msk).reason];
        actions=[msgStruct(msk).action];
        commonAction=actions(1);
        combinedNames=sort(unique([msgStruct(msk).names]));
        tempStruct=struct('id',uniqID(i),'reasons',combinedReasons,'action',commonAction,'names',combinedNames);
        groupedStruct=[groupedStruct,tempStruct];%#ok
    end

end

function actionCharVec=processAddtlAction(issueAction,issueId)

    actionCharVec=char(issueAction);
    if strcmp(issueId,"UENTRYP")
        actionCharVec=[actionCharVec,' ',DAStudio.message('Simulink:tools:MAAddtlInfoUENTRYP')];
    end

end

function unfilteredMsgs=applyFilter(msgStruct,arrayFiltered)
    if nargin<2
        arrayFiltered=[""];%#ok: the arrayFiltered can be an array of string or cellArray of charArrays
    end
    filterMask=arrayfun(@(str)any(strcmp(str,arrayFiltered)),[msgStruct.id]);
    unfilteredMsgs=msgStruct(~filterMask);
end
