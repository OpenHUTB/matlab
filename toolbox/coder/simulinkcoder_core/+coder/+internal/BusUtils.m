classdef BusUtils<handle




    methods(Static,Access=public)
        function strucBus=setBusStructField(strucBus,fieldName,value)
            if strucBus.type==2&&strucBus.node.isVirtualBus
                N=length(strucBus.node.leafe);
                for i=1:N
                    strucBus.node.leafe{i}=coder.internal.BusUtils.setBusStructField(strucBus.node.leafe{i},fieldName,value);
                end
            else
                strucBus.prm.(fieldName)=value;
            end
        end




        function strucBus=populateBlkSid(strucBus,blockSID)
            if strucBus.type==2&&strucBus.node.isVirtualBus
                numInports=length(strucBus.node.leafe);
                for i=1:numInports
                    strucBus.node.leafe{i}=coder.internal.BusUtils.populateBlkSid(...
                    strucBus.node.leafe{i},blockSID);
                end
                if strucBus.node.hasBusObject
                    strucBus.blkSid=blockSID;
                end
            elseif strucBus.type==1||strucBus.node.hasBusObject
                strucBus.blkSid=blockSID;
            else
                disp(DAStudio.message('RTW:buildProcess:UnknownTypeOfNode'));
            end
        end

        function signalName=getSignalName(blockH,portH)
            signalName=[];
            lineH=get_param(portH,'Line');
            if lineH>0
                srcPortH=get_param(lineH,'SrcPortHandle');
                if srcPortH>0
                    signalName=get_param(srcPortH,'SignalNameFromLabel');
                    if isempty(signalName)
                        signalName=get_param(srcPortH,'PropagatedSignals');
                        if isempty(signalName)||contains(signalName,',')
                            signalName=get_param(srcPortH,'Name');
                        end
                    end
                end
            end
            if isempty(signalName)
                signalName=get_param(blockH,'OutputSignalNames');
                if iscell(signalName)
                    if length(signalName)==1
                        signalName=signalName{1};
                    else
                        signalName='';
                    end
                end
                if contains(signalName,',')
                    signalName='';
                end
            end
        end


        function yesNo=outputTypeIsBus(srcBlk)
            dtCapabilities=coder.internal.DataType.l_getDTCapabilitiesOfInport;
            dtInfo=Simulink.DataTypePrmWidget.parseDataTypeString(...
            get_param(srcBlk,'OutDataTypeStr'),dtCapabilities);
            yesNo=dtInfo.isBusType;
        end


        function strPrm=getBusElementPrm(blkH,busElement)
            strPrm.CompiledPortDataType=coder.internal.Utilities.resolveDT(busElement.DataType);
            strPrm.AliasPortDataType=busElement.DataType;
            if ischar(busElement.Dimensions)
                strPrm.SymbolicDimensions=busElement.Dimensions;
                strPrm.CompiledPortDimensions=slResolve(busElement.Dimensions,blkH);
            else
                busElementDimensions=busElement.Dimensions(:);
                if~isrow(busElementDimensions)
                    busElementDimensions=busElementDimensions';
                end
                strPrm.CompiledPortDimensions=[length(busElement.Dimensions),busElementDimensions];
                strPrm.SymbolicDimensions=coder.internal.Utilities.getSymbolicFromNumericDims(strPrm.CompiledPortDimensions);
            end
            strPrm.CompiledPortComplexSignal=strcmp(busElement.Complexity,'complex');
            strPrm.CompiledPortFrameData=strcmp(busElement.SamplingMode,'Frame based');
            strPrm.CompiledSampleTime=busElement.SampleTime;


            strPrm.isFixPt=0;
            strPrm.isScaledDouble=0;
            dt=strPrm.CompiledPortDataType;
            if(fixed.internal.type.isNameOfTraditionalFixedPointType(dt))

                [~,isScaledDouble]=fixdt(dt);
                strPrm.isScaledDouble=isScaledDouble;
                strPrm.isFixPt=1;
            end

            strPrm.RTWSignalIdentifier=busElement.Name;
            strPrm.SignalObject=[];
            strPrm.RTWStorageClass='Auto';
        end


        function cacheCompiledBusInfo(blkH,strPorts,val)
            portHandles=get_param(blkH,'PortHandles');
            for i=1:strPorts.numOfInports
                set_param(portHandles.Inport(i),'CacheCompiledBusStruct',val);
            end
            for i=1:strPorts.numOfOutports
                ph=coder.internal.slBus('LocalGetBlockForPortPrm',portHandles.Outport(i),'PortHandles');
                set_param(ph.Inport,'CacheCompiledBusStruct',val);
            end




            for i=1:strPorts.numOfFromBlks
                gotoInportH=coder.internal.GotoFromChecks.getGotoInportH(strPorts.fromBlks(i));
                set_param(gotoInportH,'CacheCompiledBusStruct',val);
            end

            for i=1:strPorts.numOfGotoBlks
                gotoPortH=get_param(strPorts.gotoBlks(i),'PortHandles');
                set_param(gotoPortH.Inport,'CacheCompiledBusStruct',val);
            end
        end


        function nonvirtual=getBusSrcOutputAsStruct(srcBlkH)
            srcType=get_param(srcBlkH,'BlockType');
            switch srcType
            case 'BusCreator'
                if coder.internal.BusUtils.isBus(srcBlkH)
                    nonvirtual=get_param(srcBlkH,'NonVirtualBus');
                else
                    nonvirtual='off';
                end

            case{'Inport','Outport','SignalSpecification'}
                isBus=coder.internal.BusUtils.isBus(srcBlkH);
                if isBus
                    nonvirtual=get_param(srcBlkH,'BusOutputAsStruct');
                else
                    nonvirtual='off';
                end

            case{'ModelReference','S-Function','Concatenate','Selector','Constant','Assignment','Reshape',...
                'PermuteDimensions','DataStoreRead','Probe','BusAssignment','RateTransition','UnitDelay',...
                'ZeroOrderHold','Memory','Merge','Switch','MultiPortSwitch','SignalConversion',...
                'ForEachSliceSelector','ForEachSliceAssignment','Delay'}






                nonvirtual='on';

            otherwise
                nonvirtual='off';
            end
        end

        function status=isBus(srcBlkH)
            datatype=get_param(srcBlkH,'OutDataTypeStr');
            status=~isempty(regexp(datatype,'^\s*Bus:','once'));
        end


        function localSetBusObjectParams(portBlk,busObject)
            set_param(portBlk,'UseBusObject','on');
            set_param(portBlk,'BusObject',busObject.name);
            set_param(portBlk,'BusOutputAsStruct',busObject.asStruct);
        end


        function bus2outport(strucBus,modelH,outPortH,thisHdl)
            modelName=get_param(modelH,'Name');

            if strucBus.type==2&&strucBus.node.isVirtualBus
                [numberOfOutputs,busNodes]=coder.internal.BusUtils.LocalGetNumberOfSignals(strucBus);

                busCellArray=coder.internal.BusUtils.LocalBusStruct2CellArray(strucBus,1);
                outPortH=coder.internal.slBus('LocalAddBusSelectBlock',modelName,outPortH,busCellArray);
                for i=1:numberOfOutputs
                    coder.internal.slBus('LocalAddOutPortBlock',modelName,outPortH(i),busNodes{i},thisHdl);
                end
            else
                coder.internal.slBus('LocalAddOutPortBlock',modelName,outPortH,strucBus,thisHdl);
            end
        end


        function busString=LocalBusStruct2CellArray(strucBus,level)
            busString={};

            if strucBus.type==2&&strucBus.node.isVirtualBus
                for i=1:length(strucBus.node.leafe)
                    tmpBusString=coder.internal.BusUtils.LocalBusStruct2CellArray(strucBus.node.leafe{i},level-1);
                    busString={busString{1:end},tmpBusString{1:end}};
                end
                if level<1
                    for i=1:length(busString)
                        busString{i}=[strucBus.name,'.',busString{i}];%#ok<AGROW>
                    end
                end
            else
                busString{1}=strucBus.name;
            end
        end


        function[numSignals,busNodes]=LocalGetNumberOfSignals(strucBus)
            numSignals=0;
            busNodes={};
            if strucBus.type==2&&strucBus.node.isVirtualBus
                numLeafes=length(strucBus.node.leafe);
                for i=1:numLeafes
                    [n,nodes]=coder.internal.BusUtils.LocalGetNumberOfSignals(strucBus.node.leafe{i});
                    numSignals=numSignals+n;
                    busNodes={busNodes{1:end},nodes{1:end}};
                end
            else
                busNodes{1}=strucBus;
                numSignals=1;
            end
        end


        function[portHandles,thisHdl,inlineSubsystemNames]=inport2bus(strucBus,modelH,thisHdl)
            modelName=get_param(modelH,'Name');

            if strucBus.type==2&&strucBus.node.isVirtualBus
                [portHandles,thisHdl]=coder.internal.BusUtils.bottomup(strucBus,modelName,thisHdl);
                inlineSubsystemNames=cell(1,length(portHandles));
            else
                [portHandles,thisHdl,inlineSubsystemNames]=coder.internal.slBus('addInportBlock',strucBus,modelName,thisHdl);
            end
        end
    end

    methods(Static,Access=private)
        function[outportH,thisHdl]=bottomup(strucBus,modelName,thisHdl)
            if strucBus.type==2&&strucBus.node.isVirtualBus
                numInports=length(strucBus.node.leafe);
                outportH=zeros(1,numInports);
                for i=1:numInports
                    [outportH(i),thisHdl]=coder.internal.BusUtils.bottomup(strucBus.node.leafe{i},modelName,thisHdl);
                end
                outportH=coder.internal.GraphicalUtils.addMuxBlock(strucBus,modelName,outportH);
            elseif strucBus.type==1||strucBus.node.hasBusObject
                [outportH,thisHdl,~]=coder.internal.slBus('addInportBlock',strucBus,modelName,thisHdl);
            else
                disp(DAStudio.message('RTW:buildProcess:UnknownTypeOfNode'));
            end
        end
    end
end
