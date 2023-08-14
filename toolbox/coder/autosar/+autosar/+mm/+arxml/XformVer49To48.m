classdef XformVer49To48<autosar.mm.arxml.XformVer49To49




    properties(Access=public)
    end

    methods
        function self=XformVer49To48(versionStr,transformer)

            self@autosar.mm.arxml.XformVer49To49(versionStr,transformer);
            self.registerAttribute('PROCESS-DESIGN-REF',@self.processDesignRef);
            self.registerPreTransform('PERSISTENCY-KEY-VALUE-STORAGE',@self.persistencyKeyValueStorage);
            self.registerPostTransform('PERSISTENCY-KEY-VALUE-STORAGE',@self.persistencyKeyValueStorage);
            self.registerPreTransform('PERSISTENCY-KEY-VALUE-STORAGE-INTERFACE',@self.persistencyKeyValueStorageInterface);
            self.registerPostTransform('PERSISTENCY-KEY-VALUE-STORAGE-INTERFACE',@self.persistencyKeyValueStorageInterface);
            self.registerPreTransform('PERSISTENCY-PORT-PROTOTYPE-TO-KEY-VALUE-STORAGE-MAPPING',@self.persistencyKeyValueStorageMapping);
            self.registerPostTransform('PERSISTENCY-PORT-PROTOTYPE-TO-KEY-VALUE-STORAGE-MAPPING',@self.persistencyKeyValueStorageMapping);
            self.registerPreTransform('KEY-VALUE-STORAGE-REF',@self.keyValueStorageRef);
            self.registerPostTransform('KEY-VALUE-STORAGE-REF',@self.keyValueStorageRef);
        end

        function bool=shouldRemove48Elements(~)
            bool=false;
        end

        function retSeq=processDesignRef(~,inputCtx)
            retSeq=M3I.ContextSequence;
            context=inputCtx;
            if strcmp(context.ParentRoleName,'SERVICE-INSTANCE-TO-PORT-PROTOTYPE-MAPPING')
                context.RoleName='PROCESS-REF';
            end
            retSeq.addContext(context);
        end

        function retSeq=persistencyKeyValueStorage(~,inputCtx)
            retSeq=M3I.ContextSequence;
            context=inputCtx;
            context.RoleName='PERSISTENCY-KEY-VALUE-DATABASE';
            retSeq.addContext(context);
        end

        function retSeq=persistencyKeyValueStorageInterface(~,inputCtx)
            retSeq=M3I.ContextSequence;
            context=inputCtx;
            context.RoleName='PERSISTENCY-KEY-VALUE-DATABASE-INTERFACE';
            retSeq.addContext(context);
        end

        function retSeq=persistencyKeyValueStorageMapping(~,inputCtx)
            retSeq=M3I.ContextSequence;
            context=inputCtx;
            context.RoleName='PERSISTENCY-PORT-PROTOTYPE-TO-KEY-VALUE-DATABASE-MAPPING';
            retSeq.addContext(context);
        end

        function retSeq=keyValueStorageRef(~,inputCtx)
            retSeq=M3I.ContextSequence;
            context=inputCtx;
            if strcmp(context.ParentRoleName,'PERSISTENCY-PORT-PROTOTYPE-TO-KEY-VALUE-DATABASE-MAPPING')||...
                strcmp(context.ParentRoleName,'PERSISTENCY-PORT-PROTOTYPE-TO-KEY-VALUE-STORAGE-MAPPING')
                context.setAttribute(1,context.getAttributeNamespace(1),'DEST','PERSISTENCY-KEY-VALUE-DATABASE');
            end
            retSeq.addContext(context);
        end
    end
end


