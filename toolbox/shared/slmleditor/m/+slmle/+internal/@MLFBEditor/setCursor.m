function setCursor(obj,line,col)



    data=[];
    data.line=line;
    data.col=col;
    obj.publish('setCursor',data);

