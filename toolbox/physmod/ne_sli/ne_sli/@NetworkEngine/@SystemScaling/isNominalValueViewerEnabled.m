function isEnabled=isNominalValueViewerEnabled(hSource,~)







    isEnabled=~isempty(hSource.getModel)&&...
    hSource.isActive&&...
    strcmpi(hSource.SimscapeNormalizeSystem,'on');

end
