function tf=isLabelMode(blk)







    labelValue=get_param(blk,'LabelModeActiveChoice');
    tf=~isempty(labelValue);
end
