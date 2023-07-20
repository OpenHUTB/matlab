function defs=csc_registration(action)




















    switch action

    case 'CSCDefn'
        defs=[];

        h=Simulink.CSCDefn;
        set(h,'Name','BasicStruct');
        set(h,'OwnerPackage','ECoderDemos');
        set(h,'CSCType','FlatStructure');
        set(h,'MemorySection','Default');
        set(h,'IsMemorySectionInstanceSpecific',false);
        set(h,'IsGrouped',true);
        set(h.DataUsage,'IsParameter',true);
        set(h.DataUsage,'IsSignal',true);
        set(h,'DataScope','Exported');
        set(h,'IsDataScopeInstanceSpecific',false);
        set(h,'IsAutosarPerInstanceMemory',false);
        set(h,'DataInit','Auto');
        set(h,'IsDataInitInstanceSpecific',false);
        set(h,'DataAccess','Direct');
        set(h,'IsDataAccessInstanceSpecific',false);
        set(h,'HeaderFile','');
        set(h,'IsHeaderFileInstanceSpecific',false);
        set(h,'Owner','');
        set(h,'IsOwnerInstanceSpecific',false);
        set(h,'DefinitionFile','');
        set(h,'IsDefinitionFileInstanceSpecific',false);
        set(h,'IsReusable',false);
        set(h,'IsReusableInstanceSpecific',false);
        set(h,'CommentSource','Specify');
        set(h,'TypeComment','/* BasicStruct data */');
        set(h,'DeclareComment','');
        set(h,'DefineComment','');
        set(h,'CSCTypeAttributesClassName','Simulink.CSCTypeAttributes_FlatStructure');
        set(h.CSCTypeAttributes,'StructName','basicStruct');
        set(h.CSCTypeAttributes,'IsStructNameInstanceSpecific',false);
        set(h.CSCTypeAttributes,'BitPackBoolean',false);
        set(h.CSCTypeAttributes,'IsTypeDef',true);
        set(h.CSCTypeAttributes,'TypeName','BasicStruct');
        set(h.CSCTypeAttributes,'TypeToken','');
        set(h.CSCTypeAttributes,'TypeTag','');
        set(h,'TLCFileName','FlatStructure.tlc');
        defs=[defs;h];

        h=Simulink.CSCDefn;
        set(h,'Name','StructPointer');
        set(h,'OwnerPackage','ECoderDemos');
        set(h,'CSCType','FlatStructure');
        set(h,'MemorySection','ConstVolatile');
        set(h,'IsMemorySectionInstanceSpecific',false);
        set(h,'IsGrouped',true);
        set(h.DataUsage,'IsParameter',true);
        set(h.DataUsage,'IsSignal',false);
        set(h,'DataScope','Imported');
        set(h,'IsDataScopeInstanceSpecific',false);
        set(h,'IsAutosarPerInstanceMemory',false);
        set(h,'DataInit','None');
        set(h,'IsDataInitInstanceSpecific',false);
        set(h,'DataAccess','Pointer');
        set(h,'IsDataAccessInstanceSpecific',false);
        set(h,'HeaderFile','rtwdemo_importstruct_user.h');
        set(h,'IsHeaderFileInstanceSpecific',false);
        set(h,'Owner','');
        set(h,'IsOwnerInstanceSpecific',false);
        set(h,'DefinitionFile','');
        set(h,'IsDefinitionFileInstanceSpecific',false);
        set(h,'IsReusable',false);
        set(h,'IsReusableInstanceSpecific',false);
        set(h,'CommentSource','Default');
        set(h,'TypeComment','');
        set(h,'DeclareComment','');
        set(h,'DefineComment','');
        set(h,'CSCTypeAttributesClassName','Simulink.CSCTypeAttributes_FlatStructure');
        set(h.CSCTypeAttributes,'StructName','StructPointer');
        set(h.CSCTypeAttributes,'IsStructNameInstanceSpecific',false);
        set(h.CSCTypeAttributes,'BitPackBoolean',false);
        set(h.CSCTypeAttributes,'IsTypeDef',true);
        set(h.CSCTypeAttributes,'TypeName','DataStruct_type');
        set(h.CSCTypeAttributes,'TypeToken','');
        set(h.CSCTypeAttributes,'TypeTag','');
        set(h,'TLCFileName','FlatStructure.tlc');
        defs=[defs;h];

        h=Simulink.CSCDefn;
        set(h,'Name','ParamVariant');
        set(h,'OwnerPackage','ECoderDemos');
        set(h,'CSCType','Other');
        set(h,'MemorySection','Default');
        set(h,'IsMemorySectionInstanceSpecific',false);
        set(h,'IsGrouped',false);
        set(h.DataUsage,'IsParameter',true);
        set(h.DataUsage,'IsSignal',false);
        set(h,'DataScope','Exported');
        set(h,'IsDataScopeInstanceSpecific',false);
        set(h,'IsAutosarPerInstanceMemory',false);
        set(h,'DataInit','Auto');
        set(h,'IsDataInitInstanceSpecific',false);
        set(h,'DataAccess','Direct');
        set(h,'IsDataAccessInstanceSpecific',false);
        set(h,'HeaderFile','');
        set(h,'IsHeaderFileInstanceSpecific',false);
        set(h,'Owner','');
        set(h,'IsOwnerInstanceSpecific',false);
        set(h,'DefinitionFile','');
        set(h,'IsDefinitionFileInstanceSpecific',false);
        set(h,'IsReusable',false);
        set(h,'IsReusableInstanceSpecific',false);
        set(h,'CommentSource','Default');
        set(h,'TypeComment','');
        set(h,'DeclareComment','');
        set(h,'DefineComment','');
        set(h,'CSCTypeAttributesClassName','');
        set(h,'CSCTypeAttributes',[]);
        set(h,'TLCFileName','ParamVariant.tlc');
        defs=[defs;h];

        h=Simulink.CSCDefn;
        set(h,'Name','Invariant');
        set(h,'OwnerPackage','ECoderDemos');
        set(h,'CSCType','Other');
        set(h,'MemorySection','Default');
        set(h,'IsMemorySectionInstanceSpecific',false);
        set(h,'IsGrouped',false);
        set(h.DataUsage,'IsParameter',true);
        set(h.DataUsage,'IsSignal',true);
        set(h,'DataScope','Exported');
        set(h,'IsDataScopeInstanceSpecific',false);
        set(h,'IsAutosarPerInstanceMemory',false);
        set(h,'DataInit','Auto');
        set(h,'IsDataInitInstanceSpecific',false);
        set(h,'DataAccess','Direct');
        set(h,'IsDataAccessInstanceSpecific',false);
        set(h,'HeaderFile','');
        set(h,'IsHeaderFileInstanceSpecific',false);
        set(h,'Owner','');
        set(h,'IsOwnerInstanceSpecific',false);
        set(h,'DefinitionFile','');
        set(h,'IsDefinitionFileInstanceSpecific',false);
        set(h,'IsReusable',false);
        set(h,'IsReusableInstanceSpecific',false);
        set(h,'CommentSource','Default');
        set(h,'TypeComment','');
        set(h,'DeclareComment','');
        set(h,'DefineComment','');
        set(h,'CSCTypeAttributesClassName','');
        set(h,'CSCTypeAttributes',[]);
        set(h,'TLCFileName','Invariant.tlc');
        defs=[defs;h];

    case 'MemorySectionDefn'
        defs=[];

        h=Simulink.MemorySectionDefn;
        set(h,'Name','ConstVolatile');
        set(h,'OwnerPackage','ECoderDemos');
        set(h,'Comment','');
        set(h,'PragmaPerVar',false);
        set(h,'PrePragma','');
        set(h,'PostPragma','');
        set(h,'IsConst',true);
        set(h,'IsVolatile',true);
        set(h,'Qualifier','');
        defs=[defs;h];

        h=Simulink.MemorySectionDefn;
        set(h,'Name','SlowMemory');
        set(h,'OwnerPackage','ECoderDemos');
        set(h,'Comment','/* This memory is cheap but slow */');
        set(h,'PragmaPerVar',true);
        set(h,'PrePragma','#pragma SLOW_MEM($N)');
        set(h,'PostPragma','');
        set(h,'IsConst',false);
        set(h,'IsVolatile',false);
        set(h,'Qualifier','');
        defs=[defs;h];

        h=Simulink.MemorySectionDefn;
        set(h,'Name','MediumMemory');
        set(h,'OwnerPackage','ECoderDemos');
        set(h,'Comment','/* This memory is of moderate speed and cost */');
        set(h,'PragmaPerVar',true);
        set(h,'PrePragma','#pragma MEDIUM_MEM($N)');
        set(h,'PostPragma','');
        set(h,'IsConst',false);
        set(h,'IsVolatile',false);
        set(h,'Qualifier','');
        defs=[defs;h];

        h=Simulink.MemorySectionDefn;
        set(h,'Name','FastMemory');
        set(h,'OwnerPackage','ECoderDemos');
        set(h,'Comment','/* This memory is fast but expensive */');
        set(h,'PragmaPerVar',true);
        set(h,'PrePragma','#pragma FAST_MEM($N)');
        set(h,'PostPragma','');
        set(h,'IsConst',false);
        set(h,'IsVolatile',false);
        set(h,'Qualifier','');
        defs=[defs;h];

    otherwise
        DAStudio.error('Simulink:dialog:CSCRegInvalidAction',action);
    end



