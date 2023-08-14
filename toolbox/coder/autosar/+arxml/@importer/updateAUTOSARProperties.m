function updateAUTOSARProperties(this,modelName,varargin)














































    [modelName,varargin]=loc_convertInputArgStringsToChar(modelName,varargin);


    argParser=inputParser;


    argParser.addRequired('ModelName',@(x)(ischar(x)||isStringScalar(x)));
    argParser.addParameter('ReadOnly',true,@(x)(autosar.api.internal.FunctionArgumentValidator.validateLogicalScalar(x)));
    argParser.addParameter('Category',{},@(x)(iscell(x)));
    argParser.addParameter('RootPath',{},@(x)(iscell(x)));
    argParser.addParameter('Package',{},@(x)(iscell(x)));


    argParser.addParameter('DataTypeMappingSet',{},@(x)(iscell(x)));
    argParser.addParameter('LaunchReport','on',@(x)(any(validatestring(x,{'on','off'}))));
    argParser.addParameter('BackupModel',true,@(x)(autosar.api.internal.FunctionArgumentValidator.validateLogicalScalar(x)));
    argParser.addParameter('DisplayMessages',true,@(x)(autosar.api.internal.FunctionArgumentValidator.validateLogicalScalar(x)));
    argParser.addParameter('CreateReport',true,@(x)(autosar.api.internal.FunctionArgumentValidator.validateLogicalScalar(x)));

    argParser.parse(modelName,varargin{:});
    try

        cleanupObj=autosar.mm.util.MessageReporter.suppressWarningTrace();%#ok<NASGU>


        [~,modelName]=fileparts(modelName);


        systems=find_system('type','block_diagram','name',modelName);
        if isempty(systems)
            DAStudio.error('RTW:autosar:mdlNotLoaded',modelName);
        end


        isCompliant=strcmp(get_param(modelName,'AutosarCompliant'),'on');
        if~isCompliant
            DAStudio.error('RTW:autosar:nonAutosarCompliant');
        end

        [isModelUsingSharedDict,dictFiles]=autosar.api.Utils.isUsingSharedAutosarDictionary(modelName);
        if Simulink.internal.isArchitectureModel(modelName,'AUTOSARArchitecture')&&...
            ~isModelUsingSharedDict

            archModel=autosar.arch.loadModel(modelName);
            components=archModel.find('Component','AllLevels',true);
            linkedComponents=components(arrayfun(@(x)~isempty(x.ReferenceName),components));
            if~isempty(argParser.Results.Category)
                arrayfun(@(x)loc_loadModelAndUpdateArProps(this,x.ReferenceName,varargin),linkedComponents);
            else
                arrayfun(@(x)loc_loadModelAndUpdateArProps(this,x.ReferenceName,[{'Category',autosar.updater.ElementCopier.SupportedCategories},varargin]),linkedComponents);
            end
            return;
        end


        autosar.ui.utils.closeDictionaryUI(modelName);

        if argParser.Results.DisplayMessages
            autosar.mm.util.MessageReporter.print(...
            message('RTW:autosar:updatingModel',modelName).getString());
        end


        p_update_read(this);
        newM3IModel=this.arModel;
        this.needReadUpdate=true;



        loc_checkInterfaceDict(this,modelName);


        modelNameForBackup=modelName;
        if argParser.Results.BackupModel
            modelNameForBackup=autosar.utils.SimulinkModelCloner.backupModel(modelName,...
            argParser.Results.DisplayMessages);
        end


        if~autosar.api.Utils.isMapped(modelName)
            autosar.api.create(modelName,'init');
        end


        if isModelUsingSharedDict




            oldM3IModel=autosarcore.ModelUtils.getSharedElementsM3IModel(modelName);


            if argParser.Results.BackupModel
                assert(numel(dictFiles)==1,'Expected model to be linked to a single shared AUTOSAR dictionary.');
                dictFile=dictFiles{1};
                autosar.utils.DataDictionaryCloner.backupDictionary(dictFile);
            end
        else
            oldM3IModel=autosar.api.Utils.m3iModel(modelName);
        end
        oldM3ITransaction=M3I.Transaction(oldM3IModel);
        newM3ITransaction=M3I.Transaction(newM3IModel);


        changeLogger=autosar.updater.ChangeLogger();
        elementCopier=autosar.updater.ElementCopier(...
        newM3IModel,oldM3IModel,changeLogger,argParser.Results.ReadOnly,...
        argParser.Results.Category,argParser.Results.Package,...
        argParser.Results.RootPath);
        elementCopier.copy();


        autosar.ui.utils.registerListenerCB(oldM3IModel);
        newM3ITransaction.cancel();
        oldM3ITransaction.commit();



        if autosar.api.Utils.isMappedToAdaptiveApplication(modelName)
            p_createDataTypeObjects(this,modelName,changeLogger);
        end


        if argParser.Results.CreateReport
            report=autosar.updater.Report();
            [~,reportName]=fileparts(modelNameForBackup);
            m3iMappedComp=autosar.api.Utils.m3iMappedComponent(modelName);
            componentQualifiedName=autosar.api.Utils.getQualifiedName(m3iMappedComp);
            report.build(changeLogger,changeLogger,modelName,componentQualifiedName,reportName);
            report.dispHelpLine(modelName);
            if strcmp(argParser.Results.LaunchReport,'on')
                autosar.updater.Report.launchReport(modelName);
            end
        end
    catch Me
        autosar.mm.util.MessageReporter.throwException(Me);
    end
end

function loc_loadModelAndUpdateArProps(this,modelName,args)
    load_system(modelName);
    this.updateAUTOSARProperties(modelName,args{:})
end

function loc_checkInterfaceDict(this,modelName)


    interfaceDicts=SLDictAPI.getTransitiveInterfaceDictsForModel(modelName);
    if~isempty(interfaceDicts)
        dictsNoPath=autosar.utils.File.dropPath(interfaceDicts);
        m3iPkgElms=autosar.mm.Model.findObjectByMetaClass(this.arModel,...
        Simulink.metamodel.foundation.PackageableElement.MetaClass,true,true);
        for elmIdx=1:m3iPkgElms.size()
            m3iPkgElm=m3iPkgElms.at(elmIdx);
            if isa(m3iPkgElm,'Simulink.metamodel.arplatform.interface.SenderReceiverInterface')||...
                isa(m3iPkgElm,'Simulink.metamodel.arplatform.interface.ModeSwitchInterface')||...
                isa(m3iPkgElm,'Simulink.metamodel.arplatform.interface.NvDataInterface')
                DAStudio.error('autosarstandard:importer:UpdateARPropsUnsupportedClassForInterfaceDict',...
                autosar.api.Utils.getQualifiedName(m3iPkgElm),autosar.api.Utils.cell2str(dictsNoPath));
            end
        end
    end
end

function[modelName,optionalArgs]=loc_convertInputArgStringsToChar(modelName,optionalArgs)


    modelName=convertStringsToChars(modelName);

    optionalArgs=convertOptionalArgsStringsToChars(optionalArgs);
end

function args=convertOptionalArgsStringsToChars(args)

    for ii=1:length(args)
        if isstring(args{ii})
            args{ii}=convertStringsToChars(args{ii});
        elseif iscell(args{ii})

            args{ii}=convertOptionalArgsStringsToChars(args{ii});
        end
    end
end



