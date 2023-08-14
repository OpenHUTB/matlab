classdef XformVer49To49<handle




    properties(Access=public)
AutosarTargetNsUri
AutosarTargetVersionStr
Transformer
    end

    methods
        function self=XformVer49To49(versionStr,transformer)

            self.AutosarTargetVersionStr=versionStr;
            self.AutosarTargetNsUri=autosar.mm.arxml.SchemaUtil.getSchemaUri(versionStr);
            self.Transformer=transformer;
            self.registerAttribute('xmlns',@self.processXmlNs);
            self.registerAttribute('xsi:schemaLocation',@self.processSchemaLocation);

            self.XformVerCommon49And48();

            if self.shouldRemove48Elements()
                self.registerPreTransform('LOG-TRACE-LOG-MODES',@self.processLogElement);
                self.registerPostTransform('LOG-TRACE-LOG-MODES',@self.processLogElement);
                self.registerPreTransform('LOG-TRACE-DEFAULT-LOG-LEVEL',@self.processLogElement);
                self.registerPostTransform('LOG-TRACE-DEFAULT-LOG-LEVEL',@self.processLogElement);
                self.registerPreTransform('LOG-TRACE-PROCESS-DESC',@self.processLogElement);
                self.registerPostTransform('LOG-TRACE-PROCESS-DESC',@self.processLogElement);
                self.registerPreTransform('LOG-TRACE-PROCESS-ID',@self.processLogElement);
                self.registerPostTransform('LOG-TRACE-PROCESS-ID',@self.processLogElement);

                self.registerPreTransform('SHORT-NAME',@self.ddsMethodShortName);
                self.registerPostTransform('SHORT-NAME',@self.ddsMethodShortName);
                self.registerPreTransform('METHOD-REF',@self.ddsMethodRef);
                self.registerPostTransform('METHOD-REF',@self.ddsMethodRef);
                self.registerPreTransform('DDS-METHOD-DEPLOYMENT',@self.ddsMethodDeployment);
                self.registerPostTransform('DDS-METHOD-DEPLOYMENT',@self.ddsMethodDeployment);
                self.registerPreTransform('METHOD-DEPLOYMENTS',@self.skipElement);
                self.registerPostTransform('METHOD-DEPLOYMENTS',@self.skipElement);

                self.registerPreTransform('QOS-PROFILE',@self.qosProfile);
                self.registerPostTransform('QOS-PROFILE',@self.qosProfile);
                self.registerPreTransform('DDS-METHOD-QOS-PROPS',@self.ddsMethodQoSProfile);
                self.registerPostTransform('DDS-METHOD-QOS-PROPS',@self.ddsMethodQoSProfile);
                self.registerPreTransform('METHOD-QOS-PROPSS',@self.skipElement);
                self.registerPostTransform('METHOD-QOS-PROPSS',@self.skipElement);

                self.registerPreTransform('UPDATE-STRATEGY',@self.updateStrategy);
                self.registerPostTransform('UPDATE-STRATEGY',@self.updateStrategy);
                self.registerPreTransform('DATA-ELEMENT-REF',@self.dataElementRef);
                self.registerPostTransform('DATA-ELEMENT-REF',@self.dataElementRef);
                self.registerPreTransform('PERSISTENCY-DATA-PROVIDED-COM-SPEC',@self.perDataProvidedComSpec);
                self.registerPostTransform('PERSISTENCY-DATA-PROVIDED-COM-SPEC',@self.perDataProvidedComSpec);
            end
        end

        function delete(self)
            self.Transformer=[];
        end

        function bool=shouldRemove48Elements(~)
            bool=true;
        end

        function XformVerCommon49And48(self)
            self.registerPreTransform('ENTER-TIMEOUT-VALUE',@self.processEnterExitTimeout);
            self.registerPostTransform('ENTER-TIMEOUT-VALUE',@self.processEnterExitTimeout);
            self.registerPreTransform('EXIT-TIMEOUT-VALUE',@self.processEnterExitTimeout);
            self.registerPostTransform('EXIT-TIMEOUT-VALUE',@self.processEnterExitTimeout);
            self.registerPreTransform('TIMEOUT',@self.processTimeout);
            self.registerPostTransform('TIMEOUT',@self.processTimeout);
            self.registerPreTransform('STATE-REF',@self.skipElement);
            self.registerPostTransform('STATE-REF',@self.skipElement);
            self.registerPreTransform('PER-STATE-TIMEOUT',@self.skipElement);
            self.registerPostTransform('PER-STATE-TIMEOUT',@self.skipElement);
            self.registerPreTransform('PER-STATE-TIMEOUTS',@self.skipElement);
            self.registerPostTransform('PER-STATE-TIMEOUTS',@self.skipElement);
        end

        function registerAttribute(self,contextName,func)
            context=self.createAutosarAttributeContext(contextName);
            self.Transformer.addPreTransform(context,func);
        end

        function ret=createAutosarAttributeContext(~,roleName)
            context=M3I.Context;
            context.RoleName=roleName;
            context.setAttributeValue('');
            ret=context;
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

        function retSeq=skipElement(~,inputCtx)
            retSeq=M3I.ContextSequence;
            context=inputCtx;
            context.Skip=1;
            retSeq.addContext(context);
        end

        function retSeq=processEnterExitTimeout(~,inputCtx)
            retSeq=M3I.ContextSequence;
            context=inputCtx;
            if strcmp(context.ParentRoleName,'PER-STATE-TIMEOUT')
                context.Skip=1;
            end
            retSeq.addContext(context);
        end

        function retSeq=processTimeout(~,inputCtx)
            retSeq=M3I.ContextSequence;
            context=inputCtx;
            if strcmp(context.ParentRoleName,'PER-STATE-TIMEOUTS')
                context.Skip=1;
            end
            retSeq.addContext(context);
        end

        function retSeq=processLogElement(~,inputCtx)
            retSeq=M3I.ContextSequence;
            context=inputCtx;
            if strcmp(context.ParentRoleName,'PROCESS')
                context.Skip=1;
            end
            retSeq.addContext(context);
        end

        function retSeq=ddsMethodShortName(~,inputCtx)
            retSeq=M3I.ContextSequence;
            context=inputCtx;
            if strcmp(context.ParentRoleName,'DDS-METHOD-DEPLOYMENT')
                context.Skip=1;
            end
            retSeq.addContext(context);
        end

        function retSeq=ddsMethodDeployment(~,inputCtx)
            retSeq=M3I.ContextSequence;
            context=inputCtx;
            if strcmp(context.ParentRoleName,'METHOD-DEPLOYMENTS')
                context.Skip=1;
            end
            retSeq.addContext(context);
        end

        function retSeq=methodDeployments(~,inputCtx)
            retSeq=M3I.ContextSequence;
            context=inputCtx;
            if strcmp(context.ParentRoleName,'DDS-SERVICE-INTERFACE-DEPLOYMENT')
                context.Skip=1;
            end
            retSeq.addContext(context);
        end

        function retSeq=ddsMethodRef(~,inputCtx)
            retSeq=M3I.ContextSequence;
            context=inputCtx;
            if strcmp(context.ParentRoleName,'DDS-METHOD-DEPLOYMENT')||...
                strcmp(context.ParentRoleName,'DDS-METHOD-QOS-PROPS')
                context.Skip=1;
            end
            retSeq.addContext(context);
        end

        function retSeq=qosProfile(~,inputCtx)
            retSeq=M3I.ContextSequence;
            context=inputCtx;
            if strcmp(context.ParentRoleName,'DDS-METHOD-QOS-PROPS')
                context.Skip=1;
            end
            retSeq.addContext(context);
        end

        function retSeq=ddsMethodQoSProfile(~,inputCtx)
            retSeq=M3I.ContextSequence;
            context=inputCtx;
            if strcmp(context.ParentRoleName,'METHOD-QOS-PROPSS')
                context.Skip=1;
            end
            retSeq.addContext(context);
        end

        function retSeq=updateStrategy(~,inputCtx)
            retSeq=M3I.ContextSequence;
            context=inputCtx;
            if strcmp(context.ParentRoleName,'PERSISTENCY-KEY-VALUE-PAIR')
                context.Skip=1;
            end
            retSeq.addContext(context);
        end


        function retSeq=dataElementRef(~,inputCtx)
            retSeq=M3I.ContextSequence;
            context=inputCtx;
            if strcmp(context.ParentRoleName,'PERSISTENCY-DATA-PROVIDED-COM-SPEC')
                context.Skip=1;
            end
            retSeq.addContext(context);
        end

        function retSeq=perDataProvidedComSpec(~,inputCtx)
            retSeq=M3I.ContextSequence;
            context=inputCtx;
            if strcmp(context.ParentRoleName,'PROVIDED-COM-SPECS')
                context.Skip=1;
            end
            retSeq.addContext(context);
        end


    end
end


