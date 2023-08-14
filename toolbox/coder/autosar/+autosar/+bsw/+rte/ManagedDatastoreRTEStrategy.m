classdef ManagedDatastoreRTEStrategy<autosar.bsw.rte.RTEStrategy






    properties(Constant)
        NvramDsmControllerPath='autosarspkglib_internal_utils/NVRAM DSM Controller';
    end

    properties(Access=private)
ServiceFcnPrototype
PhysicalIdType
OperationName
    end

    methods
        function this=ManagedDatastoreRTEStrategy(serviceFunctionName,serviceFcnPrototype,physicalIdType,operationName)
            this@autosar.bsw.rte.RTEStrategy(serviceFunctionName);
            this.ServiceFcnPrototype=serviceFcnPrototype;
            this.PhysicalIdType=physicalIdType;
            this.OperationName=operationName;
        end

        function createRTE(this,simulinkFcnBlk,inArgHandles,outArgHandles,portDefArgumentStr,compTypeData)%#ok<INUSL>
            import autosar.bsw.rte.ManagedDatastoreRTEStrategy.*

            portDefArgument=str2double(portDefArgumentStr);


            fcnCallerName=[this.ServiceFunctionName,'(caller)'];
            fcnCallerBlk=[simulinkFcnBlk,'/',fcnCallerName];
            if isempty(find_system(simulinkFcnBlk,'SearchDepth',1,...
                'BlockType','FunctionCaller','Name',fcnCallerName))
                add_block('built-in/FunctionCaller',fcnCallerBlk,...
                'FunctionPrototype',this.getServiceFunctionProtoype(),...
                'Position',[335,200,595,240]);
            end
            autosar.mm.mm2sl.layout.BlockBeautifier.beautifyBlock(fcnCallerBlk);


            idConstantName='Id';
            idConstantBlock=[simulinkFcnBlk,'/',idConstantName];
            if isempty(find_system(simulinkFcnBlk,'SearchDepth',1,...
                'BlockType','Constant','Name',idConstantName))
                add_block('built-in/Constant',idConstantBlock);
            end
            set_param(idConstantBlock,'Value',portDefArgumentStr,...
            'OutDatatypeStr',this.PhysicalIdType,...
            'Position',[265,205,295,235]);
            autosar.mm.mm2sl.layout.BlockBeautifier.beautifyBlock(idConstantBlock);

            lh=get_param(idConstantBlock,'LineHandles');
            if(lh.Outport==-1)||...
                ~strcmp(getfullname(get_param(lh.Outport,'DstBlockHandle')),fcnCallerBlk)
                add_line(simulinkFcnBlk,[idConstantName,'/1'],...
                [fcnCallerName,'/1'],...
                'autorouting','on');
            end
            autosar.mm.mm2sl.MRLayoutManager.homeBlk(idConstantBlock);


            parentSystem=get_param(simulinkFcnBlk,'Parent');
            dataStoreNameStr=['Managed Memory ',portDefArgumentStr];
            dataStoreBlock=[parentSystem,'/',dataStoreNameStr];
            if isempty(find_system(parentSystem,'SearchDepth',1,...
                'LookUnderMasks','all','FollowLinks','on',...
                'BlockType','DataStoreMemory','Name',dataStoreNameStr))
                add_block('built-in/DataStoreMemory',dataStoreBlock);
                set_param(dataStoreBlock,'OutDataTypeStr','uint8');
                set_param(dataStoreBlock,'Dimensions','1');
            end
            set_param(dataStoreBlock,'DataStoreName',['NVM_Block',portDefArgumentStr]);


            typeStr=get_param(dataStoreBlock,'OutDataTypeStr');
            dimensionStr=get_param(dataStoreBlock,'Dimensions');


            dsmControllerName='DSM Controller';
            dsmControllerBlk=[simulinkFcnBlk,'/',dsmControllerName];
            if isempty(find_system(simulinkFcnBlk,'SearchDepth',1,...
                'BlockType','SubSystem','Name',dsmControllerName))
                add_block(this.NvramDsmControllerPath,dsmControllerBlk);
                set_param(dsmControllerBlk,'LinkStatus','breakWithoutHierarchy');
            end
            set_param(dsmControllerBlk,'BlockId',portDefArgumentStr);


            connectWithLine(simulinkFcnBlk,[fcnCallerName,'/1'],'ERR/1');


            controlStubConstantName='ControlStub';
            controlStubConstantBlock=[simulinkFcnBlk,'/',controlStubConstantName];
            if isempty(find_system(simulinkFcnBlk,'SearchDepth',1,...
                'BlockType','Constant','Name',controlStubConstantName))
                add_block('built-in/Constant',controlStubConstantBlock,...
                'Value','0','OutDataTypeStr','boolean');
            end

            valueStubConstantName='ValueStub';
            valueStubConstantBlock=[simulinkFcnBlk,'/',valueStubConstantName];
            if isempty(find_system(simulinkFcnBlk,'SearchDepth',1,...
                'BlockType','Constant','Name',valueStubConstantName))
                add_block('built-in/Constant',valueStubConstantBlock,...
                'Value','0');
            end


            term1Name='Terminator1';
            term1Block=[simulinkFcnBlk,'/',term1Name];
            if isempty(find_system(simulinkFcnBlk,'SearchDepth',1,...
                'BlockType','Terminator','Name',term1Name))
                add_block('built-in/Terminator',term1Block);
            end

            term2Name='Terminator2';
            term2Block=[simulinkFcnBlk,'/',term2Name];
            if isempty(find_system(simulinkFcnBlk,'SearchDepth',1,...
                'BlockType','Terminator','Name',term2Name))
                add_block('built-in/Terminator',term2Block);
            end


            switch this.OperationName
            case 'ReadBlock'

                connectWithLine(simulinkFcnBlk,[dsmControllerName,'/1'],'DstPtr/1');

                this.stubControllerInport(simulinkFcnBlk,dsmControllerName,'ControlStub',1);
                this.stubControllerInport(simulinkFcnBlk,dsmControllerName,'ControlStub',2);
                this.stubControllerInport(simulinkFcnBlk,dsmControllerName,'ValueStub',3);
                this.connectTerminator(simulinkFcnBlk,'ControlStub',term1Name);
                this.connectTerminator(simulinkFcnBlk,'ValueStub',term2Name);

                typeStr=compTypeData.outputNameToTypeStringMap('DstPtr');
                dimensionStr=compTypeData.outputNameToDimensionStringMap('DstPtr');
                set_param([simulinkFcnBlk,'/DstPtr'],'OutDataTypeStr',typeStr);
                set_param([simulinkFcnBlk,'/DstPtr'],'PortDimensions',dimensionStr);
                set_param([simulinkFcnBlk,'/ValueStub'],'OutDataTypeStr',typeStr);
                set_param([simulinkFcnBlk,'/ValueStub'],'Value',getDefaultTypeStr(typeStr));

                set_param(dataStoreBlock,'OutDataTypeStr',typeStr);
                set_param(dataStoreBlock,'Dimensions',dimensionStr);
            case 'WriteBlock'

                connectWithLine(simulinkFcnBlk,'SrcPtr/1',[dsmControllerName,'/3']);

                connectWithLine(simulinkFcnBlk,[fcnCallerName,'/2'],[dsmControllerName,'/1']);

                this.stubControllerInport(simulinkFcnBlk,dsmControllerName,'ControlStub',2);
                this.connectTerminator(simulinkFcnBlk,dsmControllerName,term1Name);
                this.connectTerminator(simulinkFcnBlk,'ValueStub',term2Name);

                typeStr=compTypeData.inputNameToTypeStringMap('SrcPtr');
                dimensionStr=compTypeData.inputNameToDimensionStringMap('SrcPtr');
                set_param([simulinkFcnBlk,'/SrcPtr'],'OutDataTypeStr',typeStr);
                set_param([simulinkFcnBlk,'/SrcPtr'],'PortDimensions',dimensionStr);

                set_param(dataStoreBlock,'OutDataTypeStr',typeStr);
                set_param(dataStoreBlock,'Dimensions',dimensionStr);
            case 'EraseNvBlock'

                connectWithLine(simulinkFcnBlk,...
                [fcnCallerName,'/2'],...
                [dsmControllerName,'/2']);

                this.stubControllerInport(simulinkFcnBlk,dsmControllerName,'ControlStub',1);
                this.stubControllerInport(simulinkFcnBlk,dsmControllerName,'ValueStub',3);
                set_param([simulinkFcnBlk,'/ValueStub'],'OutDataTypeStr',typeStr);
                set_param([simulinkFcnBlk,'/ValueStub'],'Value',getDefaultTypeStr(typeStr));
                this.connectTerminator(simulinkFcnBlk,dsmControllerName,term1Name);
                this.connectTerminator(simulinkFcnBlk,'ControlStub',term2Name);
            case 'RestoreBlockDefaults'

                connectWithLine(simulinkFcnBlk,...
                [dsmControllerName,'/1'],...
                'DestPtr/1');

                typeStr=compTypeData.outputNameToTypeStringMap('DestPtr');
                dimensionStr=compTypeData.outputNameToDimensionStringMap('DestPtr');
                set_param([simulinkFcnBlk,'/DestPtr'],'OutDataTypeStr',typeStr);
                set_param([simulinkFcnBlk,'/DestPtr'],'PortDimensions',dimensionStr);

                this.stubControllerInport(simulinkFcnBlk,dsmControllerName,'ControlStub',1);
                this.stubControllerInport(simulinkFcnBlk,dsmControllerName,'ControlStub',2);
                this.stubControllerInport(simulinkFcnBlk,dsmControllerName,'ValueStub',3);
                set_param([simulinkFcnBlk,'/ValueStub'],'OutDataTypeStr',typeStr);
                set_param([simulinkFcnBlk,'/ValueStub'],'Value',getDefaultTypeStr(typeStr));
                this.connectTerminator(simulinkFcnBlk,'ControlStub',term1Name);
                this.connectTerminator(simulinkFcnBlk,'ValueStub',term2Name);
            otherwise
                assert(false,'Unsupported operation for this RTE strategy');
            end


            set_param(dsmControllerBlk,'blockMaskType',typeStr);
            set_param(dsmControllerBlk,'blockMaskDimensions',dimensionStr);


            if slfeature('NVRAMInitialValue')
                rteConnector=get_param(simulinkFcnBlk,'Parent');
                initValues=eval(get_param(rteConnector,'NvMInitValues'));
                if(portDefArgument>0)&&(numel(initValues)>=portDefArgument)
                    initVal=initValues{portDefArgument};
                else
                    initVal=getDefaultTypeStr(typeStr);
                end
                isEnumType=startsWith(typeStr,'enum:','IgnoreCase',true);
                if isEnumType
                    enumType=strtrim(strrep(typeStr,'Enum:',''));
                    if~isa(eval(initVal),enumType)
                        serviceComp=get_param(rteConnector,'Parent');
                        DAStudio.error('autosarstandard:bsw:NvMInitValueNotEnum',portDefArgumentStr,enumType,serviceComp);
                    end
                end
                set_param(dataStoreBlock,'InitialValue',initVal);
            else
                set_param(dataStoreBlock,'InitialValue',getDefaultTypeStr(typeStr));
            end


            Simulink.BlockDiagram.arrangeSystem(simulinkFcnBlk,...
            'Animation','false');
        end
    end

    methods(Access=private)
        function fcnPrototype=getServiceFunctionProtoype(this)


            switch this.OperationName
            case 'ReadBlock'
                fcnPrototype='ERR = NvM_ReadBlock_ArBlkst(BlockId)';
            case 'WriteBlock'
                fcnPrototype='[ERR,doWrite] = NvM_WriteBlock_ArBlkst(BlockId)';
            case 'EraseNvBlock'
                fcnPrototype='[ERR,doReset] = NvM_EraseNvBlock_ArBlkst(BlockId)';
            case 'RestoreBlockDefaults'
                fcnPrototype='ERR = NvM_RestoreBlockDefaults_ArBlkst(BlockId)';
            otherwise
                assert(false,'Unsupported operation for this RTE strategy');
            end
        end
    end

    methods(Static)

        function defaultTypeStr=getDefaultTypeStr(typeStr)
            if startsWith(strtrim(typeStr),'Enum:')
                enumType=strtrim(strrep(typeStr,'Enum:',''));
                defaultEnum=eval(sprintf('%s.getDefaultValue',enumType));
                defaultTypeStr=sprintf('%s.%s',enumType,char(defaultEnum));
            else

                defaultTypeStr='0';
            end
        end
    end

    methods(Static,Access=private)
        function stubControllerInport(simulinkFcnBlk,dsmControllerName,stubBlkName,portIdx)
            autosar.bsw.rte.ManagedDatastoreRTEStrategy.connectWithLine(simulinkFcnBlk,...
            [stubBlkName,'/1'],...
            [dsmControllerName,'/',num2str(portIdx)]);
        end

        function connectTerminator(simulinkFcnBlk,srcBlock,termName)
            autosar.bsw.rte.ManagedDatastoreRTEStrategy.connectWithLine(simulinkFcnBlk,...
            [srcBlock,'/1'],...
            [termName,'/1']);
        end

        function connectWithLine(containingSystem,srcPort,dstPort)




            srcBlkAndPort=strsplit(srcPort,'/');
            srcBlk=srcBlkAndPort{1};
            srcIdx=str2double(srcBlkAndPort{2});

            dstBlkAndPort=strsplit(dstPort,'/');
            dstBlk=dstBlkAndPort{1};
            dstIdx=str2double(dstBlkAndPort{2});

            srcPH=get_param([containingSystem,'/',srcBlk],'PortHandles');
            dstPH=get_param([containingSystem,'/',dstBlk],'PortHandles');

            srcLine=get(srcPH.Outport(srcIdx),'Line');%#ok Get the port handle to make sure it exists
            dstLine=get(dstPH.Inport(dstIdx),'Line');

            if(dstLine==-1)
                autosar.mm.mm2sl.layout.LayoutHelper.addLine(containingSystem,srcPort,dstPort);
            end
        end
    end
end


