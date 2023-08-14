function outStr=serializeAnnotation(hC)

    outStr=' pirelab.getAnnotationComp(hN, ...\n';
    outStr=[outStr,'\t\t ',SerializePir.printFormatString(hC.Name),');\n'];

end
