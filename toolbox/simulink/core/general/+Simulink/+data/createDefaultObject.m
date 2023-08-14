function object=createDefaultObject(className,forceAutoSC)





    try
        object=eval(className);
        if forceAutoSC
            object.CoderInfo.StorageClass='Auto';
        end
    catch e
        errordlg(e.message);
        e.throw();
    end

