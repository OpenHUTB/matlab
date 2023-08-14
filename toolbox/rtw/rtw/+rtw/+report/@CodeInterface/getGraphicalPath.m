function out=getGraphicalPath(~,data)
    sid=data.SID;
    if isempty(sid)


        out=data.GraphicalName;
    else
        if isValidSlObject(slroot,sid)
            if strcmp(get_param(Simulink.ID.getHandle(sid),'Type'),'block_diagram')
                arg=data.GraphicalName;
                out=DAStudio.message('RTW:codeInfo:reportModelArgument',arg);
            else
                out=getfullname(sid);
            end
        else
            out=DAStudio.message('RTW:codeInfo:reportSynthesizedBlock');
        end
    end
end
