classdef ChangeInformationPanel<handle




    methods(Static)

        function panel=getDialogSchema(this)

            panel=struct('Type','togglepanel',...
            'Name',getString(message('Slvnv:slreq:ChangeInfoPanelName')),...
            'LayoutGrid',[3,5],...
            'Tag','changepanel');
            panel.Expand=slreq.gui.togglePanelHandler('get',panel.Tag,true);
            panel.ExpandCallback=@slreq.gui.togglePanelHandler;

            panel.Items={};

            mgr=slreq.app.MainManager.getInstance();
            if mgr.isAnalysisDeferred


                iconPath=fullfile(matlabroot,'toolbox','shared','dastudio','resources','warning_16.png');
                icon=struct('Type','image',...
                'RowSpan',[1,1],'ColSpan',[1,1],...
                'Tag','image_sourcechanged','FilePath',iconPath);

                textwidget.Name=getString(message('Slvnv:slreq:AnalysisPendingTooltip'));

                textwidget.Tag='text_changepaneltooltip';
                textwidget.Type='text';
                textwidget.RowSpan=[1,1];
                textwidget.ColSpan=[2,2];
                panel.Items={icon,textwidget};
                return;
            end


            keepGroup=false;

            if isa(this,'slreq.das.Link')




                if this.hasChangedIssue


                    keepGroup=true;
                else
                    items=summaryForPassedLink();
                    panel.Items=items;
                end







                if this.hasChangedSource

                    group=detailsForFailedSource(this);
                    panel.Items=[panel.Items,group];
                    currentRow=1;
                elseif this.SourceChangeStatus.isInvalidLink
                    currentRow=1;
                    [items,currentRow]=detailsForInvalidSource(currentRow,keepGroup);
                    panel.Items=[panel.Items,items];
                else
                    currentRow=1;
                    [items,currentRow]=detailsForPassedSource(this,currentRow,keepGroup);
                    panel.Items=[panel.Items,items];
                end


                if this.hasChangedDestination
                    group=detailsForFailedDestination(this);
                    panel.Items=[panel.Items,group];
                elseif this.DestinationChangeStatus.isInvalidLink
                    items=detailsForInvalidDestination(currentRow,keepGroup);
                    panel.Items=[panel.Items,items];
                else
                    items=detailsForPassedDestination(this,currentRow,keepGroup);
                    panel.Items=[panel.Items,items];
                end
            elseif isa(this,'slreq.das.LinkSet')


                textwidget.Name=getString(message('Slvnv:slreq:NumTotalLinks'));

                textwidget.Tag='text_changepaneltotallinks';
                textwidget.Type='text';
                textwidget.RowSpan=[1,1];
                textwidget.ColSpan=[1,1];
                panel.Items=[panel.Items,textwidget];

                textwidget.Name=num2str(length(this.children));
                textwidget.Tag='text_changepaneltotallinknum';
                textwidget.Type='text';
                textwidget.RowSpan=[1,1];
                textwidget.ColSpan=[2,2];
                panel.Items=[panel.Items,textwidget];


                textwidget.Name=getString(message('Slvnv:slreq:NumLinksHavingChangedSource'));
                textwidget.Tag='text_changepanelchangedsource';
                textwidget.Type='text';
                textwidget.RowSpan=[2,2];
                textwidget.ColSpan=[1,1];
                panel.Items=[panel.Items,textwidget];

                textwidget.Name=num2str(this.NumberOfChangedSource);
                textwidget.Tag='text_changepanelchangedsourcenum';
                textwidget.Type='text';
                textwidget.RowSpan=[2,2];
                textwidget.ColSpan=[2,2];
                panel.Items=[panel.Items,textwidget];


                textwidget.Name=getString(message('Slvnv:slreq:NumLinksHavingChangedDestination'));
                textwidget.Tag='text_changepanelchangeddestination';
                textwidget.Type='text';
                textwidget.RowSpan=[3,3];
                textwidget.ColSpan=[1,1];
                panel.Items=[panel.Items,textwidget];

                textwidget.Name=num2str(this.NumberOfChangedDestination);
                textwidget.Tag='text_changepanelchangeddestinationnum';
                textwidget.Type='text';
                textwidget.RowSpan=[3,3];
                textwidget.ColSpan=[2,2];

                panel.Items=[panel.Items,textwidget];

                buttonWidget.Name=getString(message('Slvnv:slreq:ChangeInfoPanelClearAll'));
                buttonWidget.ToolTip=getString(message('Slvnv:slreq:ChangeInfoPanelClearAllToolTip'));
                buttonWidget.Type='pushbutton';
                buttonWidget.Tag='pushbutton_changepanelupdatesource';
                buttonWidget.RowSpan=[4,4];
                buttonWidget.ColSpan=[1,1];
                buttonWidget.MatlabMethod='slreq.gui.ChangeInformationPanel.clearAllChangeIssuesCallBack';
                buttonWidget.MatlabArgs={this};
                buttonWidget.Visible=true;
                buttonWidget.MinimumSize=[100,30];
                buttonWidget.MaximumSize=[100,30];
                if this.NumberOfChangedSource>0||this.NumberOfChangedDestination>0
                    buttonWidget.Enabled=true;
                else
                    buttonWidget.Enabled=false;
                end


                panel.Items=[panel.Items,buttonWidget];
            else

            end
        end


        function out=getRevisionInfo(revision,timeStamp)
            timeStr=slreq.utils.getDateStr(timeStamp);

            out=sprintf('%s %s (%s %s)',...
            getString(message('Slvnv:slreq:RevisionColon')),...
            revision,...
            getString(message('Slvnv:slreq:TimeStampColon')),...
            timeStr);
        end


        function clearAllChangeIssuesCallBack(dasLinkSet)
            dlg=slreq.gui.ClearChangeDialog(dasLinkSet);
            dlg.show();
        end


        function updateLinkedSourceCallBack(dasLink)

            dlg=slreq.gui.ClearChangeDialog(dasLink,'Source');
            dlg.show();
        end


        function updateLinkedDestinationCallBack(dasLink)

            dlg=slreq.gui.ClearChangeDialog(dasLink,'Destination');
            dlg.show();
        end
    end
end


function out=summaryForPassedLink()

    iconPath=fullfile(matlabroot,'toolbox','shared','dastudio','resources','ModelAdvisor.png');
    icon=struct('Type','image',...
    'RowSpan',[1,1],'ColSpan',[1,1],...
    'Tag','image_linkpass','FilePath',iconPath);
    textwidget.Name=getString(message('Slvnv:slreq:ChangeInfoPanelNoChangeDetected'));
    textwidget.Tag='text_changepanelpassedsummary';
    textwidget.Type='text';
    textwidget.RowSpan=[1,1];
    textwidget.ColSpan=[2,4];
    out={icon,textwidget};
end


function group=detailsForFailedSource(this)

    group=struct('Type','group',...
    'Name','',...
    'LayoutGrid',[3,5],...
    'Tag','changepanelsourcechangegroup');
    group.ColStretch=[0,0,0,0,1];

    currentRow=1;
    iconPath=fullfile(matlabroot,'toolbox','shared','dastudio','resources','warning_16.png');
    icon=struct('Type','image',...
    'RowSpan',[currentRow,currentRow],'ColSpan',[1,1],...
    'Tag','image_sourcechanged','FilePath',iconPath);

    textwidget.Name=getString(message('Slvnv:slreq:ChangeInfoPanelSourceChanged'));
    textwidget.Tag='text_changepanelsourcechangevalue';
    textwidget.Type='text';
    textwidget.RowSpan=[currentRow,currentRow];
    textwidget.ColSpan=[2,3];

    srcSusLevel=textwidget;

    buttonWidget.Name=getString(message('Slvnv:slreq:ChangeInfoPanelViewDiff'));
    buttonWidget.Type='pushbutton';
    buttonWidget.Tag='pushbutton_changepanelviewsourcediff';
    buttonWidget.RowSpan=[currentRow,currentRow];
    buttonWidget.ColSpan=[4,4];
    buttonWidget.MatlabMethod='slreq.app.ChangeTracker.ViewSourceDiff';
    buttonWidget.MatlabArgs={this};
    buttonWidget.Alignment=1;
    buttonWidget.Visible=false;

    buttonViewSrcDiff=buttonWidget;

    spacer=struct('Type','panel','ColSpan',[5,5]);

    currentRow=currentRow+1;
    textWidget.Name=getString(message('Slvnv:slreq:ChangeInfoPanelStoredColon'));
    textWidget.Tag='text_changepanellinkedsourcename';
    textWidget.Type='text';
    textWidget.RowSpan=[currentRow,currentRow];
    textWidget.ColSpan=[3,3];

    storedSrcName=textWidget;

    textWidget.Name=slreq.gui.ChangeInformationPanel.getRevisionInfo(this.LinkedSourceRevision,this.LinkedSourceTimeStamp);
    textWidget.Tag='text_changepanellinkedsourcevalue';
    textWidget.Type='text';
    textWidget.RowSpan=[currentRow,currentRow];
    textWidget.ColSpan=[4,4];

    storedSrcValue=textWidget;

    currentRow=currentRow+1;
    textWidget.Name=getString(message('Slvnv:slreq:ChangeInfoPanelActualColon'));
    textWidget.Tag='text_changepanelactrualsourcename';
    textWidget.Type='text';
    textWidget.RowSpan=[currentRow,currentRow];
    textWidget.ColSpan=[3,3];

    actualSrcName=textWidget;

    textWidget.Name=slreq.gui.ChangeInformationPanel.getRevisionInfo(this.CurrentSourceRevision,this.CurrentSourceTimeStamp);
    textWidget.Tag='text_changepanelactrualsourcevalue';
    textWidget.Type='text';
    textWidget.RowSpan=[currentRow,currentRow];
    textWidget.ColSpan=[4,4];

    currentRow=currentRow+1;
    buttonWidget.Name=getString(message('Slvnv:slreq:ChangeInfoPanelClear'));
    buttonWidget.ToolTip=getString(message('Slvnv:slreq:ChangeInfoPanelClearSourceToolTip'));
    buttonWidget.Type='pushbutton';
    buttonWidget.Tag='pushbutton_changepanelupdatesource';
    buttonWidget.RowSpan=[currentRow,currentRow];
    buttonWidget.ColSpan=[1,2];
    buttonWidget.MatlabMethod='slreq.gui.ChangeInformationPanel.updateLinkedSourceCallBack';

    buttonWidget.MatlabArgs={this};
    buttonWidget.Visible=true;

    buttonUpdateSrc=buttonWidget;

    buttonWidget.Name=getString(message('Slvnv:slreq:ChangeInfoPanelConfirm'));
    buttonWidget.ToolTip=getString(message('Slvnv:slreq:ChangeInfoPanelConfirmToolTip'));
    buttonWidget.Type='pushbutton';
    buttonWidget.Tag='pushbutton_changepanelrejectlinkedsrc';
    buttonWidget.RowSpan=[currentRow,currentRow];
    buttonWidget.ColSpan=[3,4];
    buttonWidget.MatlabMethod='slreq.app.ChangeTracker.RejectLinkedSource';
    buttonWidget.MatlabArgs={this};
    buttonWidget.Visible=false;

    buttonRejectSrc=buttonWidget;


    actualSrcValue=textWidget;
    group.Items={icon,srcSusLevel,buttonViewSrcDiff,spacer,...
    buttonUpdateSrc,buttonRejectSrc,storedSrcName,storedSrcValue,...
    actualSrcName,actualSrcValue};
end


function[out,currentRow]=detailsForPassedSource(this,currentRow,keepGroup)

    if keepGroup


        group=struct('Type','group',...
        'Name','',...
        'LayoutGrid',[2,5],...
        'Tag','changepanelsourcepassgroup');
        group.ColStretch=[0,0,0,0,1];
        currentRow=1;
    else
        currentRow=currentRow+1;
    end
    textwidget.Name=getString(message('Slvnv:slreq:SourceColon'));
    textwidget.Tag='text_changepanelsourceinfoname';
    textwidget.Type='text';
    textwidget.RowSpan=[currentRow,currentRow];
    textwidget.ColSpan=[1,1];

    srcInfoName=textwidget;

    textWidget.Name=slreq.gui.ChangeInformationPanel.getRevisionInfo(this.LinkedSourceRevision,this.LinkedSourceTimeStamp);
    textWidget.Tag='text_changepanelsourceinfovalue';
    textWidget.Type='text';
    textWidget.RowSpan=[currentRow,currentRow];
    textWidget.ColSpan=[2,4];
    textWidget.Alignment=1;

    srcInfoValue=textWidget;
    spacer=struct('Type','panel','ColSpan',[5,5]);
    if keepGroup
        group.Items={srcInfoName,srcInfoValue,spacer};
        out=group;
    else
        out={srcInfoName,srcInfoValue,spacer};
    end
end


function group=detailsForFailedDestination(this)
    group=struct('Type','group',...
    'Name','',...
    'LayoutGrid',[3,5],...
    'Tag','changepaneldestinationchangegroup');
    group.ColStretch=[0,0,0,0,1];

    currentRow=1;

    iconPath=fullfile(matlabroot,'toolbox','shared','dastudio',...
    'resources','warning_16.png');
    icon=struct('Type','image',...
    'RowSpan',[currentRow,currentRow],'ColSpan',[1,1],...
    'Tag','image_dstchange','FilePath',iconPath);

    textwidget.Name=getString(message('Slvnv:slreq:ChangeInfoPanelDestinationChanged'));
    textwidget.Tag='text_changepaneldestchangevalue';
    textwidget.Type='text';
    textwidget.RowSpan=[currentRow,currentRow];
    textwidget.ColSpan=[2,3];

    dstSusLevel=textwidget;

    buttonWidget.Name=getString(message('Slvnv:slreq:ChangeInfoPanelViewDiff'));
    buttonWidget.Type='pushbutton';
    buttonWidget.Tag='pushbutton_changepanelviewdestdiff';
    buttonWidget.RowSpan=[currentRow,currentRow];
    buttonWidget.ColSpan=[4,4];
    buttonWidget.MatlabMethod='slreq.app.ChangeTracker.ViewDestinationDiff';
    buttonWidget.MatlabArgs={this};
    buttonWidget.Alignment=1;
    buttonWidget.Visible=false;

    buttonViewDstDiff=buttonWidget;

    spacer=struct('Type','panel','ColSpan',[5,5]);

    currentRow=currentRow+1;
    textWidget.Name=getString(message('Slvnv:slreq:ChangeInfoPanelStoredColon'));
    textWidget.Tag='text_changepanellinkeddestname';
    textWidget.Type='text';
    textWidget.RowSpan=[currentRow,currentRow];
    textWidget.ColSpan=[3,3];

    storedDstName=textWidget;

    textWidget.Name=slreq.gui.ChangeInformationPanel.getRevisionInfo(this.LinkedDestinationRevision,this.LinkedDestinationTimeStamp);
    textWidget.Tag='text_changepanellinkeddestvalue';
    textWidget.Type='text';
    textWidget.RowSpan=[currentRow,currentRow];
    textWidget.ColSpan=[4,4];

    storedDstValue=textWidget;

    currentRow=currentRow+1;
    textWidget.Name=getString(message('Slvnv:slreq:ChangeInfoPanelActualColon'));
    textWidget.Tag='text_changepanelactrualdestname';
    textWidget.Type='text';
    textWidget.RowSpan=[currentRow,currentRow];
    textWidget.ColSpan=[3,3];

    actualDstName=textWidget;

    textWidget.Name=slreq.gui.ChangeInformationPanel.getRevisionInfo(this.CurrentDestinationRevision,this.CurrentDestinationTimeStamp);
    textWidget.Tag='text_changepanelactrualdestvalue';
    textWidget.Type='text';
    textWidget.RowSpan=[currentRow,currentRow];
    textWidget.ColSpan=[4,4];

    actualDstValue=textWidget;

    currentRow=currentRow+1;
    buttonWidget.Name=getString(message('Slvnv:slreq:ChangeInfoPanelClear'));
    buttonWidget.ToolTip=getString(message('Slvnv:slreq:ChangeInfoPanelClearDestinationToolTip'));
    buttonWidget.Type='pushbutton';
    buttonWidget.Tag='pushbutton_changepanelupdatedest';
    buttonWidget.RowSpan=[currentRow,currentRow];
    buttonWidget.ColSpan=[1,2];
    buttonWidget.MatlabMethod='slreq.gui.ChangeInformationPanel.updateLinkedDestinationCallBack';

    buttonWidget.MatlabArgs={this};
    buttonWidget.Visible=true;

    buttonUpdateDst=buttonWidget;


    buttonWidget.Name=getString(message('Slvnv:slreq:ChangeInfoPanelConfirm'));
    buttonWidget.ToolTip=getString(message('Slvnv:slreq:ChangeInfoPanelConfirmToolTip'));
    buttonWidget.Type='pushbutton';
    buttonWidget.Tag='pushbutton_changepanelrejectlinkeddest';
    buttonWidget.RowSpan=[currentRow,currentRow];
    buttonWidget.ColSpan=[3,4];
    buttonWidget.MatlabMethod='slreq.app.ChangeTracker.RejectLinkedDestination';
    buttonWidget.MatlabArgs={this};
    buttonWidget.Visible=false;

    buttonRejectDst=buttonWidget;

    group.Items={icon,dstSusLevel,buttonViewDstDiff,...
    spacer,...
    storedDstName,storedDstValue,...
    actualDstName,actualDstValue,...
    buttonUpdateDst,buttonRejectDst};
end


function[out,currentRow]=detailsForPassedDestination(this,currentRow,keepGroup)
    if keepGroup
        group=struct('Type','group',...
        'Name','',...
        'LayoutGrid',[3,5],...
        'Tag','changepaneldestinationgpassroup');
        group.ColStretch=[0,0,0,0,1];
        currentRow=1;
    else
        currentRow=currentRow+1;
    end
    textwidget.Name=getString(message('Slvnv:slreq:DestinationColon'));
    textwidget.Tag='text_changepaneldstinfoname';
    textwidget.Type='text';
    textwidget.RowSpan=[currentRow,currentRow];
    textwidget.ColSpan=[1,1];

    dstInfoName=textwidget;

    textWidget.Name=slreq.gui.ChangeInformationPanel.getRevisionInfo(this.LinkedDestinationRevision,this.LinkedDestinationTimeStamp);
    textWidget.Tag='text_changepaneldstinfovalue';
    textWidget.Type='text';
    textWidget.RowSpan=[currentRow,currentRow];
    textWidget.ColSpan=[2,3];

    dstInfoValue=textWidget;
    spacer=struct('Type','panel','ColSpan',[5,5]);
    if keepGroup
        group.Items={dstInfoName,dstInfoValue,spacer};
        out=group;
    else
        out={dstInfoName,dstInfoValue,spacer};
    end
end



function[out,currentRow]=detailsForInvalidDestination(currentRow,keepGroup)
    if keepGroup
        group=struct('Type','group',...
        'Name','',...
        'LayoutGrid',[1,5],...
        'Tag','changepaneldestinationinvalidgroup');
        group.ColStretch=[0,0,0,0,1];
        currentRow=1;
    else
        currentRow=currentRow+1;
    end

    textwidget.Name=getString(message('Slvnv:slreq:DestinationColon'));
    textwidget.Tag='text_changepaneldstinfoname';
    textwidget.Type='text';
    textwidget.RowSpan=[currentRow,currentRow];
    textwidget.ColSpan=[1,1];

    dstInfoName=textwidget;


    iconPath=fullfile(matlabroot,'toolbox','shared','dastudio','resources','error_16.png');
    icon=struct('Type','image',...
    'RowSpan',[currentRow,currentRow],'ColSpan',[2,2],...
    'Tag','image_linkerror','FilePath',iconPath);

    textWidget.Name=getString(message('Slvnv:slreq:ChangeInfoPanelUnresolvedLinkDestination'));
    textWidget.Tag='text_changepaneldstinfovalue';
    textWidget.Type='text';
    textWidget.RowSpan=[currentRow,currentRow];
    textWidget.ColSpan=[3,4];

    dstInfoValue=textWidget;
    spacer=struct('Type','panel','ColSpan',[5,5]);
    if keepGroup
        group.Items={dstInfoName,icon,dstInfoValue,spacer};
        out=group;
    else
        out={dstInfoName,icon,dstInfoValue,spacer};
    end
end


function[out,currentRow]=detailsForInvalidSource(currentRow,keepGroup)

    if keepGroup


        group=struct('Type','group',...
        'Name','',...
        'LayoutGrid',[1,5],...
        'Tag','changepanelsourceinvalidgroup');
        group.ColStretch=[0,0,0,0,1];
        currentRow=1;
    else
        currentRow=currentRow+1;
    end

    textwidget.Name=getString(message('Slvnv:slreq:SourceColon'));
    textwidget.Tag='text_changepanelsourceinfoname';
    textwidget.Type='text';
    textwidget.RowSpan=[currentRow,currentRow];
    textwidget.ColSpan=[1,1];

    srcInfoName=textwidget;


    iconPath=fullfile(matlabroot,'toolbox','shared','dastudio','resources','error_16.png');
    icon=struct('Type','image',...
    'RowSpan',[currentRow,currentRow],'ColSpan',[2,2],...
    'Tag','image_linkerror','FilePath',iconPath);

    textWidget.Name=getString(message('Slvnv:slreq:ChangeInfoPanelUnresolvedLinkSource'));
    textWidget.Tag='text_changepaneldstinfovalue';
    textWidget.Type='text';
    textWidget.RowSpan=[currentRow,currentRow];
    textWidget.ColSpan=[3,4];

    srcInfoValue=textWidget;
    spacer=struct('Type','panel','ColSpan',[5,5]);
    if keepGroup
        group.Items={srcInfoName,icon,srcInfoValue,spacer};
        out=group;
    else
        out={srcInfoName,icon,srcInfoValue,spacer};
    end
end