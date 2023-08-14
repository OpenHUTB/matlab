classdef(Sealed)Dialog<handle





    properties(SetAccess=private)
        parentHandle;
        isParentSubsys;
        portUUID;
        port;
        isInput;
        isAllowServiceAccess;
        channelPath;
        channelSub;
        url;
        dialog;
        listeners;
        launchedForBlock;
        curHighlighted;
        styler;
        suspendRefresh;
    end


    methods(Access=private)


        function this=Dialog()

            this.parentHandle=-1;
            this.isParentSubsys=false;
            this.dialog=-1;
            this.launchedForBlock=-1;
            this.listeners=struct;
            this.curHighlighted=cell(1,0);
            this.suspendRefresh=false;
        end


        function createDDGDialog(this)






            connector.ensureServiceOn();


            urlTemplate='/toolbox/simulink/cports_dialog/%s?portUUID=%s';
            if this.isDebug()
                fileName='index-debug.html';
            else
                fileName='index.html';
            end
            this.url=sprintf(urlTemplate,fileName,this.portUUID);
            this.url=connector.getBaseUrl(this.url);
            if this.isDebug()
                log(['URL: ',this.url]);
            end


            this.dialog=DAStudio.Dialog(this);
        end



        function cl=getStyleClass(this)
            if this.isInput
                cl='CompositePortsSelectedInput';
            else
                cl='CompositePortsSelectedOutput';
            end
        end


        function initStyler(this)
            stylerName='CompositePortsTracer';
            this.styler=diagram.style.getStyler(stylerName);

            if isempty(this.styler)
                diagram.style.createStyler(stylerName);
                this.styler=diagram.style.getStyler(stylerName);


                stroke=MG2.Stroke;
                stroke.Color=[0.0,0.7,1.0,1.0];
                stroke.Width=4;
                stroke.CapStyle='FlatCap';
                stroke.JoinStyle='RoundJoin';
                stroke.ScaleFunction='SelectionNonLinear';

                traceStyle=diagram.style.Style;
                traceStyle.set('Trace',MG2.TraceEffect(stroke,'Outer'),'simulink.Block');
                stroke.Width=2;
                traceStyle.set('Trace',MG2.TraceEffect(stroke,'Outer'),'simulink.Line');
                this.styler.addRule(traceStyle,diagram.style.ClassSelector('CompositePortsSelectedInput'));
                this.styler.addRule(traceStyle,diagram.style.ClassSelector('CompositePortsSelectedOutput'));



                traceSelStyle=diagram.style.Style;
                traceSelStyle.set('StrokeColor',[0.722,0.839,0.996,1.0]);
                traceSelStyle.set('StrokeWidth',2);
                this.styler.addRule(traceSelStyle,diagram.style.MultiSelector({'MathWorks.GLUE2Styler:Selected','CompositePortsSelectedInput'},{'Editor'}));
                this.styler.addRule(traceSelStyle,diagram.style.MultiSelector({'MathWorks.GLUE2Styler:Selected','CompositePortsSelectedOutput'},{'Editor'}));
            end
        end



        function pBlks=getPortBlocks(this)
            pBlks=this.port.blocks.toArray();
            synth=arrayfun(@isSynthesizedPortBlock,pBlks);
            pBlks=pBlks(~synth);
        end


        function h=getAnSLBlockOfPort(this)
            h=-1;
            pBlks=this.getPortBlocks();
            if(~isempty(pBlks))
                h=Simulink.BlockDiagram.Internal.getSlBlock(pBlks(1));
            end
        end


        function blocks=getAllSLBlocksOfPort(this)
            pBlks=this.getPortBlocks();
            blocks=zeros(1,numel(pBlks));
            for i=1:numel(pBlks)
                blocks(i)=Simulink.BlockDiagram.Internal.getSlBlock(pBlks(i));
            end
        end


        function flatLeafs=getSignalHierarchy(this)

            warnState=warning;
            cleanupObj=onCleanup(@()warning(warnState));
            warning('off');

            if(this.isParentSubsys)

                shPort=get_param(this.parentHandle,'PortHandles');
                if(this.isInput)
                    shPort=shPort.Inport(this.port.indexOne);
                else
                    shPort=shPort.Outport(this.port.indexOne);
                end
                assert(ishandle(shPort));

                sigHier=get_param(shPort,'SignalHierarchy');
                flatLeafs=flattenSigHier(sigHier,'',true);
            else
                if slfeature('CompositePortsAtRoot')==0

                    assert(~this.isInput);
                    assert(this.isParentSubsys);
                    shPort=get_param(this.parentHandle,'PortHandles');
                    shPort=shPort.Outport(this.port.indexOne);
                    assert(ishandle(shPort));
                    sigHier=get_param(shPort,'SignalHierarchy');
                    flatLeafs=flattenSigHier(sigHier,'',true);

                    return;
                end
                if this.isInput

                    flatLeafs={};
                else

                    sigHiers=Simulink.internal.CompositePorts.TreeNode.getIncomingSignalHierarchiesOfBusElementOutport(this.port);
                    blks=this.getPortBlocks();
                    for i=1:numel(sigHiers)
                        sigHiers{i}=flattenSigHier(sigHiers{i},blks(i).element,true);
                    end
                    flatLeafs=[sigHiers{:}];
                end
            end
        end

        function blocks=getPortBlocksForDialogResponse(this)
            pBlks=this.getPortBlocks();
            blocks=cell(1,0);
            for i=1:numel(pBlks)
                b.element=pBlks(i).element;
                b.handle=Simulink.BlockDiagram.Internal.getSlBlock(pBlks(i));
                blocks{i}=b;
            end
        end



        function attrs=getNodeAttributes(this)
            warnState=warning('off','MATLAB:structOnObject');
            cleanupObj=onCleanup(@()warning(warnState));


            Simulink.internal.CompositePorts.TreeNode.reconcileBusObjectsOfTree(this.getAnSLBlockOfPort());

            attrs=cell(1,0);

            function path=locGetFullPathOfNode(path,node)

                ca=node.childAttrs;
                if isvalid(ca)
                    path{end+1}=ca.name;
                end
            end

            function s=locCleanStruct(s)

                fn=fieldnames(s);
                emptyFields=fn(cellfun(@(f)isempty(s.(f)),fn));

                fieldsToRemove=[emptyFields;{'UUID';'MetaClass';'Container';'ContainerProperty'}];

                fieldsToRemove=fieldsToRemove(cellfun(@(f)isfield(s,f),fieldsToRemove));

                s=rmfield(s,fieldsToRemove);
            end

            function s=locConvertEnums(s)
                if isfield(s,'virtuality')
                    s.virtuality=this.virtualityToString(s.virtuality);
                end

                if isfield(s,'dataMode')
                    s.dataMode=this.dataModeToString(s.dataMode);
                end

                if isfield(s,'queueType')
                    s.queueType=this.queueTypeToString(s.queueType);
                end

                if isfield(s,'complexity')
                    s.complexity=this.complexityToString(s.complexity);
                end

                if isfield(s,'dimsMode')
                    s.dimsMode=this.dimsModeToString(s.dimsMode);
                end
            end

            function busDescription=locGetBusDescription(busObjectName)
                subsysH=this.parentHandle;
                parentModel=subsysH;
                while strcmp(get_param(parentModel,'Type'),'block')
                    parentModel=get_param(parentModel,'Parent');
                end

                [busObject,doesExist]=slResolve(busObjectName,parentModel);
                if doesExist
                    busDescription=busObject.Description;
                else
                    busDescription='';
                end
            end

            function locGetAttributesOfNode(path,node,mixin)
                pa=node.parentAttrs;

                sa=node.signalAttrs;
                qa=node.msgQueueAttrs;
                btra=node.busTypeRootAttrs;
                btea=node.busTypeElementAttrs;
                blkattrs=node.blockAttrs;
                children=[];



                path=locGetFullPathOfNode(path,node);


                thisAttrs=struct();
                if isvalid(sa)
                    thisAttrs.signal=locConvertEnums(locCleanStruct(struct(sa)));
                end
                if isvalid(btra)
                    thisAttrs.busTypeRoot=struct('isBusTypeRoot',true);

                    mixin.isUnderBusType=true;
                    dt=sa.dataType;
                    mixin.busDescription='';
                    if startsWith(dt,'Bus:')
                        mixin.busDescription=locGetBusDescription(extractAfter(dt,'Bus: '));
                    end
                end
                if isvalid(btea)
                    thisAttrs.busTypeElement=locConvertEnums(locCleanStruct(struct(btea)));
                    dt=btea.dataType;
                    if startsWith(dt,'Bus:')
                        thisAttrs.busTypeElement.desc=locGetBusDescription(extractAfter(dt,'Bus: '));
                    end
                end
                if isvalid(qa)
                    thisAttrs.msgQueueAttrs=locConvertEnums(locCleanStruct(struct(qa)));
                end
                if isvalid(pa)
                    children=pa.children.toArray();
                end

                mixinFields=fieldnames(mixin);
                for i=1:numel(mixinFields)
                    thisAttrs.(mixinFields{i})=mixin.(mixinFields{i});
                end
                if~isempty(children)
                    thisAttrs.hasChildren=true;
                end



                blocklessSpecFeatureOn=slfeature('BEP_BLOCKLESS_SPECIFICATION');
                if blocklessSpecFeatureOn&&isempty(btra)&&isempty(btea)&&~isempty(node.childAttrs)&&isempty(blkattrs)
                    if isempty(Simulink.internal.CompositePorts.TreeNode.findFirstNodeWithBlocksUnder(node))
                        thisAttrs.blocklessChildNode=true;
                    end
                end


                if~isempty(thisAttrs)

                    thisAttrs.element=strjoin(path,'.');
                    attrs{end+1}=thisAttrs;
                end


                if isfield(thisAttrs,'signal')&&isfield(thisAttrs.signal,'virtuality')&&strcmp(thisAttrs.signal.virtuality,'nonvirtual')
                    mixin.isUnderNonvirtualNode=true;
                end



                if isfield(thisAttrs,'signal')&&isfield(thisAttrs.signal,'dataMode')
                    if strcmp(thisAttrs.signal.dataMode,'message')

                        mixin.isUnderNonvirtualNode=true;
                        mixin.isUnderNonInheritDataMode=true;
                    elseif strcmp(thisAttrs.signal.dataMode,'signal')
                        mixin.isUnderNonInheritDataMode=true;
                    end
                end


                for i=1:numel(children)
                    locGetAttributesOfNode(path,children(i),mixin);
                end

            end

            locGetAttributesOfNode({},this.port.tree,struct());
        end

        function e=stringToVirtuality(~,s)
            switch s
            case 'inherit'
                e=sl.mfzero.treeNode.Virtuality.INHERIT;
            case 'virtual'
                e=sl.mfzero.treeNode.Virtuality.VIRTUAL;
            case 'nonvirtual'
                e=sl.mfzero.treeNode.Virtuality.NON_VIRTUAL;
            otherwise
                error(['Unknown virtuality: ',s]);
            end
        end

        function s=virtualityToString(~,e)
            switch e
            case sl.mfzero.treeNode.Virtuality.INHERIT
                s='inherit';
            case sl.mfzero.treeNode.Virtuality.VIRTUAL
                s='virtual';
            case sl.mfzero.treeNode.Virtuality.NON_VIRTUAL
                s='nonvirtual';
            otherwise
                error(['Unknown virtuality: ',e]);
            end
        end

        function e=stringToDataMode(~,s)
            switch s
            case 'inherit'
                e=sl.mfzero.treeNode.DataMode.INHERIT;
            case 'signal'
                e=sl.mfzero.treeNode.DataMode.SIGNAL;
            case 'message'
                e=sl.mfzero.treeNode.DataMode.MESSAGE;
            otherwise
                error(['Unknown data mode: ',s]);
            end
        end

        function s=dataModeToString(~,e)
            switch e
            case sl.mfzero.treeNode.DataMode.INHERIT
                s='inherit';
            case sl.mfzero.treeNode.DataMode.SIGNAL
                s='signal';
            case sl.mfzero.treeNode.DataMode.MESSAGE
                s='message';
            otherwise
                error(['Unknown data mode: ',e]);
            end
        end

        function e=stringToQueueType(~,s)
            switch s
            case 'FIFO'
                e=sl.mfzero.treeNode.QueueType.Q_TYPE_FIFO;
            case 'LIFO'
                e=sl.mfzero.treeNode.QueueType.Q_TYPE_LIFO;
            otherwise
                error(['Unknown queue type: ',s]);
            end
        end

        function s=queueTypeToString(~,e)
            switch e
            case sl.mfzero.treeNode.QueueType.Q_TYPE_FIFO
                s='FIFO';
            case sl.mfzero.treeNode.QueueType.Q_TYPE_LIFO
                s='LIFO';
            otherwise
                error(['Unknown queue type: ',e]);
            end
        end

        function e=stringToComplexity(~,s)
            switch s
            case 'auto'
                e=sl.mfzero.treeNode.Complexity.AUTO;
            case 'real'
                e=sl.mfzero.treeNode.Complexity.REAL;
            case 'complex'
                e=sl.mfzero.treeNode.Complexity.COMPLEX;
            otherwise
                error(['Unknown complexity: ',s]);
            end
        end

        function s=complexityToString(~,e)
            switch e
            case sl.mfzero.treeNode.Complexity.AUTO
                s='auto';
            case sl.mfzero.treeNode.Complexity.REAL
                s='real';
            case sl.mfzero.treeNode.Complexity.COMPLEX
                s='complex';
            otherwise
                error(['Unknown complexity: ',e]);
            end
        end

        function e=stringToDimsMode(~,s)
            switch s
            case 'Inherit'
                e=sl.mfzero.treeNode.DimsMode.INHERIT;
            case 'Fixed'
                e=sl.mfzero.treeNode.DimsMode.FIXED;
            case 'Variable'
                e=sl.mfzero.treeNode.DimsMode.VARIABLE;
            otherwise
                error(['Unknown dims mode: ',s]);
            end
        end

        function s=dimsModeToString(~,e)
            switch e
            case sl.mfzero.treeNode.DimsMode.INHERIT
                s='Inherit';
            case sl.mfzero.treeNode.DimsMode.FIXED
                s='Fixed';
            case sl.mfzero.treeNode.DimsMode.VARIABLE
                s='Variable';
            otherwise
                error(['Unknown dims mode: ',e]);
            end
        end

        function setNodeAttribute(this,element,attr,val)

            n=Simulink.internal.CompositePorts.TreeNode.findNode(this.port.tree,element);

            switch attr
            case 'complexity'
                val=this.stringToComplexity(val);
                f=@Simulink.internal.CompositePorts.TreeNode.setComplexity;
            case 'min'
                f=@Simulink.internal.CompositePorts.TreeNode.setMin;
            case 'max'
                f=@Simulink.internal.CompositePorts.TreeNode.setMax;
            case 'unit'
                f=@Simulink.internal.CompositePorts.TreeNode.setUnit;
            case 'dataType'
                if startsWith(val,'ValueType: ')


                    Simulink.internal.CompositePorts.TreeNode.setDataTypeCL(n,'Inherit: auto');
                    f=@Simulink.internal.CompositePorts.TreeNode.setValueType;
                else



                    if~isempty(n.signalAttrs)&&...
                        (strcmp(val,n.signalAttrs.dataType)||...
                        (strcmp(val,'Inherit: auto')&&strcmp(n.signalAttrs.dataType,'')))
                        assert(~isempty(n.signalAttrs.valueType));
                        f=@Simulink.internal.CompositePorts.TreeNode.setValueType;
                        val='';
                    else
                        f=@Simulink.internal.CompositePorts.TreeNode.setDataType;
                    end
                end

            case 'dims'
                f=@Simulink.internal.CompositePorts.TreeNode.setDims;
            case 'dimsMode'
                val=this.stringToDimsMode(val);
                f=@Simulink.internal.CompositePorts.TreeNode.setDimsMode;
            case 'sampleTime'
                f=@Simulink.internal.CompositePorts.TreeNode.setSampleTime;
            case 'virtuality'
                val=this.stringToVirtuality(val);
                f=@Simulink.internal.CompositePorts.TreeNode.setVirtuality;
            case 'dataMode'
                val=this.stringToDataMode(val);
                f=@Simulink.internal.CompositePorts.TreeNode.setDataMode;
            case 'useDefaultAttrs'
                f=@Simulink.internal.CompositePorts.TreeNode.setQueueUseDefaultAttrs;
            case 'queueCapacity'
                f=@Simulink.internal.CompositePorts.TreeNode.setQueueCapacity;
            case 'queueType'
                val=this.stringToQueueType(val);
                f=@Simulink.internal.CompositePorts.TreeNode.setQueueType;
            case 'queueOverwriting'
                f=@Simulink.internal.CompositePorts.TreeNode.setQueueOverwriting;
            case 'desc'
                f=@Simulink.internal.CompositePorts.TreeNode.setDesc;
            otherwise
                error(['Unknown attribute: ',attr]);
            end


            f(this.getEditor(),n,val);
        end


        function portTypeStr=getPortTypeString(this)
            if this.isInput
                portTypeStr='Inport';
            else
                portTypeStr='Outport';
            end
        end

        function tf=isDisabled(this)
            try
                obj=get_param(this.parentHandle,'Object');
                tf=obj.isHierarchyReadonly||obj.isHierarchySimulating||obj.isHierarchyBuilding||obj.areDescendentsReadonly||obj.isLinked;
            catch
                tf=false;
            end
        end


        function items=getAvailableDataTypes(this)
            dtaItems.inheritRules={};
            dtaItems.extras=[];
            dtaItems.builtinTypes=Simulink.DataTypePrmWidget.getBuiltinList('NumHalfBool');
            dtaItems.scalingModes={'UDTBinaryPointMode','UDTSlopeBiasMode','UDTBestPrecisionMode'};
            dtaItems.signModes={'UDTSignedSign','UDTUnsignedSign'};

            dtaItems.supportsEnumType=true;
            dtaItems.supportsBusType=true;
            dtaItems.supportsStringType=true;
            dtaItems.supportsValueTypeType=true;

            if slfeature('ClientServerInterfaceEditor')==1
                dtaItems.supportsServiceBusType=true;
            end

            blockObj=get_param(this.getAnSLBlockOfPort(),'Object');
            assert(isa(blockObj,'Simulink.Block'));


            slprivate('slGetUserDataTypesFromWSDD',blockObj,[],[],true);

            items=Simulink.DataTypePrmWidget.getDataTypeAllowedItems(dtaItems,blockObj);


            items(strcmp(items,DAStudio.message('Simulink:DataType:RefreshDataTypeInWorkspace')))=[];
            items(strcmp(items,'<data type expression>'))=[];
            items(strcmp(items,'Inherit: auto'))=[];
            items(strcmp(items,'Bus: <object name>'))=[];
            items(strcmp(items,'Enum: <class name>'))=[];


            items=['Inherit: auto',items];
        end

        function channelCallback(this,msg)
            ed=this.getEditor();
            res=[];
            refresh=false;
            log(['New message:',newline,evalc('disp(msg)')]);
            switch msg.type
            case 'status'
                switch msg.payload
                case 'show'

                    this.dialog.show();
                    this.dialog.setFocus('cportdlg_webbrowser');

                    this.selectBlockInTree(this.launchedForBlock);




                    Simulink.internal.CompositePorts.Dialog.onShow(this.portUUID);
                case 'refreshComplete'

                    Simulink.internal.CompositePorts.Dialog.onRenderComplete(this.portUUID);
                case 'hangup'

                    if~this.isDebug()
                        Simulink.internal.CompositePorts.Dialog.dialogCloseCallback(this);
                    end
                otherwise
                    fprintf(2,'Unexpected payload: %s\n',msg.payload);
                end
            case 'dialog'
                res.type='dialogResp';
                res.uuid=msg.uuid;
                switch msg.payload
                case 'close'


                    res=[];
                    this.closeDialogOfPort(this.port.UUID);
                case 'getPortData'
                    res.payload.portUUID=this.port.UUID;
                    res.payload.portName=this.port.name;
                    res.payload.portNumber=num2str(this.port.indexOne);
                    res.payload.isInput=this.isInput;
                    if(slfeature('CompositeFunctionElements')==1...
                        &&strcmp(get_param(getAnSLBlockOfPort(this),'AllowServiceAccess'),'on')...
                        &&strcmp(get_param(getAnSLBlockOfPort(this),'IsClientServer'),'on'))
                        res.payload.isAllowServiceAccess=true;
                    else
                        res.payload.isAllowServiceAccess=false;
                    end
                    res.payload.isParentSubsys=this.isParentSubsys;
                    res.payload.colors=SLM3I.SLDomain.getDialogColors();
                    res.payload.isDisabled=this.isDisabled();
                    pBlks=this.getPortBlocks();
                    res.payload.isFullPort=(numel(pBlks)==1)&&isempty(pBlks.element);
                    res.payload.featBusElementPortDialogLayoutFix=slfeature('BusElementPortDialogLayoutFix')==1;
                    res.payload.featCompositePortsAtRoot=slfeature('CompositePortsAtRoot')==1;
                    res.payload.featBEPDialogInterfaceType=slfeature('BEPDialogInterfaceType')==1;
                    res.payload.featCompositePortsNonvirtualBusSupport=slfeature('CompositePortsNonvirtualBusSupport')==1;
                    res.payload.featCompositePortsDataMode=slfeature('CompositePortsDataMode');
                    res.payload.featCompositePortsMsgQueueAttrs=slfeature('CompositePortsMsgQueueAttrs')==1;
                    res.payload.featBEPBlocklessSpecification=slfeature('BEP_BLOCKLESS_SPECIFICATION')==1;
                    res.payload.featBEPGenerateCLISyntax=slfeature('BEPGenerateCLISyntax')==1;

                    this.updateDialogTitle();
                case 'getPortBlocks'
                    res.payload.blocks=this.getPortBlocksForDialogResponse();
                    res.payload.isFullPort=(numel(res.payload.blocks)==1)&&isempty(res.payload.blocks{1}.element);
                case 'getPortBlocksAndSigHier'
                    res.payload.blocks=this.getPortBlocksForDialogResponse();
                    res.payload.isFullPort=(numel(res.payload.blocks)==1)&&isempty(res.payload.blocks{1}.element);
                    res.payload.sigHier=this.getSignalHierarchy();
                    if slfeature('CompositePortsAtRoot')>0
                        res.payload.nodeAttrs=this.getNodeAttributes();
                        res.payload.availableDataTypes=this.getAvailableDataTypes();
                    end
                    if slfeature('BEPDialogInterfaceType')>0

                        res.payload.availableInterfaceTypes={'Bus: ControlBus','Bus: GNCBus'};
                        res.payload.availableInterfaceTypes=['Inherit: Auto',res.payload.availableInterfaceTypes];
                        res.payload.interfaceType='Inherit: Auto';
                    end
                otherwise
                    fprintf(2,'Unexpected payload: %s\n',msg.payload);
                end
            case 'SetPortName'
                this.suspendRefresh=true;
                res=this.wrapCall(@()SLM3I.SLDomain.renamePort(ed,this.getPortTypeString(),this.port.indexOne,msg.payload));
                res.uuid=msg.uuid;
                if strcmpi(res.type,'OK')
                    refresh=true;
                end
            case 'SetPortNumber'
                this.suspendRefresh=true;
                aBlock=this.getAnSLBlockOfPort();
                res=this.wrapCall(@()set_param(aBlock,'Port',msg.payload));
                res.uuid=msg.uuid;
                if strcmpi(res.type,'OK')
                    refresh=true;
                end
            case 'SetColor'
                handles=num2cell(msg.payload.blocks');

                if isempty(handles)
                    handles=num2cell(this.getAllSLBlocksOfPort());
                end
                setColor=@(h,c)set_param(h,'BackgroundColor',c);
                setColorForAll=@(c)cellfun(setColor,handles,repmat({c},1,numel(handles)));
                ed.createMCommand('Simulink:BusElPorts:ChangePortColor',DAStudio.message('Simulink:BusElPorts:ChangePortColor'),setColorForAll,{msg.payload.color});
            case 'SetPortBlockOrder'
                this.suspendRefresh=true;
                res=this.wrapCall(@()SLM3I.SLDomain.setElementsOfPort(ed,this.getPortTypeString(),this.port.indexOne,...
                msg.payload.blocks,msg.payload.elements,...
                msg.payload.currElements,...
                msg.payload.dotStrsBefore,msg.payload.dotStrsAfter));
                res.uuid=msg.uuid;
                if strcmpi(res.type,'OK')
                    refresh=true;
                end
            case 'setSelection'
                this.handleTreeSelectionChange(msg.payload.blocks);
            case 'DeleteBlocks'
                this.deleteBlocks(msg.payload);
            case 'DeleteBlocklessChildNodes'
                assert(slfeature('BEP_BLOCKLESS_SPECIFICATION'),...
                'Feature must be turned on to be able to delete blockless child nodes');
                this.deleteBlocklessChildNodes(msg.payload);
                refresh=true;
            case 'AddBlocks'
                this.addBlocks(msg.payload);
            case 'AddChildNode'
                assert(slfeature('BEP_BLOCKLESS_SPECIFICATION'),...
                'Feature must be turned on to be able to add blockless child nodes');
                shouldAddBlockForChildNode=msg.payload.addWithBlock;
                element=msg.payload.elementsToAdd;
                if(shouldAddBlockForChildNode)
                    this.addBlocks(element);
                else
                    elementStr=element{1,1};
                    shouldDirtyModel=true;
                    n=Simulink.internal.CompositePorts.TreeNode.addNodeToTree(this.port.tree,elementStr,shouldDirtyModel);%#ok<NASGU> 
                    refresh=true;
                end
            case 'GenerateCommandLineSyntax'
                this.generateCommandLineSyntax(msg.payload);
            case 'SetNodeAttribute'


                if~strcmpi(msg.payload.attr,'dataType')&&~strcmpi(msg.payload.attr,'virtuality')&&~strcmpi(msg.payload.attr,'dataMode')
                    this.suspendRefresh=true;
                end
                res=this.wrapCall(@()this.setNodeAttribute(msg.payload.element,msg.payload.attr,msg.payload.val));
                res.uuid=msg.uuid;
            case 'eval'
                try
                    res=eval(msg.payload);
                    res.type='evalResp';
                    res.payload=res;
                catch ME
                    res.type='evalErr';
                    res.payload=ME;
                end
            case 'help'
                switch msg.payload
                case 'QueueAttrsDocPage'
                    web(fullfile(docroot,'simulink/ug/specify-queue-properties-for-message-receive-interface.html'));
                otherwise
                    fprintf(2,'Unexpected payload: %s\n',msg.payload);
                end
            otherwise
                fprintf(2,'Unexpected type: %s\n',msg.type);
            end


            if~isvalid(this)
                return;
            end


            this.suspendRefresh=false;


            if~isempty(res)
                message.publish(this.channelPath,res);
            end


            if refresh
                this.refreshDialog();
            end
        end
    end


    methods(Static)
        function instance=getInstance(h)



            if isempty(SLM3I.SLDomain.getLastActiveEditorFor(get_param(get_param(h,'Parent'),'Handle')))
                errordlg(DAStudio.message('Simulink:BusElPorts:NeedsEditor'));
                return;
            end


            singletons=Simulink.internal.CompositePorts.Dialog.getSingletons();

            instance=-1;
            uuid='invalid';


            try
                if nargin==1&&Simulink.internal.CompositePorts.Dialog.isCompositePortBlock(h)
                    pb=Simulink.BlockDiagram.Internal.getInterfaceModelBlock(h);
                    uuid=pb.port.UUID;
                    if~isKey(singletons,uuid)||~isvalid(singletons(uuid))
                        singletons(uuid)=Simulink.internal.CompositePorts.Dialog;
                        instance=singletons(uuid);
                        log(['Created a new instance for port ',uuid]);
                    else
                        instance=singletons(uuid);
                        log(['Reusing the same instance for port ',uuid]);
                    end

                    assert(isvalid(instance));



                    if~ishandle(instance.dialog)

                        instance.portUUID=uuid;
                        instance.parentHandle=get_param(get_param(h,'Parent'),'Handle');
                        instance.isParentSubsys=strcmpi(get_param(instance.parentHandle,'Type'),'block');
                        instance.port=pb.port;
                        instance.launchedForBlock=h;
                        instance.isInput=strcmpi(pb.port.part.partType,'signal_in');
                        instance.channelPath=sprintf('/CompositePorts/%s',instance.portUUID);
                        instance.channelSub=message.subscribe(instance.channelPath,@(msg)channelCallback(instance,msg));

                        instance.initStyler();

                        instance.createDDGDialog();




                        instance.listeners.readOnlyChanged=handle.listener(DAStudio.EventDispatcher,'ReadOnlyChangedEvent',@(~,e)handleReadOnlyChanged(instance,e));
                        instance.listeners.simStatusChanged=handle.listener(DAStudio.EventDispatcher,'SimStatusChangedEvent',@(~,e)handleReadOnlyChanged(instance,e));
                        instance.listeners.childRemoved=Simulink.listener(instance.parentHandle,'ObjectChildRemoved',@(~,e)handleChildRemoved(instance,e.Child));

                    else


                        instance.dialog.show();

                        instance.selectBlockInTree(h);
                    end

                end
            catch ME
                log(['Initialization failed for port ',uuid]);
                log([ME.identifier,' - ',ME.message],ME.stack);
                if isKey(singletons,uuid)

                    if isvalid(singletons(uuid))
                        delete(singletons(uuid))
                    end

                end
                instance=-1;
            end

            updateMlock();
        end

        function updateDialogOfPort(uuid)

            singletons=Simulink.internal.CompositePorts.Dialog.getSingletons();

            if~isKey(singletons,uuid)
                return
            end

            instance=singletons(uuid);
            assert(isvalid(instance));





            if~isvalid(instance.port)||isempty(instance.port.blocks.toArray())
                log('Port is gone');
                Simulink.internal.CompositePorts.Dialog.dialogCloseCallback(instance);
                return;
            end

            instance.refreshDialog();
        end

        function closeDialogOfPort(uuid)

            singletons=Simulink.internal.CompositePorts.Dialog.getSingletons();

            if~isKey(singletons,uuid)
                return
            end

            instance=singletons(uuid);
            assert(isvalid(instance));

            Simulink.internal.CompositePorts.Dialog.dialogCloseCallback(instance);
        end

        function closeDialogsOfGraph(h)

            instances=values(Simulink.internal.CompositePorts.Dialog.getSingletons());
            for i=1:numel(instances)
                instance=instances{i};
                assert(isvalid(instance));

                if instance.parentHandle==h
                    Simulink.internal.CompositePorts.Dialog.dialogCloseCallback(instance);
                end
            end
        end

        function forceMunlock()
            log('Force munlock');
            munlock;
        end

        function dialogCloseCallback(obj)
            log('Dialog closed');
            if isvalid(obj)
                log('Deleting singleton instance');
                delete(obj);
            end
        end


        function setOnShowCallback(cb)
            Simulink.internal.CompositePorts.Dialog.setGetOnShowCallback(cb);
        end

        function setOnRenderCompleteCallback(cb)
            Simulink.internal.CompositePorts.Dialog.setGetOnRenderCompleteCallback(cb);
        end

    end

    methods(Static,Access=private)




        function res=setGetOnShowCallback(cb)
            persistent onShow;
            if nargin
                onShow=cb;
            end
            res=onShow;
        end


        function onShow(portUUID)
            cb=Simulink.internal.CompositePorts.Dialog.setGetOnShowCallback();
            if~isempty(cb)
                cb(portUUID);
            end
        end


        function res=setGetOnRenderCompleteCallback(cb)
            persistent onRenderComplete;
            if nargin
                onRenderComplete=cb;
            end
            res=onRenderComplete;
        end


        function onRenderComplete(portUUID)
            cb=Simulink.internal.CompositePorts.Dialog.setGetOnRenderCompleteCallback();
            if~isempty(cb)
                cb(portUUID);
            end
        end


        function tf=isCompositePortBlock(h)
            tf=false;
            if ishandle(h)&&strcmp(get_param(h,'type'),'block')
                blkType=get_param(h,'BlockType');
                if(strcmp(blkType,'Inport')||strcmp(blkType,'Outport'))&&strcmp(get_param(h,'IsComposite'),'on')
                    tf=true;
                end
            end
        end


        function s=getSingletons()

            persistent singletons;
            if~isa(singletons,'containers.Map')

                singletons=containers.Map('KeyType','char','ValueType','any');
                log('Initialized singletons map');
            end
            s=singletons;
        end

        function tf=isDebug()
            tf=false;
        end

        function log(msg,st)
            if Simulink.internal.CompositePorts.Dialog.isDebug()
                if nargin==1
                    st=dbstack;
                    st=st(3:end);
                end
                msg=[st(1).name,' (',st(1).file,':',num2str(st(1).line),'): ',msg];
                disp(msg);
            end
        end

    end


    methods
        function selectBlockInTree(this,h)
            s.type='changeSelection';
            s.payload=h;
            message.publish(this.channelPath,s);
        end

        function refreshDialog(this)
            if this.suspendRefresh
                return;
            end
            s.type='Refresh';
            message.publish(this.channelPath,s);
        end

        function editor=getEditor(this)
            editor=SLM3I.SLDomain.getLastActiveEditorFor(this.parentHandle);
            assert(~isempty(editor));
        end

        function handleReadOnlyChanged(this,~)
            msg.type='SetDisabled';
            msg.payload=this.isDisabled();
            message.publish(this.channelPath,msg);
        end

        function handleChildRemoved(this,child)

            try
                this.styler.removeClass({child},this.getStyleClass());
            catch
            end
        end

        function res=wrapCall(~,callable)
            res.type='OK';
            res.payload='';
            try
                callable();
            catch ME
                res.type='Error';
                res.payload=slprivate('removeHyperLinksFromMessage',ME.message);
            end
        end

        function handleTreeSelectionChange(this,blocks)

            this.styler.removeClass(this.curHighlighted,this.getStyleClass());
            this.curHighlighted=cell(1,0);


            for i=1:numel(blocks)

                b=SLM3I.SLDomain.handle2DiagramElement(blocks(i));

                if isempty(b)||~b.isvalid()
                    continue;
                end

                this.curHighlighted{end+1}=b;

                if b.outputPort.size>0
                    e=b.outputPort.at(1).edge;
                else
                    e=b.inputPort.at(1).edge;
                end
                if e.size>0
                    l=e.at(1).container;
                    this.curHighlighted{end+1}=l;
                end
            end


            this.styler.applyClass(this.curHighlighted,this.getStyleClass());


            this.showBlocksOnCanvas(blocks);
        end

        function deleteBlocks(this,blocks)

            if isempty(blocks);return;end

            elements=arrayfun(@SLM3I.SLDomain.handle2DiagramElement,unique(blocks),'UniformOutput',false);

            elements=elements(~cellfun(@(el)isempty(el),elements));

            if isempty(elements);return;end
            ed=this.getEditor();
            SLM3I.SLDomain.deleteDiagramElement(ed,[elements{:}]);
        end

        function deleteBlocklessChildNodes(this,blocklessChildNodes)
            assert(slfeature('BEP_BLOCKLESS_SPECIFICATION'),...
            'Feature must be turned on to be able to delete blockless child nodes');
            if isempty(blocklessChildNodes)
                return;
            end

            for i=1:numel(blocklessChildNodes)
                element=blocklessChildNodes{i,1};
                elementStr=element{1,1};
                node=Simulink.internal.CompositePorts.TreeNode.findNode(this.port.tree,elementStr);
                if isempty(node)


                    continue;
                end
                needsUndo=false;
                Simulink.internal.CompositePorts.TreeNode.pruneTreeAfterBlockRemoval(this.port.tree,elementStr,needsUndo);
            end
        end

        function generateCommandLineSyntax(this,elementName)

            fileExt='*.m';
            fileStr=DAStudio.message('Simulink:busEditor:MATLABFiles');
            [fileName,pathName,~]=uiputfile({fileExt,fileStr},DAStudio.message('Simulink:BusElPorts:SelectFileToWrite'));

            if isequal(fileName,0)||isequal(pathName,0)
                return;
            end
            exportFile=fullfile(pathName,fileName);
            [fid,message]=fopen(exportFile,'wt');

            if(this.isParentSubsys)
                enclosingSubsysName=getfullname(this.parentHandle);
            else
                enclosingSubsysName=get_param(this.parentHandle,'Name');
            end

            if isempty(elementName)
                intfElement=this.port.name;
            else
                intfElement=strcat(this.port.name,'.',elementName);
            end

            intfElementContextObj=strcat('''',enclosingSubsysName,'/',intfElement,'''');
            setCommandSyntax=strcat('set_param','(',intfElementContextObj,',''<attr_name>'',''<attr_value>''',');');
            fprintf(fid,setCommandSyntax);
            fprintf(fid,"\n");
            getCommandSyntax=strcat('get_param','(',intfElementContextObj,',''<attr_name>''',');');
            fprintf(fid,getCommandSyntax);
            fclose(fid);
        end

        function newPos=getNextPositionForAddBlock(~,pos,xShift,yShift)
            newPos=pos+[xShift,yShift,xShift,yShift];

            newPos(newPos<-32767)=-32767;
            newPos(newPos>32767)=32767;
        end

        function val=unanimousVoteStringParameter(~,blocks,paramName,defaultVal)
            val=get_param(blocks(1),paramName);
            for i=1:numel(blocks)
                if~strcmp(val,get_param(blocks(i),paramName))

                    val=defaultVal;
                    return;
                end
            end
        end

        function addBlocksImpl(this,elementStrs)
            ed=this.getEditor();


            portBlocks=this.getPortBlocks();
            slBlocks=arrayfun(@Simulink.BlockDiagram.Internal.getSlBlock,portBlocks);


            positions=get_param(slBlocks,'Position');
            if iscell(positions)

                positions=cell2mat(positions);
            end
            positions=sortrows(positions,4);
            pos=positions(end,:);


            defColor='black';
            foregroundColors=cell(1,numel(elementStrs));
            backgroundColors=cell(1,numel(elementStrs));
            for i=1:numel(elementStrs)
                portBlocksOfThisEl=portBlocks(cellfun(@(s)strcmp(s,elementStrs{i}),{portBlocks.element}));
                if isempty(portBlocksOfThisEl)

                    slBlocksOfThisPort=arrayfun(@Simulink.BlockDiagram.Internal.getSlBlock,portBlocks);
                    foregroundColors{i}=this.unanimousVoteStringParameter(slBlocksOfThisPort,'ForegroundColor',defColor);
                    backgroundColors{i}=this.unanimousVoteStringParameter(slBlocksOfThisPort,'BackgroundColor',defColor);
                else

                    slBlocksOfThisEl=arrayfun(@Simulink.BlockDiagram.Internal.getSlBlock,portBlocksOfThisEl);
                    foregroundColors{i}=this.unanimousVoteStringParameter(slBlocksOfThisEl,'ForegroundColor',defColor);
                    backgroundColors{i}=this.unanimousVoteStringParameter(slBlocksOfThisEl,'BackgroundColor',defColor);
                end
            end


            newBlocks=SLM3I.SLDomain.addCompositePortBlocks(ed,this.getPortTypeString(),this.port.indexOne,elementStrs);
            newHandles=-1*ones(1,numel(newBlocks));

            existingBlockNames=getfullname(Simulink.findBlocks(this.parentHandle));
            if(this.isParentSubsys)
                enclosingSubsysName=getfullname(this.parentHandle);
            else
                enclosingSubsysName=get_param(this.parentHandle,'Name');
            end


            if this.isInput
                uniquificationString='BusElementIn';
            else
                uniquificationString='BusElementOut';
            end

            for i=1:numel(newHandles)
                newHandles(i)=newBlocks(i).asImmutable.handle;
                uniqueBlockPath=SLM3I.SLDomain.uniquifyString(strcat(enclosingSubsysName,"/",uniquificationString),existingBlockNames);
                uniqueBlockName=extractAfter(uniqueBlockPath,[enclosingSubsysName,'/']);
                set_param(newHandles(i),'Name',uniqueBlockName);
                existingBlockNames{end+1}=uniqueBlockPath;%#ok<AGROW> 
                if(slfeature('CompositeFunctionElements')>0&&strcmp(get_param(slBlocks(1),'IsClientServer'),'off')==0)
                    set_param(newHandles(i),'IsClientServer','on');
                end
            end


            ed.clearSelection();
            ed.select(newBlocks);


            for i=1:numel(newHandles)
                pos=this.getNextPositionForAddBlock(pos,0,40);
                private_sl_feval_with_named_counter('Simulink::sluCheckForNewConnectionsInGraph',...
                'set_param',newHandles(i),'Position',pos,'ForegroundColor',foregroundColors{i},...
                'BackgroundColor',backgroundColors{i});
            end


            if numel(newHandles)==1&&strcmpi(get_param(newHandles(1),'BlockType'),'outport')
                this.selectBlockInTree(newHandles(1));
            end
        end

        function addBlocks(this,elementStrs)
            ed=this.getEditor();
            ed.createMCommand('Simulink:BusElPorts:AddBlock',DAStudio.message('Simulink:BusElPorts:AddBlock'),@addBlocksImpl,{this,elementStrs});
        end


        function showBlocksOnCanvas(this,blocks)

            if(isempty(blocks))
                return;
            end

            ed=this.getEditor();


            boundingBox=[];
            for i=1:numel(blocks)

                marginX=0;
                marginY=0;
                de=SLM3I.SLDomain.handle2DiagramElement(blocks(i));

                if isempty(de)||~de.isvalid()
                    continue;
                end

                g=ed.getGlyphRootForElement(de);
                c=g.Children;
                for j=1:numel(c)

                    if~isa(c(j),'MG2.TextNode')||isempty(c(j).Text)
                        continue;
                    end
                    marginX=max(marginX,c(j).Width);

                    marginY=max(marginY,max(c(j).Height-g.Height,0)/2);
                end

                pos=get_param(blocks(i),'Position');
                pos=pos+[-marginX,-marginY,marginX,marginY];
                if isempty(boundingBox)
                    boundingBox=pos;
                else
                    boundingBox=[min(boundingBox(1),pos(1)),min(boundingBox(2),pos(2)),max(boundingBox(3),pos(3)),max(boundingBox(4),pos(4))];
                end
            end


            canvas=[];
            extendSceneRect(boundingBox);



            marginX=20/canvas.Scale;
            marginY=20/canvas.Scale;
            boundingBox=boundingBox+[-marginX,-marginY,marginX,marginY];


            extendSceneRect(boundingBox);

            function extendSceneRect(newRect)
                canvas=ed.getCanvas();

                rect=canvas.SceneRectInView;

                rect=[rect(1),rect(2),rect(1)+rect(3),rect(2)+rect(4)];

                rect=[min(rect(1),newRect(1)),min(rect(2),newRect(2)),max(rect(3),newRect(3)),max(rect(4),newRect(4))];

                rect(rect<-32767)=-32767;
                rect(rect>32767)=32767;
                sceneRect=[rect(1),rect(2),rect(3)-rect(1),rect(4)-rect(2)];
                canvas.showSceneRect(sceneRect);
            end

        end

        function delete(this)

            this.handleTreeSelectionChange([]);
            log('Removed higlights');

            message.unsubscribe(this.channelSub);
            log('Unsubscribe from the channel');

            singletons=Simulink.internal.CompositePorts.Dialog.getSingletons();
            remove(singletons,this.portUUID);
            log('Removed singleton instance from map');
            updateMlock();
        end

        function title=getDialogTitle(this)
            if this.isInput
                prefix='Simulink:BusElPorts:DialogTitleBEI';
            else
                prefix='Simulink:BusElPorts:DialogTitleBEO';
            end
            if isvalid(this.port)
                portName=this.port.name;
            else
                portName='';
            end
            title=DAStudio.message(prefix,portName);
        end

        function updateDialogTitle(this)

            if~ishandle(this.dialog);return;end
            this.dialog.setTitle(this.getDialogTitle());
        end

        function registerDAListeners(this)
            obj=get_param(this.parentHandle,'Object');
            obj.registerDAListeners;
        end

    end


    methods
        function s=getDialogSchema(this,~)


            wb.Type='webbrowser';
            wb.Tag='cportdlg_webbrowser';
            wb.RowSpan=[1,1];
            wb.ColSpan=[1,1];
            wb.ClearCache=true;
            wb.DisableContextMenu=~this.isDebug();
            wb.EnableInspectorOnLoad=this.isDebug();
            wb.Url=connector.applyNonce(this.url);
            wb.WebKit=true;
            wb.WebKitToolBar={};
            wb.MinimumSize=[450,500];
            wb.Debug=this.isDebug();



            s.DialogTag='CompositePortDlg';
            s.DialogTitle=this.getDialogTitle();
            s.LayoutGrid=[1,1];
            s.RowStretch=1;
            s.ColStretch=1;
            s.ExplicitShow=true;
            s.CloseCallback='Simulink.internal.CompositePorts.Dialog.dialogCloseCallback';
            s.CloseArgs={this};
            s.EmbeddedButtonSet={'Help'};
            s.StandaloneButtonSet={'Help'};
            s.HelpMethod='helpButtonCallback';
            s.IgnoreESCClose=true;








            s.Items={wb};
        end

        function helpButtonCallback(this)
            slhelp(getAnSLBlockOfPort(this));
        end

    end

end

function log(varargin)
    Simulink.internal.CompositePorts.Dialog.log(varargin{:})
end


function updateMlock()
    singletons=Simulink.internal.CompositePorts.Dialog.getSingletons();
    if~isempty(singletons)
        log('Mlock');
        mlock;
    else
        log('Munlock');
        munlock;
    end
end

function synth=isSynthesizedPortBlock(pb)
    h=Simulink.BlockDiagram.Internal.getSlBlock(pb);
    synth=strcmpi('on',get_param(h,'Hidden'));
end

function l=flattenSigHier(sigHier,prefix,root)
    l={};

    if isempty(sigHier)
        return;
    end


    if root
        thisPath=prefix;
    else
        if~isempty(prefix)
            thisPath=[prefix,'.',sigHier.SignalName];
        else
            thisPath=sigHier.SignalName;
        end
    end
    if~isempty(sigHier.Children)
        for i=1:numel(sigHier.Children)

            ll=flattenSigHier(sigHier.Children(i),thisPath,false);

            l=[l,ll];%#ok<AGROW>
        end
    else
        l={thisPath};
    end
end




































