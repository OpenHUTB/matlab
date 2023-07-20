function isSLC=isSingleLineComments(cs)


    isSLC=false;
    if(strcmp(get_param(cs,'IsERTTarget'),'on'))
        commentsStr=get_param(cs,'CommentStyle');
        if(~strcmp(get_param(cs,'TargetLang'),'C')&&...
            strcmp('Auto',commentsStr))||...
            strcmp('Single-line',commentsStr)
            isSLC=true;
        end
    end
