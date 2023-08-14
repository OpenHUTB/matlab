function[AddrHex,Range]=getComponentAddress(map,compname)
    comp=findobj(map.map,'name',compname);

    if isempty(comp)

        AddrHex='0x00000000';
        Range={'0',''};
        return;
    end

    switch comp.type

    case{soc.memmap.MemUtil.strDevUser,soc.memmap.MemUtil.strDevImplicit}
        AddrHex=comp.baseAddr;
        Range=comp.range;
        MMU=map.controllerInfo.regBaseAddrMMU;
        if MMU{1}
            AddrHex(end-(MMU{1}-1))=MMU{2};
        end

    otherwise
        AddrHex=comp.baseAddr;
        Range=comp.range;
    end

end
