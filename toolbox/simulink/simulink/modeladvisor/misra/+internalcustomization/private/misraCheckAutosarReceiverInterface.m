








function misraCheckAutosarReceiverInterface
    rec=ModelAdvisor.Check('mathworks.misra.AutosarReceiverInterface');
    rec.Title=TEXT('AutosarReceiverInterface_Title');
    rec.TitleTips=TEXT('AutosarReceiverInterface_TitleTips');
    rec.Value=true;
    rec.SupportExclusion=true;
    rec.SupportLibrary=false;
    rec.CSHParameters.MapKey=getMisraCshMapKey();
    rec.CSHParameters.TopicID='mathworks.misra.AutosarReceiverInterface';
    rec.setCallbackFcn(@checkCallback,'None','StyleOne');
    rec.setLicense(misra_license());
    rec.HasANDLicenseComposition=false;

    mdladvRoot=ModelAdvisor.Root;
    mdladvRoot.publish(rec,'Embedded Coder');
end

function string=TEXT(ID)
    string=DAStudio.message(['RTW:misra:',ID]);
end

function RESULT=checkCallback(SYSTEM)

    RESULT={};

    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(SYSTEM);
    rootSystem=bdroot(SYSTEM);





    resultTable=ModelAdvisor.FormatTemplate('TableTemplate');
    resultTable.setCheckText(TEXT('AutosarReceiverInterface_CheckText'));
    resultTable.setColTitles({...
    TEXT('AutosarReceiverInterface_ResultColumn1'),...
    TEXT('AutosarReceiverInterface_ResultColumn2'),...
    TEXT('AutosarReceiverInterface_ResultColumn3'),...
    TEXT('AutosarReceiverInterface_ResultColumn4')});
    resultTable.setSubBar(false);





    justifiedTable=createJustifiedTable('AutosarReceiverInterface');





    if strcmp(get_param(rootSystem,'AutosarCompliant'),'off')
        mdladvObj.setCheckResultStatus(true);
        resultTable.setSubResultStatus('pass');
        resultTable.setSubResultStatusText(TEXT('AutosarReceiverInterface_TextPassNoAutosar'));
        RESULT{end+1}=resultTable;
        return;
    end
    mappingManager=get_param(rootSystem,'MappingManager');
    modelMapping=mappingManager.getActiveMappingFor('AutosarTarget');
    if~isa(modelMapping,'Simulink.AutosarTarget.ModelMapping')
        mdladvObj.setCheckResultStatus(true);
        resultTable.setSubResultStatus('pass');
        resultTable.setSubResultStatusText(TEXT('AutosarReceiverInterface_TextPassNoAutosar'));
        RESULT{end+1}=resultTable;
        return;
    end





    if~strcmp(SYSTEM,rootSystem)
        mdladvObj.setCheckResultStatus(true);
        resultTable.setSubResultStatus('pass');
        resultTable.setSubResultStatusText(TEXT('AutosarReceiverInterface_TextPass_NoRoot'));
        RESULT{end+1}=resultTable;
        return;
    end





    inportMapping=modelMapping.Inports;
    arInports={inportMapping.Block}';
    filteredInports=mdladvObj.filterResultWithExclusion(arInports);
    [~,index]=intersect(arInports,filteredInports);
    inportMapping=inportMapping(index);

    for i=1:numel(inportMapping)
        arPath=inportMapping(i).Block;
        arAccess=inportMapping(i).MappedTo.DataAccessMode;
        arPort=inportMapping(i).MappedTo.Port;
        arElement=inportMapping(i).MappedTo.Element;
        if needsStdReturnType(arAccess)
            match=false;
            for j=1:numel(inportMapping)
                if i~=j
                    arAccess2=inportMapping(j).MappedTo.DataAccessMode;
                    arPort2=inportMapping(j).MappedTo.Port;
                    arElement2=inportMapping(j).MappedTo.Element;
                    if strcmp(arAccess2,'ErrorStatus')&&...
                        strcmp(arPort,arPort2)&&...
                        strcmp(arElement,arElement2)
                        match=true;
                    end
                end
            end
            if~match
                justification=getPolyspaceJustification(arPath);
                is_D_04_07_justified=...
                misraIsJustifiedCorrectly(justification,'D4.7');
                is_R_17_07_justified=...
                misraIsJustifiedCorrectly(justification,'17.7');
                if is_D_04_07_justified&&is_R_17_07_justified
                    justifiedTable.addRow({...
                    arPath,...
                    'MISRA C:2012',...
                    justification.guidelines,...
                    justification.status,...
                    justification.severity,...
                    justification.comment});
                else
                    if isempty(arPort)
                        arPort=...
                        TEXT('AutosarReceiverInterface_NotMapped');
                    end
                    if isempty(arElement)
                        arElement=...
                        TEXT('AutosarReceiverInterface_NotMapped');
                    end
                    resultTable.addRow({arPath,arAccess,arPort,arElement});
                end
            end
        end
    end

    if size(resultTable.TableInfo,1)==0
        mdladvObj.setCheckResultStatus(true);
        resultTable.setSubResultStatus('pass');
        if size(justifiedTable.TableInfo,1)==0
            resultTable.setSubResultStatusText(...
            TEXT('AutosarReceiverInterface_TextPass'));
        else
            resultTable.setSubResultStatusText(...
            TEXT('AutosarReceiverInterface_TextPassWithAnnotation'));
        end
    else
        mdladvObj.setCheckResultStatus(false);
        resultTable.setSubResultStatus('warn');
        resultTable.setSubResultStatusText(TEXT('AutosarReceiverInterface_TextWarn'));
        resultTable.setRecAction(TEXT('AutosarReceiverInterface_RecommendedAction'));
    end

    RESULT{end+1}=resultTable;
    if size(justifiedTable.TableInfo,1)>0
        header=ModelAdvisor.Text(TEXT('Common_JustifiedBlocks'));
        header.IsBold=1;
        RESULT{end+1}=header;
        RESULT{end+1}=justifiedTable;
    end

end

function result=needsStdReturnType(arDataAccessMode)
    switch arDataAccessMode
    case 'ImplicitReceive',result=true;
    case 'ExplicitReceive',result=true;
    case 'QueuedExplicitReceive',result=false;
    case 'ErrorStatus',result=false;
    case 'ModeReceive',result=false;
    case 'IsUpdated',result=false;
    case 'EndToEndRead',result=true;
    case 'ExplicitReceiveByVal',result=false;
    otherwise,result=false;
    end
end

