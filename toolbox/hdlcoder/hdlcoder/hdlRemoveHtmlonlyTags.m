function[msg_html,msg_title]=hdlRemoveHtmlonlyTags(msg_html)









    [start_tag,end_tag]=hdlgetHtmlonlyTags;


    msg_html=strrep(msg_html,start_tag,'');
    msg_html=strrep(msg_html,end_tag,'');


    [msg_html,msg_title]=hdlRemoveHtmlonlyTitle(msg_html);

end

