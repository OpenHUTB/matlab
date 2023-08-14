
function checkbox=getCheckBoxSrc(name,varname,tag)
    checkbox.Name=DAStudio.message(name);
    checkbox.Type='checkbox';
    checkbox.ObjectProperty=varname;
    checkbox.Mode=true;
    checkbox.DialogRefresh=true;
    checkbox.Tag=tag;
end