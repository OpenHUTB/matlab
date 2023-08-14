function enabled=isDialogFeatureOn()


    try
        enabled=(exist('cv','file')==3)&&...
        strcmpi(cv('Feature','enable slcovcc dialog'),'on');
    catch
        enabled=false;
    end
end
