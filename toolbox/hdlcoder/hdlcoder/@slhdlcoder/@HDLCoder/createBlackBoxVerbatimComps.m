












function hNewN=createBlackBoxVerbatimComps(this,hC,hN)

    dBlock=findDocBlocks(this,hC);
    if(isempty(dBlock))
        hNewN=[];
        return
    end

    hNewN=updateDocBlocksToVerbatimEmission(this,dBlock,hC,hN);
end

function hNewC=updateDocBlocksToVerbatimEmission(this,dBlock,hC,hN)

    base_text=strjoin({dBlock.content},char(10));


    if(any(find(base_text>=256)))
        msgObj=message('hdlcoder:validate:verbatim_docblock_i18n_compliance',getfullname(hC.SimulinkHandle),hC.Name,dBlock(1).BlockPath);
        this.addCheck(this.ModelName,'Warning',msgObj,'model',dBlock(1).BlockPath);
    end


    hC.setHasVerbatim(true);



    hNewC=pirelab.getVerbatimDocBlockNetwork(hN,hC,base_text);
end
