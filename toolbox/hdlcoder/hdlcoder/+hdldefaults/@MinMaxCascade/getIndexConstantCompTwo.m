function[constIndex1,constIndex2,constComp1,constComp2]=...
    getIndexConstantCompTwo(this,hN,indexType)




    indexName=sprintf('const_idx');

    constValue(1)=0;
    constValue(2)=1;

    constIndex1=hN.addSignal(indexType,sprintf('%s_%d',indexName,constValue(1)));
    constIndex2=hN.addSignal(indexType,sprintf('%s_%d',indexName,constValue(2)));


    constComp1=pirelab.getConstComp(hN,constIndex1,pirelab.getTypeInfoAsFi(indexType,'Floor','Wrap',constValue(1)));
    constComp2=pirelab.getConstComp(hN,constIndex2,pirelab.getTypeInfoAsFi(indexType,'Floor','Wrap',constValue(2)));
