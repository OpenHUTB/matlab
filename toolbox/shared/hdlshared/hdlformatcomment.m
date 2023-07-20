function formatted_comment=hdlformatcomment(unformatted_comment,indent,comment_char)













    if isempty(unformatted_comment)
        formatted_comment=unformatted_comment;
    else
        if(nargin>1&&~isempty(indent))

            comment_prefix=blanks(indent);
        else
            comment_prefix='';
        end

        if(nargin<3||isempty(comment_char))
            comment_char=hdlgetparameter('comment_char');
        end
        comment_prefix=[comment_prefix,comment_char,' '];


        comment_cont=[char(10),comment_prefix];


        formatted_comment=[comment_prefix,unformatted_comment];

        formatted_comment=strrep(formatted_comment,char(10),comment_cont);

        formatted_comment=strrep(formatted_comment,'\n',comment_cont);

        formatted_comment=[formatted_comment,char(10)];
    end
