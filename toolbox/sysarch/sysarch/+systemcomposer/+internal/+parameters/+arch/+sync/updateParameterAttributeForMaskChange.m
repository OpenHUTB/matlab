function updateParameterAttributeForMaskChange(blkH,paramName,attrName)





    if~ishandle(blkH)
        return;
    end


    mask=get_param(blkH,'MaskObject');
    if isempty(mask)
        return;
    end



    paramName=string(paramName);
    attrName=string(attrName);
    if paramName.startsWith("OldName:")&&attrName.startsWith("NewName:")
        paramName=paramName.extractAfter(":");
        maskParamName=attrName.extractAfter(":");
        attrName="Name";
    else
        maskParamName=paramName;
    end
    mp=mask.getParameter(maskParamName);
    mpa=mp.(attrName);
    if isempty(mpa)
        return;
    end


    cImpl=systemcomposer.utils.getArchitecturePeer(blkH);
    if isempty(cImpl)
        return;
    end

    comp=systemcomposer.internal.getWrapperForImpl(cImpl);
    compArch=comp.Architecture;


    pd=compArch.getParameterDefinition(paramName);
    if isempty(pd)
        return;
    end


    txn=mf.zero.getModel(pd.getImpl).beginTransaction;
    switch attrName

    case 'Value'
        comp.getImpl.setParamVal(paramName,mpa);


    case 'Name'
        pd.getImpl.setName(mpa);
    case 'DefaultValue'
        pd.getImpl.setDefaultParameterValue(mpa);
    case 'DataType'
        pd.getImpl.setBaseType(mpa);
    case 'Dimensions'
        pd.getImpl.setDimensions(uint64(eval(mpa)));
    case 'Complexity'

    case 'Min'
        pd.getImpl.setMin(eval(mpa));
    case 'Max'
        pd.getImpl.setMax(eval(mpa));
    case 'Description'
        pd.getImpl.setDescription(mpa);
    case 'Unit'
        if~isempty(mpa.BaseUnit)
            pd.getImpl.setUnit(mpa.BaseUnit);
        end
    otherwise
        assert(false,"Unsupported mask parameter attribute '"+attrName+"'!");
    end
    txn.commit;

end