
function[txt,details]=getPseudoCodePreview(cscDefn,msDefn,cscBak,msBak)






    if~isempty(cscDefn)&&isempty(msDefn)
        msg=DAStudio.message('Simulink:dialog:CSCUIPseudoCodeWithEmptyMemorySection');
        txt=sprintf(msg);
        details=struct('hdrTxt','','typeTxt','','declTxt','','defnTxt','');
        return;
    end






    ftIsOther='';feIsOther='';

    ftDataInit='';feDataInit='';
    ftDataAccess='';feDataAccess='';
    ftDataScope='';feDataScope='';
    ftHeaderFile='';feHeaderFile='';

    ftTypeComment='<font color="darkred">';feTypeComment='</font>';
    ftDeclComment='<font color="darkred">';feDeclComment='</font>';
    ftDefnComment='<font color="darkred">';feDefnComment='</font>';

    ftMSComment='<font color="darkred" class="comment">';feMSComment='</font>';
    ftPrePragma='';fePrePragma='';
    ftPostPragma='';fePostPragma='';
    ftIsConst='';feIsConst='';
    ftIsVolatile='';feIsVolatile='';
    ftQualifier='';feQualifier='';

    ftIsStruct='';feIsStruct='';
    ftStructName='';feStructName='';
    ftBitPackBoolean='';feBitPackBoolean='';
    ftIsTypeDef='';feIsTypeDef='';
    ftTypeToken='';feTypeToken='';
    ftTypeTag='';feTypeTag='';
    ftTypeName='';feTypeName='';

    isOnSameCSC=~isempty(cscDefn)&&...
    ~isempty(cscBak)&&...
    isequal(cscDefn.Name,cscBak.Name);

    if isOnSameCSC

        if~isequal(cscDefn.DataInit,cscBak.DataInit)
            ftDataInit='<font color="blue"><b>';
            feDataInit='</b></font>';
        end

        if~isequal(cscDefn.DataAccess,cscBak.DataAccess)||...
            ~isequal(cscDefn.IsDataAccessInstanceSpecific,...
            cscBak.IsDataAccessInstanceSpecific)
            ftDataAccess='<font color="blue"><b>';
            feDataAccess='</b></font>';
        end

        if~isequal(cscDefn.DataScope,cscBak.DataScope)||...
            ~isequal(cscDefn.IsDataScopeInstanceSpecific,...
            cscBak.IsDataScopeInstanceSpecific)
            ftDataScope='<font color="blue"><b>';
            feDataScope='</b></font>';
        end

        if~isequal(cscDefn.HeaderFile,cscBak.HeaderFile)||...
            ~isequal(cscDefn.IsHeaderFileInstanceSpecific,...
            cscBak.IsHeaderFileInstanceSpecific)
            ftHeaderFile='<font color="blue"><b>';
            feHeaderFile='</b></font>';
        end

        if~isequal(cscDefn.CommentSource,cscBak.CommentSource)||...
            (strcmp(cscDefn.CommentSource,'Specify')&&...
            ~isequal(cscDefn.TypeComment,cscBak.TypeComment))
            ftTypeComment='<font color="blue"><b>';
            feTypeComment='</b></font>';
        end

        if~isequal(cscDefn.CommentSource,cscBak.CommentSource)||...
            (strcmp(cscDefn.CommentSource,'Specify')&&...
            ~isequal(cscDefn.DeclareComment,cscBak.DeclareComment))
            ftDeclComment='<font color="blue"><b>';
            feDeclComment='</b></font>';
        end

        if~isequal(cscDefn.CommentSource,cscBak.CommentSource)||...
            (strcmp(cscDefn.CommentSource,'Specify')&&...
            ~isequal(cscDefn.DefineComment,cscBak.DefineComment))
            ftDefnComment='<font color="blue"><b>';
            feDefnComment='</b></font>';
        end

        if~isequal(cscDefn.CSCType,cscBak.CSCType)
            if strcmp(cscDefn.CSCType,'Other')||...
                strcmp(cscBak.CSCType,'Other')
                ftIsOther='<font color="blue"><b>';
                feIsOther='</b></font>';

            elseif strcmp(cscDefn.CSCType,'FlatStructure')||...
                strcmp(cscBak.CSCType,'FlatStructure')
                ftIsStruct='<font color="blue"><b>';
                feIsStruct='</b></font>';
            end

        elseif strcmp(cscDefn.CSCType,'FlatStructure')
            structDefn=cscDefn.CSCTypeAttributes;
            structBak=cscBak.CSCTypeAttributes;

            if~isequal(structDefn.StructName,structBak.StructName)||...
                ~isequal(structDefn.IsStructNameInstanceSpecific,...
                structBak.IsStructNameInstanceSpecific)
                ftStructName='<font color="blue"><b>';
                feStructName='</b></font>';
            end

            if~isequal(structDefn.BitPackBoolean,structBak.BitPackBoolean)
                ftBitPackBoolean='<font color="blue"><b>';
                feBitPackBoolean='</b></font>';
            end

            if~isequal(structDefn.IsTypeDef,structBak.IsTypeDef)
                ftIsTypeDef='<font color="blue"><b>';
                feIsTypeDef='</b></font>';
            end

            if~isequal(structDefn.TypeToken,structBak.TypeToken)||...
                ~isequal(structDefn.IsStructNameInstanceSpecific,...
                structBak.IsStructNameInstanceSpecific)
                ftTypeToken='<font color="blue"><b>';
                feTypeToken='</b></font>';
            end

            if~isequal(structDefn.TypeTag,structBak.TypeTag)||...
                ~isequal(structDefn.IsStructNameInstanceSpecific,...
                structBak.IsStructNameInstanceSpecific)
                ftTypeTag='<font color="blue"><b>';
                feTypeTag='</b></font>';
            end

            if~isequal(structDefn.TypeName,structBak.TypeName)||...
                ~isequal(structDefn.IsStructNameInstanceSpecific,...
                structBak.IsStructNameInstanceSpecific)
                ftTypeName='<font color="blue"><b>';
                feTypeName='</b></font>';
            end
        end

    end

    isOnSameMS=~isempty(msDefn)&&...
    ~isempty(msBak)&&...
    isequal(msDefn.Name,msBak.Name);

    if((isOnSameCSC&&~isempty(msBak))||...
        (isOnSameMS&&isempty(cscDefn)))

        if~isequal(msDefn.Comment,msBak.Comment)
            ftMSComment='<font color="blue" class="comment"><b>';
            feMSComment='</b></font>';
        end

        if~isequal(msDefn.PrePragma,msBak.PrePragma)
            ftPrePragma='<font color="blue"><b>';
            fePrePragma='</b></font>';
        end

        if~isequal(msDefn.PostPragma,msBak.PostPragma)
            ftPostPragma='<font color="blue"><b>';
            fePostPragma='</b></font>';
        end

        if~isequal(msDefn.IsConst,msBak.IsConst)
            ftIsConst='<font color="blue"><b>';
            feIsConst='</b></font>';
        end

        if~isequal(msDefn.IsVolatile,msBak.IsVolatile)
            ftIsVolatile='<font color="blue"><b>';
            feIsVolatile='</b></font>';
        end

        if~isequal(msDefn.Qualifier,msBak.Qualifier)
            ftQualifier='<font color="blue"><b>';
            feQualifier='</b></font>';
        end

    end




    hdrTxt='';

    if~isempty(cscDefn)

        hdrFile=cscDefn.HeaderFile;


        hdrFile=regexprep(hdrFile,'^([^"<]*[^">])$','"$1"');


        hdrFile=escapeHTML(hdrFile);

        switch cscDefn.DataScope
        case 'Exported'
            if cscDefn.IsHeaderFileInstanceSpecific
                headerMsg=DAStudio.message('Simulink:dialog:CSCUIHeaderDataExportedVia','INSTANCE_SPECIFIC_HEADER');
            elseif isempty(hdrFile)
                headerMsg=DAStudio.message('Simulink:dialog:CSCUINoHeaderFileSpecified');
            else
                headerMsg=DAStudio.message('Simulink:dialog:CSCUIHeaderDataExportedVia',hdrFile);
            end
            hdrTxt=sprintf([ftDataScope,ftHeaderFile,...
            headerMsg,feHeaderFile,feDataScope]);

        case 'Imported'
            if cscDefn.isAccessMethod
                if cscDefn.IsHeaderFileInstanceSpecific
                    headerMsg=DAStudio.message('Simulink:dialog:CSCUIHeaderAccessFunctionImportedVia',...
                    '#include INSTANCE_SPECIFIC_HEADER');
                elseif isempty(hdrFile)
                    headerMsg=DAStudio.message('Simulink:dialog:CSCUIHeaderAccessFunctionImportedViaCustomCode');
                else
                    headerMsg=DAStudio.message('Simulink:dialog:CSCUIHeaderAccessFunctionImportedVia',...
                    ['#include ',hdrFile]);
                end
            elseif strcmp(cscDefn.DataInit,'Macro')
                if cscDefn.IsHeaderFileInstanceSpecific
                    headerMsg=DAStudio.message('Simulink:dialog:CSCUIHeaderMacroImportedVia',...
                    '#include INSTANCE_SPECIFIC_HEADER');
                elseif isempty(hdrFile)
                    headerMsg=DAStudio.message('Simulink:dialog:CSCUIHeaderMacroImportedViaCompilerFlag');
                else
                    headerMsg=DAStudio.message('Simulink:dialog:CSCUIHeaderMacroImportedVia',...
                    ['#include ',hdrFile]);
                end
            else
                if cscDefn.IsHeaderFileInstanceSpecific
                    headerMsg=DAStudio.message('Simulink:dialog:CSCUIHeaderImportedVia','#include INSTANCE_SPECIFIC_HEADER');
                elseif isempty(hdrFile)
                    headerMsg=DAStudio.message('Simulink:dialog:CSCUIHeaderImportedByExternDecl','#include.');
                else
                    headerMsg=DAStudio.message('Simulink:dialog:CSCUIHeaderImportedVia',['#include ',hdrFile]);
                end
            end

            hdrTxt=sprintf([ftDataScope,ftHeaderFile,...
            headerMsg,feHeaderFile,feDataScope]);

        case 'File'
            headerMsg=DAStudio.message('Simulink:dialog:CSCUIDataScopeLimited');
            hdrTxt=sprintf(...
            [ftDataScope,headerMsg,feDataScope]);

        case 'Auto'
            headerMsg=DAStudio.message('Simulink:dialog:CSCUIDataScopeInternalRule');
            hdrTxt=sprintf(...
            [ftDataScope,headerMsg,feDataScope]);

        end
    end





    typeTxt='';

    if(~isempty(cscDefn)&&...
        ~ismember(cscDefn.CSCType,{'Unstructured','AccessFunction'}))
        switch cscDefn.CSCType
        case 'Other'
            typeTxt='<span class="comment">/* OTHER_TYPE_DEFINITION goes here */<span>';

        case 'FlatStructure'






            structDefn=cscDefn.CSCTypeAttributes;

            if structDefn.IsTypeDef
                typeTxt=[ftIsTypeDef,'typedef struct',feIsTypeDef];
            else
                typeTxt=[ftIsTypeDef,'struct',feIsTypeDef];
            end

            if~structDefn.IsStructNameInstanceSpecific&&...
                ~isempty(structDefn.TypeToken)
                typeTxt=[typeTxt,' ',ftTypeToken,...
                escapeHTML(structDefn.TypeToken),feTypeToken];
            end

            if structDefn.IsStructNameInstanceSpecific
                actStructTag='INSTANCE_SPECIFIC_STRUCTNAME_tag';
            elseif isempty(structDefn.TypeTag)&&structDefn.IsTypeDef
                actStructTag='MISSING_TAG';
            else
                actStructTag=escapeHTML(structDefn.TypeTag);
            end

            if~isempty(actStructTag)
                typeTxt=[typeTxt,' ',ftTypeTag,actStructTag,feTypeTag];
            end

            typeTxt=[typeTxt,' {',newline];
            typeTxt=[typeTxt,'   :',newline];
            if structDefn.BitPackBoolean
                typeTxt=[typeTxt,'   ',...
                ftBitPackBoolean,...
                'unsigned int varName1:1;',...
                feBitPackBoolean,newline];
            end

            typeTxt=[typeTxt,'}'];

            if structDefn.IsTypeDef
                if structDefn.IsStructNameInstanceSpecific
                    actStructType='INSTANCE_SPECIFIC_STRUCTNAME_type';
                elseif isempty(structDefn.TypeName)
                    actStructType='MISSING_TYPE';
                else
                    actStructType=escapeHTML(structDefn.TypeName);
                end

                typeTxt=[typeTxt,' ',ftTypeName,actStructType,feTypeName];
            end

            typeTxt=[ftIsStruct,typeTxt,';',feIsStruct];

        otherwise
            assert(false,'Unexpected CSCType');
        end

        if~isempty(typeTxt)
            typeCmt='';

            switch cscDefn.CommentSource
            case 'Default'
                typeCmt='<span class="comment">/* CSC type comment generated by default */</span>';

            case 'Specify'
                typeCmt=escapeHTML(cscDefn.TypeComment);
            end

            if~isempty(typeCmt)
                typeTxt=...
                [ftTypeComment,typeCmt,feTypeComment,newline,...
                typeTxt];
            end
        end

        if typeTxt
            typeTxt=[ftIsOther,typeTxt,feIsOther];
        end
    end







    dCore='';
    dName='';

    if(isempty(cscDefn)||...
        ~(strcmp(cscDefn.DataInit,'Macro')||cscDefn.isAccessMethod))

        if isempty(cscDefn)||strcmp(cscDefn.CSCType,'Unstructured')
            dType='DATATYPE';
            dName='DATANAME';

        else
            switch cscDefn.CSCType
            case 'Other'
                dType='OTHER_DATATYPE';
                dName='OTHER_DATANAME';

            case 'FlatStructure'
                structDefn=cscDefn.CSCTypeAttributes;

                if structDefn.IsTypeDef
                    dType=[ftTypeName,actStructType,feTypeName];
                else
                    dType=['struct ',ftTypeTag,actStructTag,feTypeTag];
                end

                if structDefn.IsStructNameInstanceSpecific
                    actStructName='INSTANCE_SPECIFIC_STRUCTNAME';
                elseif isempty(structDefn.StructName)
                    actStructName='MISSING_NAME';
                else
                    actStructName=escapeHTML(structDefn.StructName);
                end

                dName=[ftStructName,actStructName,feStructName];

            otherwise
                assert(false,'Unexpected CSCType');
            end
        end

        dAccess='';
        dDimension='';
        if~isempty(cscDefn)
            if strcmp(cscDefn.DataAccess,'Pointer')
                dAccess=[ftDataAccess,'*',feDataAccess];
            end
            if~cscDefn.IsGrouped
                dDimension='[DIMENSION]';
            end
        end

        dCore=[dType,' ',dAccess,dName,dDimension];

        if~isempty(msDefn)





            if msDefn.IsVolatile
                dCore=[ftIsVolatile,'volatile',feIsVolatile,' ',dCore];
            end

            if msDefn.IsConst
                dCore=[ftIsConst,'const',feIsConst,' ',dCore];
            end

            if msDefn.Qualifier
                dCore=[ftQualifier,escapeHTML(msDefn.Qualifier),...
                feQualifier,' ',dCore];
            end
        end
    end







    if isempty(cscDefn)
        declTxt=['extern ',dCore,';'];
    elseif strcmp(cscDefn.CSCType,'AccessFunction')
        declTxt='';
    else
        if strcmp(cscDefn.DataInit,'Macro')||strcmp(cscDefn.DataScope,'File')
            declTxt='';
        else
            declTxt=['extern ',dCore,';'];
            cscDeclCmt='';

            switch cscDefn.CommentSource
            case 'Default'
                cscDeclCmt='<span class="comment">/* CSC declaration comment generated by default */</span>';

            case 'Specify'
                cscDeclCmt=escapeHTML(cscDefn.DeclareComment);
            end

            if~isempty(cscDeclCmt)
                declTxt=...
                [ftDeclComment,cscDeclCmt,feDeclComment,newline,declTxt];
            end
        end
    end

    if~isempty(declTxt)
        declTxt=addPragmaAroundDeclOrDefn(declTxt,msDefn,dName,...
        ftPrePragma,fePrePragma,ftPostPragma,fePostPragma,...
        ftMSComment,feMSComment,ftIsOther,feIsOther);

        declTxt=[ftIsOther,declTxt,feIsOther];
    end








    if isempty(cscDefn)
        defnTxt=[dCore,';'];
    elseif(strcmp(cscDefn.CSCType,'AccessFunction'))
        defnTxt='';
    elseif strcmp(cscDefn.DataScope,'Imported')

        defnTxt='';
    elseif strcmp(cscDefn.DataInit,'Macro')

        defnTxt=[ftDataInit,...
        '#define DATANAME NUMERIC_VALUE',...
        feDataInit];
    else
        if strcmp(cscDefn.DataScope,'File')
            defnTxt=['static ',dCore];
        else
            defnTxt=dCore;
        end

        if strcmp(cscDefn.DataInit,'Static')
            defnTxt=[defnTxt,' ',ftDataInit,'= {...}',feDataInit];
        end
        defnTxt=[defnTxt,';'];
    end

    if~isempty(cscDefn)&&~isempty(defnTxt)
        cscDefnCmt='';

        switch cscDefn.CommentSource
        case 'Default'
            cscDefnCmt='<span class="comment">/* CSC definition comment generated by default */</span>';

        case 'Specify'
            cscDefnCmt=escapeHTML(cscDefn.DefineComment);
        end

        if~isempty(cscDefnCmt)
            defnTxt=...
            [ftDefnComment,cscDefnCmt,feDefnComment,newline,defnTxt];
        end
    end

    defnTxt=addPragmaAroundDeclOrDefn(defnTxt,msDefn,dName,...
    ftPrePragma,fePrePragma,ftPostPragma,fePostPragma,...
    ftMSComment,feMSComment,ftIsOther,feIsOther);

    defnTxt=[ftIsOther,defnTxt,feIsOther];




    na_str=DAStudio.message('Simulink:dialog:CSCUINotApplicable');
    tlccont_str=DAStudio.message('Simulink:dialog:CSCUIControlledTLC');

    headfile_str=['<span class="previewHeader">',DAStudio.message('Simulink:dialog:CSCUIHeaderFile'),'</span>'];
    typedef_str=['<span class="previewHeader">',DAStudio.message('Simulink:dialog:CSCUITypeDefn'),'</span>'];
    declare_str=['<span class="previewHeader">',DAStudio.message('Simulink:dialog:CSCUIDeclaration'),'</span>'];
    define_str=['<span class="previewHeader">',DAStudio.message('Simulink:dialog:CSCUIDefinition'),'</span>'];

    if isempty(hdrTxt)
        hdrTxt=FormatInsideHeader(headfile_str,na_str);
    else
        hdrTxt=FormatOutsideHeader(headfile_str,hdrTxt);
    end

    if~isempty(cscDefn)&&strcmp(cscDefn.CSCType,'Other')
        typeTxt=FormatInsideHeader(typedef_str,tlccont_str);
        declTxt=FormatInsideHeader(declare_str,tlccont_str);
        defnTxt=FormatInsideHeader(define_str,tlccont_str);
    else
        if isempty(typeTxt)
            typeTxt=FormatInsideHeader(typedef_str,na_str);
        else
            typeTxt=FormatOutsideHeader(typedef_str,typeTxt);
        end
        if isempty(declTxt)
            declTxt=FormatInsideHeader(declare_str,na_str);
        else
            declTxt=FormatOutsideHeader(declare_str,declTxt);
        end
        if isempty(defnTxt)
            defnTxt=FormatInsideHeader(define_str,na_str);
        else
            defnTxt=FormatOutsideHeader(define_str,defnTxt);
        end
    end

    txt=['<PRE>',...
    hdrTxt,...
    typeTxt,...
    declTxt,...
    defnTxt,...
    '</PRE>'];
    details=struct('hdrTxt',hdrTxt,...
    'typeTxt',typeTxt,...
    'declTxt',declTxt,...
    'defnTxt',defnTxt);




    function section=FormatOutsideHeader(header,content)








        section=...
        [newline,'<hr><b>',header,'<hr></b>',content,newline];




        function section=FormatInsideHeader(header,content)








            section=[newline,'<hr><b>',header,'</b> ',content,'<hr>'];





            function txt=escapeHTML(txt)








                txt=strrep(txt,'&','&amp;');
                txt=strrep(txt,'"','&quot;');
                txt=strrep(txt,'<','&lt;');
                txt=strrep(txt,'>','&gt;');
                txt=strrep(txt,'%','&#37;');





                function text=addPragmaAroundDeclOrDefn(text,msDefn,dName,...
                    ftPrePragma,fePrePragma,ftPostPragma,fePostPragma,...
                    ftMSComment,feMSComment,ftIsOther,feIsOther)



                    if~isempty(msDefn)&&~isempty(msDefn.PrePragma)
                        assert(~isempty(dName));
                        statement=strrep(msDefn.PrePragma,'$N',dName);
                        text=...
                        [ftPrePragma,...
                        escapeHTML(statement),...
                        fePrePragma,newline,...
                        text];
                    end

                    if~isempty(msDefn)&&~isempty(msDefn.PostPragma)
                        assert(~isempty(dName));
                        statement=strrep(msDefn.PostPragma,'$N',dName);
                        text=...
                        [text,newline,...
                        ftPostPragma,...
                        escapeHTML(statement),...
                        fePostPragma];
                    end

                    if~isempty(msDefn)&&~isempty(msDefn.Comment)
                        text=...
                        [ftMSComment,...
                        escapeHTML(msDefn.Comment),...
                        feMSComment,newline,...
                        text];
                    end

                    text=[ftIsOther,text,feIsOther];





