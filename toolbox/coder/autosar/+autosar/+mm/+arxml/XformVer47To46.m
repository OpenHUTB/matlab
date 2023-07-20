classdef XformVer47To46<autosar.mm.arxml.XformVer48To47




    methods
        function self=XformVer47To46(versionStr,m3iModel,transformer)


            self@autosar.mm.arxml.XformVer48To47(versionStr,m3iModel,transformer);

            self.registerAttribute('STATE-DEPENDENT-STARTUP-CONFIGS',@self.processStateDependentConfigs);
            self.registerAttribute('STATE-DEPENDENT-STARTUP-CONFIG',@self.processStateDependentConfig);
            self.registerAttribute('FUNCTION-GROUP-STATE-IREFS',@self.processFunctionGroupStateIrefs);
            self.registerAttribute('FUNCTION-GROUP-STATE-IREF',@self.processFunctionGroupStateIref);
            self.registerAttribute('FUNCTION-GROUPS',@self.processFunctionGroups);

        end

        function delete(self)
            self.Transformer=[];
        end

        function retSeq=processStateDependentConfigs(~,inputCtx)
            retSeq=M3I.ContextSequence;
            context=inputCtx;
            context.RoleName='MODE-DEPENDENT-STARTUP-CONFIGS';
            retSeq.addContext(context);
        end

        function retSeq=processStateDependentConfig(~,inputCtx)
            retSeq=M3I.ContextSequence;
            context=inputCtx;
            context.RoleName='MODE-DEPENDENT-STARTUP-CONFIG';
            retSeq.addContext(context);
        end

        function retSeq=processFunctionGroupStateIrefs(~,inputCtx)
            retSeq=M3I.ContextSequence;
            context=inputCtx;
            context.RoleName='MACHINE-MODE-IREFS';
            retSeq.addContext(context);
        end

        function retSeq=processFunctionGroupStateIref(~,inputCtx)
            retSeq=M3I.ContextSequence;
            context=inputCtx;
            context.RoleName='MACHINE-MODE-IREF';
            retSeq.addContext(context);
        end

        function retSeq=processFunctionGroups(~,inputCtx)
            retSeq=M3I.ContextSequence;
            context=inputCtx;
            context.RoleName='MACHINE-MODE-MACHINES';
            retSeq.addContext(context);
        end

    end
end


