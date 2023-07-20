function str=formatDispStr(str,indentLevel)



    str=['### ',blanks((indentLevel-1)*3),str,char(10)];
