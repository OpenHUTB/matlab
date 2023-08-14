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
        set(h,'DataScope','Imported');
        set(h,'IsDataScopeInstanceSpecific',false);
        set(h,'IsAutosarPerInstanceMemory',false);
        set(h,'DataInit','None');
        set(h,'IsDataInitInstanceSpecific',false);
        set(h,'DataAccess','Direct');
        set(h,'IsDataAccessInstanceSpecific',false);
        set(h,'HeaderFile','');
        set(h,'IsHeaderFileInstanceSpecific',true);
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
        set(h,'CSCTypeAttributesClassName','AUTOSAR.PIMAttributes');
        set(h.CSCTypeAttributes,'needsNVRAMAccess',false);
        set(h.CSCTypeAttributes,'IsArTypedPerInstanceMemory',false);
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
        set(h,'DataScope','Imported');
        set(h,'IsDataScopeInstanceSpecific',false);
        set(h,'IsAutosarPerInstanceMemory',false);
        set(h,'DataInit','None');
        set(h,'IsDataInitInstanceSpecific',false);
        set(h,'DataAccess','Direct');
        set(h,'IsDataAccessInstanceSpecific',false);
        set(h,'HeaderFile','');
        set(h,'IsHeaderFileInstanceSpecific',true);
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
        set(h,'CSCTypeAttributesClassName','AUTOSAR.CSCTypeAttributes_CalPrm');
        set(h.CSCTypeAttributes,'ElementName','UNDEFINED');
        set(h.CSCTypeAttributes,'PortName','UNDEFINED');
        set(h.CSCTypeAttributes,'InterfacePath','UNDEFINED');
        set(h.CSCTypeAttributes,'CalibrationComponent','');
        set(h.CSCTypeAttributes,'ProviderPortName','');
        set(h,'TLCFileName','CalPrm.tlc');
        defs=[defs;h];

        h=Simulink.CSCDefn;
        set(h,'Name','SystemConstant');
        set(h,'OwnerPackage','AUTOSAR');
        set(h,'CSCType','Other');
        set(h,'MemorySection','Default');
        set(h,'IsMemorySectionInstanceSpecific',false);
        set(h,'IsGrouped',false);
        set(h.DataUsage,'IsParameter',true);
        set(h.DataUsage,'IsSignal',false);
        set(h,'DataScope','Imported');
        set(h,'IsDataScopeInstanceSpecific',false);
        set(h,'IsAutosarPerInstanceMemory',false);
        set(h,'DataInit','Macro');
        set(h,'IsDataInitInstanceSpecific',false);
        set(h,'DataAccess','Direct');
        set(h,'IsDataAccessInstanceSpecific',false);
        set(h,'HeaderFile','Rte_Cfg.h');
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
        set(h,'TLCFileName','SystemConstant.tlc');
        defs=[defs;h];

    case 'MemorySectionDefn'
        defs=[];

        h=Simulink.MemorySectionDefn;
        set(h,'Name','SwAddrMethod');
        set(h,'OwnerPackage','AUTOSAR');
        set(h,'Comment','');
        set(h,'PragmaPerVar',false);
        set(h,'PrePragma','#define %<AUTOSAR_COMPONENT>_START_SEC_%<MemorySectionName>\n#include "%<AUTOSAR_COMPONENT>_MemMap.h"');
        set(h,'PostPragma','#define %<AUTOSAR_COMPONENT>_STOP_SEC_%<MemorySectionName>\n#include "%<AUTOSAR_COMPONENT>_MemMap.h"');
        set(h,'IsConst',false);
        set(h,'IsVolatile',false);
        set(h,'Qualifier','');
        defs=[defs;h];

        h=Simulink.MemorySectionDefn;
        set(h,'Name','SwAddrMethod_Const');
        set(h,'OwnerPackage','AUTOSAR');
        set(h,'Comment','');
        set(h,'PragmaPerVar',false);
        set(h,'PrePragma','#define %<AUTOSAR_COMPONENT>_START_SEC_%<MemorySectionName>\n#include "%<AUTOSAR_COMPONENT>_MemMap.h"');
        set(h,'PostPragma','#define %<AUTOSAR_COMPONENT>_STOP_SEC_%<MemorySectionName>\n#include "%<AUTOSAR_COMPONENT>_MemMap.h"');
        set(h,'IsConst',true);
        set(h,'IsVolatile',false);
        set(h,'Qualifier','');
        defs=[defs;h];

        h=Simulink.MemorySectionDefn;
        set(h,'Name','SwAddrMethod_Const_Volatile');
        set(h,'OwnerPackage','AUTOSAR');
        set(h,'Comment','');
        set(h,'PragmaPerVar',false);
        set(h,'PrePragma','#define %<AUTOSAR_COMPONENT>_START_SEC_%<MemorySectionName>\n#include "%<AUTOSAR_COMPONENT>_MemMap.h"');
        set(h,'PostPragma','#define %<AUTOSAR_COMPONENT>_STOP_SEC_%<MemorySectionName>\n#include "%<AUTOSAR_COMPONENT>_MemMap.h"');
        set(h,'IsConst',true);
        set(h,'IsVolatile',true);
        set(h,'Qualifier','');
        defs=[defs;h];

        h=Simulink.MemorySectionDefn;
        set(h,'Name','SwAddrMethod_Volatile');
        set(h,'OwnerPackage','AUTOSAR');
        set(h,'Comment','');
        set(h,'PragmaPerVar',false);
        set(h,'PrePragma','#define %<AUTOSAR_COMPONENT>_START_SEC_%<MemorySectionName>\n#include "%<AUTOSAR_COMPONENT>_MemMap.h"');
        set(h,'PostPragma','#define %<AUTOSAR_COMPONENT>_STOP_SEC_%<MemorySectionName>\n#include "%<AUTOSAR_COMPONENT>_MemMap.h"');
        set(h,'IsConst',false);
        set(h,'IsVolatile',true);
        set(h,'Qualifier','');
        defs=[defs;h];

    otherwise
        DAStudio.error('Simulink:dialog:CSCRegInvalidAction',action);
    end





