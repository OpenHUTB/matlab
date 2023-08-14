function[bResult,message]=updateSystemObject(hBlock)
    className=get_param(hBlock,'system');
    classPath=which(className);
    bResult=false;
    info={};

    try
        info=sysobjupdate(className,'-inplace','-nobackup');
    catch e
        message=e.message;
        return;
    end

    bResult=true;
    if isempty(info)
        message='';
    else
        if isempty(info.Messages)
            message=DAStudio.message('MATLAB:system:Advisor:CheckSystemObject_uptodate',className,classPath);
        else
            message=info.Messages;
        end
    end
end