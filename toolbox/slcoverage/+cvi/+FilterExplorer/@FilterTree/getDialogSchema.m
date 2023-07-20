
function dlg=getDialogSchema(obj,~)




    try

        tag=obj.dlgTag;
        dlg.Sticky=true;
        dlg.LayoutGrid=[3,1];
        dlg.RowStretch=[0,0,1];
        info.Type='text';
        info.RowSpan=[1,1];
        info.ColSpan=[1,1];
        info.Name=getString(message('Slvnv:simcoverage:cvresultsexplorer:NewRuleHelp'));


        newFilter.Name=getString(message('Slvnv:simcoverage:cvresultsexplorer:NewFilter'));
        newFilter.Type='hyperlink';
        newFilter.MatlabMethod='cvi.FilterExplorer.FilterTree.addNewFilterCallback';
        newFilter.MatlabArgs={obj.filterExplorer.getUUID};
        newFilter.RowSpan=[1,1];
        newFilter.ColSpan=[1,1];
        newFilter.Tag=[tag,'newFilter'];
        newFilter.WidgetId=[tag,'newFilter'];

        loadFilter.Name=getString(message('Slvnv:simcoverage:cvresultsexplorer:LoadFilter'));
        loadFilter.Type='hyperlink';
        loadFilter.MatlabMethod='cvi.FilterExplorer.FilterTree.loadFilterCallback';
        loadFilter.MatlabArgs={obj.filterExplorer.getUUID};
        loadFilter.RowSpan=[2,2];
        loadFilter.ColSpan=[1,1];
        loadFilter.Tag=[tag,'loadFilter'];
        loadFilter.WidgetId=[tag,'loadFilter'];

        groupFile.Type='group';
        groupFile.Flat=true;
        groupFile.Items={newFilter,loadFilter};
        groupFile.LayoutGrid=[3,2];
        groupFile.RowSpan=[1,3];

        resultsExplorer=obj.filterExplorer.resultsExplorer;
        if~isempty(resultsExplorer)
            topModelName=obj.filterExplorer.resultsExplorer.topModelName;
        else
            topModelName=obj.filterExplorer.topModelName;
        end
        isSldvHarness=false;
        if~isempty(topModelName)&&license('test','Simulink_Design_Verifier')
            isSldvHarness=Sldv.HarnessUtils.isSldvGenHarness(topModelName);

            makeFilter.Name=getString(message('Slvnv:simcoverage:cvresultsexplorer:MakeFilter'));
            makeFilter.Type='hyperlink';
            makeFilter.MatlabMethod='cvi.FilterExplorer.FilterTree.makeDeadLogicFilterCallback';

            makeFilter.MatlabArgs={obj.filterExplorer.getUUID,'sldv'};
            makeFilter.Enabled=license('test','Simulink_Design_Verifier')&&...
            ~isSldvHarness;
            makeFilter.RowSpan=[3,3];
            makeFilter.ColSpan=[1,1];
            makeFilter.Tag=[tag,'makeFilter'];
            makeFilter.WidgetId=[tag,'makeFilter'];
            makeFilter.DialogRefresh=true;
            makeFilter.RowSpan=[4,4];
            makeFilter.ColSpan=[1,1];

            groupFile.Items=[groupFile.Items,{makeFilter}];
            groupFile.LayoutGrid=[numel(groupFile.Items),2];
        end

        if~isempty(resultsExplorer)&&SlCov.CoverageAPI.checkPolyspaceLicense()
            makeCPFilter.Name=getString(message('Slvnv:simcoverage:cvresultsexplorer:MakeCPFilter'));
            makeCPFilter.Type='hyperlink';
            makeCPFilter.MatlabMethod='cvi.FilterExplorer.FilterTree.makeDeadLogicFilterCallback';
            makeCPFilter.MatlabArgs={obj.filterExplorer.getUUID,'polyspace'};
            makeCPFilter.Enabled=SlCov.CoverageAPI.checkPolyspaceLicense()&&~isSldvHarness;
            makeCPFilter.Tag=[tag,'makeCPFilter'];
            makeCPFilter.WidgetId=[tag,'makeCPFilter'];
            makeCPFilter.DialogRefresh=true;

            rowIdx=numel(groupFile.Items)+1;
            makeCPFilter.RowSpan=[rowIdx,rowIdx];
            groupFile.Items=[groupFile.Items,{makeCPFilter}];
            groupFile.LayoutGrid=[rowIdx,2];
        end

        panel.Flat=true;
        panel.LayoutGrid=[3,3];
        panel.RowStretch=[1,0,0];
        panel.Type='panel';
        panel.Items={groupFile};


        dlg.Items={info,panel};
        dlg.DialogTitle=getString(message('Slvnv:simcoverage:cvresultsexplorer:FilterEditor'));
        dlg.DialogTag=cvi.FilterExplorer.FilterTree.dlgTag;
        dlg.HelpArgs={dlg.DialogTag};
        dlg.HelpMethod='cvi.ResultsExplorer.ResultsExplorer.helpFcn';

        cvi.FilterExplorer.FilterTree.menuNode(obj.filterExplorer.getUUID,obj.filterExplorer);

    catch MEx
        display(MEx.stack(1));
    end
end
