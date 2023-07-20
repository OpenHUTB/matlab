classdef M3IModelSplitter<handle






    properties(Access=private)
        M3IModel;
        M3IComponents;
        M3ICompositions;
        M3ISwcTimings;
        M3IVfbTimings;
        M3ISystems;

        DictionaryFile;
        CreateDictionaryChangesReport;
        DictionaryMMChangeLogger;
        NeedToBackupDictionary;
    end

    methods
        function this=M3IModelSplitter(m3iModel,dictionaryFile,varargin)


            argParser=inputParser;
            argParser.addRequired('m3iModel',@(x)isa(x,'Simulink.metamodel.foundation.Domain'));
            argParser.addRequired('dictionaryFile',@(x)((ischar(x)||isStringScalar(x))&&endsWith(x,'.sldd')));
            argParser.addParameter('CreateDictionaryChangesReport',false,@islogical);
            argParser.parse(m3iModel,dictionaryFile,varargin{:});

            this.M3IModel=argParser.Results.m3iModel;
            this.DictionaryFile=argParser.Results.dictionaryFile;
            this.CreateDictionaryChangesReport=argParser.Results.CreateDictionaryChangesReport;
            this.M3IComponents=Simulink.metamodel.arplatform.component.SequenceOfAtomicComponent.make(m3iModel);
            this.M3ICompositions=Simulink.metamodel.arplatform.composition.SequenceOfCompositionComponent.make(m3iModel);


            ddConn=autosar.mm.mm2sl.utils.checkAndCreateDD(this.DictionaryFile);
            this.DictionaryFile=ddConn.filepath;


            dictAlreadyHasAutosar=...
            autosar.dictionary.Utils.isSharedAutosarDictionary(this.DictionaryFile);


            this.NeedToBackupDictionary=dictAlreadyHasAutosar;

            if this.CreateDictionaryChangesReport
                this.DictionaryMMChangeLogger=autosar.updater.ChangeLogger();
            end
        end
    end

    methods(Access=public)
        function m3iClonedComp=splitAllUnder(this,m3iComp)
            import autosar.composition.mm2sl.M3IModelSplitter

            assert(m3iComp.rootModel==this.M3IModel,'unexpected m3iModel owner for m3iComp');
            assert(isa(m3iComp,'Simulink.metamodel.arplatform.composition.CompositionComponent')||...
            isa(m3iComp,'Simulink.metamodel.arplatform.component.AtomicComponent'),...
            'Unexpected component type');


            if this.NeedToBackupDictionary
                autosar.utils.DataDictionaryCloner.backupDictionary(this.DictionaryFile);
            end



            M3IModelSplitter.makeM3IModelLean(m3iComp);



            dictAlreadyHasAutosar=...
            autosar.dictionary.Utils.isSharedAutosarDictionary(this.DictionaryFile);
            if dictAlreadyHasAutosar
                m3iCopiedElms=this.copyM3IModelToDictionary();
                m3iModelShared=this.getSharedM3IModel();
                m3iComp=autosar.mm.Model.findChildByName(m3iModelShared,...
                autosar.api.Utils.getQualifiedName(m3iComp));
            else
                m3iModelShared=this.M3IModel;
                m3iCopiedElms=[];
            end


            this.M3ISwcTimings=autosar.mm.Model.findObjectByMetaClass(m3iModelShared,...
            Simulink.metamodel.arplatform.timingExtension.SwcTiming.MetaClass);
            this.M3IVfbTimings=autosar.mm.Model.findObjectByMetaClass(m3iModelShared,...
            Simulink.metamodel.arplatform.timingExtension.VfbTiming.MetaClass);


            this.M3ISystems=autosar.mm.Model.findObjectByMetaClass(m3iModelShared,...
            Simulink.metamodel.arplatform.system.System.MetaClass);


            this.copyCompsToNewM3IModels(m3iComp);




            trans=M3I.Transaction(m3iModelShared);

            m3iToDestroy=autosar.mm.Model.findObjectByMetaClass(m3iModelShared,...
            Simulink.metamodel.arplatform.component.Component.MetaClass,true,true);
            m3iToDestroy.addAll(this.M3ISwcTimings);
            m3iToDestroy.addAll(this.M3IVfbTimings);
            m3iToDestroy.addAll(this.M3ISystems);
            for i=1:m3iToDestroy.size()
                m3iObj=m3iToDestroy.at(i);

                if~isa(m3iObj,'Simulink.metamodel.arplatform.component.ParameterComponent')
                    m3iObj.destroy();
                end
            end

            if~dictAlreadyHasAutosar

                autosar.dictionary.Utils.registerM3IModelWithDictionary(...
                m3iModelShared,this.DictionaryFile);
            end

            trans.commit();


            if this.CreateDictionaryChangesReport
                this.reportDictionaryChanges(m3iCopiedElms);
            end

            if isa(m3iComp,'Simulink.metamodel.arplatform.composition.CompositionComponent')

                m3iClonedComp=this.M3ICompositions.back();
            else
                assert(double(this.M3IComponents.size())==1,...
                'only one component should be cloned');
                m3iClonedComp=this.M3IComponents.back();
            end
        end

        function m3iComponents=getAtomicComponents(this)
            m3iComponents=this.M3IComponents;
        end

        function m3iCompositions=getCompositions(this)
            m3iCompositions=this.M3ICompositions;
        end

        function m3iModelShared=getSharedM3IModel(this)
            m3iModelShared=Simulink.AutosarDictionary.ModelRegistry.getOrLoadM3IModel(this.DictionaryFile);
        end
    end

    methods(Access=private)
        function m3iCopiedElms=copyM3IModelToDictionary(this)
            import autosar.composition.mm2sl.M3IModelSplitter

            srcM3IModel=this.M3IModel;
            dstM3IModel=Simulink.AutosarDictionary.ModelRegistry.getOrLoadM3IModel(this.DictionaryFile);

            trans=M3I.Transaction(dstM3IModel);

            m3iPkgElms=autosar.mm.Model.findPackageableElements(srcM3IModel);
            elementCopier=autosar.updater.ElementCopier(...
            srcM3IModel,dstM3IModel,this.DictionaryMMChangeLogger,false);
            m3iCopiedElms=elementCopier.copyElements(m3iPkgElms);

            trans.commit();
        end

        function reportDictionaryChanges(this,m3iCopiedElms)
            if isempty(m3iCopiedElms)


                m3iCopiedElms=autosar.mm.Model.findObjectByMetaClass(...
                this.getSharedM3IModel(),Simulink.metamodel.foundation.NamedElement.MetaClass,...
                true,true);
            end

            for ii=1:m3iCopiedElms.size()
                m3iCopiedElm=m3iCopiedElms.at(ii);
                if m3iCopiedElm.isvalid()&&...
                    isa(m3iCopiedElm,'Simulink.metamodel.foundation.NamedElement')&&...
                    ~isa(m3iCopiedElm,'Simulink.metamodel.arplatform.component.AtomicComponent.MetaClass')&&...
                    ~isa(m3iCopiedElm,'Simulink.metamodel.arplatform.composition.CompositionComponent.MetaClass')
                    this.DictionaryMMChangeLogger.logAddition('MetaModel',m3iCopiedElm.MetaClass().name,...
                    autosar.api.Utils.getQualifiedName(m3iCopiedElm));
                end
            end


            report=autosar.updater.Report();
            [~,dictName,dictExt]=fileparts(this.DictionaryFile);
            report.buildForPackage(this.DictionaryMMChangeLogger,[dictName,dictExt]);
            report.dispHelpLine(dictName);
            autosar.updater.Report.launchReport(dictName);
        end

        function copyCompsToNewM3IModels(this,m3iComp)
            import autosar.composition.mm2sl.M3IModelSplitter

            if isa(m3iComp,'Simulink.metamodel.arplatform.composition.CompositionComponent')

                m3iCompositions=autosar.composition.Utils.findCompositionComponents(...
                m3iComp,true);
                for i=1:length(m3iCompositions)
                    m3iCopied=M3IModelSplitter.copyCompositionToNewM3IModel(...
                    m3iCompositions(i),this.M3IVfbTimings,this.M3ISystems);
                    this.M3ICompositions.append(m3iCopied);
                end


                m3iComponents=autosar.composition.Utils.findAtomicComponents(m3iComp,...
                true,false);
                for i=1:length(m3iComponents)
                    m3iCopied=M3IModelSplitter.copyComponentToNewM3IModel(...
                    m3iComponents(i),this.M3ISwcTimings);
                    this.M3IComponents.append(m3iCopied);
                end
            else
                m3iCopied=M3IModelSplitter.copyComponentToNewM3IModel(...
                m3iComp,this.M3ISwcTimings);
                this.M3IComponents.append(m3iCopied);
            end
        end
    end


    methods(Static,Access=private)

        function compSeq=findCompsToImport(m3iComp)

            m3iModel=m3iComp.rootModel;
            compSeq=Simulink.metamodel.arplatform.component.SequenceOfComponent.make(m3iModel);

            if isa(m3iComp,'Simulink.metamodel.arplatform.composition.CompositionComponent')


                m3iCompositions=autosar.composition.Utils.findCompositionComponents(...
                m3iComp,true);
                for i=1:length(m3iCompositions)
                    compSeq.append(m3iCompositions(i));
                end


                m3iComponents=autosar.composition.Utils.findAtomicComponents(m3iComp,...
                true,false);
                for i=1:length(m3iComponents)
                    compSeq.append(m3iComponents(i));
                end
            else

                compSeq.append(m3iComp);
            end


            m3iParamComps=autosar.mm.Model.findObjectByMetaClass(m3iModel,...
            Simulink.metamodel.arplatform.component.ParameterComponent.MetaClass);
            for i=1:m3iParamComps.size()
                compSeq.append(m3iParamComps.at(i));
            end
        end

        function makeM3IModelLean(m3iComp)


            import autosar.composition.mm2sl.M3IModelSplitter



            compSeqToImport=M3IModelSplitter.findCompsToImport(m3iComp);


            m3iModel=m3iComp.rootModel;
            trans=M3I.Transaction(m3iModel);

            m3iAllComps=autosar.mm.Model.findObjectByMetaClass(m3iModel,...
            Simulink.metamodel.arplatform.component.Component.MetaClass,true,true);
            for i=1:m3iAllComps.size()
                comp=m3iAllComps.at(i);
                if~any(m3i.map(@(x)(x==comp),compSeqToImport))
                    comp.destroy();
                end
            end

            trans.commit();
        end

        function m3iCopiedComp=copyComponentToNewM3IModel(m3iComponent,m3iSwcTimings)
            import autosar.composition.mm2sl.M3IModelSplitter
            import autosar.timing.Utils



            m3iSwcTiming=Utils.findM3iTimingAmongstTimingsForM3iComp(...
            m3iSwcTimings,m3iComponent);


            newM3IModel=autosar.mm.Model.newM3IModel();
            m3iCopiedComp=M3IModelSplitter.copyCompToM3IModel(m3iComponent,newM3IModel,m3iSwcTiming);
        end

        function m3iCopiedComp=copyCompositionToNewM3IModel(m3iComposition,m3iVfbTimings,m3iSystems)
            import autosar.composition.mm2sl.M3IModelSplitter
            import autosar.timing.mm2sl.VfbViewBuilder


            m3iVfbTiming=VfbViewBuilder.findM3iVfbTimingAmongstTimingsForM3iComp(...
            m3iVfbTimings,m3iComposition);


            m3iSystem=autosar.system.Utils.findM3iSystemAmongstSystemsForM3iComp(...
            m3iSystems,m3iComposition);


            newM3IModel=autosar.mm.Model.newM3IModel();
            m3iCopiedComp=M3IModelSplitter.copyCompToM3IModel(m3iComposition,newM3IModel,m3iVfbTiming,m3iSystem);
        end

        function m3iCopiedComp=copyCompToM3IModel(m3iComp,dstM3IModel,m3iTiming,m3iSystem)
            import autosar.composition.mm2sl.M3IModelSplitter

            if nargin<4
                m3iSystem=Simulink.metamodel.arplatform.system.System.empty;
            end

            trans=M3I.Transaction(dstM3IModel);
            copierOptions=Simulink.metamodel.arplatform.ElementCopierOptions();
            copierOptions.setCopyComponentMetaClassOnly(true);



            copierOptions.setDeleteUnmatchedElements(false);
            copierOptions.setDeleteUnnamedCompositeAttributes(false);
            copier=Simulink.metamodel.arplatform.ElementCopier(m3iComp.rootModel,dstM3IModel,copierOptions);
            m3iCopiedComp=copier.deepCopy(m3iComp);
            if~isempty(m3iTiming)
                copier.deepCopy(m3iTiming);
            end
            if~isempty(m3iSystem)
                copier.deepCopy(m3iSystem);
            end
            trans.commit();


            M3IModelSplitter.addM3IModelDependency(dstM3IModel,m3iComp.rootModel);
        end

        function addM3IModelDependency(srcM3IModel,dstM3IModel)

            Simulink.AutosarDictionary.ModelRegistry.addReferencedModel(srcM3IModel,dstM3IModel);
        end
    end
end


