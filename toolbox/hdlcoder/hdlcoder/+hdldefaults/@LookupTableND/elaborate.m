function newComp=elaborate(this,hN,hC)



    [table_data_typed,bpType_ex,oType_ex,fType_ex,powerof2,interpVal,bp_data,dims,rndMode,satMode,diagnostics,extrap,isEvenSpacing]=getBlockInfo(this,hC);

    useSLHandle=false;

    nfpOptions=getNFPBlockInfo(this);
    mapToRAMStr=getImplParams(this,'MapToRAM');

    if isempty(mapToRAMStr)
        mapToRAMStr=setMapToRAMForSinHDLOptimized(hC.SimulinkHandle);
    end

    if isempty(mapToRAMStr)||strcmpi(mapToRAMStr,'inherit')
        hDriver=hdlcurrentdriver;
        mapToRAM=hDriver.getParameter('LUTMapToRAM');
    elseif strcmpi(mapToRAMStr,'on')
        mapToRAM=1;
    else
        mapToRAM=0;
    end


    newComp=pirelab.getLookupNDComp(hN,hC.PirInputSignals,hC.PirOutputSignals,...
    table_data_typed,powerof2,bpType_ex,oType_ex,fType_ex,interpVal,bp_data,hC.Name,hC.SimulinkHandle,...
    dims,rndMode,satMode,diagnostics,extrap,isEvenSpacing,nfpOptions,mapToRAM);


    if isa(newComp,'hdlcoder.lookuptable_comp')
        newComp.setUseSLHandle(useSLHandle);
    end

end

function mapToRamStr=setMapToRAMForSinHDLOptimized(slbh)
    mapToRamStr='inherit';
    if(slbh>=0)

        level=3;
        while(level>0&&strcmpi(mapToRamStr,'inherit'))
            parent=get_param(slbh,'Parent');
            if~isempty(parent)
                mapToRamStr=checkMapToRam(parent);
                slbh=get_param(parent,'Handle');
                level=level-1;
            else
                break;
            end
        end
    end
end

function mapToRamStr=checkMapToRam(path)
    mapToRamStr='inherit';
    if~isempty(path)&&contains(path,'/')
        hd=slprops.hdlblkdlg(path);
        implInfo=hd.getCurrentArchImplParams;
        if isKey(implInfo,'maptoram')
            currParamInfo=implInfo('maptoram');
            mapToRamStr=currParamInfo.Value;
        end
    end
end