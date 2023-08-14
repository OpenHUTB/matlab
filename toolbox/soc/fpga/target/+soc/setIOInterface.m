function setIOInterface(sys,dut,intfInfo,verbose,resetIOInterface)
    this_blk=[sys,'/',dut];
    if verbose
        fprintf('---------- Preparing %s for IPCore generation ----------\n',this_blk);
        fprintf('---------- Validating port sample rates ----------\n');
    end

    if nargin<5
        resetIOInterface=true;
    end

    inp=find_system(this_blk,'LookUnderMasks','all','SearchDepth',1,'FollowLinks','on','BlockType','Inport');
    outp=find_system(this_blk,'LookUnderMasks','all','SearchDepth',1,'FollowLinks','on','BlockType','Outport');
    all_port=[inp;outp];



    ipcore_name=soc.util.getIPCoreName(this_blk);
    hdlset_param(this_blk,'IPCoreName',ipcore_name);


    ipcore_ver=soc.util.getIPCoreVersion(this_blk);
    hdlset_param(this_blk,'IPCoreVersion',ipcore_ver);

    if verbose
        fprintf('### Setting IPCoreName to %s\n',ipcore_name);
        fprintf('### Setting IPCoreVersion to %s\n',ipcore_ver);
    end


    if resetIOInterface
        for i=1:numel(all_port)
            hdlset_param(all_port{i},'IOInterface','');
            hdlset_param(all_port{i},'IOInterfaceMapping','');
        end
    end

    for i=1:numel(all_port)
        thisPort=all_port{i};
        if isKey(intfInfo,thisPort)
            thisPortIntfInfo=intfInfo(thisPort);
            hdlset_param(thisPort,'IOInterface',thisPortIntfInfo.interface);
            if~strcmpi(thisPortIntfInfo.interfacePort,'interrupt')
                hdlset_param(thisPort,'IOInterfaceMapping',thisPortIntfInfo.interfacePort);
            end
            if verbose
                fprintf('### Setting IOInterface of %s to %s\n',thisPort,thisPortIntfInfo.interface);
                if~isempty(thisPortIntfInfo.interfacePort)
                    fprintf('### Setting IOInterfaceMapping of %s to %s\n',thisPort,thisPortIntfInfo.interfacePort);
                end
            end
        end
    end
end

