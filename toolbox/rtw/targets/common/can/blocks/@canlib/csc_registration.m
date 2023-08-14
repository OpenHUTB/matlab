function defs=csc_registration(action)



















    switch action

    case 'CSCDefn'
        defs=[];

        h=Simulink.CSCDefn;
        set(h,'Name','Daq_List_Signal_Processing');
        set(h,'OwnerPackage','canlib');
        set(h,'CSCType','Other');
        set(h,'MemorySection','Default');
        set(h,'IsMemorySectionInstanceSpecific',false);
        set(h,'IsGrouped',false);
        set(h.DataUsage,'IsParameter',false);
        set(h.DataUsage,'IsSignal',true);
        set(h,'DataScope','Exported');
        set(h,'IsDataScopeInstanceSpecific',false);
        set(h,'DataInit','None');
        set(h,'IsDataInitInstanceSpecific',false);
        set(h,'DataAccess','Direct');
        set(h,'IsDataAccessInstanceSpecific',false);
        set(h,'HeaderFile','');
        set(h,'IsHeaderFileInstanceSpecific',false);
        set(h,'CommentSource','Default');
        set(h,'TypeComment','');
        set(h,'DeclareComment','');
        set(h,'DefineComment','');
        set(h,'CSCTypeAttributesClassName','');
        set(h,'TLCFileName','Daq_List_Signal_Processing.tlc');
        defs=[defs;h];

    case 'MemorySectionDefn'
        defs=[];

    otherwise
        DAStudio.error('Simulink:dialog:CSCRegInvalidAction',action);
    end



