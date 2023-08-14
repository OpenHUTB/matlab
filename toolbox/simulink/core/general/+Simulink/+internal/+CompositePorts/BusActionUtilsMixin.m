classdef(Abstract)BusActionUtilsMixin<handle


    methods(Access=protected)
        function tf=checkFeatures(this,featArray)
            tf=all(cellfun(@(feat)slfeature(feat)>0,featArray));
        end

        function a=mixinStructs(this,a,b)
            f=fieldnames(b);
            for i=1:length(f)
                a.(f{i})=b.(f{i});
            end
        end


        function handles=getBlocksOfType(this,selection,type)
            handles=[];
            for i=1:selection.size
                try
                    h=selection.at(1).handle;
                    if strcmpi(get_param(h,'Type'),'Block')&&strcmpi(get_param(h,'BlockType'),type)
                        handles(end+1)=h;%#ok<AGROW>
                    end
                catch

                end
            end
        end

        function uniqueModels=uniquifyModels(this,models)
            modelSequenceUnique=M3I.SequenceOfModel.makeUnique(models{1});
            cellfun(@(m)modelSequenceUnique.append(m),models);
            uniqueModels=arrayfun(@(i)modelSequenceUnique.at(i),1:modelSequenceUnique.size,'UniformOutput',false);
        end

        function res=getLineChildrenRecursively(~,lines,includeParents)
            T_SOLDER_JOINT='SLM3I.SolderJoint';
            res=[];
            if~isrow(lines)
                lines=lines';
            end

            for i=1:numel(lines)
                dl=SLM3I.SLDomain.handle2DiagramElement(lines(i)).container;
                isSignal=strcmpi(dl.type,'signal');
                assert(isSignal||strcmpi(dl.type,'connection'));
                isEmpty=dl.solderJoint.isEmpty;

                siblings=dl.segment;
                for si=1:siblings.size
                    s=siblings.at(si);
                    if includeParents
                        res(end+1)=s.handle;
                    elseif isSignal



                        if isEmpty||...
                            (isa(s.srcElement,T_SOLDER_JOINT)&&~isa(s.dstElement,T_SOLDER_JOINT))
                            res(end+1)=s.handle;
                        end
                    else

                        res(end+1)=s.handle;
                    end
                end
            end
            res=unique(res);
        end




        function tf=isValidElementString(~,el)

            C='[^.,\s]';









            ELEMENT=[C,'(?:\s*+',C,')*+'];







            re=[ELEMENT,'(?:\.',ELEMENT,')*+'];


            re=['^',re,'$'];


            [s,e]=regexp(el,re,'once');


            tf=~isempty(s)&&~isempty(e)&&s==1&&e==numel(el);
        end


        function lines=getConnectedLines(this,selection)
            lines=[];
            for i=1:selection.size
                el=selection.at(i);
                if isa(el,'SLM3I.Segment')&&strcmpi(el.container.type,'signal')&&el.container.isFullyConnected
                    lines(end+1)=el.handle;%#ok<AGROW>
                end
            end
        end

        function deleteLinesIncludingChildren(this,editor,handles)

            handlesToDelete=this.getLineChildrenRecursively(handles,true);
            this.deleteDiagramElement(editor,handlesToDelete);
        end

        function deleteDiagramElement(this,editor,handle)
            if isempty(handle)
                return;
            end
            els=arrayfun(@SLM3I.SLDomain.handle2DiagramElement,handle,'UniformOutput',false);
            SLM3I.SLDomain.deleteDiagramElement(editor,[els{:}]);
        end

        function pos=computeNewBEIBlockPosition(this,h,i)
            ph=get_param(h,'PortHandles');
            ph=ph.Outport;
            portPos=num2cell(get_param(ph(i),'Position'));
            [x,y]=portPos{:};


            pos=[x-15,y-5,x-5,y+5];
            switch get_param(h,'Orientation')
            case 'left'
                pos=[x+5,y-5,x+15,y+5];
            case 'up'
                pos=[x-5,y+5,x+5,y+15];
            case 'down'
                pos=[x-5,y-15,x+5,y-5];
            end
            pos=this.clipPos(pos);
        end

        function pos=computeNewBEOBlockPosition(this,h,i)
            ph=get_param(h,'PortHandles');
            ph=ph.Inport;
            portPos=num2cell(get_param(ph(i),'Position'));
            [x,y]=portPos{:};

            lh=get_param(h,'LineHandles');
            lh=lh.Inport;
            if ishandle(lh(i))
                offset=0;
            else
                offset=-10;
            end


            pos=[x+15+offset,y-5,x+25+offset,y+5];
            switch get_param(h,'Orientation')
            case 'left'
                pos=[x-25-offset,y-5,x-15-offset,y+5];
            case 'up'
                pos=[x-5,y-25-offset,x+5,y-15-offset];
            case 'down'
                pos=[x-5,y+15+offset,x+5,y+25+offset];
            end
            pos=this.clipPos(pos);
        end


        function newBlockHandles=expandPortBlock(this,editor,origBlks,portName,elements,newPos,orientation)
            blocks=arrayfun(@SLM3I.SLDomain.handle2DiagramElement,origBlks,'UniformOutput',false);
            blocksToDelete=[blocks{2:end}];
            if isempty(blocksToDelete)

                blocksToDelete=GLUE2.DiagramElement.empty;
            end
            newBlocks=SLM3I.SLDomain.expandPortBlock(editor,blocks{1},portName,elements,blocksToDelete);
            newBlockHandles=-1*ones(1,numel(newBlocks));
            for i=1:numel(newBlocks)

                newBlockHandles(i)=newBlocks(i).asImmutable.handle;
            end

            for i=1:numel(newBlockHandles)
                private_sl_feval_with_named_counter('Simulink::sluCheckForNewConnectionsInGraph',...
                'set_param',newBlockHandles(i),'Orientation',orientation{i},'Position',newPos{i});
            end
        end

        function removeLabelsFromLine(~,line)


            line.label='';
            numSegments=line.segment.size;
            labels={};
            for i=1:numSegments
                segment=line.segment.at(1);
                numLabels=segment.label.size;
                for j=i:numLabels
                    labels{j}=segment.label.at(j);
                end
            end
            cellfun(@(l)l.destroy,labels);
        end

        function addLabelToSegment(this,segment,label)

            this.removeLabelsFromLine(segment.container);
            segment.container.label=label;
            segment.label.append(SLM3I.SegmentLabel(segment.diagram.model));
        end

        function disconnectSegmentFromDst(~,segment)

            endPos=segment.dstElement.absPosition;
            segment.dstElement=GLUE2.GraphElement.empty;
            segment.addDstTerminator;
            segment.dstElement.position=endPos;
        end

        function disconnectSegmentFromSrc(~,segment)

            endPos=segment.srcElement.absPosition;
            segment.srcElement=GLUE2.GraphElement.empty;
            segment.addSrcTerminator;
            segment.srcElement.position=endPos;
        end

        function srcBlocks=getSrcBlocks(~,h)
            try
                lines=get_param(h,'LineHandles');
                lines=lines.Inport;
                srcBlocks=cell(1,numel(lines));
                for i=1:numel(lines)
                    if ishandle(lines(i))
                        srcBlocks{i}=get_param(lines(i),'SrcBlockHandle');
                    else
                        srcBlocks{i}=-1;
                    end
                end
            catch
                srcBlocks={};
            end
        end

        function dstBlocks=getDstBlocks(~,h)
            try
                lines=get_param(h,'LineHandles');
                lines=lines.Outport;
                dstBlocks=cell(1,numel(lines));
                for i=1:numel(lines)
                    if ishandle(lines(i))
                        dstBlocks{i}=get_param(lines(i),'DstBlockHandle')';
                    else
                        dstBlocks{i}=-1;
                    end
                end
            catch
                dstBlocks={};
            end
        end

        function pos=clipPos(~,origPos)
            pos=origPos;
            pos(pos<-32767)=-32767;
            pos(pos>32767)=32767;
        end

        function tf=isDefaultName(~,name,basename)
            tf=~isempty(regexpi(name,['^',basename,'\d*$']));
        end

        function newElement=prependElementString(~,h,prefix)
            curEl=get_param(h,'Element');
            if isempty(curEl)
                newElement=prefix;
            else
                newElement=strjoin({prefix,curEl},'.');
            end
        end

        function newElement=appendElementString(~,h,suffix)
            curEl=get_param(h,'Element');
            if isempty(curEl)
                newElement=suffix;
            else
                newElement=strjoin({curEl,suffix},'.');
            end
        end

        function srcBlocks=getSrcBlocksOfLines(~,lines)
            srcBlocks=[];
            for i=1:numel(lines)
                srcBlocks=[srcBlocks,get_param(lines(i),'SrcBlockHandle')];%#ok<AGROW>
            end
            srcBlocks=unique(srcBlocks,'stable');
        end

        function dstBlocks=getDstBlocksOfLines(~,lines)
            dstBlocks=[];
            for i=1:numel(lines)
                dstBlocks=[dstBlocks,get_param(lines(i),'DstBlockHandle')'];%#ok<AGROW>
            end
            dstBlocks=unique(dstBlocks,'stable');
        end

        function[sortedLines,ports]=sortLinesBySrcPortNums(this,lines)

            [lines,~]=this.sortLinesByDstPortNums(lines);

            ports=arrayfun(@(h)get_param(get_param(h,'SrcPortHandle'),'PortNumber'),lines);
            [~,sortIdx]=sort(ports);
            ports=ports(sortIdx);
            sortedLines=lines(sortIdx);
        end

        function[sortedLines,ports]=sortLinesByDstPortNums(~,lines)
            ports=arrayfun(@(h)get_param(get_param(h,'DstPortHandle'),'PortNumber'),lines);
            [~,sortIdx]=sort(ports);
            ports=ports(sortIdx);
            sortedLines=lines(sortIdx);
        end

        function res=getInportBlocks(~,subsys,portNums)

            props=get(subsys);
            if~isfield(props,'BlockType')||~strcmp(props.BlockType,'SubSystem')
                res=[];
            else
                res=arrayfun(@(pn)Simulink.BlockDiagram.Internal.getBlocksOfInputPort(subsys,pn),portNums,'UniformOutput',false);
            end
        end

        function res=getOutportBlocks(~,subsys,portNums)
            res=arrayfun(@(pn)Simulink.BlockDiagram.Internal.getBlocksOfOutputPort(subsys,pn),portNums,'UniformOutput',false);
        end

        function tf=hasNoJumps(~,seq)

            tf=isempty(setdiff(unique(diff(seq)),[0,1]));
        end

        function[c,dupFilter,indeces]=uniquify(~,vals)
            [c,ia,ic]=unique(vals,'stable');
            indeces=ic';
            dupFilter=zeros(1,numel(vals));
            dupFilter(ia)=1;
            dupFilter=logical(dupFilter);
        end

        function r=makeRow(~,a)
            r=a;
            if~isrow(r)
                r=r';
            end
        end

        function r=makeRowCell(this,a)
            r=this.makeRow(a);
            if~iscell(r)
                r={r};
            end
        end

        function r=removeNewLines(~,s)
            r=strrep(s,newline,' ');
        end

        function n=getBlockNameForError(this,h)
            try
                n=get_param(h,'Name');
                n=this.removeNewLines(n);
            catch
                n='';
            end
        end

        function str=joinCellStr(~,cstr,sep)
            if nargin==2
                sep='\n';
            end
            sep=sprintf(sep);
            assert(iscell(cstr));
            str=strjoin(cstr,sep);
        end

        function msg=processParameterWarningMsgs(this,prefix,cmsg)
            assert(iscell(cmsg));
            msg='';
            if isempty(cmsg);return;end


            if numel(cmsg)>10
                remCnt=numel(cmsg)-10;
                cmsg=cmsg(1:10);
                cmsg{end+1}=DAStudio.message('Simulink:BusElPorts:ActionWarnParamMore',remCnt);
            end


            cmsg=[{prefix,''},cmsg];
            msg=this.joinCellStr(cmsg);
        end

        function tf=isStateflowBlock(~,h)
            tf=strcmpi(get_param(h,'type'),'block')&&strcmpi(get_param(h,'BlockType'),'SubSystem')&&~strcmpi(get_param(h,'SFBlockType'),'none');
        end

        function tf=isConcurrentExecModel(~,h)
            tf=strcmpi(get_param(h,'type'),'block_diagram')&&strcmpi(get_param(h,'ConcurrentTasks'),'on');
        end

        function tf=isVariantWrapper(~,h)
            tf=false;
            try
                tf=strcmpi(get_param(h,'Type'),'block')&&...
                strcmpi(get_param(h,'BlockType'),'SubSystem')&&...
                strcmpi(get_param(h,'Variant'),'on');
            catch

            end
        end



        function h=addBusCreator(this,systemName,orientationStr,numInputs,pos)
            h=private_sl_feval_with_named_counter('Simulink::sluCheckForNewConnectionsInGraph',...
            'add_block','simulink/Signal Routing/Bus Creator',...
            [systemName,'/Bus Creator'],'MakeNameUnique','on');

            private_sl_feval_with_named_counter('Simulink::sluCheckForNewConnectionsInGraph',...
            'set_param',h,'Orientation',orientationStr,...
            'Inputs',num2str(numInputs),...
            'Position',pos);
        end


        function parent=getOwnerHandle(~,portLineOrBlockHandle)
            h=portLineOrBlockHandle;
            assert(ishandle(h));
            type=lower(get_param(h,'Type'));
            switch type
            case 'port'

                parent=get_param(get_param(h,'Parent'),'Parent');
            case{'line','block'}


                parent=get_param(h,'Parent');
            otherwise
                assert(false);
            end
            parent=get_param(parent,'Handle');
        end

        function tf=isBlock(this,h)
            tf=this.isOfType(h,'block');
        end

        function tf=isLine(this,h)
            tf=this.isOfType(h,'line');
        end

        function tf=isPort(this,h)
            tf=this.isOfType(h,'port');
        end

        function[param,curVal,defVal,bepPropName,bepDefVal,bepCurVal]=processNonDefaultCompositePortParam(this,paramAndDefVal,~,elemNode)
            s=split(paramAndDefVal,',');
            [param,~]=s{:};
            [curVal,defVal,bepPropName,bepDefVal,bepCurVal]=this.getCurrentAndDefaultAttrValues(elemNode,param);
        end

        function[param,curVal,defVal]=processNonDefaultParam(~,paramAndDefVal,h)
            s=split(paramAndDefVal,',');
            [param,defVal]=s{:};
            curVal=get_param(h,param);
        end
    end

    methods(Access=private)
        function tf=isOfType(~,h,type)
            tf=strcmpi(get_param(h,'Type'),type);
        end

        function[curVal,defVal,bepPropName,bepDefVal,bepCurVal]=getCurrentAndDefaultAttrValues(this,node,param)
            if isempty(node)
                return;
            end

            switch(param)
            case 'OutDataTypeStr'
                defVal='Inherit: auto';
                curVal=Simulink.internal.CompositePorts.TreeNode.getDataType(node);
                bepPropName='DataType';
                bepDefVal='Inherit: auto';
                bepCurVal=curVal;

            case 'Unit'
                defVal='inherit';
                curVal=Simulink.internal.CompositePorts.TreeNode.getUnit(node);
                bepPropName='Unit';
                bepDefVal='inherit';
                bepCurVal=curVal;

            case 'PortDimensions'
                defVal='1';
                curVal=Simulink.internal.CompositePorts.TreeNode.getDims(node);
                bepPropName='Dimensions';
                bepDefVal='-1';
                bepCurVal=curVal;

            case 'OutMin'
                defVal='[]';
                curVal=Simulink.internal.CompositePorts.TreeNode.getMin(node);
                bepPropName='Min';
                bepDefVal='[]';
                bepCurVal=curVal;

            case 'OutMax'
                defVal='[]';
                curVal=Simulink.internal.CompositePorts.TreeNode.getMax(node);
                bepPropName='Max';
                bepDefVal='[]';
                bepCurVal=curVal;

            case 'VarSizeSig'
                defVal=sl.mfzero.treeNode.DimsMode.INHERIT;
                curVal=Simulink.internal.CompositePorts.TreeNode.getDimsMode(node);
                bepPropName='DimensionsMode';
                bepDefVal='Inherit';
                bepCurVal=dimsModeToString(this,curVal);

            case 'SignalType'
                defVal=sl.mfzero.treeNode.Complexity.AUTO;
                curVal=Simulink.internal.CompositePorts.TreeNode.getComplexity(node);
                bepPropName='Complexity';
                bepDefVal='auto';
                bepCurVal=complexityToString(this,curVal);

            case 'SampleTime'
                defVal='-1';
                curVal=Simulink.internal.CompositePorts.TreeNode.getSampleTime(node);
                bepPropName='SampleTime';
                bepDefVal='-1';
                bepCurVal=curVal;

            case 'BusOutputAsStruct'
                defVal='off';
                virtuality=Simulink.internal.CompositePorts.TreeNode.getVirtuality(node);
                if isequal(virtuality,sl.mfzero.treeNode.Virtuality.NON_VIRTUAL)
                    curVal='on';
                else
                    curVal='off';
                end

                bepPropName='Virtuality';
                bepDefVal='Inherit';
                bepCurVal=virtualityToString(this,virtuality);


            otherwise

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
    end
end
