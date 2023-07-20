classdef DemStorageCondition<autosar.bsw.ServiceImplementation



    properties(Constant)
        FunctionPrototypeMap=containers.Map(autosar.bsw.DemStorageCondition.Operations,...
        autosar.bsw.DemStorageCondition.FunctionPrototypes);

        FunctionPrototypeWithIdMap=containers.Map(autosar.bsw.DemStorageCondition.Operations,...
        autosar.bsw.DemStorageCondition.FunctionPrototypesWithEventId);

        InputArgSpecMap=containers.Map(autosar.bsw.DemStorageCondition.Operations,...
        autosar.bsw.DemStorageCondition.InputArgSpecs);

        OutputArgSpecMap=containers.Map(autosar.bsw.DemStorageCondition.Operations,...
        autosar.bsw.DemStorageCondition.OutputArgSpecs);

        OperationsDescriptionMap=containers.Map(autosar.bsw.DemStorageCondition.Operations,...
        autosar.bsw.DemStorageCondition.OperationDescriptions);
    end

    properties(Constant,Access=private)
        DefaultClientPortName='StorageCondition';
        DefaultInterfacePath='/AUTOSAR/Services/Dem';
        InterfaceName='StorageCondition';
        Operations={
'SetStorageCondition'
        };

        OperationDescriptions={'autosarstandard:bsw:SetStorageConditionDesc'};

        FunctionPrototypes={
'ERR = %s_SetStorageCondition(ConditionFulfilled)'
        };

        FunctionPrototypesWithEventId={
'ERR = %s_SetStorageCondition(StorageConditionID, ConditionFulfilled)'
        };

        InputArgSpecs={
'autosar.bsw.BasicSoftwareCaller.boolean_spec(true)'
        };

        OutputArgSpecs={
'autosar.bsw.BasicSoftwareCaller.uint8_spec(1)'
        };
    end

    methods(Access=public)

        function this=DemStorageCondition()
        end

        function updateFunctionCaller(this,blkPath,portName,operationName)

            import autosar.bsw.BasicSoftwareCaller

            functionPrototypeTemplate=this.FunctionPrototypeMap(operationName);
            functionPrototype=sprintf(functionPrototypeTemplate,portName);

            inputArgSpec=this.InputArgSpecMap(operationName);
            outputArgSpec=this.OutputArgSpecMap(operationName);

            BasicSoftwareCaller.set_param(blkPath,'FunctionPrototype',functionPrototype);
            BasicSoftwareCaller.set_param(blkPath,'InputArgumentSpecifications',inputArgSpec);
            BasicSoftwareCaller.set_param(blkPath,'OutputArgumentSpecifications',outputArgSpec);

        end

    end

    methods(Static,Access=public)

        function deepCopyInterface(mdlName,dstInterfacePath)%#ok<INUSD>


            arxmlPath=fullfile(autosarroot,'+autosar','+bsw','+arxml');
            arxmlFiles={fullfile(arxmlPath,'AUTOSAR_BaseTypes.arxml')
            fullfile(arxmlPath,'AUTOSAR_MOD_PlatformTypes.arxml')
            fullfile(arxmlPath,'AUTOSAR_Dem.arxml')};

            autosar.bsw.ServiceImplementation.updateAUTOSARProperties(mdlName,arxmlFiles);
        end

        function defaultClientPortName=getDefaultClientPortName()
            defaultClientPortName=autosar.bsw.DemStorageCondition.DefaultClientPortName;
        end

        function interfaceName=getInterfaceName()
            interfaceName=autosar.bsw.DemStorageCondition.InterfaceName;
        end

        function operations=getOperations()
            operations=autosar.bsw.DemStorageCondition.Operations;
        end



        function hastypeParameter=hasDatatypeParameter()
            hastypeParameter=false;
        end

        function dataTypeCallback(~)
        end

        function desc=getDescription()
            desc=autosar.bsw.DemDiagnosticInfo.getDescription();
        end

        function type=getType()
            type='DiagnosticStorageConditionCaller';
        end

        function libBlkPath=getLibraryBlk()
            libBlkPath=['autosarlibdem/',autosar.bsw.DemStorageCondition.getType()];
        end

        function blockIconType=getBlockIconType()
            blockIconType='DemCaller';
        end

        function help=getHelp()
            help='helpview(fullfile(docroot,''autosar'',''helptargets.map''),''autosar_dem_diagnosticmonitor_block'');';
        end

        function keywords=getKeywords()
            keywords=[{'AUTOSAR';'Dem';'Diagnostic';'Storage'};...
            autosar.bsw.DemStorageCondition.getType();...
            autosar.bsw.DemStorageCondition.getOperations()];
        end

        function exportToPrevious(targetVersion,blkPath)%#ok<INUSD>

        end
    end

end



