function[msg_html,msg_title]=hdlRemoveHtmlonlyTitle(msg_html)








    [~,~,start_title_tag,end_title_tag]=hdlgetHtmlonlyTags;


    default_msg_title='HTML Message';


    html_title_start=strfind(msg_html,start_title_tag);
    html_title_end=strfind(msg_html,end_title_tag);

    if~isempty(html_title_start)&&...
        (length(html_title_start)==length(html_title_end))


        len_title_start=length(start_title_tag);
        len_title_end=length(end_title_tag);

        msg_title=msg_html(html_title_start(1)+len_title_start:...
        html_title_end(1)-1);

        if isempty(msg_title)
            msg_title=default_msg_title;
        end

        msg_html=[msg_html(1:html_title_start-1)...
        ,msg_html(html_title_end+len_title_end:end)];
    else

        msg_title=default_msg_title;
    end

end

