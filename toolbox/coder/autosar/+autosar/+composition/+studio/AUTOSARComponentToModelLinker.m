classdef AUTOSARComponentToModelLinker<systemcomposer.internal.arch.internal.ComponentToModelLinker








    properties(Access=public)
        LinkingValidator;
        LinkingFixer;
    end

    properties(Access=private)
        AutosarTxn;
    end

    methods
        function obj=AUTOSARComponentToModelLinker(blkH,mdlFile,isUIMode)
            [~,refModelName,~]=fileparts(mdlFile);
            obj@systemcomposer.internal.arch.internal.ComponentToModelLinker(blkH,refModelName);

            isAdaptiveArch=Simulink.CodeMapping.isAutosarAdaptiveSTF(obj.BDHandle);
            obj.LinkingValidator=autosar.composition.studio.ModelLinkingValidator(blkH,obj.BDHandle,mdlFile,isUIMode,isAdaptiveArch);
            obj.LinkingFixer=autosar.composition.studio.ModelLinkingFixer(blkH,obj.BDHandle,mdlFile,isUIMode,isAdaptiveArch);
        end
    end


    methods(Access=protected)
        function runValidationChecksHook(~)

        end

        function preDisableSimulinkListenerHook(obj)
            import autosar.composition.studio.SimulinkListenerUtils





            obj.AutosarTxn=SimulinkListenerUtils.disableSimulinkListener(bdroot(obj.OldBlockHandle));
        end

        function preReplaceBlockHook(~)

        end

        function postReplaceBlockHook(obj)

            import autosar.composition.studio.AUTOSARComponentToModelLinker;


            assert(~isempty(obj.NewBlockHandle)&&ishandle(obj.NewBlockHandle));

            refModelName=get_param(obj.NewBlockHandle,'ModelName');
            if(slfeature('SaveAUTOSARCompositionAsArchModel')>0)&&...
                autosar.composition.Utils.isModelInCompositionDomain(refModelName)


                return
            end


            if(slfeature('SoftwareModelingAutosar')>0)
                if strcmp(get_param(obj.NewBlockHandle,'IsModelRefExportFunction'),'off')

                    set_param(obj.NewBlockHandle,'ScheduleRates','On');
                    set_param(obj.NewBlockHandle,'ScheduleRatesWith','Ports');
                end
            else
                set_param(obj.NewBlockHandle,'ScheduleRates','On',...
                'ScheduleRatesWith','Schedule Editor');
            end



            set_param(obj.NewBlockHandle,'CodeInterface','Top model');


            inheritXmlOptsMsg=obj.LinkingValidator.checkInheritXmlOptions;


            if~isempty(inheritXmlOptsMsg)
                apiObj=autosar.api.getAUTOSARProperties(refModelName);
                apiObj.set('XmlOptions','XmlOptionsSource','Inherit');
            end


            AUTOSARComponentToModelLinker.setPortLocationForNonBEPPorts(obj.NewBlockHandle);
        end

        function enableSimulinkListenerHook(~)

        end

        function postEnableSimulinkListenerHook(obj)


            delete(obj.AutosarTxn);


            m3iRefComp=autosar.api.Utils.m3iMappedComponent(get_param(obj.NewBlockHandle,'ModelName'));
            autosar.composition.studio.AUTOSARComponentToModelLinker.syncCompBlockWithImportedM3IComp(...
            obj.NewBlockHandle,m3iRefComp,'SyncCompName',true);
        end
    end

    methods(Access=public)

        function[success,valMsgs]=validatePreLinking(obj)










            import autosar.composition.studio.ModelLinkingValidator;
            success=true;


            obj.LinkingValidator.validateModelValidForLinking;


            valMsgs=obj.LinkingValidator.validateRequirements;
            if~all(structfun(@isempty,valMsgs.failures))

                success=false;
            end
        end
    end

    methods(Static,Access=private)
        function setPortLocationForNonBEPPorts(mdlBlkH)




            inportHandles=autosar.arch.Utils.getSLInportHandles(mdlBlkH);
            nextLoc=length(inportHandles);
            for i=length(inportHandles):-1:1
                ph=inportHandles(i);
                portBlk=autosar.arch.Utils.findSLPortBlock(ph);
                portBlk=portBlk{1};
                if~autosar.arch.Utils.isBusInPortBlock(portBlk)
                    Simulink.PortPlacement.setPortLocation(ph,['Left:',num2str(nextLoc)],'World');
                    nextLoc=nextLoc-1;
                end
            end
        end
    end

    methods(Static,Access=public)

        function syncCompBlockWithImportedM3IComp(compBlkH,m3iSrcComp,varargin)
            m3iCompProto=autosar.composition.Utils.findM3ICompPrototypeForCompBlock(compBlkH);
            m3iDstComp=m3iCompProto.Type;

            m3iModel=m3iDstComp.rootModel;
            t=M3I.Transaction(m3iModel);
            if autosar.composition.studio.SimulinkListener.anyComponentPrototypesUsingCompType(...
                m3iModel,m3iDstComp,m3iCompProto)



                isComposition=false;
                modelName=bdroot(compBlkH);
                newCompName=m3iSrcComp.Name;
                m3iDstComp=autosar.composition.studio.SimulinkListener.getOrAddComponent(...
                modelName,newCompName,isComposition);
                m3iCompProto.Type=m3iDstComp;
            end
            autosar.composition.studio.MetaModelSynchronizer.syncM3IComp(...
            m3iSrcComp,m3iDstComp,varargin{:});
            t.commit;

            autosar.composition.studio.CompBlockUtils.refreshBlockIcon(compBlkH);
        end
    end
end



