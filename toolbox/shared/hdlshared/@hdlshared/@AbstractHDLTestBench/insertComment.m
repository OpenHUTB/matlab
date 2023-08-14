function formated_comment=insertComment(this,comment_string)




    comment_char=hdlgetparameter('comment_char');
    indentedcomment=['  ',comment_char,' '];
    separatorline=['  ',comment_char,' ','-'*ones(1,63-length(comment_char)),'\n'];

    formated_comment=cell2mat([separatorline,...
    indentedcomment,comment_string,'\n',...
    separatorline]);
