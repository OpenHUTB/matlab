function blkdgm=getBdRoot(h)




    if~h.isLoaded||isempty(h.daobject)
        blkdgm=h.Name;
    else
        bd=locGetBD(h.daobject);
        if isempty(bd)
            blkdgm='';
        else
            blkdgm=bdroot(bd);
        end
    end

end


function bd=locGetBD(obj)


    bd=[];
    if(~isa(obj,'DAStudio.Object')&&~isa(obj,'Simulink.DABaseObject'))
        return
    end

    while(~isa(obj,'Simulink.BlockDiagram'))
        obj=obj.getParent;
    end

    bd=obj.getFullName;
end
