function ReportFolderBrowseCB(aObj)





    aObj.fViaGUI=true;
    dir=uigetdir;
    if~strcmpi(class(dir),'double')
        try
            aObj.setWidgetValue('ReportFolder',dir);
        catch ME
            aObj.HandleException(ME);
        end
    end
    aObj.fViaGUI=false;
end

