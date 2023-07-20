
function getDUTIntfInfo(hbuild,dutBlk,memMap)
    dutIntfInfo=containers.Map;
    intfInfo=hbuild.IntfInfo;

    inpDUT=find_system(dutBlk,'SearchDepth',1,'BlockType','Inport');
    outpDUT=find_system(dutBlk,'SearchDepth',1,'BlockType','Outport');
    allPortsDUT=[inpDUT;outpDUT];


    for i=1:numel(allPortsDUT)
        thisDUTPort=allPortsDUT{i};
        thisIntfInfo=intfInfo(thisDUTPort);
        ioInterface=thisIntfInfo.interface;
        ioInterfaceMapping=thisIntfInfo.interfacePort;
        if startsWith(ioInterface,'AXI4 Master','IgnoreCase',true)...
            &&strcmpi(ioInterfaceMapping,'data')

            [cntdBlks,~,~,~]=soc.util.getConnectedBlk(thisDUTPort);
            if~iscell(cntdBlks)
                cntdBlk=cntdBlks;
            elseif numel(cntdBlks)==1
                cntdBlk=cntdBlks{1};
            else
                error(message('soc:msgs:dutPortConnectMultipleBlks',thisDUTPort));
            end
            thisTopIntfInfo=intfInfo(cntdBlk);
            ioIntfStr=thisTopIntfInfo.interface;
            cntdTopBlk=[hbuild.TopSystemName,'/',ioIntfStr(9:end)];
            cntdBlkName=get_param(cntdTopBlk,'name');
            [addr,range]=soc.memmap.getComponentAddress(memMap,cntdBlkName);
            addr=hex2dec(addr);

            dutIntfInfo(ioInterface)=addr;
        end
    end

    save('dutIntfInfo.mat','dutIntfInfo');

end