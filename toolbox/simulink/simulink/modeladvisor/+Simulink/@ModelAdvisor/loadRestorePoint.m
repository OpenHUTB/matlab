




function loadRestorePoint(this,name)
    try

        loadObj=Advisor.Utils.LoadRestorePoint.getLoadRestorePointObject(this,name);
        loadObj.load;
    catch E


        disp(E.message);
        rethrow(E);
    end
end
