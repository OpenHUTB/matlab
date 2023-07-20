function setElementDataType(h,elementName,elementDataType)




    h.hVerifyElementName(elementName);

    idx=h.leafChildName2IndexMap(elementName);

    h.busObj.Elements(idx).DataType=elementDataType;


    h.specifiedDTs{idx}=elementDataType;



    h.hModifyOrigObject();




