function busElements=setBusDimensions(elemInfo,elem,busElements,dimensions,isFixedSize)





    if isFixedSize
        elemInfo.IsVarLen=false;
        elem.DimensionsMode='Fixed';
        elem.Dimensions=dimensions;

        busElements(end+1)=elem;
    else
        elemInfo.IsVarLen=true;
        elem.DimensionsMode='Variable';



        elem.Dimensions=dimensions;


        [elem,arrayInfoElem]=addArrayInfoElement(elem);
        busElements(end+1:end+2)=[elem;arrayInfoElem];
    end
end



function[arrayElem,arrayInfoElem]=addArrayInfoElement(arrayElem)
    assert(strcmp(arrayElem.DimensionsMode,'Variable'));

    infoElemName=dds.internal.simulink.Util.getArrayInfoElementName(arrayElem.Name);

    busItemInfo=dds.internal.simulink.BusItemInfo(arrayElem.Description);
    busItemInfo.IsVarLen=true;
    busItemInfo.VarLenCategory='data';
    busItemInfo.VarLenElem=infoElemName;
    arrayElem.Dimensions=1;
    arrayElem.DimensionsMode='Fixed';
    arrayElem.Description=busItemInfo.toDescription();

    busItemInfo2=dds.internal.simulink.BusItemInfo;
    busItemInfo2.IsVarLen=true;
    busItemInfo2.VarLenCategory='length';
    busItemInfo2.VarLenElem=arrayElem.Name;

    arrayInfoElem=Simulink.BusElement;
    arrayInfoElem.Name=infoElemName;
    arrayInfoElem.DataType=dds.internal.simulink.Util.varlenInfoBusDataTypeStr();
    arrayInfoElem.DimensionsMode='Fixed';
    arrayInfoElem.Dimensions=1;
    arrayInfoElem.SamplingMode='Sample based';
    arrayInfoElem.Description=busItemInfo2.toDescription();
end
