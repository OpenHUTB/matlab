function hdlarch=insertComment(this,hdlarch,fldname,commentstr)








    indentedcomment=['  ',hdlgetparameter('comment_char'),' '];

    comment=[indentedcomment,commentstr,'\n\n'];
    hdlarch.(fldname)=[hdlarch.(fldname),comment];


