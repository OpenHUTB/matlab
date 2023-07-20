classdef(Hidden,AllowedSubclasses={?autosar.arch.Model})Composition<...
    autosar.arch.ComponentBase&matlab.mixin.CustomDisplay




    properties(Dependent=true,SetAccess=private)
Components
Compositions
Connectors
Adapters
    end

    methods(Hidden,Access=protected)
        function propgrp=getPropertyGroups(this)

            proplist={'Name','SimulinkHandle','Parent','Components',...
            'Compositions','Ports','Connectors'};
            if~isempty(this.find('Adapter'))
                proplist{end+1}='Adapters';
            end
            propgrp=matlab.mixin.util.PropertyGroup(proplist);
        end
    end

    methods(Hidden,Static)
        function this=create(comp)


            if strcmp(get_param(comp,'Type'),'block')
                this=autosar.arch.Composition(comp);
            else
                assert(strcmp(get_param(comp,'Type'),'block_diagram'),...
                'comp has unexpected type');
                this=autosar.arch.loadModel(comp);
            end
        end
    end

    methods(Hidden,Access=protected)
        function this=Composition(comp)
            this@autosar.arch.ComponentBase(comp);
        end
    end

    methods
        function compObj=get.Components(this)
            compObj=this.find('Component');
        end

        function compObj=get.Compositions(this)
            compObj=this.find('Composition');
        end

        function connectorObj=get.Connectors(this)
            connectorObj=this.find('Connector');
        end

        function adapterObj=get.Adapters(this)
            adapterObj=this.find('Adapter');
        end

        function compObj=addComponent(this,names,varargin)




















            try
                cleanupObj=autosar.mm.util.MessageReporter.suppressWarningTrace();%#ok<NASGU>


                this.checkValidSimulinkHandle();

                isComposition=false;
                compObj=this.doAddComp(isComposition,names,varargin{:});
            catch ME
                autosar.mm.util.MessageReporter.throwException(ME);
            end
        end

        function compObj=addComposition(this,names)
















            try
                cleanupObj=autosar.mm.util.MessageReporter.suppressWarningTrace();%#ok<NASGU>


                this.checkValidSimulinkHandle();

                isComposition=true;
                compObj=this.doAddComp(isComposition,names);
            catch ME
                autosar.mm.util.MessageReporter.throwException(ME);
            end
        end


        function blkH=addBSWService(this,bswKind)













            try
                cleanupObj=autosar.mm.util.MessageReporter.suppressWarningTrace();%#ok<NASGU>


                this.checkValidSimulinkHandle();


                p=inputParser;
                p.addRequired('bswKind',@(x)any(strcmpi(x,{'DEM','NvM'})));
                p.parse(bswKind);

                parentSysName=getfullname(this.SimulinkHandle);


                switch upper(bswKind)
                case 'DEM'
                    load_system('autosarlibdem');
                    blkH=add_block('autosarlibdem/Diagnostic Service Component',...
                    [parentSysName,'/Diagnostic Service Component'],...
                    'MakeNameUnique','on');
                case 'NVM'
                    load_system('autosarlibnvm');
                    blkH=add_block('autosarlibnvm/NVRAM Service Component',...
                    [parentSysName,'/NVRAM Service Component'],...
                    'MakeNameUnique','on');
                otherwise
                    assert(false,'Unexpected bswKind %s',bswKind);
                end


                this.setDefaultCompBlockSize(blkH);
            catch ME
                autosar.mm.util.MessageReporter.throwException(ME);
            end
        end

        function connObj=connect(this,src,dst)


















            try
                cleanupObj=autosar.mm.util.MessageReporter.suppressWarningTrace();%#ok<NASGU>


                this.checkValidSimulinkHandle();


                p=inputParser;
                p.addRequired('src',@(x)((isa(x,'autosar.arch.ComponentBase')||...
                isa(x,'autosar.arch.PortBase')||isempty(x))&&...
                ~isa(x,'autosar.arch.Model')));
                p.addRequired('dst',@(x)((isa(x,'autosar.arch.ComponentBase')||...
                isa(x,'autosar.arch.PortBase')||isempty(x))&&...
                ~isa(x,'autosar.arch.Model')));
                p.parse(src,dst);


                connObj=autosar.arch.Connector.connect(this,src,dst);
            catch ME
                autosar.mm.util.MessageReporter.throwException(ME);
            end
        end

        function layout(this)












            this.checkValidSimulinkHandle();

            warningState=warning('query','diagram_autolayout:autolayout:layoutRejectedCommandLine');
            warning('off','diagram_autolayout:autolayout:layoutRejectedCommandLine');
            cleanup=onCleanup(@()warning(warningState.state,'diagram_autolayout:autolayout:layoutRejectedCommandLine'));

            Simulink.BlockDiagram.arrangeSystem(this.SimulinkHandle,...
            'Animation','false');
        end

        function archObjs=find(this,category,varargin)














            try
                cleanupObj=autosar.mm.util.MessageReporter.suppressWarningTrace();%#ok<NASGU>


                this.checkValidSimulinkHandle();


                sysH=autosar.arch.Finder.find(this.SimulinkHandle,category,varargin{:});

                switch(category)
                case 'Port'
                    archObjs=autosar.arch.PortBase.empty();
                    for idx=1:length(sysH)
                        archObjs=[archObjs;autosar.arch.PortBase.createPort(sysH(idx))];%#ok<AGROW>
                    end
                case 'Component'
                    archObjs=autosar.arch.Component.empty();
                    if~isempty(sysH)
                        archObjs=arrayfun(@(x)autosar.arch.Component.create(x),sysH);
                    end
                case 'Composition'
                    archObjs=autosar.arch.Composition.empty();
                    if~isempty(sysH)
                        archObjs=arrayfun(@(x)autosar.arch.Composition.create(x),sysH);
                    end
                case 'Connector'
                    archObjs=autosar.arch.Connector.empty();
                    if~isempty(sysH)
                        archObjs=arrayfun(@(x)autosar.arch.Connector.create(x),sysH);
                    end
                case 'Adapter'
                    archObjs=autosar.arch.Adapter.empty();
                    if~isempty(sysH)
                        archObjs=arrayfun(@(x)autosar.arch.Adapter.create(x),sysH);
                    end
                otherwise
                    assert(false,'unsupported category %s',category);
                end
            catch ME
                autosar.mm.util.MessageReporter.throwException(ME);
            end
        end

    end

    methods(Hidden)
        function importCompositionFromARXML(this,importerObj,compositionQName,okToPushNags,varargin)





            compositionArgParser=autosar.composition.mm2sl.private.ArgumentParser(varargin{:});


            openModel=[];
            if isempty(this.Parent)&&compositionArgParser.OpenModel
                openModel=onCleanup(@()this.open());
            end


            compositionQName=convertStringsToChars(compositionQName);
            m3iTopComposition=autosar.mm.Model.findChildByName(importerObj.getM3IModel(),compositionQName);
            if isempty(m3iTopComposition)||~isa(m3iTopComposition,...
                'Simulink.metamodel.arplatform.composition.CompositionComponent')
                DAStudio.error('autosarstandard:importer:badImporterCompositionName',...
                'CompositionSwComponent',compositionQName);
            end



            if compositionArgParser.ShareAUTOSARProperties
                DAStudio.error('autosarstandard:importer:ShareAUTOSARPropertiesNotSupportedForArchModel');
            end


            autosar.mm.mm2sl.utils.checkAndCreateDD(compositionArgParser.DataDictionary);


            xmlOptsGetter=autosar.mm.util.XmlOptionsGetter(importerObj.getM3IModel());


            componentBuilder=autosar.composition.mm2sl.AtomicSwComponentBuilder.getBuilder(...
            importerObj,xmlOptsGetter,compositionArgParser);
            componentNamesMap=componentBuilder.importOrUpdateAtomicComponents(m3iTopComposition);


            compositionBuilder=autosar.composition.mm2sl.ArchCompositionBuilder(...
            this.getRootArchModelH(),importerObj.getSchemaVer(),okToPushNags,componentNamesMap,compositionArgParser);
            compositionBuilder.importComposition(m3iTopComposition,this.SimulinkHandle,...
            xmlOptsGetter);

            delete(openModel);
        end

        function createModel(this,modelName)

















            narginchk(1,2);

            try
                cleanupObj=autosar.mm.util.MessageReporter.suppressWarningTrace();%#ok<NASGU>

                if nargin<2
                    modelName=get_param(this.SimulinkHandle,'Name');
                end

                this.createModelImpl(modelName);

            catch ME
                autosar.mm.util.MessageReporter.throwException(ME);
            end
        end

        function linkToModel(this,modelName)




            narginchk(1,2);

            try
                cleanupObj=autosar.mm.util.MessageReporter.suppressWarningTrace();%#ok<NASGU>

                isUIMode=false;
                this.linkToModelImpl(modelName,isUIMode);
            catch ME
                autosar.mm.util.MessageReporter.throwException(ME);
            end
        end
    end

    methods(Access=private)
        function compObjs=doAddComp(this,isComposition,names,varargin)



            parentSysH=this.SimulinkHandle;


            p=inputParser;
            p.addRequired('parentSysH',@(x)autosar.arch.Utils.isBlockDiagram(x)||...
            autosar.arch.Utils.isSubSystem(x));
            p.addRequired('isComposition',@(x)islogical(x));
            p.addParameter('Kind','',@(x)any(strcmp(x,...
            {'Application','ComplexDeviceDriver',...
            'EcuAbstraction','SensorActuator','ServiceProxy'})));
            p.parse(parentSysH,isComposition,varargin{:});

            if~iscell(names)
                names={names};
            end


            this.checkCompsForAddition(names);





            SimulinkListenerAPI.clearUndoRedoARPropsCache();

            addedBlkHs=[];
            for i=1:length(names)
                compName=names{i};
                compName=char(compName);


                defaultNewBlockPos=[50,50,50+50,50+50];
                if isComposition
                    blkH=SLM3I.Util.createNewCompositionNoEditor(parentSysH,...
                    defaultNewBlockPos,compName);
                else
                    blkH=add_block('built-in/Subsystem',[getfullname(parentSysH),'/',compName],'Position',defaultNewBlockPos);
                end
                addedBlkHs=[addedBlkHs,blkH];%#ok<AGROW>


                this.setDefaultCompBlockSize(blkH);
            end


            if isComposition
                compObjs=autosar.arch.Composition.empty();
                if~isempty(addedBlkHs)
                    compObjs=arrayfun(@(x)autosar.arch.Composition.create(x),addedBlkHs);
                end
            else
                compObjs=autosar.arch.Component.empty();
                if~isempty(addedBlkHs)
                    compObjs=arrayfun(@(x)autosar.arch.Component.create(x),addedBlkHs);
                    if~isempty(p.Results.Kind)
                        arrayfun(@(x)x.setKind(p.Results.Kind),compObjs);
                    end
                end
            end
        end



        function checkCompsForAddition(this,compNames)

            parentSysH=this.SimulinkHandle;



            if~isa(this,'autosar.arch.Composition')
                DAStudio.error('autosarstandard:api:CanOnlyAddComponentsInComposition',...
                getfullname(parentSysH));
            end

            for i=1:length(compNames)
                compName=compNames{i};


                autosar.api.Utils.checkQualifiedName(this.getRootArchModelH(),...
                compName,'shortname');


                [isConflict,~,conflictingBlock]=...
                autosar.composition.Utils.isCompTypeInArchModel(...
                this.getRootArchModelH(),compName);
                if isConflict
                    if isempty(conflictingBlock)


                        conflictingBlock=compName;
                    end
                    DAStudio.error('autosarstandard:api:ConflictingCompNameInArchModel',...
                    compName,conflictingBlock);
                end
            end
        end
    end
end





