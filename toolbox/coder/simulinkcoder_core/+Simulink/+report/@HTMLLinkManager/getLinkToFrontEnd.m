function out=getLinkToFrontEnd(obj,sid,txt)




    if strfind(sid,sprintf('\n'))
        sidList=sid;







        thisObj=[];
        while isempty(thisObj)&&~isempty(sidList)
            [head,tail]=strtok(sidList,sprintf('\n'));
            try
                thisObj=Simulink.ID.getHandle(head);
            catch MEx %#ok<NASGU>
            end
            sidList=tail;
        end
        sid=head;
    end
    if isTempModelSID(obj,sid)
        try
            subsystemBuildSID=obj.getSubsystemBuildSID(sid);
            if~isempty(subsystemBuildSID)
                sid=subsystemBuildSID;
            end
        catch me %#ok<NASGU>
        end
    end
    if nargin<3
        try
            if iscell(obj.SystemMap)
                txt=rtw.report.ReportInfo.getCommentTag(sid,obj.SystemMap);
            else
                [block,ssid]=Simulink.ID.getFullName(sid);
                txt=[block,ssid];
            end
        catch me %#ok<NASGU>
            txt=sid;
            sid='';
        end
    end
    if obj.HTMLEscape


        sanitized=~isempty(strfind(txt,'&lt;'))||~isempty(strfind(txt,'&gt;'))||~isempty(strfind(txt,'&amp;'));

        if~sanitized
            txt=rtwprivate('rtwhtmlescape',txt);
        end
    end

    out=txt;
    isHidden=false;
    try


        isHidden=strcmp(get_param(sid,'Hidden'),'on');
    catch e %#ok<NASGU>
    end



    if obj.IncludeHyperlinkInReport&&~isempty(sid)&&~isHidden&&~obj.isTempModelSID(sid)&&~isempty(txt)
        out=['<a href="',obj.getHiliteCallback(sid),'" name="code2model" class="code2model">',txt,'</a>'];
    end
end


