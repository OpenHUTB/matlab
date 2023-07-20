classdef DemEnableCondition<autosar.bsw.ServiceImplementation



    properties(Constant)
        FunctionPrototypeMap=containers.Map(autosar.bsw.DemEnableCondition.Operations,...
        autosar.bsw.DemEnableCondition.FunctionPrototypes);

        FunctionPrototypeWithIdMap=containers.Map(autosar.bsw.DemEnableCondition.Operations,...
        autosar.bsw.DemEnableCondition.FunctionPrototypesWithId);

        InputArgSpecMap=containers.Map(autosar.bsw.DemEnableCondition.Operations,...
        autosar.bsw.DemEnableCondition.InputArgSpecs);

        OutputArgSpecMap=containers.Map(autosar.bsw.DemEnableCondition.Operations,...
        autosar.bsw.DemEnableCondition.OutputArgSpecs);

        OperationsDescriptionMap=containers.Map(autosar.bsw.DemEnableCondition.Operations,...
        autosar.bsw.DemEnableCondition.OperationDescriptions);
    end

    properties(Constant,Access=private)
        DefaultClientPortName='EnableCondition';
        DefaultInterfacePath='/AUTOSAR/Services/Dem';
        InterfaceName='EnableCondition';
        Operations={
'SetEnableCondition'
        };

        OperationDescriptions={'autosarstandard:bsw:SetEnableConditionDesc'};

        FunctionPrototypes={
'ERR = %s_SetEnableCondition(ConditionFulfilled)'
        };

        FunctionPrototypesWithId={
'ERR = %s_SetEnableCondition(EnableConditionID, ConditionFulfilled)'
        };

        InputArgSpecs={
'autosar.bsw.BasicSoftwareCaller.boolean_spec(true)'
        };

        OutputArgSpecs={
'autosar.bsw.BasicSoftwareCaller.uint8_spec(1)'
        };
    end

    methods(Access=public)

        function this=DemEnableCondition()
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
            defaultClientPortName=autosar.bsw.DemEnableCondition.DefaultClientPortName;
        end

        function interfaceName=getInterfaceName()
            interfaceName=autosar.bsw.DemEnableCondition.InterfaceName;
        end

        function operations=getOperations()
            operations=autosar.bsw.DemEnableCondition.Operations;
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
            type='DiagnosticEnableConditionCaller';
        end

        function libBlkPath=getLibraryBlk()
            libBlkPath=['autosarlibdem/',autosar.bsw.DemEnableCondition.getType()];
        end

        function blockIconType=getBlockIconType()
            blockIconType='DemCaller';
        end

        function help=getHelp()
            help='helpview(fullfile(docroot,''autosar'',''helptargets.map''),''autosar_dem_diagnosticmonitor_block'');';
        end

        function keywords=getKeywords()
            keywords=[{'AUTOSAR';'Dem';'Diagnostic';'Enable'};...
            autosar.bsw.DemEnableCondition.getType();...
            autosar.bsw.DemEnableCondition.getOperations()];
        end

        function exportToPrevious(targetVersion,blkPath)%#ok<INUSD>

        end
    end

end



