classdef(CaseInsensitiveProperties=true)SLDVCheck<ModelAdvisor.Check
    properties
        CheckCatalogPrefix;
        GuidelineID;

        blockFinderFcn;
        objectiveToFind;
        objectiveStatusToFind;
        optToRun;
    end

    methods
        function obj=SLDVCheck(checkID,options)
            mlock;
            obj=obj@ModelAdvisor.Check(checkID);


            obj.objectiveToFind=options.objectiveTypes;
            obj.optToRun=options.sldvOpts;
            if isfield(options,'objectiveStatus')
                obj.objectiveStatusToFind=options.objectiveStatus;
            else
                obj.objectiveStatusToFind=[];
            end

            if contains(checkID,'.sldv.')&&~contains(checkID,'.hism.')

                obj.setCallbackFcn(@(system)ModelAdvisor.SLDVCheck.SLDVCheckCallBackFcn(system),'SLDV','StyleOne');
                obj.SupportHighlighting=true;

                obj.CheckCatalogPrefix=options.MessageCatalog;

            else

                obj.blockFinderFcn=options.blockFinderFcn;

                parts=strsplit(checkID,'.');

                obj.GuidelineID=parts{end};
                standard=parts{end-1};

                obj.CheckCatalogPrefix=getCatalogPrefix(standard);

                obj.Title=DAStudio.message([obj.CheckCatalogPrefix,obj.GuidelineID,'_title']);
                obj.TitleTips=[DAStudio.message([obj.CheckCatalogPrefix,obj.GuidelineID,'_guideline']),newline,newline,DAStudio.message([obj.CheckCatalogPrefix,obj.GuidelineID,'_tip'])];
                obj.CSHParameters.MapKey=getCSHMapByStandard(standard);
                obj.CSHParameters.TopicID=checkID;
                obj.SupportHighlighting=true;
                obj.SupportExclusion=true;
                obj.Value=false;
                obj.SupportLibrary=false;

                obj.setCallbackFcn(@(system,checkObj)ModelAdvisor.SLDVCheck.CheckCallBackFcn(system,checkObj),'SLDV','DetailStyle');

            end
        end
    end

    methods(Hidden,Static)
        function CheckCallBackFcn(system,checkObj)


            ma=Simulink.ModelAdvisor.getActiveModelAdvisorObj();
            this=ma.ActiveCheck;

            violations=[];

            mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
            blocksToSearch=feval(this.blockFinderFcn,system);
            blocksToSearch=mdladvObj.filterResultWithExclusion(blocksToSearch);
            blocksToSearch2=strrep(blocksToSearch,'::',':');

            data=Sldv.ReportUtils.loadAndCheckSldvData(Advisor.SLDVCompileService.getInstance.getSLDVData());

            if isempty(data.Objectives)
                mdladvObj.setCheckResultStatus(true);
                checkObj.setResultDetails(Advisor.Utils.createResultDetailObjs('',...
                'IsViolation',false,...
                'Description',DAStudio.message([this.CheckCatalogPrefix,this.GuidelineID,'_tip']),...
                'Status',DAStudio.message([this.CheckCatalogPrefix,this.GuidelineID,'_pass'])));
                mdladvObj.setActionEnable(false);
                return;
            end
            if iscell(this.objectiveToFind)
                violating_objs=data.Objectives(contains({data.Objectives(:).type},{this.objectiveToFind{:}}));
            else
                violating_objs=data.Objectives(contains({data.Objectives(:).type},this.objectiveToFind));
            end
            objToChk={};
            indx=[];
            for i=1:numel(violating_objs)
                model_obj=data.ModelObjects(violating_objs(i).modelObjectIdx);
                objSid=model_obj.designSid;
                if~ismember(objSid,blocksToSearch)&&~ismember(objSid,blocksToSearch2)
                    continue;
                end

                if(contains(violating_objs(i).status,'Falsified')||contains(violating_objs(i).status,'Dead Logic'))
                    if strcmp(model_obj.typeDesc,'Script')
                        indices=[violating_objs(i).linkInfo.startIdx,violating_objs(i).linkInfo.endIdx];

                        if(~ismember(objSid,objToChk))||...
                            (ismember(objSid,objToChk)&&~all(ismember(indices,indx)))
                            indx=[indx;indices];%#ok<AGROW>
                            objToChk{end+1}=objSid;%#ok<AGROW>
                            vObj=ModelAdvisor.ResultDetail;
                            vObj.Description=DAStudio.message([this.CheckCatalogPrefix,this.GuidelineID,'_tip']);
                            vObj.Status=DAStudio.message([this.CheckCatalogPrefix,this.GuidelineID,'_warn']);
                            vObj.RecAction=DAStudio.message([this.CheckCatalogPrefix,this.GuidelineID,'_rec_action']);
                            objHdl=Simulink.ID.getHandle(objSid);
                            ml_Script=get(objHdl,'Script');
                            expression=regexprep(strtrim(ml_Script(indices(1):indices(2))),';$','');
                            ModelAdvisor.ResultDetail.setData(vObj,'SID',objSid,...
                            'Expression',expression,'TextStart',violating_objs(i).linkInfo.startIdx,'TextEnd',violating_objs(i).linkInfo.endIdx);
                            violations=[violations;vObj];%#ok<AGROW>
                        end
                    else
                        if~ismember(objSid,objToChk)
                            objToChk{end+1}=objSid;%#ok<AGROW>
                            vObj=ModelAdvisor.ResultDetail;
                            vObj.Description=DAStudio.message([this.CheckCatalogPrefix,this.GuidelineID,'_tip']);
                            vObj.Status=DAStudio.message([this.CheckCatalogPrefix,this.GuidelineID,'_warn']);
                            vObj.RecAction=DAStudio.message([this.CheckCatalogPrefix,this.GuidelineID,'_rec_action']);
                            ModelAdvisor.ResultDetail.setData(vObj,objSid);
                            violations=[violations;vObj];%#ok<AGROW>
                        end
                    end
                elseif contains(violating_objs(i).status,'Undecided')
                    vObj=ModelAdvisor.ResultDetail;
                    ModelAdvisor.ResultDetail.setData(vObj,objSid);
                    vObj.Description=DAStudio.message([this.CheckCatalogPrefix,this.GuidelineID,'_tip']);
                    vObj.Status=DAStudio.message('ModelAdvisor:engine:SLDVUndecided');
                    vObj.RecAction=DAStudio.message('ModelAdvisor:engine:SLDVUndecidedRecAction');
                    violations=[violations;vObj];%#ok<AGROW>
                end
            end

















            if isempty(violations)
                mdladvObj.setCheckResultStatus(true);
                checkObj.setResultDetails(Advisor.Utils.createResultDetailObjs('',...
                'IsViolation',false,...
                'Description',DAStudio.message([this.CheckCatalogPrefix,this.GuidelineID,'_tip']),...
                'Status',DAStudio.message([this.CheckCatalogPrefix,this.GuidelineID,'_pass'])));
                mdladvObj.setActionEnable(false);
            else
                mdladvObj.setActionEnable(true);
                mdladvObj.setCheckResultStatus(false);
                checkObj.setResultDetails(violations);
            end


        end

        function res=SLDVCheckCallBackFcn(system)

            mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
            this=mdladvObj.ActiveCheck;

            modelName=bdroot(system);
            catalogue=this.CheckCatalogPrefix;
            objectiveType=this.objectiveToFind;
            objectiveStatus=this.objectiveStatusToFind;

            isDLCheck=any(strcmpi(objectiveType,'any'))&&strcmpi(objectiveStatus,'Dead Logic');

            [result,status,msg]=Advisor.SLDVCompileService.getInstance.getSLDVData();


            mainTbl=createTable([catalogue,':SetInformation'],mdladvObj.System);
            numErrs=0;
            haveUndecidedObjectives=false;
            if status==1||status==-1
                setColumnTitles(mainTbl,isDLCheck);

                data=Sldv.ReportUtils.loadAndCheckSldvData(result);
                errDetails=cell(1,100);
                for i=1:length(data.Objectives)
                    objective=data.Objectives(i);

                    if~isDLCheck&&~any(strcmp(objective.type,objectiveType))
                        continue;
                    end

                    mdlObject=data.ModelObjects(objective.modelObjectIdx);

                    if contains(objective.status,'Undecided')
                        haveUndecidedObjectives=true;
                        continue;
                    end

                    if(~isDLCheck&&contains(objective.status,'Falsified'))||...
                        (isDLCheck&&strcmpi(objective.status,'Dead Logic'))

                        sid='';
                        if isfield(mdlObject,'designSid')
                            sid=mdlObject.designSid;
                        end
                        if isempty(sid)
                            sid=mdlObject.descr;
                        end
                        if isempty(objective.linkInfo)
                            modelItem=sid;
                        else
                            modelItem=ModelAdvisor.Text(mdlObject.descr);
                            link=Sldv.ReportUtils.externalLink(sid,mdlObject.descr,...
                            modelName,false,[],objective.linkInfo);
                            modelItem.setHyperlink(link.url);
                        end

                        if isDLCheck
                            txt=objective.descr;
                        else


                            txt=ModelAdvisor.Text(getString(message(...
                            'Sldv:ModelAdvisor:Runtime_Error_Detection:ViewTestCase')));







                            if strcmp(objective.status,'Falsified - No Counterexample')
                                txt.Content=getString(message('Sldv:KeyWords:NA'));
                            else
                                url=['matlab:sldvprivate(''sldvadvRuntimeErrDetectionViewTestCase'', ''harness'',',''''...
                                ,result,'''',', ''',system,''', ',num2str(objective.testCaseIdx),');'];
                                txt.setHyperlink(url);
                            end
                        end

                        numErrs=numErrs+1;
                        errDetails{numErrs}={objective.type,modelItem,txt};
                    end
                end
                errDetails(numErrs+1:end)=[];


                if status==1&&numErrs==0&&~haveUndecidedObjectives


                    makeStatusPassed(mdladvObj,mainTbl,[catalogue,':NoErrorsFound'],mdladvObj.System);
                elseif numErrs>0


                    makeStatusWarn(mdladvObj,mainTbl,numErrs,...
                    [catalogue,':Result'],[catalogue,':TableDescription'],...
                    errDetails,mdladvObj.System);
                end
            else

                isPartiallyCompatible=util_parse_IncompatMsg_to_HTML(msg,...
                mainTbl,modelName);
                mainTbl.setSubResultStatus('fail');
                if isPartiallyCompatible
                    mainTbl.setTableTitle(getString(...
                    message('Sldv:ModelAdvisor:Compatibility:PartiallyCompatTableDescription')));
                    mainTbl.setSubResultStatusText(getString(...
                    message('Sldv:ModelAdvisor:Runtime_Error_Detection:ResultPartiallyCompatible',...
                    mdladvObj.System)));
                    if~isempty(sldvprivate('configcomp_get',get_param(bdroot(system),'Handle')))


                        if strcmp(get_param(bdroot(system),'DVAutomaticStubbing'),'off')

                            cfgDialogPath='Design Verifier';
                            link2ConfigSet=sprintf('<a href="matlab:modeladvisorprivate(''openSimprmAdvancedPage'',''%s'',''%s'')">%s</a>'...
                            ,bdroot,cfgDialogPath...
                            ,getString(message('Sldv:dialog:sldvDVOptionAutoStub')));
                            mainTbl.setRecAction(getString(...
                            message('Sldv:ModelAdvisor:Compatibility:OpenDVConfigParam',...
                            link2ConfigSet)))
                        end
                    else


                        recActionStr=getString(...
                        message('Sldv:ModelAdvisor:Compatibility:OpenDVConfigParam',...
                        getString(message('Sldv:dialog:sldvDVOptionAutoStub'))));
                        mainTbl.setRecAction(recActionStr)
                    end
                else
                    mainTbl.setTableTitle(getString(...
                    message('Sldv:ModelAdvisor:Compatibility:IncompatTableDescription')));
                    mainTbl.setSubResultStatusText(getString(...
                    message('Sldv:ModelAdvisor:Compatibility:ResultIncompatible',...
                    mdladvObj.System)));
                end
                mdladvObj.setCheckErrorSeverity(2);
                mdladvObj.setCheckResultStatus(false);
            end

            res={mainTbl};

            if haveUndecidedObjectives
                undecidedTable=ModelAdvisor.FormatTemplate('TableTemplate');
                undecidedTable.setSubResultStatus('warn');
                undecidedTable.setSubResultStatusText(...
                getString(message('Sldv:ModelAdvisor:Runtime_Error_Detection:UndecidedObjectives')));
                undecidedTable.setTableTitle(getString(message([catalogue,':TableDescription'])));
                undecidedTable.setRecAction({getString(message([catalogue,':RecommendedAction']))});
                res{end+1}=undecidedTable;
            end
            if status==-1

                undecidedTable=ModelAdvisor.FormatTemplate('TableTemplate');
                undecidedTable.setSubResultStatus('warn');
                cfgDialogPath='Design Verifier';
                link2ConfigSet=sprintf('<a href="matlab:modeladvisorprivate(''openSimprmAdvancedPage'',''%s'',''%s'')">%s</a>',...
                bdroot,cfgDialogPath,getString(message(...
                'Sldv:ModelAdvisor:Runtime_Error_Detection:MaxAnalysisTime')));
                undecidedTable.setSubResultStatusText(...
                getString(message('Sldv:ModelAdvisor:Runtime_Error_Detection:TimedOut',...
                link2ConfigSet)));
                undecidedTable.setTableTitle(getString(message([catalogue,':TableDescription'])));
                res{end+1}=undecidedTable;
            end


            if status~=0

                txt=ModelAdvisor.Text(getString(message('Sldv:ModelAdvisor:Runtime_Error_Detection:ResultsSummary')));
                url=['matlab:sldvprivate(''sldvadvRuntimeErrDetectionResSummary'', '''...
                ,modelName,''', ''',result,''', true)'];
                txt.setHyperlink(url);
                p=ModelAdvisor.Paragraph();
                p.addItem(txt);
                res{end+1}=p;
            end


        end
    end

end

function prefix=getCatalogPrefix(standard)
    if strcmp(standard,'maab')
        prefix='ModelAdvisor:styleguide:';
    else
        prefix=['ModelAdvisor:',standard,':'];
    end
end

function map=getCSHMapByStandard(standard)
    if strcmp(standard,'jmaab')
        map='ma.mw.jmaab';
    else
        map=['ma.',standard];
    end
end

function bResult=isReported(sid,violations)
    bResult=~isempty(violations);
    if bResult
        bResult=ismember(sid,{violations.Data});
    end
end

function table=createTable(info,systemFullName)
    table=ModelAdvisor.FormatTemplate('TableTemplate');
    table.setInformation(getString(message(info,systemFullName)));
end



function[]=setColumnTitles(table,isDeadLogic)
    if~isDeadLogic
        table.setColTitles({...
        getString(message('Sldv:ModelAdvisor:Runtime_Error_Detection:Check')),...
        getString(message('Sldv:ModelAdvisor:Runtime_Error_Detection:ModelItem')),...
        getString(message('Sldv:ModelAdvisor:Runtime_Error_Detection:TestCase')),...
        });
    else
        table.setColTitles({...
        getString(message('Sldv:ModelAdvisor:Dead_Logic:ObjectiveType')),...
        getString(message('Sldv:ModelAdvisor:Dead_Logic:ModelItem')),...
        getString(message('Sldv:ModelAdvisor:Dead_Logic:ModelItemDescription')),...
        });
    end
end



function[]=updateTable(table,numFail,result,description,systemFullName)
    table.setSubResultStatus('warn');
    table.setSubResultStatusText(getString(message(result,numFail,systemFullName)));
    table.setTableTitle(getString(message(description)));
end



function[]=addToTable(table,errors)
    for i=1:length(errors)
        table.addRow(errors{i});
    end
end

function[]=makeStatusPassed(mdladvObj,table,msg,systemFullName)
    mdladvObj.setCheckResultStatus(true);
    table.setSubResultStatus('pass');
    table.setSubResultStatusText(getString(message(msg,systemFullName)));
end

function[]=makeStatusWarn(mdladvObj,mainTbl,numErrs,resultMsg,tableDescriptionMsg,errDetails,systemFullName)
    mdladvObj.setCheckResultStatus(false);
    updateTable(mainTbl,numErrs,resultMsg,tableDescriptionMsg,systemFullName);
    addToTable(mainTbl,errDetails);
end

function isPartiallyCompatible=util_parse_IncompatMsg_to_HTML(msg,htmlFormatTemplate,modelName)







    htmlFormatTemplate.setColTitles({...
    getString(message('Sldv:ModelAdvisor:Compatibility:ModelItem')),...
    getString(message('Sldv:ModelAdvisor:Compatibility:Message'))...
    })
    isPartiallyCompatible=false;
    for idx=1:length(msg)
        if length(msg)~=1&&strcmp(msg(idx).msgid,'SLDV:Compatibility:PartiallyCompatible')

            isPartiallyCompatible=true;
        elseif length(msg)~=1&&strcmp(msg(idx).msgid,'SLDV:Compatibility:Generic')

        else
            messageStr=util_convert_SFPath(msg(idx).msg,modelName);
            messageStr=regexprep(messageStr,'\n+([^$])','<br>$1');
            if~isempty(msg(idx).objH)
                objPath=msg(idx).objH;
            else
                if~isempty(msg(idx).sourceFullName)
                    try
                        objPath=Simulink.ID.getSID(msg(idx).sourceFullName);
                    catch

                        objPath=msg(idx).sourceFullName;
                    end
                else
                    objPath=[];
                end
            end
            htmlFormatTemplate.addRow({objPath,messageStr})
        end
    end
end