function treeComp=elaborateMain(this,hN,hC)



    blockDSPInfo=[];


    if isa(hC,'hdlcoder.sysobj_comp')
        sysObjHandle=hC.getSysObjImpl;
        blockInfo=getSysObjInfo(this,sysObjHandle);
        blockName=hC.Name;

        if strcmp(blockInfo.blockType,'dsp')
            blockDSPInfo=this.getSysObjInfoDSP(hC);
        end

    else
        blockInfo=getBlockInfo(this,hC);
        blockName=this.localGetBlockName(hC.SimulinkHandle);
        if strcmp(blockInfo.blockType,'dsp')
            blockDSPInfo=this.getBlockInfoDSP(hC);
        end
    end

    fcnString=blockInfo.fcnString;

    hNewNet=createNetworkWithComponent(hN,hC);


    if(strcmpi(hN.getFlattenHierarchy(),'on')||hN.hasUserFlattenedNics())
        hNewNet.setFlattenHierarchy('on');
    end

    if strcmpi(fcnString,'Value')

        this.elaborateTreeMinMaxValue(hNewNet,hN,blockInfo,hC.Name);

    elseif strcmpi(fcnString,'Value and Index')||...
        strcmpi(fcnString,'Index')

        this.elaborateTreeMinMaxValueAndIndex(hNewNet,hN,blockInfo,blockDSPInfo,blockName);

    else

        error(message('hdlcoder:validate:unsupportedminmax',blockName));

    end

    treeComp=pirelab.instantiateNetwork(hN,hNewNet,hC.PirInputSignals,hC.PirOutputSignals,hC.Name);
    hNewNet.flattenAfterModelgen;
end


function hNewNet=createNetworkWithComponent(hN,hC)

    hNewNet=pirelab.createNewNetworkWithInterface(...
    'Network',hN,...
    'RefComponent',hC);



    for ii=1:length(hC.PirInputSignals)
        hNewNet.PirInputSignals(ii).SimulinkRate=hC.PirInputSignals(ii).SimulinkRate;
    end

    for ii=1:length(hC.PirOutputSignals)
        hNewNet.PirOutputSignals(ii).SimulinkRate=hC.PirOutputSignals(ii).SimulinkRate;
    end
end




