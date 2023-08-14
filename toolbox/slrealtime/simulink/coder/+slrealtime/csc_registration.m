function defs=csc_registration(action)





















    switch action

    case 'CSCDefn'
        defs=[];

        h=Simulink.CSCDefn;
        set(h,'Name','PageSwitching');
        set(h,'OwnerPackage','slrealtime');
        set(h,'CSCType','AccessFunction');
        set(h,'MemorySection','Default');
        set(h,'IsMemorySectionInstanceSpecific',false);
        set(h,'IsGrouped',false);
        set(h.DataUsage,'IsParameter',true);
        set(h.DataUsage,'IsSignal',false);
        set(h,'DataScope','Imported');
        set(h,'IsDataScopeInstanceSpecific',false);
        set(h,'IsAutosarPerInstanceMemory',false);
        set(h,'DataInit','None');
        set(h,'IsDataInitInstanceSpecific',false);
        set(h,'DataAccess','Pointer');
        set(h,'IsDataAccessInstanceSpecific',false);
        set(h,'HeaderFile','');
        set(h,'IsHeaderFileInstanceSpecific',false);
        set(h,'DefinitionFile','');
        set(h,'IsDefinitionFileInstanceSpecific',false);
        set(h,'Owner','');
        set(h,'IsOwnerInstanceSpecific',false);
        set(h,'PreserveDimensions',false);
        set(h,'PreserveDimensionsInstanceSpecific',false);
        set(h,'IsReusable',false);
        set(h,'IsReusableInstanceSpecific',false);
        set(h,'CommentSource','Default');
        set(h,'TypeComment','');
        set(h,'DeclareComment','');
        set(h,'DefineComment','');
        set(h,'CSCTypeAttributesClassName','Simulink.CSCTypeAttributes_GetSet');
        set(h.CSCTypeAttributes,'GetFunction','get_$N');
        set(h.CSCTypeAttributes,'IsGetFunctionInstanceSpecific',false);
        set(h.CSCTypeAttributes,'SetFunction','set_$N');
        set(h.CSCTypeAttributes,'IsSetFunctionInstanceSpecific',false);
        set(h,'TLCFileName','GetSet.tlc');
        defs=[defs;h];

    case 'MemorySectionDefn'
        defs=[];

        h=Simulink.MemorySectionDefn;
        set(h,'Name','MemConst');
        set(h,'OwnerPackage','slrealtime');
        set(h,'Comment','/* Const memory section */');
        set(h,'PragmaPerVar',false);
        set(h,'PrePragma','');
        set(h,'PostPragma','');
        set(h.DataUsage,'IsParameter',true);
        set(h.DataUsage,'IsSignal',false);
        set(h,'IsConst',true);
        set(h,'IsVolatile',false);
        set(h,'Qualifier','');
        defs=[defs;h];

        h=Simulink.MemorySectionDefn;
        set(h,'Name','MemVolatile');
        set(h,'OwnerPackage','slrealtime');
        set(h,'Comment','/* Volatile memory section */');
        set(h,'PragmaPerVar',false);
        set(h,'PrePragma','');
        set(h,'PostPragma','');
        set(h.DataUsage,'IsParameter',true);
        set(h.DataUsage,'IsSignal',true);
        set(h,'IsConst',false);
        set(h,'IsVolatile',true);
        set(h,'Qualifier','');
        defs=[defs;h];

        h=Simulink.MemorySectionDefn;
        set(h,'Name','MemConstVolatile');
        set(h,'OwnerPackage','slrealtime');
        set(h,'Comment','/* ConstVolatile memory section */');
        set(h,'PragmaPerVar',false);
        set(h,'PrePragma','');
        set(h,'PostPragma','');
        set(h.DataUsage,'IsParameter',true);
        set(h.DataUsage,'IsSignal',false);
        set(h,'IsConst',true);
        set(h,'IsVolatile',true);
        set(h,'Qualifier','');
        defs=[defs;h];

    otherwise
        DAStudio.error('Simulink:dialog:CSCRegInvalidAction',action);
    end



