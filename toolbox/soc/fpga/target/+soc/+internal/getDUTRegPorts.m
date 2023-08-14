function[inports,outports,inPortDims,outPortDims,regChPortMap]=getDUTRegPorts(dutBlk,topModel)

    inports={};
    outports={};
    inPortDims={};
    outPortDims={};
    regChPortMap=containers.Map;
    dutPortH=get_param(dutBlk,'porthandles');
    dutInports=find_system(dutBlk,'Searchdepth',1,'lookundermasks','on','blocktype','Inport');
    dutOutports=find_system(dutBlk,'Searchdepth',1,'lookundermasks','on','blocktype','Outport');

    for ii=1:numel(dutPortH.Inport)
        connBlk=soc.util.getSrcBlk(get_param(dutPortH.Inport(ii),'line'));
        if~isempty(connBlk)
            if strcmpi(get_param(connBlk,'blocktype'),'Inport')

                [topConnBlk,connPort]=soc.internal.getConnBlkInTop(topModel,connBlk);
                if~isempty(topConnBlk)&&...
                    any(strcmpi(soc.util.getRefBlk(topConnBlk),{'socregisterchanneli2clib/Register Channel I2C','socmemlib/Register Channel','hsblib_beta2/Register Channel'}))
                    regTableName=eval(get_param(topConnBlk,'regtablenames'));
                    regName=regTableName{str2double(get_param([topConnBlk,'/',connPort],'port'))};
                    regChPortMap(dutInports{ii})=regName;
                    continue;
                end
            end
        end
        if any(strcmp(hdlget_param(dutInports{ii},'IOInterface'),{'AXI4','AXI4-Lite'}))
            inports{end+1}=dutInports{ii};%#ok<*AGROW>
            dims=get_param(dutInports{ii},'PortDimensions');
            if strcmp(dims,'-1')
                error(message('soc:memmap:NotDefinedPortDims',dutInports{ii}));
            else
                inPortDims{end+1}=dims;
            end
        end
    end


    for ii=1:numel(dutPortH.Outport)
        connBlk=soc.util.getDstBlk(get_param(dutPortH.Outport(ii),'line'));

        if~isempty(connBlk)
            if strcmpi(get_param(connBlk{1},'blocktype'),'Outport')

                [topConnBlk,connPort]=soc.internal.getConnBlkInTop(topModel,connBlk{1});
                if~isempty(topConnBlk)&&...
                    any(strcmpi(soc.util.getRefBlk(topConnBlk),{'socregisterchanneli2clib/Register Channel I2C','socmemlib/Register Channel','hsblib_beta2/Register Channel'}))
                    regTableName=eval(get_param(topConnBlk{1},'regtablenames'));
                    regName=regTableName{str2double(get_param([topConnBlk{1},'/',connPort{1}],'port'))};
                    regChPortMap(dutOutports{ii})=regName;
                    continue;
                end
            end
        end
        if any(strcmp(hdlget_param(dutOutports{ii},'IOInterface'),{'AXI4','AXI4-Lite'}))
            outports{end+1}=dutOutports{ii};
            dims=get_param(dutOutports{ii},'PortDimensions');
            if strcmp(dims,'-1')
                error(message('soc:memmap:NotDefinedPortDims',dutOutports{ii}));
            else
                outPortDims{end+1}=dims;
            end
        end
    end
end