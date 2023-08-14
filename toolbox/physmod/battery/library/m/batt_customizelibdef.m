function entry=batt_customizelibdef(entry)





    hBlockLink=batt_private('battDocumentationFcn');
    battDocRoot='simscape-battery';
    entry.documentationfcn=hBlockLink([battDocRoot,'/index.html'],...
    [battDocRoot,'/ref']);
end
