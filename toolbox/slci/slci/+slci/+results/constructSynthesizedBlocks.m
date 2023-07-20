function[synthBlockKeys,keyToHandle]=constructSynthesizedBlocks(...
    synthesizedBlks,datamgr,keyToHandle,mfModel)
    assert(nargin==3||nargin==4);



    isResultsMF=(nargin==4);
    numSyn=numel(synthesizedBlks);
    synthBlockKeys=cell(numSyn,1);
    if isResultsMF
        blockReader=datamgr;
        for k=1:numSyn

            synBlkHdl=synthesizedBlks(k);
            synBlkObj=slci_results_mf.HiddenBlockObject(mfModel);
            synBlkObj.initializeHiddenBlockObject(synBlkHdl);
            synBlkKey=synBlkObj.key;

            blockReader.insertObject(synBlkObj);
            synthBlockKeys{k}=synBlkKey;
            keyToHandle(synBlkKey)=synBlkHdl;
        end
    else
        blockReader=datamgr.getBlockReader();
        for k=1:numSyn

            synBlkHdl=synthesizedBlks(k);
            synBlkObj=slci.results.HiddenBlockObject(synBlkHdl);
            synBlkKey=synBlkObj.getKey();
            blockReader.insertObject(synBlkKey,synBlkObj);
            synthBlockKeys{k}=synBlkKey;
            keyToHandle(synBlkKey)=synBlkHdl;
        end
    end
end
