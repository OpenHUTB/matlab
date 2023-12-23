classdef MultithreadingAnalysisDDG<handle

    properties
SubsystemHandle
TopModelHandle
ModelRefPaths
Dialog
PerformanceInfo
AnalysisStage
    end


    methods
        function obj=MultithreadingAnalysisDDG(subsystemHandle,topModelHandle,modelRefPaths,performanceInfo)
            obj.SubsystemHandle=subsystemHandle;
            obj.TopModelHandle=topModelHandle;
            obj.ModelRefPaths=modelRefPaths;
            obj.PerformanceInfo=performanceInfo;
            obj.AnalysisStage=performanceInfo.AnalysisStage;
        end

        function show(obj,dialog)
            obj.Dialog=dialog;
            show(dialog);
        end

        function setFocus(obj)
            show(obj.Dialog);
        end

        function setSubsystemHandle(obj,subsystemHandle)
            obj.SubsystemHandle=subsystemHandle;
        end

        function refreshDialog(obj,performanceInfo)
            obj.PerformanceInfo=performanceInfo;
            obj.AnalysisStage=performanceInfo.AnalysisStage;
            refresh(obj.Dialog);
        end

        function analyzeButtonPushed(obj)
            pi=obj.PerformanceInfo;
            if~pi.ShowStopSimulationLink
                refreshData(obj);
            else
                set_param(obj.TopModelHandle,'SimulationCommand','stop');
            end
        end

        function applyLatencyButtonPushed(obj)
            set_param(obj.SubsystemHandle,'Latency',obj.PerformanceInfo.SuggestedLatencyStr);
            refreshData(obj);
        end

        function acceptParamButtonPushed(obj,param,value)
            set_param(obj.TopModelHandle,param,value);
            updateDialog(obj.PerformanceInfo.MultithreadingAnalysis);
        end

        function acceptAllParamButtonPushed(obj)
            params=obj.PerformanceInfo.OptimalModelSettings.Params;
            for i=1:size(params,1)
                set_param(obj.TopModelHandle,params{i,1},params{i,2});
            end
            updateDialog(obj.PerformanceInfo.MultithreadingAnalysis);
        end

        function helpButtonPushed(~)
            helpview(fullfile(docroot,'dsp','dsp.map'),'dataflowmultithreadinganalysis')
        end

        function propertyInspectorButtonPushed(obj)
            bp=Simulink.BlockPath({obj.ModelRefPaths{:},getfullname(obj.SubsystemHandle)});
            bp.open();
            set_param(gcb,'Selected','off');
            Simulink.DomainSpecPropertyDDG.openDomainPropertyInspector('Subsystem');
        end

        function closeCallback(obj)

            cache=dfs.analysis.InstanceCache.getInstance();
            remove(cache,obj.SubsystemHandle);
        end

        function closeDialog(obj)

            if ishandle(obj.Dialog)
                delete(obj.Dialog);
            end
        end

        function group=createModelSettingsGroup(obj)

            pi=obj.PerformanceInfo;
            params=pi.OptimalModelSettings.Params;

            acceptAllButtonEnabled=(~pi.OptimalModelSettings.AllOptimal)&&pi.ModelIsStopped;
            acceptAllButtonTooltip='';
            id='dataflow:MultithreadingAnalysis:AllParamButtonTooltipParam';
            for i=1:size(params,1)
                if acceptAllButtonEnabled
                    acceptAllButtonTooltip=[acceptAllButtonTooltip,newline,getString(message(id,params{i,1},params{i,2}))];
                else
                    acceptAllButtonTooltip=[acceptAllButtonTooltip,newline,params{i,1},' = ',params{i,2}];
                end
            end
            if acceptAllButtonEnabled
                acceptAllButtonTooltip=getString(message('dataflow:MultithreadingAnalysis:AllParamButtonEnabledTooltip',acceptAllButtonTooltip));
            else
                acceptAllButtonTooltip=getString(message('dataflow:MultithreadingAnalysis:AllParamButtonDisabledTooltip',acceptAllButtonTooltip));
            end

            acceptAllButton.Type='pushbutton';
            acceptAllButton.Tag='paramButtonAll';
            acceptAllButton.Name=getString(message('dataflow:MultithreadingAnalysis:AllParamButtonLabel'));
            acceptAllButton.ToolTip=acceptAllButtonTooltip;
            acceptAllButton.ObjectMethod='acceptAllParamButtonPushed';
            acceptAllButton.MethodArgs={};
            acceptAllButton.ArgDataTypes={};
            acceptAllButton.RowSpan=[1,1];
            acceptAllButton.ColSpan=[1,3];
            acceptAllButton.Enabled=acceptAllButtonEnabled;
            acceptAllButton.Alignment=4;



            acceptAllPanel.Type='panel';
            acceptAllPanel.Tag='acceptAllPanel';
            acceptAllPanel.LayoutGrid=[1,1];
            acceptAllPanel.Items={acceptAllButton};
            acceptAllPanel.Alignment=4;
            acceptAllPanel.RowSpan=[1,1];
            acceptAllPanel.ColSpan=[3,3];


            paramItems={};
            model=get_param(obj.TopModelHandle,'name');

            id='dataflow:MultithreadingAnalysis:ParamLabel';
            for i=1:size(params,1)


                labelTextHLink=getString(message(id,['<a href="matlab:configset.internal.open(''',model,''',''',params{i,1},''')">',params{i,1},'</a>'],params{i,2}));
                paramLabel.Type='text';
                paramLabel.Name=labelTextHLink;
                paramLabel.Tag=['paramLabel',params{i,1}];
                paramLabel.RowSpan=[i,i];
                paramLabel.ColSpan=[1,2];

                paramItems{end+1}=paramLabel;


                paramButtonEnabled=(~params{i,3})&&pi.ModelIsStopped;
                if paramButtonEnabled
                    acceptAllButtonTooltip=getString(message('dataflow:MultithreadingAnalysis:ParamButtonEnabledTooltip',params{i,1},params{i,2}));
                else
                    acceptAllButtonTooltip=getString(message('dataflow:MultithreadingAnalysis:ParamButtonDisabledTooltip',params{i,1}));
                end

                paramButton.Type='pushbutton';
                paramButton.Tag=['paramButton',params{i,1}];
                paramButton.ToolTip=acceptAllButtonTooltip;
                paramButton.Name='Accept';
                paramButton.ObjectMethod='acceptParamButtonPushed';
                paramButton.MethodArgs={params{i,1},params{i,2}};
                paramButton.ArgDataTypes={'string','string'};
                paramButton.RowSpan=[i,i];
                paramButton.ColSpan=[3,3];
                paramButton.Alignment=10;
                paramButton.Enabled=paramButtonEnabled;

                paramItems{end+1}=paramButton;
            end


            paramPanel.Type='panel';
            paramPanel.Tag='paramPanel';
            paramPanel.LayoutGrid=[1,1];
            paramPanel.Items=paramItems;
            paramPanel.Alignment=0;
            paramPanel.RowSpan=[1,1];
            paramPanel.ColSpan=[3,3];
            paramPanel.ContentsMargins=[0,14,0,0];

            paramTogglePanel.Type='togglepanel';
            paramTogglePanel.Name=getString(message('dataflow:MultithreadingAnalysis:ModelSettingsToggleLabel'));
            paramTogglePanel.Tag='paramTogglePanel';
            paramTogglePanel.RowSpan=[1,1];
            paramTogglePanel.ColSpan=[1,3];
            paramTogglePanel.LayoutGrid=[1,3];
            paramTogglePanel.Items={paramPanel};
            paramTogglePanel.Alignment=0;


            group.Type='group';
            group.Tag='SettingsGroup';
            group.LayoutGrid=[1,3];
            group.ColStretch=[1,1,1];
            group.Items={paramTogglePanel,acceptAllPanel};
        end

        function dialog=getDialogSchema(obj,~)
            info=createInfoContainer(obj);
            settings=createModelSettingsGroup(obj);
            group=createAnalysisGroup(obj);
            buttons=createButtonPanel(obj);
            dialog=createDialogWithItems(obj,info,settings,group,buttons);
        end
    end

    methods(Access=private)
        function refreshData(obj)
            cache=dfs.analysis.InstanceCache.getInstance();
            refreshData(cache,obj.SubsystemHandle);
        end

        function dialog=createDialogWithItems(obj,info,settings,data,buttons)
            subsystemName=getfullname(obj.SubsystemHandle);
            subsystemName=regexprep(subsystemName,'\s',' ');
            subsystemName=regexprep(subsystemName,'\s{2,}',' ');

            dialog.DialogTitle=getString(message('dataflow:MultithreadingAnalysis:DialogTitle',...
            subsystemName));
            dialog.IsScrollable=true;
            dialog.DialogStyle='normal';
            dialog.ExplicitShow=true;
            dialog.StandaloneButtonSet={''};
            dialog.CloseMethod='closeCallback';
            dialog.CloseMethodArgs={};
            dialog.CloseMethodArgsDT={};

            dialog.LayoutGrid=[4,2];
            dialog.RowStretch=[0,0,1,0];
            settings.RowSpan=[1,1];
            settings.ColSpan=[1,2];
            info.RowSpan=[2,2];
            info.ColSpan=[1,2];
            data.RowSpan=[3,3];
            data.ColSpan=[1,2];
            buttons.RowSpan=[4,4];
            buttons.ColSpan=[1,2];
            dialog.Items={info,settings,data,buttons};
        end

        function info=createInfoContainer(obj)
            description.Type='text';
            description.Tag='DescriptionText';
            description.Name=getString(message('dataflow:MultithreadingAnalysis:Description'));
            description.RowSpan=[1,1];
            description.ColSpan=[1,1];


            subsystemName=getfullname(obj.SubsystemHandle);
            subsystemName=regexprep(subsystemName,'\s',' ');
            subsystemName=regexprep(subsystemName,'\s{2,}',' ');
            if strlength(subsystemName)>35
                hlinkName=['...',subsystemName(strlength(subsystemName)-32:end)];
            else
                hlinkName=subsystemName;
            end

            piHLink.Type='hyperlink';
            piHLink.Name=hlinkName;
            piHLink.ToolTip=getString(message('dataflow:MultithreadingAnalysis:PropertyInspectorHyperlinkTooltip',subsystemName));
            piHLink.Tag='PropertyInspectorLink';
            piHLink.ObjectMethod='propertyInspectorButtonPushed';
            piHLink.MethodArgs={};
            piHLink.ArgDataTypes={};
            piHLink.RowSpan=[1,1];
            piHLink.ColSpan=[2,2];
            piHLink.Alignment=1;
            piHLink.ForegroundColor=[1,1,1];

            descriptionPanel.Type='panel';
            descriptionPanel.Tag='DescriptionPanel';
            descriptionPanel.LayoutGrid=[1,2];
            descriptionPanel.ColStretch=[0,1];
            descriptionPanel.Items={description,piHLink};
            descriptionPanel.RowSpan=[1,1];
            descriptionPanel.ColSpan=[1,1];

            progressPanel=createProgressPanel(obj);
            progressPanel.RowSpan=[3,3];
            progressPanel.ColSpan=[1,2];

            infoPanel.Type='panel';
            infoPanel.Tag='InfoPanel';
            infoPanel.LayoutGrid=[3,2];
            infoPanel.Items={descriptionPanel,progressPanel};

            info=infoPanel;
        end

        function group=createAnalysisGroup(obj)

            threads.Type='text';
            threads.Name=getString(message('dataflow:MultithreadingAnalysis:ThreadsLabel',obj.PerformanceInfo.ThreadsStr));
            threads.Tag='ThreadCount';
            threads.RowSpan=[2,2];
            threads.ColSpan=[1,1];

            latency.Type='text';
            latency.Name=getString(message('dataflow:MultithreadingAnalysis:LatencyLabel',obj.PerformanceInfo.CurrentLatencyStr));
            latency.ToolTip=getString(message('dataflow:MultithreadingAnalysis:LatencyTooltip'));
            latency.Tag='CurrentLatency';
            latency.RowSpan=[1,1];
            latency.ColSpan=[1,1];

            suggested.Type='text';
            suggested.Name=getString(message('dataflow:MultithreadingAnalysis:SuggestedLabel',obj.PerformanceInfo.SuggestedLatencyStr));
            suggested.ToolTip=getString(message('dataflow:MultithreadingAnalysis:SuggestedTooltip'));
            suggested.Tag='SuggestedLatency';
            suggested.RowSpan=[1,1];
            suggested.ColSpan=[2,2];

            pi=obj.PerformanceInfo;

            accept.Type='pushbutton';
            accept.Tag='AcceptLatencyButton';
            accept.Name=getString(message('dataflow:MultithreadingAnalysis:AcceptLatencyButtonLabel'));
            accept.ToolTip=getString(message('dataflow:MultithreadingAnalysis:AcceptLatencyButtonTooltip'));
            accept.ObjectMethod='applyLatencyButtonPushed';
            accept.MethodArgs={};
            accept.ArgDataTypes={};
            accept.RowSpan=[1,1];
            accept.ColSpan=[3,3];
            accept.Enabled=pi.ModelIsStopped&&pi.ValidData&&(pi.CurrentLatency~=pi.SuggestedLatency);
            accept.Alignment=7;

            feedback.Type='textbrowser';
            feedback.Tag='FeedbackMessage';
            feedback.Editable=false;
            feedback.RowSpan=[3,3];
            feedback.ColSpan=[1,3];
            feedback.PreferredSize=[460,150];
            feedback.Alignment=0;


            msg=strrep(pi.Message,'<','&lt;');
            msg=strrep(msg,newline,'<br/>');

            if pi.ShowDiagnosticViewerErrorLink||pi.ShowDiagnosticViewerWarningLink
                modelName=getfullname(bdroot(obj.SubsystemHandle));
                if pi.ShowDiagnosticViewerErrorLink
                    linkText=getString(message('dataflow:MultithreadingAnalysis:DiagnosticViewerErrorLink'));
                else
                    linkText=getString(message('dataflow:MultithreadingAnalysis:DiagnosticViewerWarningLink'));
                end
                html=['<a href="matlab:eval(''dfs.analysis.openMessageViewer(''''',modelName,''''')'');">','',linkText,'</a>'];
                feedback.Text=[msg,' ',html];
            else

                feedback.Text=[msg,'<div />'];
            end

            items={threads,latency,suggested,accept,feedback};
            layoutGrid=[3,3];
            rowStretch=[0,0,1];
            colStretch=[1,1,1];

            group.Type='group';
            group.Name=getString(message('dataflow:MultithreadingAnalysis:AnalysisGroupLabel'));
            group.Tag='AnalysisGroup';
            group.LayoutGrid=layoutGrid;
            group.RowStretch=rowStretch;
            group.ColStretch=colStretch;
            group.Items=items;
        end


        function panel=createProgressPanel(obj)
            pi=obj.PerformanceInfo;

            profileStartOffset=pi.ProgressState.ProfileStartOffset;
            profileProgess=pi.ProgressState.ProfilePercentage;
            profileBar=getProgressBar(obj,profileStartOffset,profileProgess,'ProgressProf');
            profileBar.RowSpan=[1,3];
            profileBar.ColSpan=[2,3];
            profileBar.Tag='ProgressProfileBar';

            partProgess=pi.ProgressState.PartitionPercentage;
            partBar=getProgressBar(obj,0,partProgess,'ProgressPart');
            partBar.RowSpan=[1,3];
            partBar.ColSpan=[4,5];
            partBar.Tag='ProgressPartitionBar';

            checkLabel.Type='text';
            checkLabel.Name=getString(message('dataflow:MultithreadingAnalysis:ProgressCheckLabel'));
            checkLabel.RowSpan=[4,4];
            checkLabel.ColSpan=[1,2];
            checkLabel.Alignment=6;
            checkLabel.Tag='ProgressCheckLabel';

            checkImage.Type='image';
            checkImage.FilePath=pi.ProgressState.getImagePath(pi.ProgressState.CheckState);
            checkImage.RowSpan=[1,3];
            checkImage.ColSpan=[1,2];
            checkImage.Alignment=6;
            checkImage.Enabled=pi.ProgressState.CheckState~=dfs.analysis.ProgressTrackerEnum.None;
            checkImage.ToolTip=getString(message('dataflow:MultithreadingAnalysis:ProgressCheckTooltip'));
            checkImage.Tag='ProgressCheckImage';

            profileLabel.Type='text';
            profileLabel.Name=getString(message('dataflow:MultithreadingAnalysis:ProgressProfileLabel'));
            profileLabel.RowSpan=[4,4];
            profileLabel.ColSpan=[3,4];
            profileLabel.Alignment=6;
            profileLabel.Tag='ProgressProfileLabel';

            profileImage.Type='image';
            profileImage.FilePath=pi.ProgressState.getImagePath(pi.ProgressState.ProfileState);
            profileImage.RowSpan=[1,3];
            profileImage.ColSpan=[3,4];
            profileImage.Alignment=6;
            profileImage.Enabled=pi.ProgressState.ProfileState~=dfs.analysis.ProgressTrackerEnum.None;
            profileImage.ToolTip=getString(message('dataflow:MultithreadingAnalysis:ProgressProfileTooltip'));
            profileImage.Tag='ProgressProfileImage';

            partLabel.Type='text';
            partLabel.Name=getString(message('dataflow:MultithreadingAnalysis:ProgressPartitionLabel'));
            partLabel.RowSpan=[4,4];
            partLabel.ColSpan=[5,6];
            partLabel.Alignment=6;
            partLabel.Tag='ProgressPartitionLabel';

            partImage.Type='image';
            partImage.FilePath=fullfile(matlabroot,'toolbox','shared','sl_multicore','dfs','resources','success_32.svg');
            partImage.FilePath=pi.ProgressState.getImagePath(pi.ProgressState.PartitionState);
            partImage.RowSpan=[1,3];
            partImage.ColSpan=[5,6];
            partImage.Alignment=6;
            partImage.Enabled=pi.ProgressState.PartitionState~=dfs.analysis.ProgressTrackerEnum.None;
            partImage.ToolTip=getString(message('dataflow:MultithreadingAnalysis:ProgressPartitionTooltip'));
            partImage.Tag='ProgressPartitionImage';

            panel.Type='panel';
            panel.Tag='ProgressPanel';
            panel.LayoutGrid=[4,6];
            panel.ColStretch=[1,1,1,1,1,1];
            panel.RowStretch=[1,0,1,1];
            panel.Spacing=0;
            panel.Items={profileBar,partBar,checkLabel,checkImage,...
            profileLabel,profileImage,...
            partLabel,partImage};
        end


        function panel=createButtonPanel(obj)
            pi=obj.PerformanceInfo;

            actionButtonLabel=getString(message('dataflow:MultithreadingAnalysis:ActionButtonAnalyzeLabel'));
            actionButtonTootip=getString(message('dataflow:MultithreadingAnalysis:ActionButtonAnalyzeTooltip'));
            if pi.ShowStopSimulationLink
                actionButtonLabel=getString(message('dataflow:MultithreadingAnalysis:ActionButtonStopLabel'));
                actionButtonTootip=getString(message('dataflow:MultithreadingAnalysis:ActionButtonStopTooltip'));
            end

            refresh.Type='pushbutton';
            refresh.Tag='AnalyzeButton';
            refresh.Name=actionButtonLabel;
            refresh.ToolTip=actionButtonTootip;
            refresh.ObjectMethod='analyzeButtonPushed';
            refresh.MethodArgs={};
            refresh.ArgDataTypes={};
            refresh.RowSpan=[1,1];
            refresh.ColSpan=[1,3];
            refresh.Enabled=pi.ModelIsStopped||pi.ShowStopSimulationLink;
            refresh.Alignment=6;

            help.Type='pushbutton';
            help.Tag='HelpButton';
            help.Name=getString(message('dataflow:MultithreadingAnalysis:HelpButtonLabel'));
            help.ToolTip=getString(message('dataflow:MultithreadingAnalysis:HelpButtonTooltip'));
            help.ObjectMethod='helpButtonPushed';
            help.MethodArgs={};
            help.ArgDataTypes={};
            help.RowSpan=[1,1];
            help.ColSpan=[3,3];
            help.Alignment=7;

            panel.Type='panel';
            panel.Tag='ButtonPanel';
            panel.LayoutGrid=[1,3];
            panel.Items={refresh,help};
        end

        function bar=getProgressBar(~,startPos,endPos,tagPrefix)
            greenRGB=[202,230,208];
            greyRGB=[230,230,230];
            segs=cell(1,11);




            for i=1:11
                segs{i}.Type='text';
                segs{i}.Name=' ';

                if(startPos<(i*10))&&(endPos>=(i*10))

                    segs{i}.BackgroundColor=greenRGB;
                    segs{i}.UserData=1;
                else

                    segs{i}.BackgroundColor=greyRGB;
                    segs{i}.UserData=0;
                end

                segs{i}.RowSpan=[1,1];
                segs{i}.ColSpan=[i,i];
                segs{i}.Alignment=0;
                segs{i}.Tag=[tagPrefix,'Seg',num2str(i)];
            end

            bar.Type='panel';
            bar.LayoutGrid=[1,11];
            bar.ColStretch=zeros(1,11)+10;
            bar.Items=segs;
            bar.Spacing=0;
            bar.Alignment=0;
            bar.ContentsMargins=0;
        end

    end
end



