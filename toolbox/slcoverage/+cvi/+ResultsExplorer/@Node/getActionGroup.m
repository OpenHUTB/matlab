function actionGroup=getActionGroup(obj,isFilter)




    dlgTag='Node_';
    tabTag='';
    fe=obj.parentTree.resultsExplorer.filterEditor;
    if isFilter
        tabTag='_filterTab';
    end
    isVisible=~fe.hasUnappliedChanges&&~obj.needsApply;

    actionGroup.Type='group';
    actionGroup.Flat=true;

    if isempty(obj.data.lastReport)
        lastReportLink.Name=getString(message('Slvnv:simcoverage:cvresultsexplorer:GenerateReport'));
        lastReportLink.MatlabArgs={obj,'genReport'};
        lastReportLink.DialogRefresh=true;
    else
        [~,filename]=fileparts(obj.data.lastReport);
        lastReportLink.Name=[getString(message('Slvnv:simcoverage:cvresultsexplorer:LastReport')),' ',filename];
        lastReportLink.ToolTip=filename;
        lastReportLink.MatlabArgs={obj,'openReport'};
    end

    lastReportLink.Type='hyperlink';
    lastReportLink.Enabled=isVisible;
    lastReportLink.MatlabMethod='actionCallback';
    lastReportLink.RowSpan=[1,1];
    lastReportLink.Tag=[dlgTag,'lastReportLink',tabTag];
    lastReportLink.WidgetId=[dlgTag,'lastReportLink'];

    modelviewLink.Type='hyperlink';
    modelviewLink.Enabled=isVisible;
    modelviewLink.MatlabMethod='actionCallback';

    if obj.parentTree.resultsExplorer.highlightedNode==obj
        modelviewLink.Name=getString(message('Slvnv:simcoverage:cvresultsexplorer:RemoveHighlight'));
        modelviewLink.MatlabArgs={obj,'removeHighlight'};
    else
        modelviewLink.Name=getString(message('Slvnv:simcoverage:cvresultsexplorer:Highlight'));
        modelviewLink.MatlabArgs={obj,'modelview'};
    end

    modelviewLink.RowSpan=[2,2];
    modelviewLink.Tag=[dlgTag,'modelviewLink',tabTag];
    modelviewLink.WidgetId=[dlgTag,'modelviewLink'];

    sdiLink.Enabled=obj~=obj.parentTree.root&&...
    ~isempty(obj.data.sdiRunId);

    sdiLink.Type='hyperlink';
    sdiLink.MatlabMethod='actionCallback';
    sdiLink.Name=getString(message('Slvnv:simcoverage:cvresultsexplorer:OpenSdi'));
    sdiLink.MatlabArgs={obj,'openSDI'};
    sdiLink.RowSpan=[3,3];
    sdiLink.Tag=[dlgTag,'sdiLink',tabTag];
    sdiLink.WidgetId=[dlgTag,'sdiLink'];
    sdiLink.Visible=obj~=obj.parentTree.root;


    saveCovData.Visible=numel(obj.parentTree.root.children)>1&&...
    obj.parentTree.isActive&&...
    obj==obj.parentTree.root;
    saveCovData.Name=getString(message('Slvnv:simcoverage:cvresultsexplorer:SaveCumData'));
    saveCovData.Type='hyperlink';
    saveCovData.MatlabMethod='actionCallback';
    saveCovData.MatlabArgs={obj,'saveCovData'};
    saveCovData.RowSpan=[4,4];
    saveCovData.Tag=[dlgTag,'saveCovData'];
    saveCovData.WidgetId=[dlgTag,'saveCovData'];
    saveCovData.DialogRefresh=true;


    actionGroup.Type='group';
    actionGroup.Flat=true;
    actionGroup.Enabled=isVisible;
    actionGroup.RowSpan=[4,4];
    actionGroup.LayoutGrid=[7,1];
    actionGroup.Alignment=1;
    actionGroup.Items={lastReportLink,modelviewLink,sdiLink,saveCovData};

end
