function[yesno,inLibSID]=isActiveLibRefSID(sid)




    yesno=false;
    inLibSID='';

    blk=Simulink.ID.getHandle(sid);
    if strcmp(get_param(blk,'StaticLinkStatus'),'implicit')
        yesno=true;
        if nargout>1
            refBlk=get_param(blk,'ReferenceBlock');
            inLibSID=Simulink.ID.getSID(refBlk);
        end
    end
end
