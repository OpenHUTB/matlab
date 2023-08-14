function cmt=createComment(d,commentString)





    if rptgen.use_java
        cmt=javaMethod('createComment',...
        java(d),...
        rptgen.toString(commentString,0));
    else
        cmt=createComment(d.Document,rptgen.toString(commentString,0));
    end