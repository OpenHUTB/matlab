function hostName=getLocalHostName(this)






    try
        if ispc
            [dummy,hostName]=dos('HOSTNAME');
        else
            hostName=getenv('HOST');
        end
        hostName=strtrim(hostName);
    catch
        hostName='';
    end


