function updateParameterForMaskChange(blkH)





    if~ishandle(blkH)
        return;
    end

    cImpl=systemcomposer.utils.getArchitecturePeer(blkH);
    if isempty(cImpl)
        return;
    end

    comp=systemcomposer.internal.getWrapperForImpl(cImpl);
    compArch=comp.Architecture;

    mask=get_param(blkH,'MaskObject');
    if isempty(mask)
        return;
    end

    maskParams=mask.Parameters;
    numMaskParams=numel(maskParams);
    maskParamNames=strings(1,numMaskParams);
    for i=1:numMaskParams
        maskParamNames(i)=maskParams(i).Name;
    end

    compParamNames=compArch.getParameterNames;


    paramsToAdd=setdiff(maskParamNames,compParamNames);
    for pn=paramsToAdd
        compArch.getImpl.addParameter(pn);
        pd=compArch.getParameterDefinition(pn);
        maskP=mask.getParameter(pn);

        txn=mf.zero.getModel(pd.getImpl).beginTransaction;
        if~isempty(maskP.DataType)
            pd.getImpl.setBaseType(maskP.DataType);
        end
        if~isempty(maskP.Dimensions)
            pd.getImpl.setDimensions(uint64(eval(maskP.Dimensions)));
        end

        if~isempty(maskP.Min)
            pd.getImpl.setMin(eval(maskP.Min));
        end
        if~isempty(maskP.Max)
            pd.getImpl.setMax(eval(maskP.Max));
        end
        pd.getImpl.setDefaultParameterValue(maskP.DefaultValue);

        if~isempty(maskP.Unit)&&~isempty(maskP.Unit.BaseUnit)
            pd.getImpl.setUnit(maskP.Unit.BaseUnit);
        end
        txn.commit;
    end



    paramsToRemove=setdiff(compParamNames,maskParamNames);
    for pn=paramsToRemove
        compArch.getImpl.removeParameter(pn);
    end



end