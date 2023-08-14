classdef(Sealed)RefactorInterfaceWrapper<Simulink.internal.CompositePorts.BusActionWrapper&Simulink.internal.CompositePorts.BusActionUtilsMixin


    methods

        function this=RefactorInterfaceWrapper(varargin)

            this@Simulink.internal.CompositePorts.BusActionWrapper(varargin{:});

            try



                this.mData=this.mixinStructs(this.mData,this.processSelection());


                this.mData.actions.input=Simulink.internal.CompositePorts.RefactorInputInterface(this.mData.editor,this.mData.selection,this.mData);
                this.mData.actions.output=Simulink.internal.CompositePorts.RefactorOutputInterface(this.mData.editor,this.mData.selection,this.mData);
                this.mData.actions.inputOutput=Simulink.internal.CompositePorts.RefactorInputOutputInterface(this.mData.editor,this.mData.selection,this.mData);
            catch ex
                if slsvTestingHook('BusActionsRethrow')==1
                    rethrow(ex);
                end
            end
        end


        function models=getAdditionalModels(this)
            models=SLM3I.SequenceOfModel.makeUnique(this.mData.editor.getDiagram.model.getRootDeviant);
            if~isempty(this.mData.dstSubsys)&&ishandle(this.mData.dstSubsys)
                models.append(SLM3I.SLDomain.handleToM3IModel(this.mData.dstSubsys).getRootDeviant);
            end
            if~isempty(this.mData.srcSubsys)&&ishandle(this.mData.srcSubsys)
                models.append(SLM3I.SLDomain.handleToM3IModel(this.mData.srcSubsys).getRootDeviant);
            end
        end
    end


    methods(Access=protected)
        function msg=executeImpl(this)

            conExecMsg='';
            m=-1;
            if ishandle(this.mData.srcSubsys)
                m=bdroot(this.mData.srcSubsys);
            elseif ishandle(this.mData.dstSubsys)
                m=bdroot(this.mData.dstSubsys);
            end
            if ishandle(m)&&this.isConcurrentExecModel(m)
                conExecMsg=DAStudio.message('Simulink:BusElPorts:ActionWarnConcurrentExec',get_param(m,'Name'));
            end


            srcMsg=this.checkIfSubsystemIsNotCompatible('output');
            dstMsg=this.checkIfSubsystemIsNotCompatible('input');


            cmsg={conExecMsg,srcMsg,dstMsg};
            cmsg=cmsg(~cellfun('isempty',cmsg));
            msg=this.joinCellStr(cmsg,'\n\n');

            if~isempty(conExecMsg)
                return;
            elseif this.mData.actions.inputOutput.canExecute()&&isempty(srcMsg)&&isempty(dstMsg)
                this.mData.actions.inputOutput.execute();
            elseif this.mData.actions.input.canExecute()&&isempty(dstMsg)
                this.mData.actions.input.execute();
            elseif this.mData.actions.output.canExecute()&&isempty(srcMsg)
                this.mData.actions.output.execute();
            end
        end
    end

    methods(Access=private)

        function actionData=processSelection(this)

            actionData=cell2struct({[],[],[],[],[],[],[],-1,-1},...
            {'srcBlocks','dstBlocks','srcPorts','dstPorts','lines','linesBySrc','linesByDst','srcSubsys','dstSubsys'},2);



            actionData.lines=this.pickLines();


            actionData.srcBlocks=this.getSrcBlocksOfLines(actionData.lines);
            actionData.dstBlocks=this.getDstBlocksOfLines(actionData.lines);


            [actionData.linesBySrc,actionData.srcPorts]=this.sortLinesBySrcPortNums(actionData.lines);
            [actionData.linesByDst,actionData.dstPorts]=this.sortLinesByDstPortNums(actionData.lines);


            actionData.srcSubsys=this.pickSubsystem(actionData.srcBlocks);
            actionData.dstSubsys=this.pickSubsystem(actionData.dstBlocks);
        end


        function subsys=pickSubsystem(this,h)

            subsys=-1;


            if numel(h)~=1||~ishandle(h)
                return;
            end


            if~strcmpi(get_param(h,'Type'),'Block')||...
                ~strcmpi(get_param(h,'BlockType'),'SubSystem')
                return;
            end







            if strcmpi(get_param(h,'Variant'),'on')||...
                ~strcmpi(get_param(h,'Permissions'),'ReadWrite')||...
                Simulink.BlockDiagram.Internal.isForEachSubsystem(h)||...
                ~isempty(get_param(h,'TemplateBlock'))||...
                this.isStateflowBlock(h)
                return;
            end


            linkStatus=get_param(h,'LinkStatus');
            supportedLinkStatus={'none','inactive'};
            if~ismember(linkStatus,supportedLinkStatus)
                return;
            end


            subsys=h;
        end


        function r=pickLines(this)

            r=[];


            lines=this.getConnectedLines(this.mData.selection);


            if double(this.mData.selection.size)~=numel(lines)
                return;
            end


            srcPortHandles=get_param(lines,'SrcPortHandle');
            if~iscell(srcPortHandles)
                srcPortHandles={srcPortHandles};
            end
            srcPortHandles=unique([srcPortHandles{:}]);


            if numel(srcPortHandles)<2||~all(arrayfun(@ishandle,srcPortHandles))
                return;
            end


            lines=get_param(srcPortHandles,'Line');
            r=this.getLineChildrenRecursively([lines{:}],false);
        end


        function msg=checkIfSubsystemIsNotCompatible(this,side)
            msg='';
            jumpMsg='';
            paramMsg='';
            cmsg={};

            function ph=getOutputPortHandles(bh)
                ph=get_param(bh,'PortHandles');
                ph=ph.Outport;
            end

            function ph=getInputPortHandles(bh)
                ph=get_param(bh,'PortHandles');
                ph=ph.Inport;
            end

            function tf=isPortOfType(portH,portType)
                tf=ishandle(portH)&&strcmpi(get_param(portH,'PortType'),portType);
            end

            function tf=areAllSrcPortsDataPorts()
                srcs=get_param(this.mData.lines,'SrcPortHandle');
                if iscell(srcs);srcs=vertcat(srcs{:});end
                tf=all(arrayfun(@(portH)isPortOfType(portH,'outport'),srcs));
            end

            function tf=areAllDstPortsDataPorts()
                dsts=get_param(this.mData.lines,'DstPortHandle');
                if iscell(dsts);dsts=vertcat(dsts{:});end
                tf=all(arrayfun(@(portH)isPortOfType(portH,'inport'),dsts));
            end

            switch side
            case 'input'
                ss=this.mData.dstSubsys;
                if~ishandle(ss);return;end
                portNums=this.mData.dstPorts;
                ssph=getInputPortHandles(ss);


                props=get(ss);
                if~isfield(props,'BlockType')||~strcmp(props.BlockType,'SubSystem')
                    getPortBlocksForPort=[];
                else
                    getPortBlocksForPort=@(pn)Simulink.BlockDiagram.Internal.getBlocksOfInputPort(ss,pn);
                end
                getPortOfPortBlock=@(pb)getOutputPortHandles(pb);
                areAllPortsDataPorts=@areAllDstPortsDataPorts;
                msgPrefixKey='Simulink:BusElPorts:ActionWarnSubsysInputPrefix';
                msgJumpKey='Simulink:BusElPorts:ActionWarnContDstPortNums';
                msgExtPortKey='Simulink:BusElPorts:ActionWarnInputPortParam';
                msgIntPortKey='Simulink:BusElPorts:ActionWarnOutputPortParam';
                msgNonDataPortKey='Simulink:BusElPorts:ActionWarnNonDataPortSubsysInput';
            case 'output'
                ss=this.mData.srcSubsys;
                if~ishandle(ss);return;end

                portNums=unique(this.mData.srcPorts,'stable');
                ssph=getOutputPortHandles(ss);
                getPortBlocksForPort=@(pn)Simulink.BlockDiagram.Internal.getBlocksOfOutputPort(ss,pn);
                getPortOfPortBlock=@(pb)getInputPortHandles(pb);
                areAllPortsDataPorts=@areAllSrcPortsDataPorts;
                msgPrefixKey='Simulink:BusElPorts:ActionWarnSubsysOutputPrefix';
                msgJumpKey='Simulink:BusElPorts:ActionWarnContSrcPortNums';
                msgExtPortKey='Simulink:BusElPorts:ActionWarnOutputPortParam';
                msgIntPortKey='Simulink:BusElPorts:ActionWarnInputPortParam';
                msgNonDataPortKey='Simulink:BusElPorts:ActionWarnNonDataPortSubsysOutput';
            otherwise
                assert(false,'Expecting ''input'' or ''output''.');
            end
            ssName=this.getBlockNameForError(ss);





            if~areAllPortsDataPorts()
                msg=DAStudio.message(msgNonDataPortKey,ssName);
                return;
            end


            if~this.hasNoJumps(portNums)
                jumpMsg=DAStudio.message(msgJumpKey,ssName);
            end


            for i=1:numel(portNums)
                pn=portNums(i);

                badParams=Simulink.BlockDiagram.Internal.isPortDefault(ssph(pn),true);
                for j=1:numel(badParams)
                    [param,curVal,defVal]=this.processNonDefaultParam(badParams{j},ssph(pn));
                    tmpMsg=message(msgExtPortKey,param,pn,ssName,curVal,defVal);
                    cmsg{end+1}=MSLDiagnostic(tmpMsg).message;
                end

                portBlocks=getPortBlocksForPort(pn);
                for j=1:numel(portBlocks)
                    pb=portBlocks(j);

                    pbName=[ssName,'/',this.getBlockNameForError(pb)];
                    badParams=Simulink.BlockDiagram.Internal.isPortBlockDefault(pb);
                    for k=1:numel(badParams)
                        [param,curVal,defVal]=this.processNonDefaultParam(badParams{k},pb);
                        if strcmp(param,'Interpolate')&&strcmp(side,'input')


                            continue;
                        end
                        cmsg{end+1}=DAStudio.message('Simulink:BusElPorts:ActionWarnBlockParam',param,pbName,curVal,defVal);
                    end

                    pbph=getPortOfPortBlock(pb);
                    badParams=Simulink.BlockDiagram.Internal.isPortDefault(pbph,true);
                    for k=1:numel(badParams)
                        [param,curVal,defVal]=this.processNonDefaultParam(badParams{k},pbph);
                        tmpMsg=message(msgIntPortKey,param,1,pbName,curVal,defVal);
                        cmsg{end+1}=MSLDiagnostic(tmpMsg).message;
                    end
                end
            end


            paramMsg=this.processParameterWarningMsgs(DAStudio.message(msgPrefixKey,ssName),cmsg);


            msg=jumpMsg;
            if~isempty(paramMsg)
                if~isempty(msg)
                    msg=sprintf('%s\n\n%s',msg,paramMsg);
                else
                    msg=paramMsg;
                end
            end
        end
    end
end
