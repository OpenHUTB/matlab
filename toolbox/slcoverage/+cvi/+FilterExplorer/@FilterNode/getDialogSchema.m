
function dlg=getDialogSchema(obj,~)




    dlgTag=cvi.FilterExplorer.FilterNode.dlgTag;


    [filterPanel,obj.editNameTag,obj.editDescrTag]=getFilterPanel(obj,dlgTag);
    dlg.Sticky=true;
    dlg.LayoutGrid=[3,1];
    dlg.RowStretch=[0,0,1];
    dlg.Items=filterPanel.Items;
    title=getString(message('Slvnv:simcoverage:cvresultsexplorer:FilterEditor'));

    dlg.DialogTitle=title;

    dlg.DialogTag=[dlgTag,'dialog'];
    dlg.PreApplyArgs={obj};
    dlg.PreApplyCallback='preApplyCallback';
    dlg.PostApplyArgs={obj,'%dialog',obj.editNameTag,obj.editDescrTag};
    dlg.PostApplyCallback='postApplyCallback';
    dlg.PostRevertArgs={obj,'%dialog'};
    dlg.PostRevertCallback='postRevertCallback';
    dlg.CloseArgs={obj,'%dialog',obj.editNameTag,obj.editDescrTag};
    dlg.CloseCallback='closeCallback';
    dlg.HelpArgs={dlg.DialogTag};
    dlg.HelpMethod='cvi.ResultsExplorer.ResultsExplorer.helpFcn';


end


function[filterPanel,editNameTag,editDescrTag]=getFilterPanel(obj,dlgTag)
    widgetId=dlgTag;
    filterObj=obj.filterRec.filterObj;
    editName.Name=getString(message('Slvnv:simcoverage:cvresultsexplorer:FilterName'));
    editName.Type='edit';
    editName.RowSpan=[1,1];
    editName.ColSpan=[1,6];

    editName.Source=filterObj;
    editName.Value=filterObj.filterName;
    editName.Tag=[dlgTag,'editName'];
    editName.WidgetId=[dlgTag,'editName'];
    editNameTag=editName.Tag;

    [~,tmpFileName]=fileparts(obj.filterRec.fileName);
    if isempty(tmpFileName)
        tmpFileName=getString(message('Slvnv:simcoverage:cvresultsexplorer:NotSaved'));
    end
    filterFileName.Name=[DAStudio.message('Slvnv:simcoverage:covFilterFilename'),' ',tmpFileName];
    filterFileName.Type='text';
    filterFileName.RowSpan=[2,2];
    filterFileName.ColSpan=[1,1];
    filterFileName.Tag=[dlgTag,'filterFilename'];
    filterFileName.WidgetId=[widgetId,'filterFilename'];



    saveFilter.Name=getString(message('Slvnv:simcoverage:cvresultsexplorer:SaveAs'));
    saveFilter.Type='hyperlink';
    saveFilter.MatlabMethod='saveFilter';
    saveFilter.MatlabArgs={obj};
    saveFilter.RowSpan=[3,3];
    saveFilter.ColSpan=[1,2];
    saveFilter.Tag=[dlgTag,'saveFilter'];
    saveFilter.WidgetId=[dlgTag,'saveFilter'];

    infoGroup.Type='panel';
    infoGroup.Flat=true;
    infoGroup.LayoutGrid=[3,6];
    infoGroup.RowSpan=[2,2];
    infoGroup.Items={editName,filterFileName,saveFilter};
    infoGroup.Tag=[dlgTag,'infoGroup'];
    infoGroup.WidgetId=[dlgTag,'infoGroup'];


    editDescr.Type='editarea';
    editDescr.RowSpan=[3,3];
    editDescr.ColSpan=[1,6];
    editDescr.Source=filterObj;
    editDescr.Value=filterObj.filterDescr;
    editDescr.MaximumSize=[1000,40];
    editDescr.Tag=[dlgTag,'editDescr'];
    editDescr.WidgetId=[dlgTag,'editDescr'];
    editDescrTag=editDescr.Tag;



    descrGroup.Type='group';
    descrGroup.Name=[getString(message('Slvnv:simcoverage:cvresultsexplorer:Description')),'  '];
    descrGroup.Flat=true;
    descrGroup.LayoutGrid=[3,6];
    descrGroup.RowSpan=[2,2];
    descrGroup.Items={editDescr};
    descrGroup.Tag=[dlgTag,'descrGroup'];
    descrGroup.WidgetId=[dlgTag,'descrGroup'];


    help=getString(message('Slvnv:simcoverage:cvresultsexplorer:NewRuleHelp'));
    filterState=getFilterStateGroup(filterObj,dlgTag,widgetId,help);

    ruleGroup.Type='group';
    ruleGroup.Name=getString(message('Slvnv:simcoverage:cvresultsexplorer:FilterRules'));
    ruleGroup.Flat=true;
    ruleGroup.RowSpan=[2,2];
    ruleGroup.Items={filterState};
    ruleGroup.Tag=[dlgTag,'descrGroup'];
    ruleGroup.WidgetId=[dlgTag,'descrGroup'];



    filterPanel.LayoutGrid=[3,3];
    filterPanel.RowStretch=[1,0,0];
    filterPanel.Type='panel';
    filterPanel.Items={infoGroup,descrGroup,ruleGroup};

    filterPanel.Name=getString(message('Slvnv:simcoverage:cvresultsexplorer:FilterPanel'));
    filterPanel.Tag=[dlgTag,'filterPanel'];
    filterPanel.WidgetId=[widgetId,'filterPanel'];

end
