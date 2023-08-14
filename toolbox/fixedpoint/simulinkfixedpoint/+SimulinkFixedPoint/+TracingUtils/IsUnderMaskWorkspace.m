function flag=IsUnderMaskWorkspace(blkObj)




    flag=false;

    curRoot=get_param(bdroot(blkObj.Handle),'Name');
    curParent=blkObj.parent;



    while~strcmp(curParent,curRoot)



        if hasmask(curParent)==2
            flag=true;
            return;
        end
        curParent=get_param(curParent,'parent');
    end


    if(hasmask(blkObj.getFullName)==2)
        if~isa(blkObj,'Simulink.SFunction')

            flag=true;
        end
    end
end