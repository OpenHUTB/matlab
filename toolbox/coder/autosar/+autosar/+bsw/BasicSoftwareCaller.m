classdef BasicSoftwareCaller<handle



    properties(Constant)
        RefLibName='autosarspkglib_internal';
        DemPath=[autosar.bsw.BasicSoftwareCaller.RefLibName,'/Dem Module'];
        FiMPath=[autosar.bsw.BasicSoftwareCaller.RefLibName,'/FiM Module'];
        NvMPath=[autosar.bsw.BasicSoftwareCaller.RefLibName,'/NvM Module'];
    end

    methods(Static,Access=public)

        function updateBlock(blkPath)
            try

                autosar.bsw.BasicSoftwareCaller.updateFunctionCaller(blkPath);




                if autosar.validation.CompiledModelUtils.isCompiled(bdroot(blkPath))
                    autosar.api.Utils.autosarlicensed(true);
                end
            catch ME

                autosar.mm.util.MessageReporter.throwException(ME);
            end
        end

        function operationCallback(blkPath)
            if~autosar.validation.CompiledModelUtils.isCompiled(bdroot(blkPath))

                serviceImpl=autosar.bsw.BasicSoftwareCaller.getServiceImpl(blkPath);
                serviceImpl.operationCallback(blkPath);
            end
        end

        function dataTypeCallback(blkPath)
            if~autosar.validation.CompiledModelUtils.isCompiled(bdroot(blkPath))

                serviceImpl=autosar.bsw.BasicSoftwareCaller.getServiceImpl(blkPath);
                serviceImpl.dataTypeCallback(blkPath);
            end
        end

        function serviceBlocks=find(sys)



            serviceBlocks=find_system(sys,...
            'RegExp','on',...
            'FollowLinks','on',...
            'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
            'LookUnderMasks','on',...
            'BlockType','FunctionCaller',...
            'ServiceImpl','.*');
        end

        function isbswBlock=isBSWCallerBlock(block)
            isbswBlock=~isempty(block)&&~isempty(autosar.bsw.BasicSoftwareCaller.find(block));
        end

        function syncModel(mdlName)



            serviceBlocks=autosar.bsw.BasicSoftwareCaller.find(mdlName);
            for ii=1:length(serviceBlocks)
                autosar.bsw.BasicSoftwareCaller.syncBlock(serviceBlocks{ii});
            end
        end

        function registerIcons()

            DVG.Registry.addIconPackage(fullfile(autosarroot,'blocks','BlockGraphics'));
        end

        function blkPath=createBlock(sys,serviceImplStr)


            serviceImpl=eval(serviceImplStr);

            blkName=serviceImpl.getType();
            blkPath=[sys,'/',blkName];
            blkPath=add_block('built-in/FunctionCaller',blkPath,'MakeNameUnique','on');


            mo=get_param(blkPath,'MaskObject');
            if isempty(mo)
                mo=Simulink.Mask.create(blkPath);
            end


            mo.Description=serviceImpl.getDescription();
            mo.Help=serviceImpl.getHelp();
            mo.Type=serviceImpl.getType();


            mo.Initialization='autosar.bsw.BasicSoftwareCaller.updateBlock(gcb);';



            mo.SelfModifiable='on';


            mo.removeAllParameters();
            operations=serviceImpl.getOperations();
            defaultOperation=operations{1};
            if serviceImpl.hasDatatypeParameter()||serviceImpl.hasArgumentSpecificationParameter()
                operationCallbackStr='autosar.bsw.BasicSoftwareCaller.operationCallback(gcb);';
            else
                operationCallbackStr='';
            end
            mo.addDialogControl('Type','group',...
            'Name','ParameterGroupVar',...
            'Prompt','General');
            mo.addParameter('Type','edit',...
            'Name','PortName',...
            'Prompt','autosarstandard:bsw:ClientPortNamePrompt',...
            'Value',serviceImpl.getDefaultClientPortName',...
            'Container','ParameterGroupVar',...
            'Tunable','on',...
            'Evaluate','off',...
            'Hidden','off');
            mo.getDialogControl('PortName').Tooltip='autosarstandard:bsw:ClientPortNameTooltip';
            mo.addParameter('Type','popup',...
            'TypeOptions',operations,...
            'Name','Operation',...
            'Prompt','autosarstandard:bsw:OperationPrompt',...
            'Container','ParameterGroupVar',...
            'Tunable','on',...
            'Evaluate','off',...
            'Callback',operationCallbackStr,...
            'Hidden','off');
            mo.getDialogControl('Operation').Tooltip='autosarstandard:bsw:OperationTooltip';
            mo.addDialogControl('Type','text',...
            'Name','OperationDescription',...
            'Container','ParameterGroupVar');
            if serviceImpl.hasDatatypeParameter()
                mo.addParameter('Type','edit',...
                'Name','Datatype',...
                'Value',serviceImpl.getDefaultDatatype(defaultOperation)',...
                'Tunable','on',...
                'Evaluate','off',...
                'Callback','autosar.bsw.BasicSoftwareCaller.dataTypeCallback(gcb);',...
                'Visible',serviceImpl.getDatatypeVisibility(defaultOperation),...
                'Hidden','off');
            end
            if serviceImpl.hasArgumentSpecificationParameter()
                mo.addParameter('Type','edit',...
                'Name','ArgumentSpecification',...
                'Prompt','autosarstandard:bsw:ArgSpecPrompt',...
                'Value',serviceImpl.getDefaultArgumentSpecification(defaultOperation)',...
                'Tunable','off',...
                'Evaluate','off',...
                'Visible',serviceImpl.getArgumentSpecificationVisibility(defaultOperation),...
                'Hidden','off');
            end
            mo.addParameter('Type','edit',...
            'Name','st',...
            'Prompt','autosarstandard:bsw:SampleTimePrompt',...
            'Value','-1',...
            'Tunable','on',...
            'Evaluate','on',...
            'Hidden','off');
            mo.addParameter('Type','edit',...
            'Name','ServiceImpl',...
            'Prompt','autosarstandard:bsw:ServiceImplPrompt',...
            'Value',serviceImplStr,...
            'Tunable','on',...
            'Evaluate','on',...
            'Visible','off',...
            'Hidden','off');


            dialogControls=mo.getDialogControls();
            for ii=1:length(dialogControls)
                dc=dialogControls(ii);
                if strcmp(dc.Name,'DescGroupVar')
                    dc.Prompt=serviceImpl.getType();
                    break
                end
            end


            set_param(blkPath,'SampleTime','st');

            blockIconType=serviceImpl.getBlockIconType();
            if~isempty(blockIconType)
                blockDVGIcon=['BSWBlockIcon.',blockIconType];
                mo.BlockDVGIcon=blockDVGIcon;


                width=80;
                height=50;


                set_param(bdroot(sys),'PreLoadFcn','autosar.bsw.BasicSoftwareCaller.registerIcons();');
            else
                width=325;
                height=80;
            end


            pos=get_param(blkPath,'Position');
            pos(3)=pos(1)+width;
            pos(4)=pos(2)+height;
            set_param(blkPath,'Position',pos);


            set_param(blkPath,'BlockKeywords',serviceImpl.getKeywords());



            Simulink.Block.eval(get_param(blkPath,'Handle'));
        end

        function val=boolean_spec(val)

            val=boolean(val);
        end

        function val=uint8_spec(val)

            val=uint8(val);
        end

        function val=uint16_spec(val)

            val=uint16(val);
        end

        function val=uint32_spec(val)

            val=uint32(val);
        end

        function set_param(blk,paramName,newValue)





            currentValue=get_param(blk,paramName);
            if~strcmp(currentValue,newValue)
                set_param(blk,paramName,newValue);
            end
        end

    end

    methods(Hidden,Static,Access=public)
        function toggleBswRefHiding()

            refLib=autosar.bsw.BasicSoftwareCaller.RefLibName;
            open_system(refLib);


            if strcmp(get_param(refLib,'Lock'),'on')
                set_param(refLib,'Lock','off');
            end


            if strcmp(get_param(autosar.bsw.BasicSoftwareCaller.DemPath,'MaskHideContents'),'on')
                toggle='off';
            else
                toggle='on';
            end

            set_param(autosar.bsw.BasicSoftwareCaller.DemPath,'MaskHideContents',toggle);
            set_param(autosar.bsw.BasicSoftwareCaller.FiMPath,'MaskHideContents',toggle);
            set_param(autosar.bsw.BasicSoftwareCaller.NvMPath,'MaskHideContents',toggle);
            set_param(refLib,'Lock',toggle);
        end
    end

    methods(Static,Access=private)
        function serviceImpl=getServiceImpl(blkPath)
            serviceImpl=eval(get_param(blkPath,'ServiceImpl'));
        end

        function syncBlock(blkPath)

            autosar.bsw.BasicSoftwareCaller.updateAUTOSARProperties(blkPath);
            autosar.bsw.BasicSoftwareCaller.updateSimulinkMapping(blkPath);
        end


        function updateFunctionCaller(blkPath)

            portName=get_param(blkPath,'PortName');
            operationName=get_param(blkPath,'Operation');



            autosar.api.Utils.checkQualifiedName(bdroot(blkPath),...
            portName,'shortname');


            serviceImpl=autosar.bsw.BasicSoftwareCaller.getServiceImpl(blkPath);





            serviceImpl.operationCallback(blkPath);
            serviceImpl.dataTypeCallback(blkPath);


            serviceImpl.updateFunctionCaller(blkPath,portName,operationName);
        end

        function updateAUTOSARProperties(blkPath)



            autosar.bsw.BasicSoftwareCaller.deepCopyInterface(blkPath);


            autosar.bsw.BasicSoftwareCaller.updatePortName(blkPath);
        end


        function updateSimulinkMapping(blkPath)


            mdlName=bdroot(blkPath);
            assert(autosar.api.Utils.isMapped(mdlName),'Expected model to be mapped to AUTOSAR');

            portName=get_param(blkPath,'PortName');
            operationName=get_param(blkPath,'Operation');


            fcnCaller=[portName,'_',operationName];
            slMapping=autosar.api.getSimulinkMapping(mdlName);
            slMapping.mapFunctionCaller(fcnCaller,portName,operationName);
        end


        function deepCopyInterface(blkPath)


            serviceImpl=autosar.bsw.BasicSoftwareCaller.getServiceImpl(blkPath);

            mdlName=bdroot(blkPath);
            dataObj=autosar.api.getAUTOSARProperties(mdlName,true);
            interfaceName=serviceImpl.getInterfaceName();
            interfaces=dataObj.find([],'ClientServerInterface','Name',interfaceName,'PathType','FullyQualified');
            if isempty(interfaces)
                serviceImpl.deepCopyInterface(mdlName,[])
            end

        end

        function updatePortName(blkPath)


            serviceImpl=autosar.bsw.BasicSoftwareCaller.getServiceImpl(blkPath);


            portName=get_param(blkPath,'PortName');

            mdlName=bdroot(blkPath);
            dataObj=autosar.api.getAUTOSARProperties(mdlName,true);
            component=dataObj.get('XmlOptions','ComponentQualifiedName');
            ports=dataObj.find(component,'Port','Name',portName);
            if isempty(ports)
                interfaceName=serviceImpl.getInterfaceName();
                interfaces=dataObj.find([],'ClientServerInterface','Name',interfaceName,'PathType','FullyQualified');
                dataObj.add(component,'ClientPorts',portName,'Interface',interfaces{1});
            end
        end
    end

end


