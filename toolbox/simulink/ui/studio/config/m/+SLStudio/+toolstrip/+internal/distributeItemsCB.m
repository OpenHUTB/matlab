function distributeItemsCB(userdata,cbinfo)
    strArray=split(userdata,':');
    affinity=strArray{1};
    direction=strArray{2};
    cbinfo.studio.App.getActiveEditor.distributeItems(affinity,direction);
end
