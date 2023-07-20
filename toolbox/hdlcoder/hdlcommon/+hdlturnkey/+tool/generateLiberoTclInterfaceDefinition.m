function generateLiberoTclInterfaceDefinition(fid,interface,dirMode,type,portlist,instanceIPCoreName)




    if dirMode==hdlturnkey.IOType.IN
        interfaceMode='end';
    else
        interfaceMode='start';
    end

    [~,fileName,~]=fileparts(instanceIPCoreName);

    model=bdroot;
    if isempty(model)

        hDriver=hdlcurrentdriver;
    else

        hDriver=hdlmodeldriver(model);
    end

    hDI=hDriver.DownstreamIntegrationDriver;
    FPGAFamilyName=hDI.get('Family');


    if(strcmp(interface,'s_axi')||strcmp(interface,'AXI4_Master'))
        fprintf(fid,'# Connection point for Bus Interface\n');
        interfaceDef=split(interface,'_');
        if strcmp(interfaceDef{2},'axi')
            interfaceDef{2}='Slave';
        end
        if strcmp(interface,'AXI4_Master')
            downstreamtools.Plugin_Tcl_Libero.getTclAddBusInterfaceDefn(fid,fileName,FPGAFamilyName,lower(interfaceDef{2}),interface);
        elseif strcmp(type,'AXI4_Lite')
            downstreamtools.Plugin_Tcl_Libero.getTclAddBusInterfaceDefn(fid,fileName,FPGAFamilyName,lower(interfaceDef{2}),type);
        else
            downstreamtools.Plugin_Tcl_Libero.getTclAddBusInterfaceDefn(fid,fileName,FPGAFamilyName,lower(interfaceDef{2}),...
            hdlturnkey.ip.IPEmitterLibero.busInterfacePortName);

        end
        for j=1:numel(portlist)
            if(strcmp(interface,'s_axi'))
                if strcmp(type,'axi4')
                    bifSig=strrep(portlist{j}{1},'AXI4_','');
                    downstreamtools.Plugin_Tcl_Libero.getTclAddBusInterfaceSignals(fid,fileName,...
                    hdlturnkey.ip.IPEmitterLibero.busInterfacePortName,bifSig,portlist{j}{1});
                else
                    bifSig=strrep(portlist{j}{1},'AXI4_Lite_','');
                    downstreamtools.Plugin_Tcl_Libero.getTclAddBusInterfaceSignals(fid,fileName,type,bifSig,portlist{j}{1});
                end
            else
                if strcmp(interface,'AXI4_Master')
                    RdWrSig=split(portlist{j}{1},'_');
                    if strcmp(RdWrSig{3},'Rd')
                        bifSig=strrep(portlist{j}{1},'AXI4_Master_Rd_','');
                        downstreamtools.Plugin_Tcl_Libero.getTclAddBusInterfaceSignals(fid,fileName,interface,bifSig,portlist{j}{1});

                    else
                        bifSig=strrep(portlist{j}{1},'AXI4_Master_Wr_','');
                        downstreamtools.Plugin_Tcl_Libero.getTclAddBusInterfaceSignals(fid,fileName,interface,bifSig,portlist{j}{1});

                    end
                end
            end
        end
        fprintf(fid,'\n');
    else
        fprintf(fid,'# connection point %s\n',interface);
        ipCoreLiberoInst=[fileName,'_0'];
        for ii=1:numel(portlist)
            thisPort=portlist{ii};
            fprintf(fid,'sd_connect_pin_to_port -sd_name %s -pin_name %s:%s -port_name %s',hdlturnkey.ip.IPEmitterLibero.smartDesignName,...
            ipCoreLiberoInst,thisPort{ii},interface);
            fprintf(fid,'\n');
        end
        fprintf(fid,'\n');
    end
end
