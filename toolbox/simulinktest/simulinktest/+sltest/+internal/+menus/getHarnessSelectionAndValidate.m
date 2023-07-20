function[sel,isCompatSingleSel]=getHarnessSelectionAndValidate(cbinfo)
    if slreq.utils.selectionHasMarkup(cbinfo)
        sel=[];
    else
        sel=cbinfo.getSelection();
    end
    isCompatSingleSel=false;
    if isempty(sel)&&isa(get_param(gcs,'Object'),'Simulink.BlockDiagram')
        sel=cbinfo.model;
    elseif isempty(sel)&&isa(get_param(gcs,'Object'),'Simulink.SubSystem')
        sel=get_param(gcs,'Object');
        isCompatSingleSel=true;
    else
        isCompatSingleSel=(numel(sel)==1)&&Simulink.harness.internal.isValidHarnessOwnerObject(sel);
        if~isCompatSingleSel&&isa(get_param(gcs,'Object'),'Simulink.SubSystem')
            sel=get_param(gcs,'Object');
            isCompatSingleSel=true;
        end
    end
end
