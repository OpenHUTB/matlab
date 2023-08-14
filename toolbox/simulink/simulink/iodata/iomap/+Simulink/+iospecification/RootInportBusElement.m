classdef RootInportBusElement<Simulink.iospecification.Inport&Simulink.iospecification.BusTreeNodeCompatibleInterface




    properties
        OUT_PORT_BLOCK_TO_COPY=[];
    end


    methods(Static)


        function bool=isa(blockPath)
            try

                bool=strcmpi(get_param(blockPath,'IsBusElementPort'),'on');
            catch
                bool=false;
            end

        end


        function leafElementNames=getBusElementPortLeavesFromHandle(blockH,varargin)

            FIRST_ORDER_CHILDREN_ONLY=false;

            if~isempty(varargin)
                FIRST_ORDER_CHILDREN_ONLY=varargin{1};
            end

            thePortTree=Simulink.iospecification.RootInportBusElement.getBusElementPortTree(blockH);
            leafElementNames=Simulink.iospecification.RootInportBusElement.getLeafNamesFromTree(thePortTree,FIRST_ORDER_CHILDREN_ONLY);
        end


        function thePortTree=getBusElementPortTree(blockH)
            aBlock=Simulink.iospecification.RootInportBusElement.getBusElementModelBlock(blockH);
            thePortTree=aBlock.port.tree;
        end


        function aBlock=getBusElementModelBlock(blockH)
            aBlock=Simulink.BlockDiagram.Internal.getInterfaceModelBlock(blockH);
        end


        function treeChildren=getLeafNamesFromTree(thePortTree,varargin)

            treeChildren=Simulink.internal.CompositePorts.TreeNode.getDotStringsFromTree(thePortTree);
            treeChildren(cellfun(@isempty,treeChildren))=[];

            FIRST_ORDER_CHILDREN_ONLY=false;

            if~isempty(varargin)
                FIRST_ORDER_CHILDREN_ONLY=varargin{1};
            end

            if FIRST_ORDER_CHILDREN_ONLY



                nonChildrenIndexes=contains(treeChildren,'.');

                treeChildren(nonChildrenIndexes)=[];
            end
        end


        function treeNode=getTreeNode(thePortTree,nodeName)
            treeNode=Simulink.internal.CompositePorts.TreeNode.findNode(thePortTree,nodeName);
        end


        function dataType=getTreeNodeDataType(treeNode)
            dataType=Simulink.internal.CompositePorts.TreeNode.getDataType(treeNode);
        end


        function signalType=getTreeNodeSignalType(treeNode)
            mfzeroComplexity=Simulink.internal.CompositePorts.TreeNode.getComplexity(treeNode);

            switch mfzeroComplexity
            case sl.mfzero.treeNode.Complexity.COMPLEX
                signalType='complex';
            case sl.mfzero.treeNode.Complexity.REAL
                signalType='real';
            case sl.mfzero.treeNode.Complexity.AUTO
                signalType='auto';
            end
        end


        function dims=getTreeNodeDimensions(treeNode)
            dims=Simulink.internal.CompositePorts.TreeNode.getDims(treeNode);
        end


        function IS_LEAF=isTreeNodeALeaf(treeNode)

            leafNames=Simulink.internal.CompositePorts.TreeNode.findLeavesOfTree(treeNode);

            IS_LEAF=all(cellfun(@isempty,leafNames));
        end

    end





    methods

        function IS_VALID_INPUTVAR_TO_COMPARE=isValidVariableType(obj,inputVariableObj)
            IS_VALID_INPUTVAR_TO_COMPARE=Simulink.iospecification.RootInportBus.isValidVariableTypeImpl(inputVariableObj);
        end


        function[ARE_DIMS_COMPATIBLE,inputVar_DIMS,plugin_DIMS]=areDimsCompatible(obj,inputVariableObj)




            inputVar_DIMS=inputVariableObj.getDimensions();
            plugin_DIMS=obj.getDimensions();






            ARE_DIMS_COMPATIBLE.dimension.status=prod(inputVar_DIMS)==1;
            ARE_DIMS_COMPATIBLE.dimension.diagnosticstext='';
            if~ARE_DIMS_COMPATIBLE.dimension.status
                portDim=plugin_DIMS;
                if isnumeric(portDim)
                    portDim=num2str(portDim);

                    if any(isspace(portDim))
                        portDim=['[',portDim,']'];
                    end
                end
                sigDim=inputVar_DIMS;
                if isnumeric(sigDim)
                    sigDim=num2str(sigDim);

                    if any(isspace(sigDim))
                        sigDim=['[',sigDim,']'];
                    end
                end
                ARE_DIMS_COMPATIBLE.dimension.diagnosticstext=DAStudio.message('sl_iospecification:inputvariables:compatibleMismatchDimension',portDim,sigDim);
            end

        end


        function[IS_DATATYPE_COMPATIBLE,errMsg,sigDT,portDT]=isDataTypeCompatible(obj,inputVariableObj)

            IS_DATATYPE_COMPATIBLE.datatype.status=false;
            IS_DATATYPE_COMPATIBLE.datatype.diagnosticstext='';
            IS_DATATYPE_COMPATIBLE.portspecific='';
            errMsg='';

            sigDT=inputVariableObj.getDataType();
            portDT=getDataType(obj);


            thePortTree=Simulink.iospecification.RootInportBusElement.getBusElementPortTree(obj.Handle);

            [IS_COMPATIBLE,errMsg]=isInputCompatibleWithTree(obj,thePortTree,inputVariableObj);
            IS_DATATYPE_COMPATIBLE.datatype.status=IS_COMPATIBLE;

            if~IS_COMPATIBLE
                IS_DATATYPE_COMPATIBLE.datatype.diagnosticstext=DAStudio.message('sl_iospecification:inputvariables:leafSignalMismatch');
            elseif IS_COMPATIBLE==2
                IS_DATATYPE_COMPATIBLE.portspecific=DAStudio.message('sl_iospecification:inputvariables:leafSignalInherit');
            end
        end


        function outDataType=getDataType(obj)
            thePortTree=Simulink.iospecification.RootInportBusElement.getBusElementPortTree(obj.Handle);
            outDataType=Simulink.iospecification.RootInportBusElement.getTreeNodeDataType(thePortTree);
        end


        function outSignalType=getSignalType(obj)

            outSignalType='real';
        end


        function outDims=getDimensions(obj)


            outDims=1;

        end


        function[BAIL_EARLY,statusUpdate]=resolveStatusForLogicalAndInHeritCases(obj,portDataType,portDimension,portComplexity,statusUpdate,BAIL_EARLY)
            if strcmp(portDataType,'logical')||strcmp(portDataType,'boolean')
                if(~isa(portDataType,'struct')&&...
                    ~isempty(strfind(lower(portDataType),'inherit')))||...
                    (numel(portDimension)==1&&portDimension==-1)



                    statusUpdate=2;
                    BAIL_EARLY=true;

                end
            end
        end
    end





    methods


        function[boolOut,err]=copyAndConnect(obj,model,isModelCompiled,blockPathToBeCreated,portNumber)

            [boolOut,err]=copyAndConnectImpl(obj,model,isModelCompiled,blockPathToBeCreated,portNumber);

            blockBlockPath=strsplit(blockPathToBeCreated,'/');
            outport_name=sprintf('%s/Out%s',blockBlockPath{1},get_param(obj.Handle,'Name'));

            lastBusElH_ToCopy=get_param(outport_name,'Handle');
            elPortH=getAllElementPortsForPort(obj);

            if boolOut&&length(elPortH)>1

                inportFactory=Simulink.iospecification.InportFactory.getInstance();


                idx_me=cellfun(@(x)x==obj.Handle,elPortH);
                elPortH(idx_me)=[];

                for kEl=1:length(elPortH)
                    aInportType=getInportType(inportFactory,elPortH{kEl});
                    aInportType.OUT_PORT_BLOCK_TO_COPY=lastBusElH_ToCopy;

                    [boolOut,err]=copyAndConnectImpl(aInportType,model,...
                    isModelCompiled,[blockBlockPath{1},'/',get_param(aInportType.Handle,'Name')],portNumber);

                    if~boolOut
                        return;
                    end
                end

            end

        end


        function create(obj,blockPathToBeCreated,portNumber)

            path=getfullname(obj.Handle);
            newBlockH=add_block(path,blockPathToBeCreated,'MakeNameUnique','on');
            set_param(newBlockH,'Element',get_param(obj.Handle,'Element'));


        end


        function setBlockParams(obj,blockPathToBeCreated,isModelCompiled)

            theBlock=Simulink.BlockDiagram.Internal.getInterfaceModelBlock(obj.Handle);
            theTree=theBlock.port.tree;

            elName=get_param(obj.Handle,'Element');
            node=Simulink.internal.CompositePorts.TreeNode.findNode(theTree,elName);
            theTempBlock=Simulink.BlockDiagram.Internal.getInterfaceModelBlock(get_param(blockPathToBeCreated,'Handle'));
            theTempTree=theTempBlock.port.tree;

            tempNode=Simulink.internal.CompositePorts.TreeNode.findNode(theTempTree,get_param(blockPathToBeCreated,'Element'));

            IS_BUSOBJ=~isempty(tempNode.busTypeRootAttrs)||~isempty(tempNode.busTypeElementAttrs);
            if isModelCompiled&&~IS_BUSOBJ

                compiledDT=Simulink.iospecification.Inport.resolveCompiledDataTypeString(obj.Handle);




                if contains(lower(Simulink.internal.CompositePorts.TreeNode.getDataType(node)),'inherit')


                    Simulink.internal.CompositePorts.TreeNode.setDataTypeCL(tempNode,compiledDT);
                end

                if contains(lower(compiledDT),'string')

                    compiledSampleTime=get_param(obj.Handle,'CompiledSampleTime');
                    Simulink.internal.CompositePorts.TreeNode.setSampleTimeCL(tempNode,mat2str(compiledSampleTime));
                end



                if~contains(elName,'.')
                    PortDimensionsStruct=get_param(obj.Handle,'CompiledPortDimensions');

                    Simulink.internal.CompositePorts.TreeNode.setDimsCL(tempNode,['[',num2str(PortDimensionsStruct.Outport(2:end)),']']);
                end
            end
        end


        function createOutport(obj,outport_name)

            if isempty(obj.OUT_PORT_BLOCK_TO_COPY)
                newBlockH=add_block('simulink/Ports & Subsystems/Out Bus Element',outport_name,'CreateNewPort','on');
                set_param(newBlockH,'Element',get_param(obj.Handle,'Element'));
            else
                newBlockH=add_block(obj.OUT_PORT_BLOCK_TO_COPY,outport_name,'MakeNameUnique','on');
                set_param(newBlockH,'Element',get_param(obj.Handle,'Element'));
            end

        end


        function decorateOutportSettings(obj,outport)


        end


        function rootNodeName=getRootBusNodeName(obj)
            rootNodeName=get_param(obj.Handle,'PortName');
        end


        function elPortH=getAllElementPortsForPort(obj)
            rootNodeName=get_param(obj.Handle,'PortName');

            hModeledSys=get_param(get_param(obj.Handle,'Parent'),'Handle');

            elPortH=get_param(find_system(hModeledSys,...
            'SearchDepth',1,'BlockType','Inport','PortName',rootNodeName),'Handle');
        end


        function newPath=getPathOfNewPortToCreate(obj,blockPathToBeCreated,portNumber)
            pathSplit=strsplit(blockPathToBeCreated,'/');
            newPath=[pathSplit{1},'/',get_param(obj.Handle,'Name')];
        end


        function errMsg=getInvalidVarTypeErrorMessage(obj,portName,varName,inputVariableObj)
            errMsg=DAStudio.message('sl_iospecification:inports:assignNonBusToBusPort',portName);
        end
    end


    methods(Access=protected)

        function[boolOut,err]=copyAndConnectImpl(obj,model,isModelCompiled,blockPathToBeCreated,portNumber)

            [boolCopy,err]=createACopy(obj,blockPathToBeCreated,isModelCompiled,portNumber);

            if~boolCopy
                boolOut=false;
                return;
            end

            splitBlockPath=strsplit(blockPathToBeCreated,'/');
            copyToModel=splitBlockPath{1};

            inport_name=[copyToModel,'/',get_param(obj.Handle,'Name')];

            outport_name=sprintf('%s/Out%s',copyToModel,get_param(obj.Handle,'Name'));

            [boolConnect,err]=createAndConnectOutport(obj,copyToModel,inport_name,outport_name);



            if~isempty(err)&&strcmp(err.identifier,'Simulink:BusElPorts:OutportContainmentErrorEditTime')

                boolConnect=true;
                err=[];
                delete_block(get_param(outport_name,'Handle'));
                delete_block(get_param(inport_name,'Handle'));

            end

            if~boolConnect
                boolOut=false;
                return;
            end

            boolOut=true;

        end

    end
end
