function[zerOneIdxMode,idxMode,elements,fillValues,rowsOrCols,numInputs]=getBlockInfo(~,hC)






    slbh=hC.SimulinkHandle;
    zerOneIdxMode=get_param(slbh,'ZerOneIdxMode');

    idxMode=get_param(slbh,'IdxMode');
    if strcmp(idxMode,'Variable')
        indexMode=1;
    else
        indexMode=0;
    end

    logicalIndexing=0;
    if indexMode==0
        elements=getResolvedInfo(slbh,'Elements');

    else
        elements=[];
        selSig=hC.SLInputSignals(end);
        if selSig.Type.getLeafType.isBooleanType||selSig.Type.getLeafType.isLogicType(1)
            logicalIndexing=1;
        end
    end

    if logicalIndexing==1&&strcmp(get_param(slbh,'FillMode'),'on')

        rto=get_param(slbh,'RuntimeObject');
        fillValues=zeros(rto.NumRuntimePrms,1);
        for ii=1:rto.NumRuntimePrms
            fillValues(ii)=rto.RuntimePrm(ii).Data;
        end
    else
        fillValues=[];
    end

    rowsOrCols=get_param(slbh,'RowsOrCols');
    numInputs=getResolvedInfo(slbh,'NumInputs');



    function val=getResolvedInfo(block,prop)

        prop_val=get_param(block,prop);
        val=slResolve(prop_val,block);
