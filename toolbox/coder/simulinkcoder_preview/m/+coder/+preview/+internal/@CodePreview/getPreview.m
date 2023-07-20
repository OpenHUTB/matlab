



function out=getPreview(obj)
    siPreview='';
    miPreview='';

    if isempty(obj.getEntry)
        return;
    end
    entry=obj.getEntry();

    defnTxt=obj.getDefinition;
    declTxt=obj.getDeclaration;
    daTxt=obj.getDataAccess;
    ret=sprintf('%s%s%s',declTxt,defnTxt,daTxt);
    if isa(entry,'coderdictionary.data.LegacyStorageClass')
        multiInstanceTxt=obj.FormatHeader(DAStudio.message('Simulink:dialog:CSCUINotApplicable'),'');
        siPreview=ret;
        miPreview=multiInstanceTxt;

        ret=['<div class="instanceSection">',...
        '<p class="previewSectionHeader">',message('SimulinkCoderApp:ui:SingleInstanceData').getString,':</p>',...
        '<div class="sectionDivider"></div>',...
        ret,...
        '</div>',...
        '<div class="instanceSection">',...
        '<p class="previewSectionHeader">',message('SimulinkCoderApp:ui:MultiInstanceData').getString,':</p>',...
        '<div class="sectionDivider"></div>',...
        multiInstanceTxt,...
        '</div>'];
    elseif isa(entry,'coderdictionary.data.StorageClass')
        [ret,siPreview,miPreview]=loc_getSingleInstancePreview(obj,ret);
        if strcmp(entry.StorageType,'Mixed')
            miPreview=loc_getMultiInstancePreview(obj);
        end
    end
    if strcmp(obj.EntryType,'StorageClass')
        out=struct('singleInstance',siPreview,'multiInstance',miPreview,'type',obj.EntryType);
    else
        out=struct('previewStr',sprintf('<pre>%s</pre>',ret),'type',obj.EntryType);
    end
end

function[ret,siPreview,miPreview]=loc_getSingleInstancePreview(obj,ret)
    entry=obj.getEntry();
    if(strcmp(entry.StorageType,'Structured')&&~strcmp(entry.DataAccess,'Pointer'))||...
        (strcmp(entry.StorageType,'Mixed')&&strcmp(entry.SingleInstanceStorageType,'Structured'))
        entryStruct=obj.pvt_getEntryStruct;
        sc=entryStruct.StorageClass;
        ms=entryStruct.MemorySection;
        actStructType=obj.resolveStructTypeToken(sc.CSCTypeAttributes.TypeName,sc.Name,obj.ModelName,'',true);
        actStructName=obj.resolveStructInstanceToken(sc.CSCTypeAttributes.StructName,sc.Name,obj.ModelName,'',true);
        if ms.IsConst
            tooltipStr=message('SimulinkCoderApp:ui:PropertyConstIsTrue').getString;
            constStr=[obj.getPropertyPreview(tooltipStr,'kw','isConst','const'),' '];
        else
            constStr='';
        end
        typedefStr=sprintf('%s<div class="previewcode"><span class="kw">struct</span> tag_RTM {\n <p class="tabIndent">...</p><p class="tabIndent">%s%s *%s;</p><p class="tabIndent">...</p>}</div>',...
        ['<p class="previewHeader">',DAStudio.message('Simulink:dialog:CSCUITypeDefn'),'</p>'],...
        constStr,actStructType,actStructName);
        typedefStr=['<div class="previewSection">',typedefStr,'</div>'];
        define_str=['<div class="previewSection"><span class="previewHeader">',DAStudio.message('Simulink:dialog:CSCUIDefinition'),'</span>',newline,...
        '<div class="previewmessage">',message('SimulinkCoderApp:ui:MultiInstanceDataDefinition').getString,'</div></div>'];
        multiInstanceTxt=sprintf('%s%s',typedefStr,define_str);
        siPreview=ret;
        miPreview=multiInstanceTxt;

        ret=['<div class="instanceSection"><p class="previewSectionHeader">',message('SimulinkCoderApp:ui:SingleInstanceData').getString,':</p><div class="sectionDivider"></div>',ret,'</div>',...
        '<div class="instanceSection"><p class="previewSectionHeader">',message('SimulinkCoderApp:ui:MultiInstanceData').getString,':</p><div class="sectionDivider"></div>',multiInstanceTxt,'</div>'];%#ok<*AGROW>
    elseif strcmp(entry.StorageType,'Unstructured')||...
        (strcmp(entry.StorageType,'Mixed')&&strcmp(entry.SingleInstanceStorageType,'Unstructured'))||...
        (strcmp(entry.StorageType,'Structured')&&strcmp(entry.DataAccess,'Pointer'))
        multiInstanceTxt=obj.FormatHeader(DAStudio.message('Simulink:dialog:CSCUINotApplicable'),'');
        siPreview=ret;
        miPreview=multiInstanceTxt;

        ret=['<div class="instanceSection"><p class="previewSectionHeader">',message('SimulinkCoderApp:ui:SingleInstanceData').getString,':</p><div class="sectionDivider"></div>',ret,'</div>',...
        '<div class="instanceSection"><p class="previewSectionHeader">',message('SimulinkCoderApp:ui:MultiInstanceData').getString,':</p><div class="sectionDivider"></div>',multiInstanceTxt,'</div>'];%#ok<*AGROW>
    end
end

function miPreview=loc_getMultiInstancePreview(obj)
    entry=obj.getEntry();

    entryStruct=obj.pvt_getEntryStruct;
    sc=entryStruct.StorageClass;
    ms=entryStruct.MemorySection;

    mi_actStructType=obj.resolveStructTypeToken(sc.MultiInstanceCSCTypeAttributes.TypeName,sc.Name,obj.ModelName,'',false);
    mi_actStructName=obj.resolveStructInstanceToken(sc.MultiInstanceCSCTypeAttributes.StructName,sc.Name,obj.ModelName,obj.ModelName,false);
    if ms.IsConst
        tooltipStr=message('SimulinkCoderApp:ui:PropertyConstIsTrue').getString;
        constStr=[obj.getPropertyPreview(tooltipStr,'kw','isConst','const'),' '];
    else
        constStr='';
    end

    tagRTM=obj.getCodePreviewUsingNamingService(obj.ModelName,obj.CustomSymbolStrType,'tag_RTM',sc.Name,'');
    RTMODEL=obj.getCodePreviewUsingNamingService(obj.ModelName,obj.CustomSymbolStrType,'RT_MODEL',sc.Name,'');
    MdlrefDW=obj.getCodePreviewUsingNamingService(obj.ModelName,obj.CustomSymbolStrType,'MdlrefDW',sc.Name,'');


    if strcmp(sc.MultiInstanceCSCTypeAttributes.Placement,'InParent')
        pointerToParent='*';
    else
        pointerToParent='';
    end
    ellipses='<p class="tabIndent">...</p>';
    inChild=['<span class="kw">typedef struct</span> ',...
    tagRTM,' ',RTMODEL,';',newline,newline,...
    '<span class="kw">typedef struct</span> {',newline,...
    ellipses,...
    '<p class="tabIndent tk">FIELDTYPE FIELDNAME;</p>',...
    ellipses,...
    '} ',mi_actStructType,';',newline,newline,...
    '<span class="kw">struct</span> ',tagRTM,' {',newline,...
    ellipses,...
    '<p class="tabIndent">',constStr,mi_actStructType,' ',...
    pointerToParent,mi_actStructName,';</p>',...
    ellipses,...
    '};',newline,newline,...
    '<span class="kw">typedef struct</span> {',newline,...
    ellipses,...
    '<p class="tabIndent">',RTMODEL,' rtm;</p>',...
    ellipses,...
    '} ',MdlrefDW,';'];
    inChild=['<div class="previewSection"><div class="previewcode">',inChild,'</div></div>'];
    inChild=['<div class="previewHeader"><b>',message('SimulinkCoderApp:core:CodeInChildModel').getString,...
    ': </b>',obj.ModelName,'</div>',inChild];


    inParent='';
    subMdlRefType=MdlrefDW;
    if strcmp(sc.MultiInstanceCSCTypeAttributes.Placement,'InParent')

        if strcmp(entry.SingleInstanceStorageType,'Unstructured')


            mi_actStructNameInParent=obj.resolveStructInstanceToken(sc.MultiInstanceCSCTypeAttributes.StructName,sc.Name,obj.TopModelName,[obj.ModelName,'Inst'],false);
            mi_actStructName=obj.resolveStructInstanceToken(sc.MultiInstanceCSCTypeAttributes.StructName,sc.Name,obj.ModelName,obj.ModelName,false);

            instanceData=['rt',obj.ModelName,'Inst_InstanceData'];






            inParent=[subMdlRefType,' ',instanceData,';',newline,newline,...
            mi_actStructType,' ',mi_actStructNameInParent,';',newline,newline,...
            instanceData,'.rtm.',mi_actStructName,' = &',mi_actStructNameInParent,';'];
        else


            si_actStructType=obj.resolveStructTypeToken(sc.CSCTypeAttributes.TypeName,sc.Name,obj.TopModelName,'',true);
            si_actStructName=obj.resolveStructInstanceToken(sc.CSCTypeAttributes.StructName,sc.Name,obj.TopModelName,'',true);

            instanceData=[obj.ModelName,'Inst_InstanceData'];

            inParent=['<span class="kw">typedef struct</span> {',newline,...
            ellipses,...
            '<p class="tabIndent">',subMdlRefType,' ',instanceData,';</p>',...
            '<p class="tabIndent">',mi_actStructType,' ',mi_actStructName,';</p>',...
            ellipses,...
            '} ',si_actStructType,';',newline,newline,...
            si_actStructType,' ',si_actStructName,';',newline,newline,...
            si_actStructName,'.',instanceData,'.rtm.',mi_actStructName,' = &',si_actStructName,'.',mi_actStructName,';'];
        end
    elseif strcmp(sc.MultiInstanceCSCTypeAttributes.Placement,'InSelf')
        if strcmp(entry.SingleInstanceStorageType,'Unstructured')
            inParent=[MdlrefDW,' rt',obj.ModelName,'Inst_InstanceData;',newline,...
            ];
        else


            si_actStructType=obj.resolveStructTypeToken(sc.CSCTypeAttributes.TypeName,sc.Name,obj.TopModelName,'',true);
            si_actStructName=obj.resolveStructInstanceToken(sc.CSCTypeAttributes.StructName,sc.Name,obj.TopModelName,'',true);

            instanceData=[obj.ModelName,'Inst_InstanceData'];

            inParent=['<span class="kw">typedef struct</span> {',newline,...
            ellipses,...
            '<p class="tabIndent">',subMdlRefType,' ',instanceData,';</p>',...
            ellipses,...
            '} ',si_actStructType,';',newline,newline,...
            si_actStructType,' ',si_actStructName,';'];
        end
    end

    inParent=['<div class="previewSection"><div class="previewcode">',inParent,'</div></div>'];
    inParent=['<div class="previewHeader"><b>',...
    message('SimulinkCoderApp:core:CodeInParentModel').getString,': </b>',obj.TopModelName,'</div>',inParent];

    multiInstanceTxt=[inChild,inParent];
    miPreview=multiInstanceTxt;
end



