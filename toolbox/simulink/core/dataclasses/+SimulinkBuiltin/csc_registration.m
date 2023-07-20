function defs=csc_registration(action)




















    switch action

    case 'CSCDefn'
        defs=[];

        h=Simulink.CSCDefn;
        set(h,'Name','BuiltinExportedGlobal');
        set(h,'OwnerPackage','SimulinkBuiltin');
        set(h,'CSCType','Unstructured');
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
        set(h,'CommentSource','Specify');
        set(h,'TypeComment','');
        set(h,'DeclareComment','/* Data with Exported storage */');
        set(h,'DefineComment','/* Data with Exported storage */');
        set(h,'CSCTypeAttributesClassName','');
        set(h,'CSCTypeAttributes',[]);
        set(h,'TLCFileName','Unstructured.tlc');
        set(h,'ConcurrentAccess',false);
        set(h,'IsConcurrentAccessInstanceSpecific',true);
        defs=[defs;h];

        h=Simulink.CSCDefn;
        set(h,'Name','BuiltinImportedExtern');
        set(h,'OwnerPackage','SimulinkBuiltin');
        set(h,'CSCType','Unstructured');
        set(h,'MemorySection','Default');
        set(h,'IsMemorySectionInstanceSpecific',false);
        set(h,'IsGrouped',false);
        set(h.DataUsage,'IsParameter',true);
        set(h.DataUsage,'IsSignal',true);
        set(h,'DataScope','Imported');
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
        set(h,'TypeComment','');
        set(h,'DeclareComment','/* Data with Imported storage */');
        set(h,'DefineComment','/* Data with Imported storage */');
        set(h,'CSCTypeAttributesClassName','');
        set(h,'CSCTypeAttributes',[]);
        set(h,'TLCFileName','Unstructured.tlc');
        set(h,'ConcurrentAccess',false);
        set(h,'IsConcurrentAccessInstanceSpecific',true);
        defs=[defs;h];

        h=Simulink.CSCDefn;
        set(h,'Name','BuiltinImportedExternPointer');
        set(h,'OwnerPackage','SimulinkBuiltin');
        set(h,'CSCType','Unstructured');
        set(h,'MemorySection','Default');
        set(h,'IsMemorySectionInstanceSpecific',false);
        set(h,'IsGrouped',false);
        set(h.DataUsage,'IsParameter',true);
        set(h.DataUsage,'IsSignal',true);
        set(h,'DataScope','Imported');
        set(h,'IsDataScopeInstanceSpecific',false);
        set(h,'IsAutosarPerInstanceMemory',false);
        set(h,'DataInit','Auto');
        set(h,'IsDataInitInstanceSpecific',false);
        set(h,'DataAccess','Pointer');
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
        set(h,'TypeComment','');
        set(h,'DeclareComment','/* Data with Imported storage (pointer) */');
        set(h,'DefineComment','/* Data with Imported storage (pointer) */');
        set(h,'CSCTypeAttributesClassName','');
        set(h,'CSCTypeAttributes',[]);
        set(h,'TLCFileName','Unstructured.tlc');
        set(h,'ConcurrentAccess',false);
        set(h,'IsConcurrentAccessInstanceSpecific',true);
        defs=[defs;h];

    case 'MemorySectionDefn'
        defs=[];

    otherwise
        DAStudio.error('Simulink:dialog:CSCRegInvalidAction',action);
    end



