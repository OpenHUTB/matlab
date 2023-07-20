function ssid=mapFromHarnessBlockCvId(blockCvId)




    ssid=[];
    try
        origBlockSID=cvi.TopModelCov.getSID(blockCvId);
        modelcovId=cv('get',blockCvId,'.modelcov');
        if(modelcovId>0)
            [rootId,ownerBlock,currentTest]=cv('get',modelcovId,'.activeRoot','.ownerBlock','.currentTest');
            if(rootId>0)&&(currentTest>0)
                analyzedModel=cv('get',currentTest,'.analyzedModel');
                ssid=cvdata.mapFromHarnessSID_internal(origBlockSID,rootId,ownerBlock,analyzedModel);
            end
        end
    catch
        ssid=[];
    end
end
