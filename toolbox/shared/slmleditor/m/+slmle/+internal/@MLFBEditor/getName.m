function name=getName(obj)



    try
        if strcmp(obj.type,'EMChart')
            name=getfullname(obj.blkH);
        else
            name=slmle.internal.object2Data(obj.objectId,'blkName');
        end
    catch
        name='';
    end

