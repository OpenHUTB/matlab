function scopeToSeedView(sigId)




    engine=Simulink.sdi.Instance.engine;


    sid=engine.getSignalSID(sigId);
    fullpath=engine.getSignalBlockSource(sigId,true);
    bpath=fullpath{end};


    try
        hBlk=Simulink.ID.getHandle(sid);
        obj=get_param(hBlk,'Object');
        if~isa(obj,'Simulink.BlockDiagram')
            blockPath=obj.getFullName();
        else

            blockPath=bpath;
        end
    catch me %#ok<NASGU>
        blockPath=bpath;
    end


    try

        subSys=get_param(blockPath,'Parent');

        if length(fullpath)>1

            parentSys=get_param(subSys,'Parent');
            if isempty(parentSys)

                fullpath(end)=[];
            else

                fullpath{end}=subSys;
            end
            bp=Simulink.BlockPath(fullpath);

            try
                validate(bp);
                open(bp);
            catch me %#ok<NASGU>

                open_system(subSys);
            end
        else
            open_system(subSys);
        end
    catch me %#ok<NASGU>
    end

end
