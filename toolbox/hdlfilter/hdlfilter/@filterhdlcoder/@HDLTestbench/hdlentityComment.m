function hdlcode=hdlentityComment(this,node,level,nname)





    commentchars=hdlgetparameter('comment_char');
    revisiontag=hdlgetparameter('rcs_cvs_tag');
    if isempty(revisiontag)
        rcs_cvs_tag='';
    else
        rcs_cvs_tag=[revisiontag,commentchars,'\n'];
    end


    fheader=sptfileheader('','hdlfilter',commentchars,31);
    separatorline=[commentchars,' ','-'*ones(1,63-length(commentchars)),'\n'];
    if hdlgetparameter('isvhdl')
        hdlcode=[separatorline,...
        commentchars,'\n',...
        commentchars,' Module: ',nname,'\n',...
        fheader,...
        '\n',...
        rcs_cvs_tag,...
        separatorline,...
        '\n',...
        separatorline];
    else

        hdlcode='';
    end


