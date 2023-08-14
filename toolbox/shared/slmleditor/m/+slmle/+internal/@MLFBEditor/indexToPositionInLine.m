function[line,column]=indexToPositionInLine(obj,index)



    text=obj.fText;
    [line,column]=slmle.internal.indexToPositionInLine(text,index);

