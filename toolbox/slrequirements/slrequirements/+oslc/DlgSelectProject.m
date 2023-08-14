classdef DlgSelectProject<handle



    properties
        callerDlg=[];
        projName='';
        contextName='';
        contextUri='';
        contexts={};
        showRecentContexts=false;
        localContextCount=0;
        doTestBrowser=false;
    end

    methods(Access='public',Hidden=true)

        function obj=DlgSelectProject()
            obj.callerDlg=ReqMgr.activeDlgUtil();
        end

        function dlgStruct=getDialogSchema(this)

            label_1.Type='text';
            label_1.Name=[' ',getString(message('Slvnv:oslc:PleaseSelectProjectFromList')),' '];

            projNameCombo.Type='combobox';
            projNameCombo.Name='';
            projNameCombo.Tag='SimulinkDNGPrjectCombo';

            projNames=sort(oslc.Project.getProjectNames());
            projNameCombo.Entries=[...
            {['<',getString(message('Slvnv:oslc:ProjectNotSpecified')),'>']};projNames];
            if isempty(this.projName)
                projNameCombo.Value=0;
            else
                matchedIdx=find(strcmp(this.projName,projNames));
                if length(matchedIdx)==1
                    projNameCombo.Value=matchedIdx;
                else
                    projNameCombo.Value=0;
                    this.projName='';
                end
            end
            projNameCombo.ObjectMethod='DlgSelectProject_NameCombo_callback';
            projNameCombo.MethodArgs={'%dialog'};
            projNameCombo.ArgDataTypes={'handle'};

            label_2.Type='text';
            label_2.Name=[' ',getString(message('Slvnv:oslc:PleaseSelectContextFromList')),' '];
            label_2.Enabled=projNameCombo.Value>0;

            contextCombo.Type='combobox';
            contextCombo.Name='';
            contextCombo.Tag='SimulinkDNGContextCombo';
            if isempty(this.contexts)
                contextNames={};
            else
                contextNames=this.contexts(:,2);
            end
            contextCombo.Entries=[{['<',getString(message('Slvnv:oslc:ProjectContextNotSpecified')),'>']};contextNames];
            if this.showRecentContexts

                contextCombo.Entries{end+1,1}=getString(message('Slvnv:oslc:ClickForMore'));
            elseif numel(contextNames)>this.localContextCount

                sepMarker=getString(message('Slvnv:oslc:GlobalConfigsSeparator'));
                lastLocalContextIdx=this.localContextCount+1;
                contextCombo.Entries=[contextCombo.Entries(1:lastLocalContextIdx,1);sepMarker;contextCombo.Entries(lastLocalContextIdx+1:end,1)];
            end
            contextCombo.Values=(0:length(contextCombo.Entries)-1)';

            if isempty(this.contextName)
                contextCombo.Value=0;
            else
                matchedIdx=find(strcmp(this.contextName,contextNames));
                if length(matchedIdx)==1
                    contextCombo.Value=matchedIdx;
                else
                    contextCombo.Value=0;
                    this.contextName='';
                end
            end
            contextCombo.ObjectMethod='DlgSelectProject_ContextCombo_callback';
            contextCombo.MethodArgs={'%dialog'};
            contextCombo.ArgDataTypes={'handle'};
            contextCombo.Enabled=label_2.Enabled;

            dlgStruct.DialogTitle=getString(message('Slvnv:oslc:DngProject'));
            dlgStruct.LayoutGrid=[4,1];
            dlgStruct.Items={label_1,projNameCombo,label_2,contextCombo};
            dlgStruct.StandaloneButtonSet={'OK'};

            dlgStruct.PreApplyCallback='preApplyCallback';
            dlgStruct.PreApplyArgs={this,'%dialog'};
            dlgStruct.Sticky=true;

        end

        function[isValid,msg]=preApplyCallback(this,dlg)
            msg='';

            if this.doTestBrowser


                oslc.configure('');
                isValid=true;
                return;
            end




            idx=dlg.getWidgetValue('SimulinkDNGPrjectCombo');
            isValid=(idx>0);
            if isValid

                parentDlgH=this.callerDlg;
                if~isempty(parentDlgH)
                    parentSrc=parentDlgH.getSource;


                    project=oslc.Project.get(this.projName);
                    queryBase=project.queryBase;
                    projectDoc=[queryBase,' (',this.projName,')'];
                    parentDlgH.setWidgetValue('docEdit',projectDoc);
                    parentSrc.changeDocItem(parentDlgH);
                    parentDlgH.setEnabled('locEdit',true);
                else




                    oslc.manualSelectionLink(this.projName);
                end
            else
                msg=getString(message('Slvnv:oslc:PleaseMakeValidSelection'));
            end
        end

        function DlgSelectProject_NameCombo_callback(this,dlg)
            idx=dlg.getWidgetValue('SimulinkDNGPrjectCombo');
            if idx>0
                this.projName=dlg.getComboBoxText('SimulinkDNGPrjectCombo');





                rmiut.progressBarFcn('set',0.1,getString(message('Slvnv:oslc:ConnectingTo',this.projName)));
                project=oslc.Project.get(this.projName);
                this.contexts=project.getRecentContexts(true);
                this.localContextCount=size(this.contexts,1);
                this.showRecentContexts=true;
                currentContext=project.getContext();
                if~isempty(currentContext.uri)
                    this.contextUri=currentContext.uri;
                    this.contextName=currentContext.name;
                end
                rmiut.progressBarFcn('delete');
                dlg.refresh();
            end
        end

        function DlgSelectProject_ContextCombo_callback(this,dlg)
            idx=dlg.getWidgetValue('SimulinkDNGContextCombo');
            if idx>0
                rmiut.progressBarFcn('set',0.4,getString(message('Slvnv:oslc:CheckingConfigurations')));
                newValue=dlg.getComboBoxText('SimulinkDNGContextCombo');
                if strcmp(newValue,getString(message('Slvnv:oslc:ClickForMore')))
                    this.contexts=this.listAllContexts();
                    this.localContextCount=size(this.contexts,1);
                    if rmi.settings_mgr('get','oslcSettings','useGlobalConfig')
                        rmiut.progressBarFcn('set',0.6,getString(message('Slvnv:oslc:CheckingConfigurations')));
                        this.uppendGlobalContexts();
                    end
                    this.showRecentContexts=false;
                    dlg.refresh();
                elseif strcmp(newValue,getString(message('Slvnv:oslc:GlobalConfigsSeparator')))
                    this.contextName='';
                    this.contextUri='';
                    dlg.setWidgetValue('SimulinkDNGContextCombo',0);
                elseif~strcmp(newValue,this.contextName)
                    if idx>this.localContextCount
                        idx=idx-1;
                    end
                    project=oslc.Project.get(this.projName);


                    project.setContext(this.contexts{idx,:});
                    this.contextName=newValue;
                    this.contextUri=this.contexts{idx,1};
                end
                rmiut.progressBarFcn('delete');
            end
        end

        function sortedContexts=listAllContexts(this)
            allContexts=this.contexts;
            project=oslc.Project.get(this.projName);
            [streams,baselines,changesets]=project.getAllConfigurations();
            if isempty(allContexts)
                knownContexts=containers.Map();
            else
                knownContexts=containers.Map(allContexts(:,1),allContexts(:,2));
            end

            for i=1:size(streams,1)


                if~isKey(knownContexts,streams{i,1})
                    allContexts(end+1,:)=streams(i,1:2);%#ok<AGROW>
                end
            end

            for i=1:size(baselines,1)
                if~isKey(knownContexts,baselines{i,1})
                    allContexts(end+1,:)=baselines(i,1:2);%#ok<AGROW>
                end
            end

            for i=1:size(changesets,1)
                if~isKey(knownContexts,changesets{i,1})
                    allContexts(end+1,:)=changesets(i,1:2);%#ok<AGROW>
                end
            end
            sortedContexts=this.sortByColumn(allContexts,2);
        end

        function uppendGlobalContexts(this)
            [globalNames,globalUrls]=oslc.matlab.DngClient.getGlobalConfigs(true);
            if~isempty(globalNames)
                sortedGlobal=this.sortByColumn([globalUrls,globalNames],2);
                this.contexts=[this.contexts;sortedGlobal];
            end
        end

        function sorted=sortByColumn(~,unsorted,colIdx)

            sortBy=lower(unsorted(:,colIdx));
            [~,sortIdx]=sort(sortBy);
            sorted=unsorted(sortIdx,:);
        end
    end
end