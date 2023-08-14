function result=navigate(dest)




    try
        rmi.navigate(dest.domain,dest.artifact,dest.id);
        result='';
    catch ex
        result=sprintf('<font color="red">%s</font>',ex.message);
    end
end
