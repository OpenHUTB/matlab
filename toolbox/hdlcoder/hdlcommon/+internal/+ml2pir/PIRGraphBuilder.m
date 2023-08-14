



classdef PIRGraphBuilder<internal.ml2pir.BaseGraphBuilder
    properties(Access=protected)
        CurrentSubGraph=struct('NIC',{},'Network',{});
Network

PirOptions

TraceCmtPrefix

TraceCmtOverride

NICsToFlatten
    end

    properties(Constant)
        INCORRECT_IO_SIGNAL_MSG=['Unsupported input, output signal '...
        ,'count found during node construction.'];
    end

    methods

        function this=PIRGraphBuilder(varargin)
            pirOptions=this.parseInputs(varargin{:});


            this.PirOptions=pirOptions;

            this.NICsToFlatten=containers.Map('KeyType','char','ValueType','any');



            this.TraceCmtPrefix=this.createTraceCmtPrefix;
        end

        function finalize(this)

            refNtwkIDs=this.NICsToFlatten.keys;
            refNtwkIter=1;

            while~this.NICsToFlatten.isempty


                nicsToFlatten=this.NICsToFlatten(refNtwkIDs{refNtwkIter});







                refNtwkComps=nicsToFlatten{1}.ReferenceNetwork.components;
                flattenNIC=true;
                for ii=1:length(refNtwkComps)
                    if refNtwkComps(ii).isNetworkInstance
                        refNet=refNtwkComps(ii).ReferenceNetwork;

                        if this.NICsToFlatten.isKey(refNet.RefNum)
                            flattenNIC=false;
                            break;
                        end
                    end
                end

                if flattenNIC





                    refNet=nicsToFlatten{1}.ReferenceNetwork;
                    splitAllInstances=numel(nicsToFlatten)<...
                    numel(refNet.instances);

                    for ii=1:numel(nicsToFlatten)
                        if ii~=numel(nicsToFlatten)||splitAllInstances



                            nicsToFlatten{ii}.splitInstance;
                        end
                        this.flattenNetwork(nicsToFlatten{ii});
                    end



                    this.NICsToFlatten.remove(refNtwkIDs{refNtwkIter});
                    refNtwkIDs(refNtwkIter)=[];
                else


                    refNtwkIter=refNtwkIter+1;
                end

                if refNtwkIter>this.NICsToFlatten.length


                    refNtwkIter=1;
                end
            end


            this.Network.simplifyWiring;
        end

        function hNIC=createGraph(this,dutName)
            parentNetwork=this.PirOptions.ParentNetwork;

            hN=this.createNewNetwork(dutName);
            hNIC=pirelab.instantiateNetwork(parentNetwork,hN,[],[],dutName);

            this.Network=hN;
            this.CurrentSubGraph(end+1)=struct('NIC',hNIC,'Network',hN);


            internal.ml2pir.PIRGraphBuilder.passOptimizationFlags(this,hN);
        end

        function createIO(~,~,~,~,~,~)

        end

        function hNIC=beginSubGraph(this,name,description,subGraphInfo)
            dstNetwork=this.getCurrentNetwork;
            hNewN=this.createNewNetwork(name);
            this.CurrentSubGraph(end+1)=struct('NIC',-1,'Network',hNewN);

            if isempty(subGraphInfo)
                hNIC=this.instantiateNetwork(dstNetwork,hNewN);
            elseif isa(subGraphInfo,'internal.ml2pir.utils.LoopStreamInfo')
                hNIC=this.instantiateStreamedNetwork(dstNetwork,hNewN,subGraphInfo);
            elseif isa(subGraphInfo,'internal.mtree.utils.iteratorfun.Info')
                hNIC=this.instantiateIteratorFunNetwork(dstNetwork,hNewN,subGraphInfo);
            else
                assert(isa(subGraphInfo,'internal.mtree.utils.npufun.Info'),...
                'Unknown graph info');
                hNIC=this.instantiateNPUNetwork(dstNetwork,hNewN,subGraphInfo);
            end

            hNIC.Name=name;
            hNIC.OrigModelHandle=this.PirOptions.OriginalSLHandle;

            if isstruct(description)
                comments=description.comments;

                hNIC.setMLFBFile(description.file);
                hNIC.setMLFBLine(description.line);
                hNIC.setMLFBCol(description.col);
            else
                comments=description;
            end

            if~isempty(comments)
                hNIC.addComment(comments);
            end

            this.CurrentSubGraph(end).NIC=hNIC;
        end

        function setSubGraph(this,subGraphNode)
            this.CurrentSubGraph(end+1)=struct('NIC',subGraphNode,...
            'Network',subGraphNode.ReferenceNetwork);
        end

        function endSubGraph(this)
            assert(~isempty(this.CurrentSubGraph))
            this.CurrentSubGraph(end)=[];
        end

        function hNIC=getCurrentSubGraphNode(this)
            assert(~isempty(this.CurrentSubGraph))
            hNIC=this.CurrentSubGraph(end).NIC;
        end

        function name=getCurrentSubGraphName(this)
            hN=this.getCurrentNetwork;
            name=hN.FullPath;
        end

        function hNewNIC=copySubGraph(this,name,hOldNIC,description,subGraphInfo)
            hNIC=this.getCurrentSubGraphNode;



            assert(hNIC~=-1,'cannot copy a graph into the parent network')

            dstNetwork=this.getCurrentNetwork;

            hN=hOldNIC.ReferenceNetwork;

            if isempty(subGraphInfo)
                hNewNIC=this.instantiateNetwork(dstNetwork,hN);
            elseif isa(subGraphInfo,'internal.mtree.utils.iteratorfun.Info')
                hNewNIC=this.instantiateIteratorFunNetwork(dstNetwork,hN,subGraphInfo);
            else
                assert(isa(subGraphInfo,'internal.mtree.utils.npufun.Info'),...
                'Unknown or non-copyable graph info');
                hNewNIC=this.instantiateNPUNetwork(dstNetwork,hN,subGraphInfo);
            end

            hNewNIC.Name=name;
            hNewNIC.OrigModelHandle=this.PirOptions.OriginalSLHandle;

            if isstruct(description)
                comments=description.comments;

                hNewNIC.setMLFBFile(description.file);
                hNewNIC.setMLFBLine(description.line);
                hNewNIC.setMLFBCol(description.col);
            else
                comments=description;
            end

            if~isempty(comments)
                hNewNIC.addComment(comments);
            end
        end

        function[inp,inpIdx]=addInput(this,name,typeInfo)
            assert(numel(typeInfo.Ins)==0&&numel(typeInfo.Outs)==1);

            hN=this.getCurrentNetwork;

            inp=hN.addInputPort;
            inp.Name=name;

            inpIdx=inp.PortIndex+1;

            outSig=this.getSignalsFromTypes(hN,typeInfo.Outs);
            outSig.Name=name;
            outSig.addDriver(inp);



            isIteratorFunNetwork=false;
            if hN.hasForIterDataTag
                tag=hN.getForIterDataTag;
                imageSize=tag.getImageSize;
                outputSize=tag.getOutputSize;
                if~isempty(outputSize)
                    isIteratorFunNetwork=true;
                end
            end

            if isIteratorFunNetwork
                outerType=typeInfo.Outs.copy;
                switch inpIdx
                case 1
                    outerType.setDimensions(double(imageSize));
                case 2
                    outerType.setDimensions(double(outputSize));
                case 3
                    outerType.setDimensions([1,1]);
                otherwise
                    outerType=typeInfo.Outs;
                end
            elseif hN.hasNPUDataTag



                npudt=hN.getNPUDataTag;
                if npudt.isStreamedInput(inpIdx-1)
                    outerType=typeInfo.Outs.copy;
                    outerType.setDimensions([npudt.getImageRows,npudt.getImageCols]);
                else
                    outerType=typeInfo.Outs;
                end
            else
                outerType=typeInfo.Outs;
            end



            hNIC=hN.instances;
            assert(numel(hNIC)==1,...
            'adding an input to a NIC with more than 1 instance');

            port=hNIC.addInputPort;
            port.Name=name;



            hOtherN=hNIC.Owner;
            if~strcmp(hOtherN.RefNum,this.PirOptions.ParentNetwork.RefNum)
                sig=this.getSignalsFromTypes(hOtherN,outerType);
                sig.Name=name;
                sig.addReceiver(port);
            end
        end

        function[out,outIdx]=addOutput(this,name,typeInfo)
            assert(numel(typeInfo.Ins)==1&&numel(typeInfo.Outs)==0);

            hN=this.getCurrentNetwork;

            out=hN.addOutputPort;
            out.Name=name;

            outIdx=out.PortIndex+1;

            inSig=this.getSignalsFromTypes(hN,typeInfo.Ins);
            inSig.Name=name;
            inSig.addReceiver(out);

            isIteratorFunNetwork=false;
            if hN.hasForIterDataTag
                tag=hN.getForIterDataTag;
                outputSize=tag.getOutputSize;
                if~isempty(outputSize)
                    isIteratorFunNetwork=true;
                end
            end



            if isIteratorFunNetwork
                outerType=typeInfo.Ins.copy;
                outerType.setDimensions(double(outputSize));
            elseif hN.hasNPUDataTag
                npudt=hN.getNPUDataTag;
                outerType=typeInfo.Ins.copy;
                outerType.setDimensions([npudt.getImageRows,npudt.getImageCols]);
            else
                outerType=typeInfo.Ins;
            end



            hNIC=hN.instances;
            assert(numel(hNIC)==1,...
            'adding a signal to a network with more than 1 instance');

            port=hNIC.addOutputPort;
            port.Name=name;



            hOtherN=hNIC.Owner;
            if~strcmp(hOtherN.RefNum,this.PirOptions.ParentNetwork.RefNum)
                sig=this.getSignalsFromTypes(hOtherN,outerType);
                sig.Name=name;
                sig.addDriver(port);
            end
        end

        function setType(this,obj,type,varargin)
            assert(~type.isUnknown,'all PIR nodes must have a type');
            pirType=type.toPIRType;



            if isa(obj,'hdlcoder.port')
                if obj.isDriver
                    ports=obj;
                else



                    idx=obj.PortIndex+1;
                    hN=obj.Owner;
                    hNICs=hN.instances;
                    for i=1:numel(hNICs)
                        hNIC=hNICs(i);

                        hOtherN=hNIC.Owner;
                        if~strcmp(hOtherN.RefNum,this.PirOptions.ParentNetwork.RefNum)
                            port=hNIC.PirOutputPorts(idx);
                            port.Signal.Type=pirType;
                        end
                    end
                    ports=[];
                end
            else
                ports=obj.PirOutputPorts;
            end

            for i=1:length(ports)
                port=ports(i);
                port.Signal.Type=pirType;
            end
        end

        function setInitialValue(~,node,ic)
            assert(isa(node,'hdlcoder.integerdelay_comp'),...
            'node provided is not an integerdelay_comp');

            if ischar(ic)
                ic=eval(ic);
            end

            [isReset,initValScalarExpandable,ic]=pircore.processDelayIC(ic);
            node.setResetInitVal(isReset);
            node.setInitValScalarExpandable(initValScalarExpandable);
            node.setInitialValue(ic);


            node.setPreserveInitValDimensions(false);




            hN=node.Owner;
            delayOutSig=node.PirOutputSignals;
            if~delayOutSig.Type.is2DMatrix



                pirelab.insertSignalSpecOnSignal(hN,delayOutSig);
            end
        end

        function connect(this,node1,node2)
            p1=1;
            if iscell(node1)
                p1=node1{2};
                node1=node1{1};
            end

            p2=1;
            if iscell(node2)
                p2=node2{2};
                node2=node2{1};
            end



            if isa(node1,'internal.mtree.Constant')
                node1=this.instantiateConstant(node1);
            end

            hN=node1.Owner;


            assert(strcmp(hN.RefNum,node2.Owner.RefNum),...
            'Trying to connect objects in different PIR networks.');

            if isa(node1,'hdlcoder.port')
                port1=node1;
            else
                port1=node1.PirOutputPorts(p1);
            end

            if isa(node2,'hdlcoder.port')
                port2=node2;
            else
                port2=node2.PirInputPorts(p2);
            end

            sig1=port1.Signal;
            sig2=port2.Signal;

            if~isEqual(sig1.Type,sig2.Type)
                this.resolveMismatchedSignals(sig1,sig2)
            else



                hN.removeSignal(sig2);
                sig1.addReceiver(port2);
            end
        end

        function setSignalName(~,node,name)
            p=1;
            if iscell(node)&&numel(node)==2&&isnumeric(node{2})


                p=node{2};
                node=node{1};
            end


            if isprop(node,'PirOutputSignals')
                node.PirOutputSignals(p).Name=name;
            end
        end

        function isit=isValidIdentifier(~,name)



            isit=~isempty(regexp(name,'^[a-zA-Z]+[a-zA-Z0-9_]*$','once'));
        end

        function vals=setupNewNode(this,description,nodeTypeInfo)
            vals=struct;



            vals.addedNIC=this.beginSubGraph('tmp','',[]);
            vals.hN=vals.addedNIC.ReferenceNetwork;
            vals.description=description;


            for i=1:numel(nodeTypeInfo.Ins)
                inTypeInfo=internal.mtree.NodeTypeInfo([],nodeTypeInfo.Ins(i));
                this.addInput(['In_',num2str(i)],inTypeInfo);
            end
            vals.inSigs=vals.hN.PirInputSignals;


            for i=1:numel(nodeTypeInfo.Outs)
                outTypeInfo=internal.mtree.NodeTypeInfo(nodeTypeInfo.Outs(i),[]);
                this.addOutput(['Out_',num2str(i)],outTypeInfo);
            end
            vals.outSigs=vals.hN.PirOutputSignals;


            vals.typeInfo=nodeTypeInfo;




            vals.allowFlattening=true;



            vals.name='';
        end

        function node=finalizeNewNode(this,innerNode,vals)
            this.endSubGraph;

            newNIC=vals.addedNIC;
            childNetwork=newNIC.ReferenceNetwork;




            newNIC.setShouldDraw(true);
            childNetwork.setShouldDraw(true);
            for i=1:numel(childNetwork.Components)
                childNetwork.Components(i).setShouldDraw(true);


                if~isa(childNetwork.Components(i),'hdlcoder.buffer_comp')
                    childNetwork.Components(i).OrigModelHandle=this.PirOptions.OriginalSLHandle;

                    if~isstruct(vals.description)
                        comments=vals.description;
                    else
                        comments=vals.description.comments;


                        childNetwork.Components(i).setMLFBFile(vals.description.file);
                        childNetwork.Components(i).setMLFBLine(vals.description.line);
                        childNetwork.Components(i).setMLFBCol(vals.description.col);
                    end

                    if~isempty(comments)

                        childNetwork.Components(i).addComment(comments);
                    end
                end
            end

            if vals.allowFlattening&&numel(childNetwork.Components)==1&&...
                numel(childNetwork.Components.PirInputPorts)==numel(newNIC.PirInputSignals)&&...
                numel(childNetwork.Components.PirOutputPorts)==numel(newNIC.PirOutputSignals)





                this.removeNICToBeFlattened(newNIC);

                internal.ml2pir.PIRGraphBuilder.flattenNetwork(newNIC);
                node=innerNode;
            else
                node=newNIC;


                this.NICsToFlatten(childNetwork.RefNum)={node};
            end



            if isa(node,'hdlcoder.port')
                if node.isDriver
                    ports=node;
                else



                    idx=node.PortIndex+1;
                    hN=node.Owner;
                    hNICs=hN.instances;


                    ports=repmat(node,1,numel(hNICs));
                    portsIdx=1;

                    for i=1:numel(hNICs)
                        hNIC=hNICs(i);

                        hOtherN=hNIC.Owner;
                        if~strcmp(hOtherN.RefNum,this.PirOptions.ParentNetwork.RefNum)
                            ports(portsIdx)=hNIC.PirOutputPorts(idx);
                            portsIdx=portsIdx+1;
                        end
                    end

                    ports(portsIdx:end)=[];
                end
            else
                ports=node.PirOutputPorts;



                assert(isempty(vals.name)||numel(ports)==1);
            end

            useProvidedName=this.isValidIdentifier(vals.name);

            for i=1:length(ports)
                port=ports(i);

                if useProvidedName
                    port.Signal.Name=vals.name;
                    port.Name=vals.name;
                else
                    port.Signal.Name=port.Name;
                end
            end
        end




        function[node,vals]=instantiateFromNode(~,vals,tag)
            assert(numel(vals.inSigs)==0&&numel(vals.outSigs)==1);
            node=pirelab.getFromComp(vals.hN,vals.outSigs,tag);
        end


        function[node,vals]=instantiateGotoNode(~,vals,tag)
            assert(numel(vals.inSigs)==1&&numel(vals.outSigs)==0);
            node=pirelab.getGotoComp(vals.hN,vals.inSigs,tag);
        end

        function[node,vals]=instantiateUnitDelayNode(this,vals)
            assert(numel(vals.inSigs)==1&&numel(vals.outSigs)==1,...
            internal.ml2pir.PIRGraphBuilder.INCORRECT_IO_SIGNAL_MSG);

            node=pirelab.getIntDelayComp(vals.hN,vals.inSigs,vals.outSigs,...
            1,'intdelay',0,this.PirOptions.ResetType);
        end

        function[node,vals]=instantiateDelayNode(~,vals,~,delayLength)


            assert(numel(vals.inSigs)==1&&numel(vals.outSigs)==1,...
            internal.ml2pir.PIRGraphBuilder.INCORRECT_IO_SIGNAL_MSG);


            node=pirelab.getWireComp(vals.hN,vals.inSigs,vals.outSigs,...
            ['pipeline_',int2str(delayLength)]);


            node.setInputPipeline(delayLength);
        end

        function[node,vals]=instantiateSumNode(~,vals,~)


            assert(numel(vals.inSigs)==1&&numel(vals.outSigs)==1,...
            internal.ml2pir.PIRGraphBuilder.INCORRECT_IO_SIGNAL_MSG);

            rndMode=vals.typeInfo.getRoundMode;
            satMode=vals.typeInfo.getOverflowMode;
            compName='sum';
            accType=vals.outSigs.Type;
            if accType.isArrayType

                accType=accType.BaseType;
            end
            inputSigns='+';

            node=pirelab.getAddComp(vals.hN,vals.inSigs,vals.outSigs,...
            rndMode,satMode,compName,accType,inputSigns);
        end

        function[node,vals]=instantiateTreeSumNode(~,vals,~)


            assert(numel(vals.inSigs)==1&&numel(vals.outSigs)==1,...
            internal.ml2pir.PIRGraphBuilder.INCORRECT_IO_SIGNAL_MSG);


            opName='sum';
            rndMode=vals.typeInfo.getRoundMode;
            satMode=vals.typeInfo.getOverflowMode;
            compName='treesum';
            minmaxIdxBase='Zero';
            pipeline=false;
            useDetailedElab=true;


            hCInSignals=vals.inSigs;
            hCOutSignals=vals.outSigs;
            hCInPorts=vals.hN.PirInputPorts;
            hCOutPorts=vals.hN.PirOutputPorts;
            nDims=1;


            if hCInSignals(1).Type.is2DMatrix&&numel(hCInSignals)==1
                [hCInSignals,~,hCOutSignals,~,nDims]=splitMatrix2SpecifiedDims(vals.hN,hCInSignals,hCOutSignals,hCInPorts,hCOutPorts);
            end

            function out=needTreeArch(hC,hSignalsIn,hSignalsOut)
                dimLen=max(hSignalsIn(1).Type.getDimensions);
                numOutports=length(hC.PirOutputPorts);
                dimOut=max(hSignalsOut(1).Type.getDimensions);
                out=~(dimLen==1||(dimOut>1&&dimOut==dimLen&&numOutports==1));
            end

            for i=1:nDims
                if needTreeArch(vals.hN,hCInSignals(i),hCOutSignals(i))

                    node=pirelab.getTreeArch(vals.hN,hCInSignals(i),...
                    hCOutSignals(i),opName,rndMode,satMode,...
                    compName,minmaxIdxBase,pipeline,useDetailedElab);
                else
                    node=pirelab.getDTCComp(vals.hN,hCInSignals(i),...
                    hCOutSignals(i),rndMode,satMode);
                end
            end
        end

        function[node,vals]=instantiateProdNode(~,vals,~)
            assert(numel(vals.inSigs)==1&&numel(vals.outSigs)==1,...
            internal.ml2pir.PIRGraphBuilder.INCORRECT_IO_SIGNAL_MSG);

            rndMode=vals.typeInfo.getRoundMode;
            satMode=vals.typeInfo.getOverflowMode;
            compName='prod';
            inputSigns='*';

            node=pirelab.getMulComp(vals.hN,vals.inSigs,vals.outSigs,...
            rndMode,satMode,compName,inputSigns);
        end

        function[node,vals]=instantiateTreeProdNode(~,vals,~)
            assert(numel(vals.inSigs)==1&&numel(vals.outSigs)==1,...
            internal.ml2pir.PIRGraphBuilder.INCORRECT_IO_SIGNAL_MSG);


            opName='product';
            rndMode=vals.typeInfo.getRoundMode;
            satMode=vals.typeInfo.getOverflowMode;
            compName='treeprod';
            minmaxIdxBase='Zero';
            pipeline=false;
            useDetailedElab=true;
            minmaxISDSP=false;
            minmaxOutMode='Value';
            dspMode=int8(0);
            nfpOptions.Latency=int8(0);
            nfpOptions.MantMul=int8(0);
            nfpOptions.Denormals=int8(0);
            prodWordLenMode='SameAsOutput';


            hCInSignals=vals.inSigs;
            hCOutSignals=vals.outSigs;
            hCInPorts=vals.hN.PirInputPorts;
            hCOutPorts=vals.hN.PirOutputPorts;
            nDims=1;


            if hCInSignals(1).Type.is2DMatrix&&numel(hCInSignals)==1
                [hCInSignals,~,hCOutSignals,~,nDims]=splitMatrix2SpecifiedDims(vals.hN,hCInSignals,hCOutSignals,hCInPorts,hCOutPorts);
            end

            function out=needTreeArch(hC,hSignalsIn,hSignalsOut)
                dimLen=max(hSignalsIn(1).Type.getDimensions);
                numOutports=length(hC.PirOutputPorts);
                dimOut=max(hSignalsOut(1).Type.getDimensions);
                out=~(dimLen==1||(dimOut>1&&dimOut==dimLen&&numOutports==1));
            end

            for i=1:nDims
                if needTreeArch(vals.hN,hCInSignals(i),hCOutSignals(i))

                    node=pirelab.getTreeArch(vals.hN,hCInSignals(i),...
                    hCOutSignals(i),opName,rndMode,satMode,...
                    compName,minmaxIdxBase,pipeline,useDetailedElab,...
                    minmaxISDSP,minmaxOutMode,dspMode,nfpOptions,...
                    prodWordLenMode);
                else
                    node=pirelab.getDTCComp(vals.hN,hCInSignals(i),...
                    hCOutSignals(i),rndMode,satMode);
                end
            end
        end

        function[lookupTableComp,vals]=instantiateTableLookupNDNode(this,vals,paramVals)%#ok<INUSL>







            dims=paramVals.dimension;
            powerof2=-9999*ones(1,dims);
            bpType_ex=cell(1,dims);
            bpType_ex(:)={0};
            oType_ex=0;
            fType_ex=0;
            rndMode='Simplest';
            compName='nD Lookup Table';
            satMode='Wrap';
            diagnostics='None';
            extrap=paramVals.extrapolation;
            isEvenSpacing=zeros(1,dims);
            slbh=-1;
            mapToRAM=1;


            nfpOptions.Latency=0;
            nfpOptions.CustomLatency=1;
            nfpOptions.Denormals=0;
            nfpOptions.MantMul=0;
            nfpOptions.PrecomputeCoefficients=false;
            nfpOptions.AreaOptimization=[];

            lookupTableComp=pirelab.getLookupNDComp(vals.hN,vals.inSigs,vals.outSigs,...
            paramVals.tableData,powerof2,bpType_ex,oType_ex,fType_ex,...
            paramVals.interpolation,paramVals.breakPointData,compName,slbh,dims,rndMode,satMode,...
            diagnostics,extrap,isEvenSpacing,nfpOptions,mapToRAM);


            tag=lookupTableComp.getModelGenForNICTag;



            if(vals.typeInfo.Ins.isDouble)
                inputDataType='double';
            else
                inputDataType='single';
            end






            params=cell(1,16+dims*4);

            params(1:16)={'NumberOfTableDimensions',num2str(dims),'ExtrapMethod',paramVals.extrapolation,'InterpMethod',paramVals.interpolation,...
            'Table',sprintf('reshape(%s, %s);',internal.mtree.formatConstValStr(paramVals.tableData(:)),internal.mtree.formatConstValStr(size(paramVals.tableData))),...
            'TableDataTypeStr',inputDataType,'OutDataTypeStr',inputDataType,...
            'IndexSearchMethod','Binary search','DiagnosticForOutOfRangeInput','None'};

            currentInd=17;
            for i=1:dims
                params{currentInd}=strcat('BreakpointsForDimension',num2str(i));
                params{currentInd+1}=internal.mtree.formatConstValStr(paramVals.breakPointData{i});
                params{currentInd+2}=strcat('BreakpointsForDimension',num2str(i),'DataTypeStr');
                params{currentInd+3}=inputDataType;
                currentInd=currentInd+4;
            end

            tag.setLibBlockInfo('hdlsllib/Lookup Tables/n-D Lookup Table',params);
        end


        function[node,vals]=instantiateAddNode(this,vals)
            assert(numel(vals.inSigs)==2&&numel(vals.outSigs)==1);
            vals=this.convertLogical2OutputType(vals);

            rndMode=vals.typeInfo.getRoundMode;
            satMode=vals.typeInfo.getOverflowMode;
            compName='adder';
            accumType=vals.outSigs.Type;

            node=pirelab.getAddComp(vals.hN,vals.inSigs,vals.outSigs,...
            rndMode,satMode,compName,accumType);
        end

        function[node,vals]=instantiateSubNode(this,vals)
            assert(numel(vals.inSigs)==2&&numel(vals.outSigs)==1);
            vals=this.convertLogical2OutputType(vals);

            rndMode=vals.typeInfo.getRoundMode;
            satMode=vals.typeInfo.getOverflowMode;
            compName='subtract';
            accumType=vals.outSigs.Type;
            inputSigns='+-';

            node=pirelab.getAddComp(vals.hN,vals.inSigs,vals.outSigs,...
            rndMode,satMode,compName,accumType,inputSigns);
        end

        function[node,vals]=instantiateGainNode(this,vals,gainAmount,...
            useDotMul,KTimesU)
            assert(numel(vals.inSigs)==1&&numel(vals.outSigs)==1,...
            internal.ml2pir.PIRGraphBuilder.INCORRECT_IO_SIGNAL_MSG);

            vals=this.convertLogical2OutputType(vals);

            if(isa(gainAmount,'internal.mtree.Constant'))
                gainFactor=gainAmount.Value;
            else
                gainFactor=gainAmount;
            end

            if(useDotMul)
                gainMode=1;
            elseif(~KTimesU)
                gainMode=2;
            else
                gainMode=3;
            end

            constMultiplierOptimMode=this.PirOptions.ConstMultiplierOptimization;

            roundMode=vals.typeInfo.getRoundMode;
            satMode=vals.typeInfo.getOverflowMode;

            node=pirelab.getGainComp(vals.hN,vals.inSigs,vals.outSigs,...
            gainFactor,gainMode,constMultiplierOptimMode,roundMode,satMode);
        end

        function[node,vals]=instantiateDotMulNode(this,vals)
            assert(numel(vals.inSigs)==2&&numel(vals.outSigs)==1);
            vals=this.convertLogical2OutputType(vals);

            rndMode=vals.typeInfo.getRoundMode;
            satMode=vals.typeInfo.getOverflowMode;

            node=pirelab.getMulComp(vals.hN,vals.inSigs,vals.outSigs,...
            rndMode,satMode);
        end

        function[node,vals]=instantiateMulNode(~,vals)
            assert(numel(vals.inSigs)==2&&numel(vals.outSigs)==1);
            rndMode=vals.typeInfo.getRoundMode;
            satMode=vals.typeInfo.getOverflowMode;
            compName='multiplier';
            inputSigns='**';
            desc='';
            slbh=-1;
            dspMode=int8(0);
            nfpOptions.Latency=int8(0);
            nfpOptions.MantMul=int8(0);
            nfpOptions.Denormals=int8(0);
            node=pirelab.getMulComp(vals.hN,vals.inSigs,vals.outSigs,...
            rndMode,satMode,compName,inputSigns,desc,slbh,...
            dspMode,nfpOptions,'Matrix(*)');
        end

        function[node,vals]=instantiateDotDivNode(this,vals)
            assert(numel(vals.inSigs)==2&&numel(vals.outSigs)==1);
            vals=this.convertLogical2OutputType(vals);

            rndMode=vals.typeInfo.getRoundMode;
            satMode=vals.typeInfo.getOverflowMode;
            compName='divider';
            inputSigns='*/';

            node=pirelab.getMulComp(vals.hN,vals.inSigs,vals.outSigs,...
            rndMode,satMode,compName,inputSigns);
        end

        function[node,vals]=instantiateUminusNode(this,vals)
            assert(numel(vals.inSigs)==1&&numel(vals.outSigs)==1,...
            internal.ml2pir.PIRGraphBuilder.INCORRECT_IO_SIGNAL_MSG);
            vals=this.convertLogical2OutputType(vals);

            satMode=vals.typeInfo.getOverflowMode;

            node=pirelab.getUnaryMinusComp(vals.hN,vals.inSigs,vals.outSigs,...
            satMode);
        end

        function[node,vals]=instantiateSignNode(~,vals)
            assert(numel(vals.inSigs)==1&&numel(vals.outSigs)==1,...
            internal.ml2pir.PIRGraphBuilder.INCORRECT_IO_SIGNAL_MSG);

            node=pirelab.getSignToNumComp(vals.hN,vals.inSigs,vals.outSigs);
        end

        function[node,vals]=instantiateDTCNode(~,vals)
            assert(numel(vals.inSigs)==1&&numel(vals.outSigs)==1,...
            internal.ml2pir.PIRGraphBuilder.INCORRECT_IO_SIGNAL_MSG);

            roundMode=vals.typeInfo.getRoundMode;
            satMode=vals.typeInfo.getOverflowMode;
            conversionMode='RWV';

            node=pirelab.getDTCComp(vals.hN,vals.inSigs,vals.outSigs,...
            roundMode,satMode,conversionMode);
        end

        function[node,vals]=instantiateReinterpretNode(~,vals)
            assert(numel(vals.inSigs)==1&&numel(vals.outSigs)==1,...
            internal.ml2pir.PIRGraphBuilder.INCORRECT_IO_SIGNAL_MSG);

            roundMode='Floor';
            satMode='Wrap';
            conversionMode='SI';

            node=pirelab.getDTCComp(vals.hN,vals.inSigs,vals.outSigs,...
            roundMode,satMode,conversionMode);
        end

        function[node,vals]=instantiateBitsetNode(~,vals,bitIdx,toVal)
            assert(numel(vals.inSigs)==1&&numel(vals.outSigs)==1,...
            internal.ml2pir.PIRGraphBuilder.INCORRECT_IO_SIGNAL_MSG);
            node=pirelab.getBitSetComp(vals.hN,vals.inSigs,vals.outSigs,...
            toVal,bitIdx);
        end

        function[node,vals]=instantiateAbsNode(~,vals)
            assert(numel(vals.inSigs)==1&&numel(vals.outSigs)==1,...
            internal.ml2pir.PIRGraphBuilder.INCORRECT_IO_SIGNAL_MSG);

            roundingMode=vals.typeInfo.getRoundMode;
            satMode=vals.typeInfo.getOverflowMode;

            node=pirelab.getAbsComp(vals.hN,vals.inSigs,vals.outSigs,...
            roundingMode,satMode);
        end

        function[node,vals]=instantiateSqrtNode(~,vals)
            assert(numel(vals.inSigs)==1&&numel(vals.outSigs)==1,...
            internal.ml2pir.PIRGraphBuilder.INCORRECT_IO_SIGNAL_MSG);

            compName='sqrt';
            slbh=-1;
            fname='sqrt';

            node=pirelab.getSqrtComp(vals.hN,vals.inSigs,vals.outSigs,...
            compName,slbh,fname);
        end

        function[node,vals]=instantiateMinMaxNode(~,vals,fcn)
            assert((numel(vals.inSigs)==2||numel(vals.inSigs)==1)...
            &&numel(vals.outSigs)==1);

            compName=fcn;
            opName=fcn;

            if numel(vals.inSigs)==2
                node=pirelab.getMinMaxComp(vals.hN,vals.inSigs,vals.outSigs,...
                compName,opName);
            else

                useDetailedElab=true;
                pipeline=false;
                rndMode=vals.typeInfo.getRoundMode;
                satMode=vals.typeInfo.getOverflowMode;
                node=hdlarch.tree.getTreeArch(vals.hN,vals.inSigs,vals.outSigs,...
                opName,rndMode,satMode,compName,'One',pipeline,...
                useDetailedElab,false,'Value');
            end
        end

        function[node,vals]=instantiateCordicTrigNode(~,vals,fcnName,iterNum)

            hdldriver=hdlcurrentdriver;
            vals.usePipelines=hdldriver.getParameter('UsePipelinedToolboxFunctions');


            vals.fName=strrep(fcnName,'cordic','');


            inputWL=vals.inSigs(1).Type.BaseType.WordLength;
            vals.cordicInfo=hdldefaults.Cordic.getSinCosCordicInfo(iterNum,fcnName,inputWL);


            latencyStrategy='MAX';
            customLatency=0;
            node=pirelab.getSinCosCordicComp(vals.hN,vals.inSigs,vals.outSigs,...
            vals.cordicInfo,vals.fName,vals.usePipelines,customLatency,...
            latencyStrategy,fcnName);


            if vals.usePipelines
                delay=vals.cordicInfo.iterNum+1;
                node.addOutputDelay(delay);
            end
        end

        function postFinalizeCordicTrigNode(~,node,vals)

            switch vals.fName
            case 'sin'
                cordicType=0;
            case 'cos'
                cordicType=1;
            case 'sincos'
                cordicType=2;
            otherwise


                cordicType=-1;
            end

            assert(cordicType~=-1,['Unsupported CORDIC function: ',vals.fName]);


            node.setSyntheticCordicBlock(cordicType,vals.cordicInfo.iterNum,vals.usePipelines);
        end

        function[node,vals]=instantiateTrigNode(~,vals,fcn)
            oneOpFunctions=...
            {'sin','cos','tan','acos','asin','atan',...
            'sinh','cosh','tanh','asinh','acosh','atanh'};
            twoOpFunctions={'atan2'};

            assert((ismember(fcn,oneOpFunctions)&&numel(vals.inSigs)==1)||...
            (ismember(fcn,twoOpFunctions)&&numel(vals.inSigs)==2),...
            ['cannot build ',fcn,' yet.']);
            assert(numel(vals.outSigs)==1)

            compName=fcn;
            slbh=-1;
            fname=fcn;

            node=pirelab.getTrigonometricComp(vals.hN,vals.inSigs,vals.outSigs,...
            compName,slbh,fname);
        end

        function[node,vals]=instantiateMathNode(~,vals,fcn)
            oneOpFunctions={'10^u','exp','hermitian','log','log10'...
            ,'square','reciprocal','transpose','conj'};
            twoOpFunctions={'mod','pow','rem','hypot'};

            assert((ismember(fcn,oneOpFunctions)&&numel(vals.inSigs)==1)||...
            (ismember(fcn,twoOpFunctions)&&numel(vals.inSigs)==2),...
            ['Cannot build ',fcn,' yet.']);
            assert(numel(vals.outSigs)==1)

            switch fcn
            case 'conj'
                rndMode=vals.typeInfo.getRoundMode;
                satMode=vals.typeInfo.getOverflowMode;
                compName='conj';

                node=pirelab.getComplexConjugateComp(...
                vals.hN,-1,vals.inSigs,vals.outSigs,...
                satMode,compName,rndMode);

            case 'hermitian'
                satMode=vals.typeInfo.getOverflowMode;
                compName='hermitian';

                if vals.typeInfo.Outs.Complex
                    outSigType='complex';
                else
                    outSigType='real';
                end

                if vals.typeInfo.Ins.isFi&&~vals.typeInfo.Ins.isSigned
                    node=pirelab.getTransposeComp(vals.hN,vals.inSigs,vals.outSigs);
                else
                    node=pirelab.getHermitianComp(vals.hN,vals.inSigs,vals.outSigs,...
                    satMode,compName,outSigType);
                end

            case 'square'
                rndMode=vals.typeInfo.getRoundMode;
                satMode=vals.typeInfo.getOverflowMode;
                compName='square';

                node=pirelab.getMulComp(vals.hN,[vals.inSigs,vals.inSigs],vals.outSigs,...
                rndMode,satMode,compName);

            case 'transpose'
                node=pirelab.getTransposeComp(vals.hN,vals.inSigs,vals.outSigs);

            otherwise
                compName=fcn;
                slbh=-1;
                fname=fcn;

                node=pirelab.getMathComp(vals.hN,vals.inSigs,vals.outSigs,...
                compName,slbh,fname);
            end
        end


        function[node,vals]=instantiateBitsliceNode(~,vals,leftIdx,rightIdx)
            assert(numel(vals.inSigs)==1&&numel(vals.outSigs)==1,...
            internal.ml2pir.PIRGraphBuilder.INCORRECT_IO_SIGNAL_MSG)
            node=pirelab.getBitSliceComp(vals.hN,vals.inSigs,vals.outSigs,...
            leftIdx,rightIdx);
        end

        function[node,vals]=instantiateBitshiftNode(~,vals,kind,shiftBy)
            assert(numel(vals.inSigs)==1&&numel(vals.outSigs)==1,...
            internal.ml2pir.PIRGraphBuilder.INCORRECT_IO_SIGNAL_MSG)
            node=pirelab.getBitShiftComp(vals.hN,vals.inSigs,vals.outSigs,...
            kind(4:end),shiftBy);
        end

        function[node,vals]=instantiateBitReduceNode(~,vals,kind)
            assert(numel(vals.inSigs)==1&&numel(vals.outSigs)==1,...
            internal.ml2pir.PIRGraphBuilder.INCORRECT_IO_SIGNAL_MSG);
            switch kind
            case 'bitandreduce'
                reductionMode='AND';
            case 'bitorreduce'
                reductionMode='OR';
            case 'bitxorreduce'
                reductionMode='XOR';
            otherwise
                error(['unsupported bit reduce: ',kind]);
            end
            node=pirelab.getBitReduceComp(vals.hN,vals.inSigs,vals.outSigs,...
            reductionMode);
        end

        function[node,vals]=instantiateBitRotNode(~,vals,kind,shiftAmount)
            assert(numel(vals.inSigs)==1&&numel(vals.outSigs)==1,...
            internal.ml2pir.PIRGraphBuilder.INCORRECT_IO_SIGNAL_MSG)

            switch lower(kind)


            case 'bitrol'
                kind='Rotate Left';
            case 'bitror'
                kind='Rotate Right';
            otherwise
                assert(false);
            end

            node=pirelab.getBitRotateComp(vals.hN,vals.inSigs,vals.outSigs,...
            kind,shiftAmount.Value);
        end

        function[node,vals]=instantiateVarArithShiftNode(~,vals,direction)
            assert(numel(vals.inSigs)==2&&numel(vals.outSigs)==1)
            node=pirelab.getDynamicBitShiftComp(vals.hN,vals.inSigs,vals.outSigs,...
            lower(direction),'dynamic_shift',true);
        end


        function[node,vals]=instantiateBitconcatNode(~,vals)
            assert((numel(vals.inSigs)==2||...
            (numel(vals.inSigs)==1&&vals.inSigs.Type.isArrayType))...
            &&numel(vals.outSigs)==1)
            node=pirelab.getBitConcatComp(vals.hN,vals.inSigs,vals.outSigs);
        end

        function[node,vals]=instantiateInstantiatedConstantNode(this,vals,value)
            assert(numel(vals.inSigs)==0&&numel(vals.outSigs)==1)

            if ischar(value)
                value=eval(value);
            end

            if isa(value,'struct')



                fieldNames=fieldnames(value);
                nFields=numel(fieldNames);



                inSignals=cell(1,nFields);
                for i=1:nFields





                    const=internal.mtree.Constant([],value.(fieldNames{i}),fieldNames{i});
                    constNode=this.instantiateConstant(const);



                    inSignals{i}=constNode.PirOutputSignals;
                end

                if numel(value)>1



















                else

                    node=pirelab.getBusCreatorComp(vals.hN,inSignals,vals.outSigs,'','off');
                end
            else

                node=pirelab.getConstComp(vals.hN,vals.outSigs,value,'const',...
                'off');
            end
        end

        function[node,vals]=instantiateTunableConstantNode(~,vals,name)
            assert(numel(vals.inSigs)==0&&numel(vals.outSigs)==1,...
            internal.ml2pir.PIRGraphBuilder.INCORRECT_IO_SIGNAL_MSG);

            value=vals.typeInfo.Outs.getExampleValue;

            node=pirelab.getConstComp(vals.hN,vals.outSigs,...
            value,name,...
            false,...
            false,...
            name);
        end

        function[node,vals]=instantiateRelOpNode(~,vals,kind)
            assert(numel(vals.inSigs)==2&&numel(vals.outSigs)==1)
            node=pirelab.getRelOpComp(vals.hN,vals.inSigs,vals.outSigs,...
            kind);
        end

        function[node,vals]=instantiateFloatRelOpNode(~,vals,fcn)
            assert(numel(vals.inSigs)==1&&numel(vals.outSigs)==1)
            node=pirelab.getRelOpComp(vals.hN,vals.inSigs,vals.outSigs,...
            fcn);
        end

        function[node,vals]=instantiateCompareToConstantNode(~,vals,kind,value)
            assert(numel(vals.inSigs)==1&&numel(vals.outSigs)==1,...
            internal.ml2pir.PIRGraphBuilder.INCORRECT_IO_SIGNAL_MSG)
            node=pirelab.getCompareToValueComp(vals.hN,vals.inSigs,vals.outSigs,...
            kind,value);
        end

        function[node,vals]=instantiateLogicOpNode(~,vals,kind)


            assert((numel(vals.inSigs)==2||numel(vals.inSigs)==1)&&numel(vals.outSigs)==1)

            switch lower(kind)
            case '&&'
                opName='and';
            case '||'
                opName='or';
            case '~'
                opName='not';
            case 'xor'
                opName='xor';
            otherwise
                assert(false,(['LOGICOPNODE: invalid op name: ',kind]));
            end

            node=pirelab.getLogicComp(vals.hN,vals.inSigs,vals.outSigs,opName);
        end

        function[node,vals]=instantiateBitwiseOpNode(~,vals,kind)
            assert((strcmp(kind,'bitcomp')&&numel(vals.inSigs)==1)||...
            (ismember(kind,{'bitand','bitor','bitxor'})&&numel(vals.inSigs)==2))
            assert(numel(vals.outSigs)==1)
            if strcmp(kind,'bitcomp')
                assert(logical(vals.inSigs.Type.isEqual(vals.outSigs.Type)),...
                'In and out types not equivalent for bitcomp')
            end

            switch kind
            case 'bitand'
                opName='AND';
            case 'bitor'
                opName='OR';
            case 'bitcomp'
                opName='NOT';
            case 'bitxor'
                opName='XOR';
            otherwise
                assert(false,['BITWISEOPNODE: invalid op name: ',kind]);
            end

            node=pirelab.getBitwiseOpComp(vals.hN,vals.inSigs,vals.outSigs,opName);
        end

        function[node,vals]=instantiateDotExpNode(~,vals)
            assert(numel(vals.inSigs)==2&&numel(vals.outSigs)==1);
            node=pirelab.getMathComp(vals.hN,vals.inSigs,vals.outSigs,...
            'pow',...
            -1,...
            'pow');
        end

        function[node,vals]=instantiateRealImagToComplexNode(~,vals,mode,constPart)

            assert((numel(vals.inSigs)==2||numel(vals.inSigs)==1)&&numel(vals.outSigs)==1);


            if(isa(constPart,'internal.mtree.Constant'))
                constPart=constPart.Value;
            end

            if vals.typeInfo.Outs.isFi
                rndMode=vals.typeInfo.Outs.Fimath.RoundingMethod;
                satMode=vals.typeInfo.Outs.Fimath.OverflowMode;
            else
                rndMode='Nearest';
                satMode='wrap';
            end



            node=pirelab.getRealImag2Complex(vals.hN,vals.inSigs,...
            vals.outSigs,mode,constPart,'ri2c',rndMode,satMode);
        end

        function[node,vals]=instantiateComplexToRealImagNode(~,vals,mode)


            assert(numel(vals.inSigs)==1&&numel(vals.outSigs)==1,...
            internal.ml2pir.PIRGraphBuilder.INCORRECT_IO_SIGNAL_MSG);
            node=pirelab.getComplex2RealImag(vals.hN,vals.inSigs,...
            vals.outSigs,mode);
        end


        function[node,vals]=instantiateSwitchNode(~,vals,kind,threshold)
            assert(numel(vals.inSigs)==3&&numel(vals.outSigs)==1);

            switch kind
            case 'u2 ~= 0'
                threshold=0;
                operator='~=';
            case 'u2 > Threshold'
                operator='>';
            case 'u2 >= Threshold'
                operator='>=';
            end




            inSignals=[vals.inSigs(1),vals.inSigs(3)];
            outSignals=vals.outSigs;
            selSignal=vals.inSigs(2);
            compName='switch';
            compareStr=operator;
            compareVal=threshold;

            node=pirelab.getSwitchComp(vals.hN,...
            inSignals,outSignals,selSignal,compName,...
            compareStr,compareVal);
        end

        function[node,vals]=instantiateMultiportSwitchNode(~,vals,inputmode,dpOrder)
            assert(numel(vals.inSigs)>1&&numel(vals.outSigs)==1);

            inSignals=vals.inSigs;
            outSignals=vals.outSigs;
            node=pirelab.getMultiPortSwitchComp(vals.hN,inSignals,outSignals,...
            inputmode,dpOrder);
        end


        function[node,vals]=instantiateReshapeNode(~,vals)
            assert(numel(vals.inSigs)==1&&numel(vals.outSigs)==1,...
            internal.ml2pir.PIRGraphBuilder.INCORRECT_IO_SIGNAL_MSG)

            node=pirelab.getReshapeComp(vals.hN,vals.inSigs,vals.outSigs);
        end

        function[node,vals]=instantiateSubscrNode(this,vals,indexArray,isConditional)
            assert(numel(vals.inSigs)>=1&&numel(vals.outSigs)==1)

            if vals.inSigs(1).type.isArrayType||vals.outSigs(1).type.isArrayType

                dimNumber=numel(indexArray);

                indexMode='One-based';
                [indexOptionArray,indexParamArray]=this.getIndexOptionArrays(indexArray,false);


                outputSizeArray=repmat({0},1,dimNumber);
                numDims=num2str(dimNumber);

                node=pirelab.getSelectorComp(vals.hN,vals.inSigs,vals.outSigs,...
                indexMode,indexOptionArray,indexParamArray,outputSizeArray,numDims);
                if isConditional
                    node.setIsInConditionalBranch;
                end
            else

                node=pirelab.getWireComp(vals.hN,vals.inSigs(1),vals.outSigs,'Selector');
            end
        end

        function[node,vals]=instantiateSubassignNode(this,vals,indexArray,isConditional)
            assert(numel(vals.inSigs)>=2&&numel(vals.outSigs)==1)

            if vals.inSigs(1).type.isArrayType

                dimNumber=numel(indexArray);

                indexMode='One-based';
                [indexOptionArray,indexParamArray]=this.getIndexOptionArrays(indexArray,true);


                outputSizeArray=repmat({0},1,dimNumber);
                numDims=num2str(dimNumber);

                node=pirelab.getAssignmentComp(vals.hN,vals.inSigs,vals.outSigs,...
                indexMode,indexOptionArray,indexParamArray,outputSizeArray,numDims);
                if isConditional
                    node.setIsInConditionalBranch;
                end
            else


                node=pirelab.getWireComp(vals.hN,vals.inSigs(2),vals.outSigs,'Assignment');
            end
        end


        function[node,vals]=instantiateArrayConcatNode(~,vals,concatDimension)
            assert(numel(vals.outSigs)==1);

            outType=vals.outSigs.Type;
            inputsAllBool=all(arrayfun(@(x)x.Type.isBooleanType,vals.inSigs));

            if outType.is2DMatrix

                mode='Multidimensional array';
            elseif outType.isArrayType&&(outType.isRowVector||outType.isColumnVector)&&...
                ~inputsAllBool



                mode='Multidimensional array';
            else

                mode='Vector';
            end

            node=pirelab.getConcatenateComp(vals.hN,vals.inSigs,vals.outSigs,...
            mode,concatDimension);
        end

        function[node,vals]=instantiateRoundingNode(~,vals,fcn)
            assert(numel(vals.inSigs)==1&&numel(vals.outSigs)==1,...
            internal.ml2pir.PIRGraphBuilder.INCORRECT_IO_SIGNAL_MSG)


            if vals.typeInfo.Ins.isFloat
                node=pirelab.getRoundingFunctionComp(vals.hN,vals.inSigs,...
                vals.outSigs,fcn);
            elseif vals.typeInfo.Ins.isFi
                if strcmp(fcn,'fix')


                    roundMode='zero';
                else
                    roundMode=fcn;
                end

                satMode=vals.typeInfo.getOverflowMode;
                conversionMode='RWV';

                node=pirelab.getDTCComp(vals.hN,vals.inSigs,vals.outSigs,...
                roundMode,satMode,conversionMode);
            else
                error('rounding methods only supported for float or fi arguments');
            end
        end

        function[sysComp,vals]=instantiatePIRSystemObjectNode(~,vals,sysObjInstance)




            hN=vals.hN;
            numIns=1;
            for ii=1:numel(vals.typeInfo.Ins)
                if vals.typeInfo.Ins(ii).isStructType
                    fields=vals.typeInfo.Ins(ii).getFieldNames;
                    for jj=1:numel(fields)
                        type=vals.inSigs(ii).Type.MemberTypes(jj);
                        newInSigs(numIns)=hN.addSignal(type,['InElem',num2str(jj)]);%#ok<AGROW>
                        pirelab.getBusSelectorComp(hN,vals.inSigs(ii),newInSigs(numIns),fields{jj});
                        numIns=numIns+1;
                    end
                else
                    newInSigs(numIns)=vals.inSigs(ii);
                    numIns=numIns+1;
                end
            end
            numOuts=1;
            for ii=1:numel(vals.typeInfo.Outs)
                if vals.typeInfo.Outs(ii).isStructType
                    fields=vals.typeInfo.Outs(ii).getFieldNames;
                    for jj=1:numel(fields)
                        type=vals.outSigs(ii).Type.MemberTypes(jj);
                        newOutSigs(numOuts)=hN.addSignal(type,['OutElem',num2str(jj)]);%#ok<AGROW>
                        newBusIns(jj)=newOutSigs(numOuts);%#ok<AGROW>
                        numOuts=numOuts+1;
                    end
                    pirelab.getBusCreatorComp(vals.hN,newBusIns(1:numel(fields)),...
                    vals.outSigs(ii),'','off');
                else
                    newOutSigs(numOuts)=vals.outSigs(ii);
                    numOuts=numOuts+1;
                end
            end
            sysComp=hN.addComponent2('kind','sysobj_comp',...
            'InputSignals',newInSigs,...
            'OutputSignals',newOutSigs);
            if isa(sysObjInstance,'dsp.Delay')
                setup(sysObjInstance,vals.typeInfo.Ins(1).getExampleValue);
                reset(sysObjInstance);
            end
            sysComp.setSysObjImpl(sysObjInstance);
        end

        function[node,vals]=instantiateBusSelectorNode(~,vals,busElementName)

            assert(numel(vals.inSigs)==1&&numel(vals.outSigs)==1);


            node=pirelab.getBusSelectorComp(vals.hN,vals.inSigs,vals.outSigs,busElementName);
        end

        function[node,vals]=instantiateBusCreatorNode(~,vals,busObject)%#ok<INUSD>


            node=pirelab.getBusCreatorComp(vals.hN,vals.inSigs,vals.outSigs,'','off');
        end

        function[node,vals]=instantiateBusAssignmentNode(~,vals,busElementName)

            assert(numel(vals.inSigs)==2&&numel(vals.outSigs)==1);


            node=pirelab.getBusAssignmentComp(vals.hN,vals.inSigs,vals.outSigs,busElementName);
        end

        function[node,vals]=instantiateBusConcatenateNode(~,vals)
            assert(numel(vals.outSigs)==1);

            node=pirelab.getConcatenateComp(vals.hN,vals.inSigs,vals.outSigs,...
            'Vector','1');
        end

        function[node,vals]=instantiateNoopNode(~,vals)
            assert(numel(vals.inSigs)==numel(vals.outSigs)&&numel(vals.inSigs)>=1);

            for ii=1:numel(vals.inSigs)
                node=pirelab.getWireComp(vals.hN,vals.inSigs(ii),vals.outSigs(ii));
            end

        end

        function[node,vals]=instantiateCounterNode(~,vals,start,step,stop)
            assert(numel(vals.inSigs)==0&&numel(vals.outSigs)==1);

            outType=vals.typeInfo.Outs;
            assert(outType.isFi||outType.isInt);

            type='Count limited';
            resetport=false;
            loadport=false;
            enbport=false;
            dirport=false;
            compName='iterator';
            countFrom=start;

            node=pirelab.getCounterComp(vals.hN,vals.inSigs,vals.outSigs,...
            type,start,step,stop,...
            resetport,loadport,enbport,dirport,...
            compName,countFrom);
        end



        function val=generateSourceCodeComments(this)
            val=this.PirOptions.SourceCodeComments;
        end

        function val=generateTraceability(this)
            val=this.PirOptions.Traceability;
        end

        function traceCmt=getNodeTraceability(this,node)
            if isempty(this.TraceCmtOverride)
                traceCmt=strcat('''',this.TraceCmtPrefix,int2str(node.lineno),'''');
            else
                traceCmt=this.TraceCmtOverride;
            end
        end

        function setNodeTraceabilityOverride(this,overrideStr)
            this.TraceCmtOverride=overrideStr;
        end

        function traceCmt=getNodeTraceabilityOverride(this)
            traceCmt=this.TraceCmtOverride;
        end

        function val=generateUserComments(this)
            val=this.PirOptions.UserComments;
        end

        function setUserCommentForFunction(this,comment)
            hN=this.getCurrentNetwork;
            hN.addComment(comment);
        end

        function setInliningForCurrentFunction(this,inlineOpt)
            hNIC=this.getCurrentSubGraphNode;
            hN=this.getCurrentNetwork;



            isCurrSubFunc=~strcmp(hN.RefNum,this.Network.RefNum);
            switch inlineOpt
            case 0

                if isCurrSubFunc
                    this.addNICToBeFlattened(hNIC);
                else
                    this.Network.setFlattenHierarchy('on');
                end
            case 1

                if isCurrSubFunc
                    this.removeNICToBeFlattened(hNIC);


                    hNIC.ReferenceNetwork.setFlattenHierarchy('off');
                else
                    this.Network.setFlattenHierarchy('off');
                end
            case 2





                if isCurrSubFunc
                    hNIC.ReferenceNetwork.setFlattenHierarchy('inherit');
                else


                end
            otherwise
                error('unknown option provided for inlining');
            end
        end

    end

    methods(Abstract,Access=protected)

        traceCmtPrefix=createTraceCmtPrefix(this);
    end

    methods(Access=protected)

        function hN=getCurrentNetwork(this)
            assert(~isempty(this.CurrentSubGraph))
            hN=this.CurrentSubGraph(end).Network;
        end



        function fullPath=getRootPath(this,name)
            parentNetwork=this.PirOptions.ParentNetwork;
            fullPath=[parentNetwork.fullPath,'/',name];
        end

        function hNewN=createNewNetwork(this,name)
            if isempty(this.CurrentSubGraph)
                fullPath=this.getRootPath(name);
            else
                hN=this.getCurrentNetwork;
                fullPath=[hN.FullPath,'/',name];
            end

            hNewN=pirelab.createNewNetwork('Name',name);
            hNewN.FullPath=fullPath;
            hNewN.SimulinkHandle=-1;
            hNewN.renderCodegenPir(true);
            hNewN.generateModelFromPir;
        end

        function hNIC=instantiateNetwork(this,dstNetwork,hN)


            hNIC=pirelab.instantiateNetwork(dstNetwork,hN,[],[],'tmp');


            if~this.PirOptions.InstantiateFunctions


                this.addNICToBeFlattened(hNIC);
            else


                hNIC.ReferenceNetwork.setFlattenHierarchy('off')
            end




            for i=1:numel(hN.PirInputPorts)
                newInSig=dstNetwork.addSignal(hN.PirInputSignals(i));
                newInSig.addReceiver(hNIC.PirInputPorts(i));
            end


            for j=1:numel(hN.PirOutputPorts)
                newOutSig=dstNetwork.addSignal(hN.PirOutputSignals(j));
                newOutSig.addDriver(hNIC.PirOutputPorts(j));
            end
        end

        function hFIC=instantiateStreamedNetwork(this,dstNetwork,hN,streamInfo)


            assert(~hN.hasForIterDataTag&&numel(hN.PirInputPorts)==0&&...
            numel(hN.PirOutputPorts)==0);


            hCounterComp=this.createCounterNode(...
            streamInfo.idxDesc,...
            internal.mtree.NodeTypeInfo([],streamInfo.iterType),...
            streamInfo.idxName,...
            streamInfo.start,...
            streamInfo.step,...
            streamInfo.stop);
            assert(isa(hCounterComp,'hdlcoder.hdlcounter_comp'));



            fidt=hN.getForIterDataTag;
            fidt.setIterations(streamInfo.iterations);
            fidt.setIterationCounter(hCounterComp);
            fidt.setResetStates(false);
            fidt.setIsFromML2PIR(true);
            fidt.setLocation(streamInfo.location);

            hFIC=dstNetwork.addComponent('for_iter_comp',hN);

            this.CurrentSubGraph(end).NIC=hFIC;

            streamInfo.iterNode=hCounterComp;
        end

        function hNPUComp=instantiateNPUNetwork(this,dstNetwork,hN,npuInfo)
            if hN.hasNPUDataTag


                npudt=hN.getNPUDataTag;

                streamedArgsMatch=true;
                for i=1:numel(hN.PirInputPorts)
                    streamedArgsMatch=npudt.isStreamedInput(i-1)==...
                    ismember(i,npuInfo.GraphStreamedIdxs);

                    if~streamedArgsMatch
                        break;
                    end
                end

                assert(...
                npudt.getKernelRows==npuInfo.KernelSize(1)&&...
                npudt.getKernelCols==npuInfo.KernelSize(2)&&...
                npudt.getImageRows==npuInfo.ImageSize(1)&&...
                npudt.getImageCols==npuInfo.ImageSize(2)&&...
                strcmp(npudt.getBoundaryMethod,npuInfo.BoundaryMethod)&&...
                npudt.getBoundaryConstantValue==npuInfo.BoundaryConst&&...
                streamedArgsMatch);
            else
                npudt=hN.getNPUDataTag;

                npudt.setKernelRows(npuInfo.KernelSize(1));
                npudt.setKernelCols(npuInfo.KernelSize(2));
                npudt.setImageRows(npuInfo.ImageSize(1));
                npudt.setImageCols(npuInfo.ImageSize(2));
                npudt.setBoundaryMethod(npuInfo.BoundaryMethod);
                npudt.setBoundaryConstantValue(npuInfo.BoundaryConst);

                for i=npuInfo.GraphStreamedIdxs
                    npudt.setStreamedInput(i-1);
                end
            end

            hNPUComp=dstNetwork.addComponent('npu_comp',hN);




            for i=1:numel(hN.PirInputPorts)
                inType=internal.mtree.Type.fromPIRType(hN.PirInputSignals(i).Type);
                inType.setDimensions(npuInfo.ImageSize);
                newInSig=this.getSignalsFromTypes(dstNetwork,inType);
                newInSig.addReceiver(hNPUComp.PirInputPorts(i));
            end

            for j=1:numel(hN.PirOutputPorts)
                outType=internal.mtree.Type.fromPIRType(hN.PirOutputSignals(j).Type);
                outType.setDimensions(npuInfo.ImageSize);
                newOutSig=this.getSignalsFromTypes(dstNetwork,outType);
                newOutSig.addDriver(hNPUComp.PirOutputPorts(j));
            end
        end

        function hIteratorComp=instantiateIteratorFunNetwork(this,dstNetwork,hN,iteratorInfo)
            tag=hN.getForIterDataTag;
            tag.setImageSize(iteratorInfo.ImageSize);
            tag.setOutputSize(iteratorInfo.OutputSize);
            tag.setLocation(iteratorInfo.CalleeFcnInfo.scriptPath);
            tag.setIsFromML2PIR(true);

            hIteratorComp=pirelab.instantiateNetwork(dstNetwork,hN,[],[],'iterator');

            for i=1:numel(hN.PirInputPorts)
                inType=internal.mtree.Type.fromPIRType(hN.PirInputSignals(i).Type);
                if i==1
                    inType.setDimensions(iteratorInfo.ImageSize);
                end
                newInSig=this.getSignalsFromTypes(dstNetwork,inType);
                newInSig.addReceiver(hIteratorComp.PirInputPorts(i));
            end

            for j=1:numel(hN.PirOutputPorts)
                outType=internal.mtree.Type.fromPIRType(hN.PirOutputSignals(j).Type);
                newOutSig=this.getSignalsFromTypes(dstNetwork,outType);
                newOutSig.addDriver(hIteratorComp.PirOutputPorts(j));
            end

            this.CurrentSubGraph(end).NIC=hIteratorComp;
        end


        function addNICToBeFlattened(this,hNIC)


            if isa(hNIC,'hdlcoder.ntwk_instance_comp')
                hRefNtwk=hNIC.ReferenceNetwork;
                refNtwkID=hRefNtwk.RefNum;

                if this.NICsToFlatten.isKey(refNtwkID)
                    if~any(cellfun(@(x)x==hNIC,this.NICsToFlatten(refNtwkID)))


                        oldVal=this.NICsToFlatten(refNtwkID);
                        newVal=[oldVal,{hNIC}];
                        this.NICsToFlatten(refNtwkID)=newVal;
                    end
                else


                    this.NICsToFlatten(refNtwkID)={hNIC};
                end
            end
        end

        function removeNICToBeFlattened(this,hNIC)
            hRefNtwk=hNIC.ReferenceNetwork;
            refNtwkID=hRefNtwk.RefNum;

            if this.NICsToFlatten.isKey(refNtwkID)


                oldVal=this.NICsToFlatten(refNtwkID);
                nicIndexing=cellfun(@(x)x~=hNIC,this.NICsToFlatten(refNtwkID));
                if iscell(nicIndexing)
                    nicIndexing=cell2mat(nicIndexing);
                end
                newVal=oldVal(nicIndexing);
                if isempty(newVal)


                    this.NICsToFlatten.remove(refNtwkID);
                else


                    this.NICsToFlatten(refNtwkID)=newVal;
                end
            end
        end

        function sigArray=getSignalsFromTypes(this,hN,types)
            numSigs=numel(types);

            if numSigs==0
                sigArray=[];
            else

                for i=numSigs:-1:1
                    sig=hN.addSignal;
                    sig.SimulinkHandle=0;
                    sig.SimulinkRate=this.PirOptions.SLRate;

                    ml2dfType=types(i);
                    sig.Type=ml2dfType.toPIRType;

                    sigArray(i)=sig;
                end
            end
        end

        function val=resolveWithParentNtwk(this,localSetting)
            if strcmpi(localSetting,'inherit')
                st=dbstack(1);

                onFunc=st(1).name;


                ntwkCall=onFunc(regexp(onFunc,'[^.]*$'):end);
                ntwk=this.PirOptions.ParentNetwork;%#ok<NASGU>

                val=eval([ntwkCall,'(ntwk)']);
            else
                val=localSetting;
            end
        end

        function resolveMismatchedSignals(~,sig1,sig2)
            if sig1.Type.isArrayType&&sig2.Type.isArrayType&&...
                all(sig1.Type.Dimensions==sig2.Type.Dimensions)


                pirelab.getReshapeComp(sig1.Owner,sig1,sig2);
            elseif~sig1.Type.isArrayType&&sig2.Type.isArrayType&&...
                isEqual(sig1.Type,sig2.Type.BaseType)

                outDim=sig2.Type.Dimensions;
                numElements=prod(outDim);

                vecOut=pirelab.scalarExpand(sig1.Owner,sig1,numElements);

                pirelab.getReshapeComp(sig1.Owner,vecOut,sig2);
            elseif sig1.Type.isArrayType&&sig2.Type.isArrayType&&...
                prod(sig1.Type.Dimensions)==prod(sig2.Type.Dimensions)





                pirelab.getReshapeComp(sig1.Owner,sig1,sig2);
            else


                error('Unequal types found while connecting two signals');
            end
        end

        function vals=convertLogical2OutputType(~,vals)



            if numel(vals.typeInfo.Outs)==1&&...
                ~all(arrayfun(@(x)x.isLogical,vals.typeInfo.Outs))


                for ii=1:numel(vals.typeInfo.Ins)
                    if vals.typeInfo.Ins(ii).isLogical
                        rndMode=vals.typeInfo.getRoundMode;
                        satMode=vals.typeInfo.getOverflowMode;
                        dtctype=vals.outSigs.Type;
                        vals.inSigs(ii)=pirelab.insertDTCCompOnInput(...
                        vals.hN,vals.inSigs(ii),dtctype,rndMode,satMode);

                        type=internal.mtree.Type.makeType(vals.typeInfo.Outs.getMLName,1);
                        vals.typeInfo.Ins(ii)=type;
                    end
                end
            end
        end





        function val=getHardwareMode(this)




            val=this.PirOptions.AdaptivePipelining;
        end

        function val=getDelayBalancing(this)

            val=this.resolveWithParentNtwk(this.PirOptions.BalanceDelays);
        end

        function val=getLocalClockRatePipelining(this)

            val=this.resolveWithParentNtwk(this.PirOptions.ClockRatePipelining);
        end

        function val=getConstrainedOutputPipeline(this)
            val=this.PirOptions.ConstrainedOutputPipeline;
        end

        function val=getDistributedPipelining(this)
            val=this.PirOptions.DistributedPipelining;
        end

        function val=getMultStyle(this)
            val=this.PirOptions.DSPStyle;
        end

        function val=getFlattenHierarchy(this)

            val=this.resolveWithParentNtwk(this.PirOptions.FlattenHierarchy);
        end

        function val=getSharingFactor(this)
            val=this.PirOptions.SharingFactor;
        end

        function val=getStreamingFactor(this)
            val=this.PirOptions.StreamingFactor;
        end

    end

    methods(Static)
        function asStr=DistributedPipeliningBool2String(dp)
            if islogical(dp)
                if dp
                    asStr='on';
                else
                    asStr='off';
                end
            else
                asStr=dp;
            end
        end

        function s=toString(value)
            s=toString@internal.ml2pir.BaseGraphBuilder(value);

            if strcmp(s,'')&&isa(value,'handle')


                if~isa(value,'internal.mtree.Constant')
                    s=[value.Owner.FullPath,'/'];
                end
                s=[s,value.Name];
            end
        end

        function pirOptions=parseInputs(varargin)
            persistent p

            if isempty(p)
                p=inputParser;
                p.StructExpand=true;

                p.addParameter('OriginalSLHandle',-1,@isnumeric);
                p.addParameter('ParentNetwork',[],@(hN)isa(hN,'hdlcoder.network'));
                p.addParameter('SLRate',0,@isnumeric);
                p.addParameter('SourceCodeComments',false,@islogical);
                p.addParameter('Traceability',false,@islogical);
                p.addParameter('UserComments',true,@islogical);

                p.addParameter('ConstMultiplierOptimization',0,@isnumeric);
                p.addParameter('InstantiateFunctions',false,@islogical);
                p.addParameter('ResetType',false,@islogical);


                p.addParameter('AdaptivePipelining','inherit',@ischar);
                p.addParameter('BalanceDelays','inherit',@ischar);
                p.addParameter('ClockRatePipelining','inherit',@ischar);
                p.addParameter('ConstrainedOutputPipeline',0,@isnumeric);
                p.addParameter('DistributedPipelining','inherit',@(x)islogical(x)||ischar(x));
                p.addParameter('DSPStyle',int8(0),@isinteger);
                p.addParameter('FlattenHierarchy','inherit',@ischar);
                p.addParameter('SharingFactor',0,@isnumeric);
                p.addParameter('StreamingFactor',0,@isnumeric);
            end

            p.parse(varargin{:});

            pirOptions=p.Results;
            pirOptions.DistributedPipelining=internal.ml2pir.PIRGraphBuilder.DistributedPipeliningBool2String(pirOptions.DistributedPipelining);

            if isempty(pirOptions.ParentNetwork)
                error('a handle to the parent network is required to construct a PIR graph');
            end
        end

        function flattenNetwork(hNIC,transferNtwkComment,overrideParentSigType)
            if nargin<3
                overrideParentSigType=false;
            end
            if nargin<2
                transferNtwkComment=true;
            end

            hParent=hNIC.Owner;
            hChild=hNIC.ReferenceNetwork;
            assert(numel(hChild.instances)==1,...
            'flattening of network requires that there be only one instance');



            map=containers.Map;


            for i=1:numel(hChild.PirInputSignals)
                childSig=hChild.PirInputSignals(i);
                parentSig=hNIC.PirInputSignals(i);

                if~(childSig.Type.isRecordType&&parentSig.Type.isRecordType)&&...
                    ~childSig.Type.isEqual(parentSig.Type)
                    if~overrideParentSigType





                        sig_copy=hParent.addSignal(childSig);
                        sig_copy.acquireReceivers(parentSig);
                        pirelab.getWireComp(hParent,parentSig,sig_copy,parentSig.Name);
                        parentSig=sig_copy;
                    else



                        parentSig.Type=childSig.Type;
                    end
                end

                map(childSig.RefNum)=parentSig;
            end

            for i=1:numel(hChild.PirOutputSignals)
                childSig=hChild.PirOutputSignals(i);
                parentSig=hNIC.PirOutputSignals(i);

                if~childSig.Type.isEqual(parentSig.Type)
                    if~overrideParentSigType





                        sig_copy=hParent.addSignal(childSig);
                        sig_copy.acquireDrivers(parentSig);
                        pirelab.getWireComp(hParent,sig_copy,parentSig,parentSig.Name);
                        parentSig=sig_copy;
                    else



                        parentSig.Type=childSig.Type;
                    end
                end

                if isKey(map,childSig.RefNum)


                    outPort=hChild.PirOutputPorts(i);
                    sig_copy=hChild.addSignal(childSig);
                    childSig.disconnectReceiver(outPort);
                    sig_copy.addReceiver(outPort);
                    pirelab.getWireComp(hChild,childSig,sig_copy);


                    childSig=sig_copy;
                end

                map(childSig.RefNum)=parentSig;
            end

            signalsToProcess=hChild.PirOutputSignals;
            while~isempty(signalsToProcess)






                sig=signalsToProcess(1);
                signalsToProcess(1)=[];

                drivingPort=sig.getDrivers;
                if isempty(drivingPort)


                    continue;
                end


                assert(isscalar(drivingPort));
                hC=drivingPort.Owner;


                assert(~isa(hC,'hdlcoder.network'));
                moveCompAndCloneIO(hC);
            end



            nicComment=hNIC.getComment;
            if~isempty(nicComment)


                userComments=strjoin(regexp(nicComment,...
                '''<S+\d*>:+\d*:+\d*''[\r\n]*','split'),'');

                if~isempty(userComments)
                    hC.addComment(userComments);
                end
            end



            if transferNtwkComment&&~isempty(hChild.getComment)
                hC.addComment(hChild.getComment);
            end




            p=pir(hChild.getCtxName);
            p.removeNetwork(hChild);

            hParent.renderCodegenPir(true);



            function moveCompAndCloneIO(hC)


                if numel(hC.PirInputSignals)==0
                    inSigs=[];
                else

                    for j=numel(hC.PirInputSignals):-1:1
                        innerSig=hC.PirInputSignals(j);
                        if map.isKey(innerSig.RefNum)
                            inSigs(j)=map(innerSig.RefNum);
                        else
                            outerSig=hParent.addSignal(innerSig);
                            map(innerSig.RefNum)=outerSig;
                            inSigs(j)=outerSig;



                            signalsToProcess(end+1)=innerSig;%#ok<AGROW>
                        end
                    end
                end



                if numel(hC.PirOutputSignals)==0
                    outSigs=[];
                else

                    for j=numel(hC.PirOutputSignals):-1:1
                        innerSig=hC.PirOutputSignals(j);
                        if map.isKey(innerSig.RefNum)
                            outSigs(j)=map(innerSig.RefNum);
                        else
                            outerSig=hParent.addSignal(innerSig);
                            map(innerSig.RefNum)=outerSig;
                            outSigs(j)=outerSig;
                        end
                    end
                end



                for ii=1:numel(hC.PirInputPorts)
                    hC.PirInputSignals(ii).disconnectReceiver(hC.PirInputPorts(ii));
                end
                for ii=1:numel(hC.PirOutputPorts)
                    hC.PirOutputSignals(ii).disconnectDriver(hC.PirOutputPorts(ii));
                end
                hParent.acquireComp(hC);


                pirelab.connectComp(hC,inSigs,outSigs);
            end
        end

        function passOptimizationFlags(source,targetNtwk)

            constroutpipe=source.getConstrainedOutputPipeline;
            targetNtwk.setHardwareMode(source.getHardwareMode);
            targetNtwk.setDelayBalancing(source.getDelayBalancing);
            targetNtwk.setLocalClockRatePipelining(source.getLocalClockRatePipelining);
            targetNtwk.setConstrainedOutputPipeline(constroutpipe);
            targetNtwk.setDistributedPipeliningFromString(internal.ml2pir.PIRGraphBuilder.DistributedPipeliningBool2String(source.getDistributedPipelining));
            targetNtwk.setMultStyle(source.getMultStyle);
            targetNtwk.setFlattenHierarchy(source.getFlattenHierarchy);
            targetNtwk.setSharingFactor(source.getSharingFactor);
            targetNtwk.setStreamingFactor(source.getStreamingFactor);

            targetInst=targetNtwk.instances;
            arrayfun(@(x)x.setConstrainedOutputPipeline(constroutpipe),targetInst);
        end

    end

end







