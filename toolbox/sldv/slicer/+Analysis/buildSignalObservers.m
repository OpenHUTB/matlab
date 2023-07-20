function signalObservers=buildSignalObservers(allMdls,blockHandleToProcid,synthBlkHMap)





    handles=cell2mat(blockHandleToProcid.keys);
    signalObserversHandles=Analysis.getSignalObserversForModel(allMdls,handles,synthBlkHMap);
    signalObservers=values(blockHandleToProcid,num2cell(signalObserversHandles));
    signalObservers=reshape(cell2mat(signalObservers),1,[]);
end
