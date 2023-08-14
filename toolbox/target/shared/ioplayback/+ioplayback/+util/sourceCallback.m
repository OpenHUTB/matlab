function sourceCallback(blk,~)




    maskObj=get_param(blk,'MaskObject');
    tmp=get_param(blk,'SimulationOutput');
    if isequal(tmp,'From recorded file')


        p=getParameter(maskObj,'DatasetName');
        p.Visible='on';
        p=getParameter(maskObj,'SourceName');
        p.Visible='on';
        c=getDialogControl(maskObj,'browser');
        c.Visible='on';
        c=getDialogControl(maskObj,'sourceSelector');
        c.Visible='on';
    else
        p=getParameter(maskObj,'DatasetName');
        p.Visible='off';
        p=getParameter(maskObj,'SourceName');
        p.Visible='off';
        c=getDialogControl(maskObj,'browser');
        c.Visible='off';
        c=getDialogControl(maskObj,'sourceSelector');
        c.Visible='off';
    end
end
