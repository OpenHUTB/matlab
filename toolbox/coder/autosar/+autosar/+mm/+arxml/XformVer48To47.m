classdef XformVer48To47<handle




    properties(Access=public)
AutosarTargetNsUri
AutosarTargetVersionStr
Transformer
m3iModel
    end

    methods
        function self=XformVer48To47(versionStr,m3iModel,transformer)
            self.AutosarTargetVersionStr=versionStr;
            self.AutosarTargetNsUri=autosar.mm.arxml.SchemaUtil.getSchemaUri(versionStr);
            self.Transformer=transformer;
            self.m3iModel=m3iModel;
            self.registerAttribute('xmlns',@self.processXmlNs);
            self.registerAttribute('xsi:schemaLocation',@self.processSchemaLocation);
            self.registerAttribute('SERVICE-INTERFACE-DEPLOYMENT-REF',@self.processServiceIntfDeployment);
            self.registerAttribute('PROCESS-DESIGN-REF',@self.processPRefInServiceInstanceToPortMapping);
            self.registerPreTransform('LOG-TRACE-LOG-MODES',@self.processLogTraceLogModes);
            self.registerPostTransform('LOG-TRACE-LOG-MODES',@self.processLogTraceLogModes);
            self.registerPreTransform('DESIGN-REF',@self.skipElement);
            self.registerPostTransform('DESIGN-REF',@self.skipElement);

            self.registerPreTransform('SHORT-NAME',@self.processPDesignShortName);
            self.registerPostTransform('SHORT-NAME',@self.processPDesignShortName);
            self.registerPreTransform('EXECUTABLE-REF',@self.processPDesignExecRef);
            self.registerPostTransform('EXECUTABLE-REF',@self.processPDesignExecRef);
            self.registerPreTransform('PROCESS-DESIGN',@self.skipElement);
            self.registerPostTransform('PROCESS-DESIGN',@self.skipElement);

            self.registerPreTransform('LOGGING-BEHAVIOR',@self.skipElement);
            self.registerPostTransform('LOGGING-BEHAVIOR',@self.skipElement);

            self.registerPreTransform('PERSISTENCY-KEY-VALUE-STORAGE',@self.persistencyKeyValueStorage);
            self.registerPostTransform('PERSISTENCY-KEY-VALUE-STORAGE',@self.persistencyKeyValueStorage);
            self.registerPreTransform('PERSISTENCY-KEY-VALUE-STORAGE-INTERFACE',@self.persistencyKeyValueStorageInterface);
            self.registerPostTransform('PERSISTENCY-KEY-VALUE-STORAGE-INTERFACE',@self.persistencyKeyValueStorageInterface);
            self.registerPreTransform('PERSISTENCY-PORT-PROTOTYPE-TO-KEY-VALUE-STORAGE-MAPPING',@self.persistencyKeyValueStorageMapping);
            self.registerPostTransform('PERSISTENCY-PORT-PROTOTYPE-TO-KEY-VALUE-STORAGE-MAPPING',@self.persistencyKeyValueStorageMapping);
            self.registerPreTransform('KEY-VALUE-STORAGE-REF',@self.keyValueStorageRef);
            self.registerPostTransform('KEY-VALUE-STORAGE-REF',@self.keyValueStorageRef);
        end

        function delete(self)
            self.Transformer=[];
        end

        function registerAttribute(self,contextName,func)
            context=self.createAutosarAttributeContext(contextName);
            self.Transformer.addPreTransform(context,func);
        end

        function registerPreTransform(self,contextName,func)
            context=self.createAutosarElementContext(contextName);
            self.Transformer.addPreTransform(context,func);
        end

        function ret=createAutosarElementContext(~,roleName)
            context=M3I.Context;
            context.RoleName=roleName;
            context.setElement('');
            ret=context;
        end

        function registerPostTransform(self,contextName,func)
            context=self.createAutosarElementContext(contextName);
            self.Transformer.addPostTransform(context,func);
        end

        function ret=createAutosarAttributeContext(~,roleName)
            context=M3I.Context;
            context.RoleName=roleName;
            context.setAttributeValue('');
            ret=context;
        end

        function retSeq=processXmlNs(self,inputCtx)
            retSeq=M3I.ContextSequence;
            context=inputCtx;
            context.setAttributeValue(self.AutosarTargetNsUri);
            retSeq.addContext(context);
        end

        function retSeq=processSchemaLocation(self,inputCtx)
            retSeq=M3I.ContextSequence;
            context=inputCtx;
            autosarTargetVersionStr=regexprep(self.AutosarTargetVersionStr,'\.','-');
            context.setAttributeValue([self.AutosarTargetNsUri,' ','AUTOSAR_',autosarTargetVersionStr,'.xsd']);
            retSeq.addContext(context);
        end

        function retSeq=processServiceIntfDeployment(~,inputCtx)
            retSeq=M3I.ContextSequence;
            context=inputCtx;
            context.RoleName='SERVICE-INTERFACE-REF';
            retSeq.addContext(context);
        end

        function retSeq=processLogTraceLogModes(~,inputCtx)
            retSeq=M3I.ContextSequence;
            context=inputCtx;
            context.Skip=1;
            retSeq.addContext(context);
        end

        function retSeq=processPRefInServiceInstanceToPortMapping(self,inputCtx)
            retSeq=M3I.ContextSequence;
            context=inputCtx;


            if strcmp(context.ParentRoleName,'SERVICE-INSTANCE-TO-PORT-PROTOTYPE-MAPPING')
                context.setAttribute(1,context.getAttributeNamespace(1),'DEST','PROCESS');
                context.RoleName='PROCESS-REF';
                processDesignValue=context.getValue;
                processes=autosar.mm.Model.findObjectByMetaClass(self.m3iModel,...
                Simulink.metamodel.arplatform.manifest.Process.MetaClass);



                for i=1:numel(processes.size)
                    process=processes.at(i);
                    processDesign=process.ProcessDesign;
                    if contains(processDesign.qualifiedNameWithSeparator('/'),processDesignValue)
                        processQualPath=process.qualifiedNameWithSeparator('/');
                        context.setValueElement(processQualPath(8:end));
                        break;
                    end
                end
            end
            retSeq.addContext(context);
        end

        function unregisterPreTransform(self,contextName)
            context=self.createAutosarElementContext(contextName);
            self.Transformer.removeLastPreTransform(context);
        end

        function unregisterPostTransform(self,contextName)
            context=self.createAutosarElementContext(contextName);
            self.Transformer.removeLastPostTransform(context);
        end

        function retSeq=processPDesignShortName(~,inputCtx)
            retSeq=M3I.ContextSequence;
            context=inputCtx;
            if strcmp(context.ParentRoleName,'PROCESS-DESIGN')
                context.Skip=1;
            end
            retSeq.addContext(context);
        end

        function retSeq=processPDesignExecRef(~,inputCtx)
            retSeq=M3I.ContextSequence;
            context=inputCtx;
            if strcmp(context.ParentRoleName,'PROCESS-DESIGN')
                context.Skip=1;
            end
            retSeq.addContext(context);
        end

        function retSeq=skipElement(~,inputCtx)
            retSeq=M3I.ContextSequence;
            context=inputCtx;
            context.Skip=1;
            retSeq.addContext(context);
        end

        function retSeq=processDesignRef(~,inputCtx)
            retSeq=M3I.ContextSequence;
            context=inputCtx;
            context.RoleName='PROCESS-REF';
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


