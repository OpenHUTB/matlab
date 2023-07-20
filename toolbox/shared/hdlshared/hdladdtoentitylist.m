function hdladdtoentitylist(fullpath,nname,hdl_entity_ports,hdl_arch)



    if hdlisfiltercoder
        hdl_parameters=PersistentHDLPropSet;
        hINI=hdl_parameters.INI;
        hFC=hINI.getPropSet('Filter').getPropSet('Common');

        if isempty(hFC.entitynamelist)
            hFC.entitypathlist{1}=fullpath;
            hFC.entitynamelist{1}=nname;
            hFC.entityportlist{1}=hdl_entity_ports;
            hFC.entityarchlist{1}=hdl_arch;
        else
            loc=strcmpi(nname,hFC.entitynamelist);
            if any(loc)
                error(message('HDLShared:directemit:duplicateaddentity',nname))
            else
                hFC.entitypathlist{end+1}=fullpath;
                hFC.entitynamelist{end+1}=nname;
                hFC.entityportlist{end+1}=hdl_entity_ports;
                hFC.entityarchlist{end+1}=hdl_arch;
            end
        end
    else
        hCurrentDriver=hdlcurrentdriver;
        hCurrentDriver.updateDriverState(fullpath,nname);
    end
end
