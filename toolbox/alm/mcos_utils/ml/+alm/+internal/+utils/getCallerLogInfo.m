function stackEntry=getCallerLogInfo()





    st=dbstack;
    if numel(st)>1
        stackEntry=st(2);
    else
        stackEntry=struct(...
        "file",'unknown',...
        "name",'unknown',...
        "line",0);
    end

end
