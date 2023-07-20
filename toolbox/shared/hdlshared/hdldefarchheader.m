function comment=hdldefarchheader(nname)






    commentchars=hdlgetparameter('comment_char');

    separatorline=[repmat(commentchars,1,floor(64/length(commentchars))),'\n'];

    comment=[separatorline,...
    commentchars,'Module Architecture: ',nname,'\n',...
    separatorline];


