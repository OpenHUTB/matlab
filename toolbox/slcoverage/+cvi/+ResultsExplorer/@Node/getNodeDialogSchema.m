function dlg=getNodeDialogSchema(obj,needsItems)





    dlgTag='Node_';

    dlg.DialogTitle=getString(message('Slvnv:simcoverage:cvresultsexplorer:CoverageData'));
    dlg.LayoutGrid=[5,1];
    dlg.RowStretch=[0,0,0,1,0];
    dlg.Sticky=true;
    if needsItems
        [dlg.Items,editDescrTag,editTagTag,excludeInactiveVariantsTag]=getItems(obj,dlgTag);
    else
        dlg.Items={};
        editDescrTag='';
        editTagTag='';
        excludeInactiveVariantsTag='';
    end
    dlg.DialogTag=[dlgTag,'dialog'];
    dlg.PostApplyArgs={obj,'%dialog',editDescrTag,editTagTag,excludeInactiveVariantsTag};
    dlg.PostApplyCallback='postApplyCallback';
    dlg.PostRevertArgs={obj,'%dialog'};
    dlg.PostRevertCallback='postRevertCallback';
    dlg.CloseArgs={obj,'%dialog',editDescrTag,editTagTag,excludeInactiveVariantsTag};
    dlg.CloseCallback='closeCallback';


end

function[items,editDescrTag,editTagTag,excludeInactiveVariantsTag]=getItems(obj,dlgTag)
    try
        infoGroup.Items={};
        for idx=1:numel(obj.data.info)
            info1.RowSpan=[idx,idx];
            info1.ColSpan=[1,1];
            info1.Type='text';
            info1.Name=obj.data.info{idx}{1};
            info1.Tag=[dlgTag,obj.data.info{idx}{3},'_text'];
            info2.RowSpan=[idx,idx];
            info2.ColSpan=[2,2];
            info2.Type='text';
            info2.Name=obj.data.info{idx}{2};
            info2.Tag=[dlgTag,obj.data.info{idx}{3}];
            infoGroup.Items=[infoGroup.Items,{info1,info2}];
        end

        infoGroup.Type='panel';
        infoGroup.Flat=true;
        infoGroup.LayoutGrid=[numel(obj.data.info),2];
        infoGroup.RowSpan=[1,1];
        infoGroup.Tag=[dlgTag,'infoGroup'];
        infoGroup.WidgetId=[dlgTag,'infoGroup'];

        editDescr.Type='editarea';
        editDescr.Source=obj.data;
        editDescr.Value=obj.data.getDescription;
        editDescr.MaximumSize=[1000,40];
        editDescr.Tag=[dlgTag,'editDescr'];
        editDescr.WidgetId=[dlgTag,'editDescr'];
        editDescrTag=editDescr.Tag;

        editTag.Name=getString(message('Slvnv:simcoverage:cvresultsexplorer:Tag'));
        editTag.Type='edit';
        editTag.Source=obj.data;
        editTag.Value=obj.data.tag;
        editTag.Tag=[dlgTag,'editTag'];
        editTag.WidgetId=[dlgTag,'editTag'];
        editTagTag=editTag.Tag;


        excludeInactiveVariantsCheckbox.Name=getString(message('Slvnv:simcoverage:dialog:CovExcludeInactiveVariants_Name'));
        excludeInactiveVariantsCheckbox.DialogRefresh=true;
        excludeInactiveVariantsCheckbox.Type='checkbox';

        excludeInactiveVariantsCheckbox.Enabled=isExclInactiveVariantApplicable(obj);
        if(excludeInactiveVariantsCheckbox.Enabled)
            excludeInactiveVariantsCheckbox.Value=obj.excludeInactiveVariantCheckboxValue;
        end
        excludeInactiveVariantsCheckbox.RowSpan=[1,1];
        excludeInactiveVariantsCheckbox.Tag=[dlgTag,'excludeInactiveVariantsCheckbox'];
        excludeInactiveVariantsCheckbox.WidgetId=[dlgTag,'excludeInactiveVariantsCheckbox'];
        excludeInactiveVariantsTag=excludeInactiveVariantsCheckbox.Tag;

        editDescrGroup.Type='group';
        editDescrGroup.Name=[getString(message('Slvnv:simcoverage:cvresultsexplorer:Description')),'  '];
        editDescrGroup.Flat=true;
        editDescrGroup.RowSpan=[2,2];
        editDescrGroup.Items={editDescr,editTag};
        editDescrGroup.Tag=[dlgTag,'editDescrGroup'];
        editDescrGroup.WidgetId=[dlgTag,'editDescrGroup'];


        summaryHtml=obj.getSummary();

        coverageSummary.Bold=true;

        coverageSummary.Type='textbrowser';
        coverageSummary.Visible=~isempty(summaryHtml);
        coverageSummary.Text=summaryHtml;
        coverageSummary.Graphical=true;


        coverageSummary.RowSpan=[2,2];
        coverageSummary.ColSpan=[1,1];
        coverageSummary.Tag=[dlgTag,'coverageSummary'];
        coverageSummary.WidgetId=[dlgTag,'coverageSummary'];

        coverageSummaryGroup.Type='group';
        coverageSummaryGroup.Name=[getString(message('Slvnv:simcoverage:cvresultsexplorer:Summary')),'  '];
        coverageSummaryGroup.Flat=true;
        coverageSummaryGroup.RowSpan=[3,3];
        coverageSummaryGroup.LayoutGrid=[2,1];
        coverageSummaryGroup.Items={coverageSummary};
        coverageSummaryGroup.Tag=[dlgTag,'coverageSummaryGroup'];
        coverageSummaryGroup.WidgetId=[dlgTag,'coverageSummaryGroup'];


        items={infoGroup,editDescrGroup,excludeInactiveVariantsCheckbox,coverageSummaryGroup,getActionGroup(obj,false)};
    catch
        items={};
        editDescrTag='';
        editTagTag='';
        excludeInactiveVariantsTag='';
    end
end

function res=isExclInactiveVariantApplicable(obj)

    res=false;
    cvd=obj.data.getCvd();
    if isempty(cvd)||~cvd.valid
        return;
    end

    if(isa(cvd,'cv.cvdatagroup'))
        allCvd=cvd.getAll;
    else
        allCvd={cvd};
    end
    hasFilterData=cellfun(@(c)~isempty([c.filterData]),allCvd);
    res=any(hasFilterData);
end