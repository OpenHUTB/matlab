function[deadLogicSummary,deadLogic]=prepareDeadLogic(~,data,createLink,justifiedInfo)




    if nargin==2
        createLink=1;
    end

    if nargin<4
        justifiedInfo.objectives=[];
        justifiedInfo.rationales=[];
    end

    deadLogic.items=buildObjectives(data,createLink,justifiedInfo);
    if(~isempty(deadLogic.items.designModel))
        deadLogic.help=helpQuickDeadLogic(data);
    else

        deadLogic={};
    end

    deadLogicSummary='';

    if~slfeature('SLDVCombinedDLRTE')
        deadLogicSummary=getSummaryForQuickDeadLogic(data);
    end
end

function deadLogic=buildObjectives(data,createLink,justifiedInfo)
    opts=data.AnalysisInformation.Options;
    props=find(opts.classhandle.properties,'accessflags.publicset','on',...
    'accessflags.publicget','on','visible','on',...
    'accessflags.serialize','on','Name','DetectDeadLogic');

    hasDeadLogic=strcmp(opts.Mode,'DesignErrorDetection')&&...
    ~isempty(props)&&strcmp(opts.DetectDeadLogic,'on');%#ok<NASGU>





    if isfield(data.ModelObjects,'modelScope')
        deadLogic=struct('designModel',[],'observerModel',[]);
    else
        deadLogic=struct('designModel',[]);
    end





    sectionToReport='designModel';

    header={...
    getString(message('Sldv:RptGen:Hash')),...
    getString(message('Sldv:RptGen:Type')),...
    getString(message('Sldv:RptGen:ModelItem')),...
    getString(message('Sldv:RptGen:Description'))};


    isXilData=Sldv.DataUtils.isXilSldvData(data);

    activeMcdcJustifiedAfterAnalysis=[];
    for idx=1:length(data.DeadLogic)
        dlInfo=data.DeadLogic(idx);


        if contains(dlInfo.label,{getString(message('Sldv:KeyWords:Excluded')),...
            getString(message('Sldv:KeyWords:Justified'))})
            continue;
        end

        if~isXilData


            dlInfos=Sldv.utils.updateDeadLogicDescriptionBasedOnFilter(dlInfo,...
            data,...
            justifiedInfo.objectives);
            activeMcdcJustifiedAfterAnalysis=[activeMcdcJustifiedAfterAnalysis,dlInfos(2:end)];%#ok<AGROW>
            makeTableRow(dlInfos(1),idx);
        else
            makeTableRow(dlInfo,idx);
        end
    end


    if~isempty(activeMcdcJustifiedAfterAnalysis)
        [~,uniqueIdxs]=unique([activeMcdcJustifiedAfterAnalysis.objectiveIdx]);
        activeMcdcJustifiedAfterAnalysis=activeMcdcJustifiedAfterAnalysis(uniqueIdxs);
        for idx=1:length(activeMcdcJustifiedAfterAnalysis)
            dlInfo=activeMcdcJustifiedAfterAnalysis(idx);
            makeTableRow(dlInfo,length(data.DeadLogic)+idx);
        end
    end

    deadLogic.(sectionToReport)=addHeader(header,deadLogic.(sectionToReport));


    function makeTableRow(dlInfos,idx)
        for locDlInfo=dlInfos
            mdlObj=data.ModelObjects(locDlInfo.modelObjIdx);

            tblRow=cell(1,4);

            tblRow(1,1)={num2str(idx)};
            tblRow(1,2)={sldvprivate('util_translate_ObjectiveType',locDlInfo.coverageType)};



            numModelObjects=numel(mdlObj);
            if numModelObjects>1
                tblRow{1,3}=cell(1,numModelObjects);
            end

            for mdlObjIdx=1:numModelObjects
                [sid,modelname]=Sldv.ReportUtils.getSidFromModelObjectData(data,mdlObj(mdlObjIdx));
                if isempty(sid)
                    sid=mdlObj(mdlObjIdx).descr;
                end



                if isempty(modelname)
                    modelname=Sldv.ReportUtils.getAnalyzedModelName(data);
                end

                itemDescrpt=Sldv.ReportUtils.itemDescriptWLink(mdlObj(mdlObjIdx),sid,modelname,[],createLink,isXilData);


                if numModelObjects==1
                    tblRow(1,3)=itemDescrpt;
                else
                    tblRow{1,3}(mdlObjIdx)=itemDescrpt;
                end
            end

            objDescript=Sldv.ReportUtils.styleStructCat([locDlInfo.descr,' '],Sldv.ReportUtils.styleStruct(locDlInfo.label,'bold'));
            tblRow(1,4)={objDescript};

            deadLogic.(sectionToReport)=cat(1,deadLogic.(sectionToReport),tblRow);
        end
    end

end

function deadLogicSummary=getSummaryForQuickDeadLogic(data)





    totalObjectives=getNumOfDecisionConditionObjective(data);
    deadLogicSummary={getString(message('Sldv:ReportUtils:prepareObjectives:NumberofObjectives')),num2str(totalObjectives)};
    label=[getString(message('Sldv:ReportUtils:prepareObjectives:DeadLogic')),': '];
    deadLogicSummary=cat(1,deadLogicSummary,{label,num2str(length(data.DeadLogic))});
end

function total=getNumOfDecisionConditionObjective(data)
    total=sum(strcmp({data.Objectives.type},'Decision'))+...
    sum(strcmp({data.Objectives.type},'Condition'))+...
    sum(strcmp({data.Objectives.type},'S-Function Decision'))+...
    sum(strcmp({data.Objectives.type},'S-Function Condition'));
end

function help=helpQuickDeadLogic(data)
    opts=data.AnalysisInformation.Options;
    help=Sldv.ReportUtils.getDeadLogicHelpText(opts);
    activeLogicDialogStr=getString(message('Sldv:dialog:sldvDesignErrPanelActiveLogic'));
    incompleteCheckWarning=getString(message('Sldv:ReportUtils:prepareObjectives:QuickDeadLogicIncompleteCheckWarning',...
    activeLogicDialogStr));
    help=[help,' ',incompleteCheckWarning];
end


function table=addHeader(header,table)
    if~isempty(table)
        table=cat(1,header,table);
    end
end
