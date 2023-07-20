




function varargout=saveRestorePoint(this,name,description)

    try
        saveObj=Advisor.Utils.SaveRestorePoint.getSaveRestorePointObject(this,name,description);
        if nargout==1
            varargout{1}=saveObj.save;
        else
            saveObj.save;
        end

    catch E


        disp(E.message);
        rethrow(E);
    end

end
