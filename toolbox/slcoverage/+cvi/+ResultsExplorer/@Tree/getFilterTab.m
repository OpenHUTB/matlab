



function filterPanel=getFilterTab(obj,tag,actionGroup)
    widgetId=tag;

    help='Add new rule by clicking in the report';
    fe=obj.resultsExplorer.filterEditor;
    filterState=getFilterStateGroup(fe,tag,widgetId,help);
    node=obj.root;
    changeString='';
    if fe.needSave
        changeString='*';
    end
    filterFileName.Name=[DAStudio.message('Slvnv:simcoverage:covFilterFilename'),' ',fe.fileName,changeString];
    filterFileName.Type='text';
    filterFileName.RowSpan=[1,1];
    filterFileName.ColSpan=[1,2];
    filterFileName.Tag=[tag,'filterFilename'];
    filterFileName.WidgetId=[widgetId,'filterFilename'];

    saveFilter.Name=getString(message('Slvnv:simcoverage:cvresultsexplorer:SaveFilter'));
    saveFilter.Type='hyperlink';
    saveFilter.Enabled=~fe.isEmpty()&&~fe.hasUnappliedChanges&&fe.hasNonRteProps;
    saveFilter.MatlabMethod='actionCallback';
    saveFilter.MatlabArgs={node,'saveFilter'};
    saveFilter.RowSpan=[2,2];
    saveFilter.ColSpan=[1,1];
    saveFilter.Tag=[tag,'saveFilter'];
    saveFilter.WidgetId=[tag,'saveFilter'];
    saveFilter.DialogRefresh=true;

    loadFilter.Name=getString(message('Slvnv:simcoverage:cvresultsexplorer:LoadFilter'));
    loadFilter.Type='hyperlink';
    loadFilter.Enabled=~fe.hasUnappliedChanges;
    loadFilter.MatlabMethod='actionCallback';
    loadFilter.MatlabArgs={node,'loadFilter'};
    loadFilter.RowSpan=[3,3];
    loadFilter.ColSpan=[1,1];
    loadFilter.Tag=[tag,'loadFilter'];
    loadFilter.WidgetId=[tag,'loadFilter'];
    loadFilter.DialogRefresh=true;


    isSldvHarness=Sldv.HarnessUtils.isSldvGenHarness(obj.resultsExplorer.topModelName);

    makeFilter.Name=getString(message('Slvnv:simcoverage:cvresultsexplorer:MakeFilter'));
    makeFilter.Type='hyperlink';
    makeFilter.MatlabMethod='actionCallback';
    makeFilter.MatlabArgs={node,'makeFilter'};
    makeFilter.Enabled=license('test','Simulink_Design_Verifier')&&...
    ~fe.hasUnappliedChanges&&...
    ~isSldvHarness;
    makeFilter.Visible=~obj.isCodeFilterTab;
    makeFilter.RowSpan=[4,4];
    makeFilter.ColSpan=[1,1];
    makeFilter.Tag=[tag,'makeFilter'];
    makeFilter.WidgetId=[tag,'makeFilter'];
    makeFilter.DialogRefresh=true;

    makeCPFilter.Name=getString(message('Slvnv:simcoverage:cvresultsexplorer:MakeCPFilter'));
    makeCPFilter.Type='hyperlink';
    makeCPFilter.MatlabMethod='actionCallback';
    makeCPFilter.MatlabArgs={node,'makeCPFilter'};
    makeCPFilter.Enabled=SlCov.CoverageAPI.checkPolyspaceLicense()&&...
    ~fe.hasUnappliedChanges&&...
    ~isSldvHarness;
    makeCPFilter.Visible=obj.isCodeFilterTab;
    makeCPFilter.ColSpan=[1,1];
    makeCPFilter.Tag=[tag,'makeCPFilter'];
    makeCPFilter.WidgetId=[tag,'makeCPFilter'];
    makeCPFilter.DialogRefresh=true;

    groupFile.Type='panel';

    groupFile.Items={filterFileName,loadFilter,saveFilter};
    groupFile.LayoutGrid=[3,2];
    groupFile.RowSpan=[1,3];


    if SlCov.CoverageAPI.feature('sldvfilter')&&...
        license('test','Simulink_Design_Verifier')
        groupFile.Items=[groupFile.Items,{makeFilter}];
        groupFile.LayoutGrid=[numel(groupFile.Items),2];
    end

    if obj.isCodeFilterTab&&SlCov.CoverageAPI.checkPolyspaceLicense()
        rowIdx=numel(groupFile.Items)+1;
        makeCPFilter.RowSpan=[rowIdx,rowIdx];
        groupFile.Items=[groupFile.Items,{makeCPFilter}];
        groupFile.LayoutGrid=[rowIdx,2];
    end

    panel.LayoutGrid=[3,3];
    panel.RowStretch=[1,0,0];
    panel.Type='panel';
    panel.Items={filterState,groupFile};
    if~isempty(actionGroup)
        panel.Items=[panel.Items,{actionGroup}];
    end



    filterPanel.Name=getString(message('Slvnv:simcoverage:cvresultsexplorer:FilterPanel'));
    filterPanel.Tag=[tag,'filterPanel'];
    filterPanel.WidgetId=[widgetId,'filterPanel'];
    filterPanel.Items={panel};


end
