function out=isUpToDate(obj)
    bdModifiedTime=get_param(bdroot(obj.getActiveModelName),'RTWModifiedTimestamp');
    codegenTime=rtwprivate('convertTimeStamp',obj.Summary.TimeStamp);
    if(bdModifiedTime>codegenTime)
        out=false;
    else
        out=true;
    end
end
