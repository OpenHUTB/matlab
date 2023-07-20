function legendInteractiveChange(p)





    hL=p.hLegend;
    str=hL.String;
    if~isequal(p.pDataLabels,str)

        str=internal.polariCommon.convertEmbeddedCellsToCharMatrices(str);
        str=internal.polariCommon.convertEmbeddedCRsToCharMatrices(str);



        str=downdateDataLabels(str);






        p.pLabels=str;



        p.pLabelsPendingUpdate=true;
    end
