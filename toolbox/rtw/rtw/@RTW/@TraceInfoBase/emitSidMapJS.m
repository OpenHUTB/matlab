function emitSidMapJS(h,filename)





    fid=fopen(filename,'w','n','utf-8');
    fwrite(fid,sprintf('function RTW_SidParentMap() {\n'),'char');
    fwrite(fid,sprintf('    this.sidParentMap = new Array();\n'),'char');
    try
        arrayfun(@(x)(locWriteCodeLocation(fid,x)),h.Registry);
    catch me
        fclose(fid);
        rethrow(me);
    end
    fwrite(fid,sprintf('    this.getParentSid = function(sid) { return this.sidParentMap[sid];}\n}\n'),'char');
    fwrite(fid,sprintf('    RTW_SidParentMap.instance = new RTW_SidParentMap();\n'),'char');
    fclose(fid);

    function locWriteCodeLocation(fid,reg)
        if 0==slfeature('TraceVarSource')
            sid=reg.sid;
        else
            h=Simulink.URL.parseURL(reg.sid);
            if class(h)=="Simulink.URL.SID"
                sid=reg.sid;
            else
                sid=h.getParent;
            end
        end
        pid=Simulink.ID.getParent(sid);
        str=sprintf('    this.sidParentMap["%s"] = "%s";\n',sid,pid);
        fwrite(fid,str,'char');


