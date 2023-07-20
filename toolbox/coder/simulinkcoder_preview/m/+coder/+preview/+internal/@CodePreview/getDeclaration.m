



function txt=getDeclaration(obj)
    txt='';

    if isempty(obj.getEntry)
        return;
    end
    declTxt=obj.pvt_getDeclarationPreview();
    entryStruct=obj.pvt_getEntryStruct();
    cscDefn=entryStruct.StorageClass;

    hdrTxt=loc_getHeaderString(obj,entryStruct.StorageClass);
    typeTxt=loc_getTypedefString(obj,entryStruct.StorageClass);

    tlccont_str=DAStudio.message('Simulink:dialog:CSCUIControlledTLC');
    typedef_str=['<p class="previewHeader">',DAStudio.message('Simulink:dialog:CSCUITypeDefn'),'</p>'];
    declare_section_header=obj.getDeclarationHeader;
    if~isempty(hdrTxt)
        declare_section_header=[declare_section_header,' ',hdrTxt];
    end
    if isempty(hdrTxt)
        hdrTxt='';
    else
        hdrTxt=obj.FormatHeader('',hdrTxt);
    end
    if~isempty(cscDefn)&&strcmp(cscDefn.CSCType,'Other')
        typeTxt=obj.FormatHeader(typedef_str,tlccont_str);
        declTxt=obj.FormatHeader(declare_section_header,tlccont_str);
    else
        if isempty(typeTxt)
            typeTxt='';
        else
            typeTxt=obj.FormatHeader(typedef_str,typeTxt);
        end
        if isempty(declTxt)&&isempty(hdrTxt)
            declTxt='';
        else
            declTxt=obj.FormatHeader(declare_section_header,declTxt);
        end
    end


    if~isempty(declTxt)
        hdrTxt='';
    end
    txt='';
    if~isempty(hdrTxt)
        txt=[txt,hdrTxt];
    end
    if~isempty(typeTxt)
        txt=[txt,typeTxt];
    end
    if~isempty(declTxt)
        txt=[txt,declTxt];
    end
end




function hdrTxt=loc_getHeaderString(obj,cscDefn)
    hdrTxt='';

    if~isempty(cscDefn)

        hdrFile=cscDefn.HeaderFile;
        hdrFile=obj.resolveHeaderFileToken(hdrFile,cscDefn.HeaderFile,cscDefn);

        switch cscDefn.DataScope
        case 'Exported'
            hdrFileStr='';
            if cscDefn.IsHeaderFileInstanceSpecific
                headerMsg=[DAStudio.message('SimulinkCoderApp:ui:DataExportedVia'),obj.getTK('INSTANCE_SPECIFIC_HEADER')];
            elseif isempty(cscDefn.HeaderFile)

                headerMsg=[DAStudio.message('SimulinkCoderApp:ui:DataExportedVia'),obj.getTK([obj.ModelName,'.h'])];
            else
                headerMsg=DAStudio.message('SimulinkCoderApp:ui:DataExportedVia');
                hdrFileStr=hdrFile;
            end
            tooltipStr=[message('SimulinkCoderApp:core:GroupTableDataScopeColumn').getString,': exported.'];
            hdrTxt=[obj.getPropertyPreview(tooltipStr,'','DataScope',headerMsg),hdrFileStr];
        case 'Imported'
            hdrFileStr='';
            if cscDefn.isAccessMethod
                if cscDefn.IsHeaderFileInstanceSpecific
                    headerMsg=[DAStudio.message('SimulinkCoderApp:ui:AccessFunctionImportedVia')...
                    ,obj.getTK('INSTANCE_SPECIFIC_HEADER')];
                elseif isempty(hdrFile)
                    headerMsg=DAStudio.message('SimulinkCoderApp:ui:AccessFunctionImportedViaCustomCode');
                else
                    hdrFileStr=hdrFile;
                    headerMsg=DAStudio.message('SimulinkCoderApp:ui:AccessFunctionImportedVia');
                end
            elseif strcmp(cscDefn.DataInit,'Macro')
                if cscDefn.IsHeaderFileInstanceSpecific
                    headerMsg=[DAStudio.message('SimulinkCoderApp:ui:MacroImportedVia'),...
                    obj.getTK('INSTANCE_SPECIFIC_HEADER')];
                elseif isempty(cscDefn.HeaderFile)
                    headerMsg=DAStudio.message('Simulink:dialog:CSCUIHeaderMacroImportedViaCompilerFlag');
                else
                    hdrFileStr=hdrFile;
                    headerMsg=DAStudio.message('SimulinkCoderApp:ui:MacroImportedVia');
                end
            else
                if cscDefn.IsHeaderFileInstanceSpecific
                    headerMsg=[DAStudio.message('SimulinkCoderApp:ui:DataImportedVia'),obj.getTK('INSTANCE_SPECIFIC_HEADER')];
                elseif isempty(cscDefn.HeaderFile)
                    headerMsg=DAStudio.message('SimulinkCoderApp:ui:HeaderImportedByExternDecl');
                else
                    hdrFileStr=hdrFile;
                    headerMsg=DAStudio.message('SimulinkCoderApp:ui:DataImportedVia');
                end
            end
            tooltipStr=[message('SimulinkCoderApp:core:GroupTableDataScopeColumn').getString,': imported.'];
            hdrTxt=[obj.getPropertyPreview(tooltipStr,'','DataScope',headerMsg),hdrFileStr];
        case 'File'
            hdrTxt=DAStudio.message('Simulink:dialog:CSCUIDataScopeLimited');
        case 'Auto'
            hdrTxt=DAStudio.message('Simulink:dialog:CSCUIDataScopeInternalRule');
        end
    end
end



function typeTxt=loc_getTypedefString(obj,cscDefn)
    typeTxt='';
    ftTypeComment='<span class="comment">';feTypeComment='</span>';
    if(~isempty(cscDefn)&&...
        ~ismember(cscDefn.CSCType,{'Unstructured','AccessFunction'}))
        if strcmp(cscDefn.CSCType,'Other')
            typeTxt='<span class="comment">/* OTHER_TYPE_DEFINITION goes here */<span>';
        elseif strcmp(cscDefn.CSCType,'FlatStructure')||...
            (strcmp(cscDefn.CSCType,'Mixed')&&strcmp(cscDefn.SingleInstanceCSCType,'FlatStructure'))






            structDefn=cscDefn.CSCTypeAttributes;
            scName=cscDefn.Name;

            if structDefn.IsTypeDef
                typeTxt=obj.getKW('typedef struct');
            else
                typeTxt=obj.getKW('struct');
            end

            if~structDefn.IsStructNameInstanceSpecific&&...
                ~isempty(structDefn.TypeToken)
                typeTxt=[typeTxt,' ',obj.escapeHTML(structDefn.TypeToken)];
            end

            if structDefn.IsStructNameInstanceSpecific
                actStructTag=obj.getTK('INSTANCE_SPECIFIC_STRUCTNAME_tag');
            elseif isempty(structDefn.TypeTag)&&structDefn.IsTypeDef
                actStructTag=obj.getTK('MISSING_TAG');
            else
                actStructTag=obj.escapeHTML(structDefn.TypeTag);
            end

            if~isempty(actStructTag)
                typeTxt=[typeTxt,' ',actStructTag];
            end

            typeTxt=[typeTxt,' {',newline];
            if structDefn.BitPackBoolean
                typeTxt=[typeTxt,'<p class="tabIndent">',...
                obj.getKW('unsigned int'),' ',obj.getTK('varName1'),':1;</p>'];
            else
                typeTxt=[typeTxt,'<p class="tabIndent">...</p>',...
                '<p class="tabIndent tk">FIELDTYPE FIELDNAME;</p>','<p class="tabIndent">...</p>'];
            end

            typeTxt=[typeTxt,'}'];

            if structDefn.IsTypeDef
                if structDefn.IsStructNameInstanceSpecific
                    actStructType=obj.getTK('INSTANCE_SPECIFIC_STRUCTNAME_type');
                elseif isempty(structDefn.TypeName)
                    actStructType=obj.getTK('MISSING_TYPE');
                else
                    actStructType=obj.resolveStructTypeToken(structDefn.TypeName,scName,obj.ModelName,'',true);
                end

                typeTxt=[typeTxt,' ',actStructType];
            end

            typeTxt=[typeTxt,';'];
        end

        if~isempty(typeTxt)
            typeCmt='';

            switch cscDefn.CommentSource
            case 'Default'
                typeCmt='<span class="comment">/* CSC type comment generated by default */</span>';

            case 'Specify'
                typeCmt=obj.escapeHTML(cscDefn.TypeComment);
            end

            if~isempty(typeCmt)
                typeTxt=...
                [ftTypeComment,typeCmt,feTypeComment,newline,...
                typeTxt];
            end
        end
    end
end



