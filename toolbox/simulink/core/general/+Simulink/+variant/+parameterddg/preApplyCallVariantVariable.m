function[status,msg]=preApplyCallVariantVariable(obj,dlg)





    status=true;
    msg='';

    try




        ddgCreator=dlg.getWidgetSource(obj.SpreadSheetTag).fDDGCreator;
        dlgSrc=dlg.getSource();
        if isa(dlgSrc,'Simulink.dd.EntryDDGSource')
            dlgSrc.setEntryValue(ddgCreator.fVariantVariable);
        else
            evaluator=Simulink.variant.parameterddg.Evaluator(dlg.getContext);
            evaluator.assign(obj.fVariableName,ddgCreator.fVariantVariable);
        end
    catch ME
        status=false;
        msg=ME.message;
    end
end
