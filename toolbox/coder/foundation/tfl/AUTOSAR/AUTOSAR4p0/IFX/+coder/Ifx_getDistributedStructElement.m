function structElem=Ifx_getDistributedStructElement(signed,WL,FL,identifier)

    eT=embedded.numerictype;
    eT.Signedness=signed;
    eT.WordLength=WL;
    eT.FractionLength=FL;
    structElem=embedded.structelement;
    structElem.Type=eT;
    structElem.Identifier=identifier;
end
