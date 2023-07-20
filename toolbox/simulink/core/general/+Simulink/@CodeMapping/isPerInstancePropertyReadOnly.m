function isReadOnly=isPerInstancePropertyReadOnly(modelH,mappingObj,member,propName)







    isReadOnly=false;
    obj=mappingObj.(member);
    if isa(obj,'Simulink.AutosarTarget.DictionaryReference')&&...
        strcmp(obj.ArDataRole,'PortParameter')
        if any(strcmp(propName,{'Port','DataElement'}))


            return;
        end
        m3iDataElement=...
        autosar.mm.util.findM3iDataElementFromPortParameterMapping(modelH,mappingObj);
        if isempty(m3iDataElement)

            return;
        end


        isReadOnly=autosar.mm.arxml.Exporter.isExternalReference(m3iDataElement);
    end
end
