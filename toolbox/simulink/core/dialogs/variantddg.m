function dlgstruct=variantddg(h,name)









    descTxt.Name=DAStudio.message('Simulink:dialog:VariantObject');
    descTxt.Type='text';
    descTxt.WordWrap=true;

    descGrp.Name='Simulink.Variant';
    descGrp.Type='group';
    descGrp.Items={descTxt};
    descGrp.RowSpan=[1,1];
    descGrp.ColSpan=[1,2];






    conditionLabel.Name=DAStudio.message('Simulink:dialog:SLVariantCondition');
    conditionLabel.Type='text';
    conditionLabel.RowSpan=[2,2];
    conditionLabel.ColSpan=[1,1];
    conditionLabel.Tag='ConditionLabel';

    condition.Name='';
    condition.RowSpan=[2,2];
    condition.ColSpan=[2,2];
    condition.Type='edit';
    condition.Tag='Condition_tag';
    condition.ObjectProperty='Condition';
    condition.Mode=1;
    condition.ValidationCallback=@i_ValidateConditionCallback;
    spacer.Name='';
    spacer.Type='text';
    spacer.RowSpan=[3,3];
    spacer.ColSpan=[1,2];




    dlgstruct.DialogTitle=[class(h),': ',name];
    dlgstruct.Items={descGrp,conditionLabel,condition,spacer};
    dlgstruct.LayoutGrid=[3,2];
    dlgstruct.HelpMethod='helpview';
    dlgstruct.HelpArgs={[docroot,'/mapfiles/simulink.map'],'simulink_variant_type'};
    dlgstruct.RowStretch=[0,0,1];
    dlgstruct.ColStretch=[0,1];




    if~strcmp(name,'default')
        dlgstruct.PostApplyCallback='updateVariantObjectInBlockDialogs';
        dlgstruct.PostApplyArgs={'%dialog',name};
    end


    function i_ValidateConditionCallback(dlg,tag,~,errMsg)



        if~isempty(errMsg)
            dlg.setWidgetWithError(tag)
            dp=DAStudio.DialogProvider;
            dp.errordlg(errMsg,'Error',true);
        else
            dlg.clearWidgetsWithError;
        end

