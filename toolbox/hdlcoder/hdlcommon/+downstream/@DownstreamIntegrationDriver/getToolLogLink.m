function msg=getToolLogLink(obj,taskName)




    hDI=obj;

    file=hDI.getToolLogFileName(taskName);
    link=sprintf('<a href="matlab:edit(''%s'')">%s</a>',file,file);
    msg=message('hdlcoder:workflow:SynthesisToolLog',link).getString;

end