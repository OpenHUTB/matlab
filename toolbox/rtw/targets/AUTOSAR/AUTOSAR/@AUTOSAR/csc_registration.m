function defs=csc_registration(action)



















    switch action

    case 'CSCDefn'
        defs=[];

        h=Simulink.CSCDefn;
        set(h,'Name','InternalCalPrm');
        set(h,'OwnerPackage','AUTOSAR');
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
        set(h,'CommentSource','Default');
        set(h,'TypeComment','');
        set(h,'DeclareComment','');
        set(h,'DefineComment','');
        set(h,'CSCTypeAttributesClassName','AUTOSAR.InternalCalPrmAttributes');
        set(h.CSCTypeAttributes,'PerInstanceBehavior','Parameter shared by all instances of the Software Component');
        set(h,'TLCFileName','CalPrm.tlc');
        defs=[defs;h];

        h=Simulink.CSCDefn;
        set(h,'Name','PerInstanceMemory');
        set(h,'OwnerPackage','AUTOSAR');
        set(h,'CSCType','Other');
        set(h,'MemorySection','Default');
        set(h,'IsMemorySectionInstanceSpecific',false);
        set(h,'IsGrouped',false);
        set(h.DataUsage,'IsParameter',false);
        set(h.DataUsage,'IsSignal',true);
        set(h,'DataScope','Exported');
        set(h,'IsDataScopeInstanceSpecific',false);
        set(h,'IsAutosarPerInstanceMemory',true);
        set(h,'DataInit','Auto');
        set(h,'IsDataInitInstanceSpecific',false);
        set(h,'DataAccess','Direct');
        set(h,'IsDataAccessInstanceSpecific',false);
        set(h,'HeaderFile','');
        set(h,'IsHeaderFileInstanceSpecific',false);
        set(h,'CommentSource','Default');
        set(h,'TypeComment','');
        set(h,'DeclareComment','');
        set(h,'DefineComment','');
        set(h,'CSCTypeAttributesClassName','AUTOSAR.PIMAttributes');
        set(h.CSCTypeAttributes,'needsNVRAMAccess',false);
        set(h,'TLCFileName','PerInstanceMemory.tlc');
        defs=[defs;h];

        h=Simulink.CSCDefn;
        set(h,'Name','CalPrm');
        set(h,'OwnerPackage','AUTOSAR');
        set(h,'CSCType','Other');
        set(h,'MemorySection','Default');
        set(h,'IsMemorySectionInstanceSpecific',false);
        set(h,'IsGrouped',false);
        set(h.DataUsage,'IsParameter',true);
        set(h.DataUsage,'IsSignal',false);
        set(h,'DataScope','Exported');
        set(h,'IsDataScopeInstanceSpecific',false);
        set(h,'IsAutosarPerInstanceMemory',false);
        set(h,'DataInit','Static');
        set(h,'IsDataInitInstanceSpecific',false);
        set(h,'DataAccess','Direct');
        set(h,'IsDataAccessInstanceSpecific',false);
        set(h,'HeaderFile','');
        set(h,'IsHeaderFileInstanceSpecific',false);
        set(h,'CommentSource','Default');
        set(h,'TypeComment','');
        set(h,'DeclareComment','');
        set(h,'DefineComment','');
        set(h,'CSCTypeAttributesClassName','AUTOSAR.CSCTypeAttributes_CalPrm');
        set(h.CSCTypeAttributes,'ElementName','UNDEFINED');
        set(h.CSCTypeAttributes,'PortName','UNDEFINED');
        set(h.CSCTypeAttributes,'InterfacePath','UNDEFINED');
        set(h.CSCTypeAttributes,'CalibrationComponent','');
        set(h.CSCTypeAttributes,'ProviderPortName','');
        set(h,'TLCFileName','CalPrm.tlc');
        defs=[defs;h];

    case 'MemorySectionDefn'
        defs=[];

    otherwise
        DAStudio.error('Simulink:dialog:CSCRegInvalidAction',action);
    end



