function defTxt=getDefinition(obj)



    defTxt='';

    if isempty(obj.getEntry)
        return;
    end
    defTxt=obj.pvt_getDefinitionPreview;
    entryStruct=obj.pvt_getEntryStruct();
    cscDefn=entryStruct.StorageClass;


    defnTxt='';
    define_str=obj.getDefinitionHeader;
    if~isempty(cscDefn)&&~isempty(cscDefn.DefinitionFile)
        defFile=obj.resolveDefinitionFileToken(cscDefn.DefinitionFile,cscDefn.DefinitionFile,cscDefn);
        defnTxt=[' ',DAStudio.message('SimulinkCoderApp:ui:DefinedInFile'),defFile];
    end

    if~isempty(defnTxt)
        define_str=['<p>',define_str,defnTxt,'</p>'];
    else
        define_str=['<p>',define_str,'</p>'];
    end
    tlccont_str=DAStudio.message('Simulink:dialog:CSCUIControlledTLC');
    if~isempty(cscDefn)&&strcmp(cscDefn.CSCType,'Other')
        defTxt=obj.FormatHeader(define_str,tlccont_str);
    else
        if~isempty(defTxt)
            defTxt=obj.FormatHeader(define_str,defTxt);
        end
    end
end


