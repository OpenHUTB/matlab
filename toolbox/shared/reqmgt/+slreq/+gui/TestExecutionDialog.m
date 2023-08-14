classdef TestExecutionDialog<handle




    properties
        runall=[];
    end

    properties(Access=private)
        dialogTitle;
        requirement;
        reqdata;
        dlghandle;
        allLinks;
        verifItems;
        unresolvedLinks;
        isRunning;
        resultmanager=[];
        providerRegistry=[];
        sourceIndexMap=containers.Map();
        progressbar;
    end

    properties(Constant,Hidden)
        simulinkicon='data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAACXBIWXMAAAsTAAALEwEAmpwYAAAAGXRFWHRTb2Z0d2FyZQBBZG9iZSBJbWFnZVJlYWR5ccllPAAAAOlJREFUeNrkktsNgkAQRUdiAZZgC4QGpAL9JOHLEqxAOyB2YAtWoAVAtBnej3XuZocsqyT+Gic5gWFn7jxYop+3he0EQaC+ScqybMxbuodpmk78pmkoz/OROI4n5x5XfTDruWpKqQmm0zHeY64MRDZu8jAM1LYtdV1Hfd9rjCF+pwV4nhM/QyZxk+u61gIChIwh/sgiydsOUEUqQwBgD/CtDsRW2AE6uDEHfJFlFUVBZVlqRER2YOLP3P0eO9gyPjv3TwJVVWmc6iHHX/Rv5BffPkEyRkACZkbrVmW5B8/ZexBFEf2ZvQQYAFEntRavCJdRAAAAAElFTkSuQmCC';
        testmanagericon='data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAIAAACQkWg2AAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAAJcEhZcwAADsMAAA7DAcdvqGQAAAEcSURBVDhPlZDLaoNAFED75UEJom669DtcdArWClGoLjq+H/hERBHUjYmLQCG2N1FIagM1BxcynHPn6tPhQc7B8yPMgef5fx/HcTHWNU2TZUUU3xF6/SewbecT4w9V3e3kN1F8QegarGf+aJqm4epbVFVVFEWSJEEQEEI8z4MD5hxwHPd9w+l0Oh6P+/2+67qqqrIsC4IAnDvBOI4syzIMQ1HUdrslCAIOoyhyXXcZfF2AwXD1ZJMkudlsIPB93zTNZTAMA7z0fX+56ReWZWGMlwGs27Zt0zR1XZdlmed5kiSwum3buq7fCUACiqIANU1T2Bs2gdmTfSeAeUAcx2EYguo4jmEYkzqxDDzPg18BHkxdqBPLYA3XYC2Hww/tPV69sPQ/cwAAAABJRU5ErkJggg==';
        LINK_TABLE_TAG='TEDLinkTable';
        RUN_TESTS_BUTTON_TAG='runAllButton';
        CLOSE_BUTTON_TAG='closeButton';
        STATUS_COL=3;
    end


    methods(Static)

        function onRunAllClick(~,source)





            timerObj=timer('TasksToExecute',2,'ExecutionMode','fixedRate','Period',0.1,'TimerFcn',' ');
            timerObj.StopFcn=@(~,~)source.runTests(timerObj);
            timerObj.start();
        end

        function onClose(dialog,~)
            src=dialog.getSource();
            src.dlghandle=[];


            slreq.app.MainManager.getInstance.notify('WakeUI');
        end

        function onHyperLinkClick(dialog,row,~,~)
            if row~=0

                dialogSourceObj=dialog.getDialogSource();
                dialogSourceObj.navigateToSource(row);
            end
            dialog.refresh();
        end

        function onTableCellClick(dialog,row,col,value)
            if(row==0)&(col==0)

                source=dialog.getSource();
                source.runall=value;
                dialog.refresh();

            elseif(col==0)


                source=dialog.getSource();
                source.evaluateTestSelection();
            end

        end

        function onCloseButtonClick(dialog,~)
            dialog.delete();


            slreq.app.MainManager.getInstance.notify('WakeUI');
        end
    end

    methods(Hidden)
        function show(this)


            [~,reason]=this.resultmanager.hasNecessaryVerificationProducts(this.allLinks);
            if~isempty(reason)
                messageStr=[{getString(message('Slvnv:slreq:BatchTestDialogErrorInstallLicense'))}...
                ,{getString(message('Slvnv:slreq:BatchTestDialogErrorTestFilteredOut'))}...
                ,{''}...
                ,reason.unavailableproducts...
                ];
                wd=warndlg(messageStr,'Warning','modal');
                waitfor(wd);
            end

            if isempty(this.dlghandle)
                this.dlghandle=DAStudio.Dialog(this);
            end
            this.dlghandle.show();
            this.dlghandle.resetSize(true);
            this.evaluateTestSelection();



            slreq.app.MainManager.getInstance.notify('SleepUI');
        end

        function refresh(this)
            if~isempty(this.dlghandle)
                this.dlghandle.refresh();
                this.evaluateTestSelection();
            end
        end

        function outhandle=getHandle(this)
            outhandle=this.dlghandle;
        end

        function selectedLinks=getSelectedLinks(this)
            selectedLinks=this.verifItems(this.checkLinks());
        end
    end

    methods
        function this=TestExecutionDialog(requirement)
            if isa(requirement,'slreq.data.RequirementSet')
                this.dialogTitle=getString(message('Slvnv:slreq:BatchTestDialogTitle',requirement.name,requirement.description));
            else
                this.dialogTitle=getString(message('Slvnv:slreq:BatchTestDialogTitle',requirement.index,requirement.summary));
            end
            this.requirement=requirement;

            this.reqdata=slreq.data.ReqData.getInstance();
            this.resultmanager=slreq.data.ResultManager.getInstance();
            this.isRunning=[];
        end

        function dialogStruct=getDialogSchema(this)
            linkList=this.makeLinkListTable();
            dialogStruct=struct('DialogTitle',this.dialogTitle...
            ,'DialogTag','TestExecutionDialog'...
            ,'LayoutGrid',[1,1]...
            ,'DialogStyle','framed');
            dialogStruct.EmbeddedButtonSet={''};
            dialogStruct.StandaloneButtonSet=this.makeButtonPanel(linkList);
            dialogStruct.Items={linkList};
            dialogStruct.CloseCallback='slreq.gui.TestExecutionDialog.onClose';
            dialogStruct.CloseArgs={'%dialog','%closeaction'};
        end
    end

    methods(Access=private)

        function buttonPanel=makeButtonPanel(this,linkList)



            runAllButton.Type='pushbutton';
            runAllButton.Name=getString(message('Slvnv:slreq:BatchTestDialogRunButton'));
            runAllButton.Tag=this.RUN_TESTS_BUTTON_TAG;
            runAllButton.Value='runAllButton';
            runAllButton.RowSpan=[1,1];
            runAllButton.ColSpan=[1,1];
            runAllButton.MatlabMethod='slreq.gui.TestExecutionDialog.onRunAllClick';
            runAllButton.MatlabArgs={'%dialog','%source'};
            if~isempty(this.runall)
                runAllButton.Enabled=this.runall;
            end
            if isempty(this.verifItems)||~isempty(this.isRunning)


                runAllButton.Enabled=false;
            else

                [~,runButtonStatus]=this.checkTestSelection(linkList);
                runAllButton.Enabled=runButtonStatus;
            end

            cancelButton.Type='pushbutton';
            cancelButton.Name=getString(message('Slvnv:slreq:Close'));
            cancelButton.Tag=this.CLOSE_BUTTON_TAG;
            cancelButton.RowSpan=[1,1];
            cancelButton.ColSpan=[2,2];
            cancelButton.MatlabMethod='slreq.gui.TestExecutionDialog.onCloseButtonClick';
            cancelButton.MatlabArgs={'%dialog','%source'};
            cancelButton.Enabled=isempty(this.isRunning);


            buttonPanel.Type='panel';
            buttonPanel.LayoutGrid=[1,2];
            buttonPanel.Items={runAllButton,cancelButton};
        end

        function linkList=makeLinkListTable(this)


            [items,tablesize]=this.maketabledata();
            if isempty(this.verifItems)






                linkList.Type='text';
                linkList.RowSpan=[2,2];
                linkList.ColSpan=[1,2];

                linkList.Tag=this.LINK_TABLE_TAG;
                linkList.Name=getString(message('Slvnv:slreq:BatchTestDialogNoTestsToRun'));
                linkList.MinimumSize=[500,300];
            else

                headerBackGroundColor=[230,230,235];
                selectAllCheckBox.Type='checkbox';
                if~isempty(this.runall)
                    selectAllCheckBox.Value=this.runall;
                end
                selectAllCheckBox.Tag='selectAllCheckBox';
                selectAllCheckBox.RowSpan=[1,1];
                selectAllCheckBox.ColSpan=[1,1];
                selectAllCheckBox.Enabled=~all(this.unresolvedLinks);
                selectAllCheckBox.BackgroundColor=headerBackGroundColor;

                headerTextTest.Type='text';
                headerTextTest.Name=getString(message('Slvnv:slreq:BatchTestDialogColumnTest'));
                headerTextTest.BackgroundColor=headerBackGroundColor;

                headerTextSource.Type='text';
                headerTextSource.Name=getString(message('Slvnv:slreq:BatchTestDialogColumnSource'));
                headerTextSource.BackgroundColor=headerBackGroundColor;

                headerTextStatus.Type='text';
                headerTextStatus.Name=getString(message('Slvnv:slreq:BatchTestDialogColumnTestStatus'));
                headerTextStatus.BackgroundColor=headerBackGroundColor;

                headerTextVerifies.Type='text';
                headerTextVerifies.Name=getString(message('Slvnv:slreq:BatchTestDialogColumnVerifies'));
                headerTextVerifies.BackgroundColor=headerBackGroundColor;

                headerRow={selectAllCheckBox,headerTextTest,headerTextSource,headerTextStatus,headerTextVerifies};


                linkList.Type='table';
                linkList.RowSpan=[2,2];
                linkList.ColSpan=[1,2];
                linkList.Editable=true;

                linkList.Tag=this.LINK_TABLE_TAG;
                linkList.Size=tablesize;
                linkList.Data=[headerRow;items];
                linkList.Graphical=true;
                linkList.MinimumSize=[500,300];
                linkList.HeaderVisibility=[0,0];
                linkList.ColumnStretchable=[0,1,1,1,1];
                linkList.ItemClickedCallback=@this.onHyperLinkClick;
                linkList.ValueChangedCallback=@this.onTableCellClick;
            end
        end

        function[thisbox,tablesize]=maketabledata(this)
            theseVerifItems=this.getListOfSourceItems();
            tablesize=[length(theseVerifItems)+1,5];
            thisbox=cell(tablesize);
            for i=1:length(theseVerifItems)

                iCheckbox.Type='checkbox';
                iCheckbox.Name='';
                iCheckbox.Tag=['linkCheck_',num2str(i)];
                iCheckbox.Enabled=true;




                if~isempty(this.runall)
                    iCheckbox.Value=this.runall;
                elseif strcmpi(theseVerifItems(i).status,getString(message('Slvnv:slreq:Unknown')))...
                    ||strcmpi(theseVerifItems(i).status,getString(message('Slvnv:slreq:Stale')))
                    iCheckbox.Value=true;
                else
                    iCheckbox.Value=false;
                end



                if this.unresolvedLinks(i)
                    iCheckbox.Enabled=false;
                    iCheckbox.Value=false;
                end


                iSourceItem.Type='hyperlink';
                iSourceItem.Name=theseVerifItems(i).srcStr;
                iSourceItem.ToolTip=theseVerifItems(i).srcTooltip;

                iSourceParent.Type='text';
                iSourceParent.Name=theseVerifItems(i).sourceParent;

                iStatus.Type='text';
                iStatus.Name=theseVerifItems(i).status;

                iVerifies.Type='text';
                iVerifies.Name=theseVerifItems(i).verifies;

                thisbox(i,:)={iCheckbox,iSourceItem,iSourceParent,iStatus,iVerifies};


                this.updateStatusMap(theseVerifItems(i).uuid,i);
            end
        end

        function sourceItems=getListOfSourceItems(this)


            isVerificationRollupType=@(link)slreq.app.LinkTypeManager.isa(...
            link.type,slreq.custom.LinkType.Verify,link.getLinkSet());
            getSourceID=@(source)source.getUuid();
            getSourceFromLinks=@(link)link.source;
            getDestination=@(link)link.dest;




            this.allLinks=slreq.data.ResultManager.getHierarchicalLinksForRequirement(this.requirement);
            isVerificationType=arrayfun(isVerificationRollupType,this.allLinks);
            allVerifLinks=this.allLinks(isVerificationType);


            sources=arrayfun(getSourceFromLinks,allVerifLinks,'UniformOutput',false);
            destinations=arrayfun(getDestination,allVerifLinks);


            hasResultProviders=cellfun(@this.hasResultProvider,sources);
            hasLicenses=cellfun(@this.hasLicense,sources);
            sources(~hasResultProviders|~hasLicenses)=[];
            destinations(~hasResultProviders)=[];

            sourcesIDs=cellfun(getSourceID,sources,'uniformoutput',false);





            [uniqsources,firsts,indices]=unique(sourcesIDs,'stable');

            uniqSrcObjects=arrayfun(@(x)sources(firsts(x)),1:length(uniqsources));

            this.verifItems=uniqSrcObjects;
            this.unresolvedLinks=false(1,length(this.verifItems));
            sourceItems=repmat(struct('srcStr',[]...
            ,'srcTooltip',[]...
            ,'sourceParent',[]...
            ,'hyperlink',[]...
            ,'domain',[]...
            ,'status',[]...
            ,'uuid',[]...
            ,'verifies',[])...
            ,1,length(this.verifItems));

            for i=1:length(this.verifItems)
                linkSrc=this.verifItems{i};
                caller='standalone';
                [~,parentName,~]=fileparts(linkSrc.artifactUri);
                sourceItems(i).sourceParent=parentName;
                [adapter,artifact,id]=linkSrc.getAdapter();
                sourceItems(i).srcStr=adapter.getSummary(artifact,id);
                sourceItems(i).srcTooltip=adapter.getTooltip(artifact,id);
                sourceItems(i).hyperLink=adapter.getClickActionCommandString(artifact,id,caller);

                if~adapter.isResolved(artifact,id)
                    sourceItems(i).sourceParent=getString(message('Slvnv:slreq:BatchTestDialogUnresolvedSource'));

                    this.unresolvedLinks(i)=true;
                end

                sourceItems(i).domain=linkSrc.domain;
                sourceItems(i).status=this.getVerificationItemStatus(linkSrc);
                sourceItems(i).uuid=linkSrc.getUuid();



                requirementItems=destinations(indices==i);
                requirementIDs=join(unique(arrayfun(@(d)d.index,requirementItems,'uniformoutput',false),'stable'),', ');
                sourceItems(i).verifies=requirementIDs{1};

            end

        end

        function status=getVerificationItemStatus(this,link)
            if isempty(this.resultmanager)
                this.resultmanager=slreq.data.ResultManager.getInstance();
            end

            statusObj=this.resultmanager.getResult(link);
            switch statusObj
            case slreq.verification.ResultStatus.Unknown
                status=getString(message('Slvnv:slreq:Unknown'));
            case slreq.verification.ResultStatus.Pass
                status=getString(message('Slvnv:slreq:Passed'));
            case slreq.verification.ResultStatus.Fail
                status=getString(message('Slvnv:slreq:Failed'));
            case slreq.verification.ResultStatus.Stale
                status=getString(message('Slvnv:slreq:Stale'));
            end
        end

        function tf=hasResultProvider(~,verificationitem)










            tf=~strcmp(verificationitem.domain,'linktype_rmi_slreq');
        end

        function tf=hasLicense(this,verificationitem)
            tf=false;
            if isa(verificationitem,'slreq.data.Link')
                domain=verificationitem.source.domain;
            else
                domain=verificationitem.domain;
            end
            switch domain
            case 'linktype_rmi_testmgr'
                tf=slreq.verification.TestManagerResultProvider.hasSTMLicenseAndInstallation();
            case 'linktype_rmi_matlab'

                tf=this.resultmanager.hasNecessaryVerificationProducts(verificationitem);
            case 'linktype_rmi_simulink'



                tf=this.resultmanager.hasNecessaryVerificationProducts(verificationitem);
            end
        end

        function out=checkLinks(this,linkList)
            out=false(1,length(this.verifItems));
            if nargin>1

                getCheckboxValueForList=@(item)item.Enabled;



                out=cellfun(getCheckboxValueForList,linkList.Data(1:end-1,1),'UniformOutput',true);
            elseif~isempty(this.dlghandle)

                getCheckboxValue=@(x)logical(str2double(this.dlghandle.getTableItemValue(this.LINK_TABLE_TAG,x,0)));
                out=arrayfun(getCheckboxValue,1:(length(this.verifItems)));
            end
        end

        function resetRunAll(this)
            this.runall=[];
        end

        function navigateToSource(this,row)
            linkSrc=this.verifItems{row};
            caller='standalone';
            [adapter,artifact,id]=linkSrc.getAdapter();
            adapter.onClickHyperlink(artifact,id,caller);
        end

        function runTests(this,timerObj)
            timerObj.delete();
            selectedLinkIndexes=this.checkLinks();
            this.isRunning=repmat(slreq.gui.RunStatus.Waiting,1,numel(this.verifItems));
            this.isRunning(~selectedLinkIndexes)=slreq.gui.RunStatus.NotNeeded;
            numToVerify=numel(find(this.isRunning==slreq.gui.RunStatus.Waiting));


            this.dlghandle.setEnabled(this.RUN_TESTS_BUTTON_TAG,false);
            this.dlghandle.setEnabled(this.CLOSE_BUTTON_TAG,false);

            slreq.utils.updateWaitBar('start',...
            getString(message('Slvnv:slreq:BatchTestDialogWaitbarRunningTests','')),...
            numToVerify);
            ensureWaitBarClearOnClose=onCleanup(@()slreq.utils.updateWaitBar('clear'));



            appmgr=slreq.app.MainManager.getInstance();
            resumeUpdateObj=appmgr.reqRoot.pauseUpdatesFromSTMEvents();


            resultManager=slreq.data.ResultManager.getInstance();
            resultManager.runVerification(this.getSelectedLinks(),this);


            delete(resumeUpdateObj);
            appmgr.reqRoot.refreshVerificationStatus();
            appmgr.update(true);


            this.dlghandle.setEnabled(this.RUN_TESTS_BUTTON_TAG,true);
            this.dlghandle.setEnabled(this.CLOSE_BUTTON_TAG,true);
            this.progressbar=[];
            this.isRunning=[];
        end

        function updateSpreadsheetStatus(this,index,status)
            this.dlghandle.setTableItemValue(this.LINK_TABLE_TAG,index,this.STATUS_COL,status);
        end

        function evaluateTestSelection(this)
            [selectAllStatus,runButtonStatus]=this.checkTestSelection();


            this.dlghandle.setTableItemValue(this.LINK_TABLE_TAG,0,0,num2str(selectAllStatus));


            this.dlghandle.setEnabled(this.RUN_TESTS_BUTTON_TAG,runButtonStatus);
        end

        function[selectAllStatus,runButtonStatus]=checkTestSelection(this,linkList)
            if nargin<2
                selectedLinkIndexes=this.checkLinks();
            else
                selectedLinkIndexes=this.checkLinks(linkList);
            end
            if all(this.unresolvedLinks)
                selectAllStatus=false;
            else
                selectAllStatus=all(selectedLinkIndexes|this.unresolvedLinks);
            end
            runButtonStatus=any(selectedLinkIndexes);
        end

        function updateStatusMap(this,sourceItemUUID,index)
            this.sourceIndexMap(sourceItemUUID)=index;
        end

        function updateProgressBar(~,updateMethod,currentArtifact)
            slreq.utils.updateWaitBar(updateMethod,...
            getString(message('Slvnv:slreq:BatchTestDialogWaitbarRunningTests',...
            currentArtifact))...
            ,true);
        end
    end
    methods(Access=?slreq.data.ResultManager)
        function markVerificationStatus(this,verifItem,status)


            index=this.sourceIndexMap(verifItem.getUuid());



            switch status
            case slreq.verification.ResultStatus.Unknown
                status=getString(message('Slvnv:slreq:Unknown'));
            case slreq.verification.ResultStatus.Pass
                status=getString(message('Slvnv:slreq:Passed'));
            case slreq.verification.ResultStatus.Fail
                status=getString(message('Slvnv:slreq:Failed'));
            case slreq.verification.ResultStatus.Stale
                status=getString(message('Slvnv:slreq:Stale'));
            end

            [~,artifactName,ext]=fileparts(verifItem.artifactUri);

            if status==slreq.verification.ResultStatus.Running
                status=getString(message('Slvnv:slreq:BatchTestDialogRunningTestStatus'));
                this.isRunning(index)=slreq.gui.RunStatus.Running;


                this.updateProgressBar('updateText',[artifactName,ext]);
            else
                this.isRunning(index)=slreq.gui.RunStatus.Finished;

                this.updateProgressBar('update',[artifactName,ext]);
            end


            this.updateSpreadsheetStatus(index,status);
        end
    end
end
