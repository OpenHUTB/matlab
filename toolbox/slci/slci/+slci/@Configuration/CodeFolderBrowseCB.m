function CodeFolderBrowseCB(aObj)





    aObj.fViaGUI=true;
    dir=uigetdir;
    if~strcmpi(class(dir),'double')
        try
            aObj.setWidgetValue('CodeFolder',dir);
        catch ME
            aObj.HandleException(ME);
        end
    end
    aObj.fViaGUI=false;
end

