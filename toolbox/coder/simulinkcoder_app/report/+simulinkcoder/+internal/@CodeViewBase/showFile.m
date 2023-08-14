function showFile(obj,file,line,select)




    action='showFile';
    data.file=file;
    if nargin>2
        data.line=line;
    end
    if nargin>3
        data.select=select;
    end

    cv=obj.src;
    cv.publish(action,data);

