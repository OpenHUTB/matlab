function result=modelref_CommentStyle(csTop,csChild,varargin)














    topComments=csTop.get_param('CommentStyle');
    childComments=csChild.get_param('CommentStyle');


    result=~isequal(topComments,childComments);

    if result
        topLang=csTop.get_param('TargetLang');

        topIsAuto=strcmp(topComments,'Auto');
        topIsMultiLine=strcmp(topComments,'Multi-line');
        topIsSingleLine=strcmp(topComments,'Single-line');
        childIsAuto=strcmp(childComments,'Auto');
        childIsMultiLine=strcmp(childComments,'Multi-line');
        childIsSingleLine=strcmp(childComments,'Single-line');
        if((strcmp(topLang,'C')&&((topIsAuto&&childIsMultiLine)||...
            (topIsMultiLine&&childIsAuto)))||(~strcmp(topLang,'C')&&...
            ((topIsAuto&&childIsSingleLine)||(topIsSingleLine&&childIsAuto))))
            result=false;
        end
    end

end