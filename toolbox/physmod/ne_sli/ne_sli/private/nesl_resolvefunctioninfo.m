function[result,msg]=nesl_resolvefunctioninfo(info)





    if~info.IsFile
        result='';
        msg=getString(message('physmod:ne_sli:dialog:SimscapeFileNotFound',...
        info.FileName));
    elseif~info.IsSimscapeType
        result='';
        msg=getString(message('physmod:ne_sli:dialog:UnsupportedSimscapeFileType',...
        info.FileName));
    elseif info.IsShadowed
        result='';
        if info.IsOnPath
            msg=sprintf('The file %s is shadowed by %s',info.FileName,info.ShadowFile);
        else
            msg=getString(message('physmod:ne_sli:dialog:SimscapeFileShadowed',...
            info.FileName,info.ShadowFile));
        end
    elseif~info.IsOnPath&&~info.IsShadowed
        result='';
        msg=getString(message('physmod:simscape:engine:sli:block:FileNotOnPath',...
        info.FileName));
    else
        result=info.FunctionName;
        msg='';
    end

end
