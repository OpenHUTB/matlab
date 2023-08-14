function footer=getFooter(con)




    if isempty(con)
        footer='';
    elseif isempty(con.Variables)
        msgId="optim_problemdef:"+con.className+":NoConstraintDefined";
        footer=getString(message(msgId));
        footer=sprintf('  %s\n',footer);
    else

        helpPopupStr="optim.problemdef."+con.className+"/show";
        [startTag,endTag]=optim.internal.problemdef.createHotlinks(...
        'helpPopup',helpPopupStr);


        msgId="optim_problemdef:"+con.className+":ArrayFooterStr";
        footer=getString(message(msgId,startTag,endTag));
        footer=sprintf('  %s\n',footer);
    end


    if~isempty(con)&&strcmp(get(0,'FormatSpacing'),'compact')
        footer=sprintf('\n%s',footer);
    end
