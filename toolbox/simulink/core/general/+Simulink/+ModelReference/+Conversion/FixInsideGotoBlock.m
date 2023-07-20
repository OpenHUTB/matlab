classdef FixInsideGotoBlock<Simulink.ModelReference.Conversion.GotoFromFix




    methods(Access=public)
        function this=FixInsideGotoBlock(subsys,gotoBlocks,portInfos,params,portInfoMap)
            this@Simulink.ModelReference.Conversion.GotoFromFix(subsys,gotoBlocks,portInfos,params,portInfoMap);
        end
    end
    methods(Access=private)
        function[newOutport]=addGeneralPortAtRoot(this,newModel,gotoTag,originalGotoBlock,portWidth,portHeight,x_pos,y_pos)
            newOutport=this.addBlock(newModel,'Outport','built-in/Outport');
            newOutportObj=get_param(newOutport,'Object');

            newFromBlock=this.addBlock(newModel,'From','built-in/From');
            newFromBlockObj=get_param(newFromBlock,'Object');

            newFromBlockObj.GotoTag=gotoTag;


            fromPos=get_param(originalGotoBlock,'Position');
            fromWidth=fromPos(3)-fromPos(1);
            fromHeight=fromPos(4)-fromPos(2);

            y=y_pos+2*max(portHeight,fromHeight);
            newOutportObj.Position=[x_pos-portWidth,y-portHeight/2,x_pos,y+portHeight/2];

            x=x_pos-2*portWidth-fromWidth;
            newFromBlockObj.Position=[x,y-fromHeight/2,x+fromWidth,y+fromHeight/2];

            ph1=newFromBlockObj.PortHandles;
            ph2=newOutportObj.PortHandles;
            add_line(newModel,ph1.Outport,ph2.Inport);
        end

        function[newOutport]=addExpandedBEPAtRoot(this,newModel,newModelName,compiledPortInfo,originalGotoBlock,gotoTag,x_pos,y_pos,portWidth,portHeight)
            expandedPortInfo=Simulink.ModelReference.Conversion.PortUtils.expandCompIOInfo(compiledPortInfo.compIOInfo,true,false);
            origGotoBlockObj=get_param(originalGotoBlock,'Object');
            newFromBlock=this.addBlock(newModel,'From','built-in/From');
            newFromBlockObj=get_param(newFromBlock,'Object');
            newFromBlockObj.GotoTag=gotoTag;

            fromPos=origGotoBlockObj.Position;
            fromWidth=fromPos(3)-fromPos(1);
            fromHeight=fromPos(4)-fromPos(2);
            x=x_pos-2*portWidth-fromWidth;
            y=y_pos+2*max(portHeight,fromHeight);
            newFromBlockObj.Position=[x,y-fromHeight/2,x+fromWidth,y+fromHeight/2];

            if(get_param(newFromBlockObj.PortHandles.Outport,'Line')==-1)
                signalHierarchy=get_param(origGotoBlockObj.PortHandles.Inport,'SignalHierarchy');
                signalNameFromLabel=signalHierarchy.SignalName;
                signalHierarchy.SignalName='';

                signalVecs=Simulink.ModelReference.Conversion.PortUtils.flattenSignalHierarchy(signalHierarchy);
                signalCommaSepList=strjoin(signalVecs,',');

                if compiledPortInfo.addRTB
                    rateTransitionHandle=add_block('simulink/Signal Attributes/Rate Transition',[newModelName,'/Rate Transition'],'MakeNameUnique','on');
                    Simulink.ModelReference.Conversion.CopySubsystemToNewModel.setPositionAssociatesWithPorts(false,newModelName,this.PortHandles.Outport(realPortIdx),rateTransitionHandle,subsystemRotation,signalNameFromLabel);

                    rateTransitionPorts=get_param(rateTransitionHandle,'PortHandles');
                    rateTransitionOutport=rateTransitionPorts.Outport;
                    busSelectorHandle=add_block('simulink/Commonly Used Blocks/Bus Selector',[modelName,'/busSelector'],'MakeNameUnique','on');
                    set_param(busSelectorHandle,'OutputSignals',signalCommaSepList);
                    Simulink.ModelReference.Conversion.CopySubsystemToNewModel.setPositionAssociatesWithPorts(false,newModelName,rateTransitionOutport,busSelectorHandle,subsystemRotation,signalNameFromLabel);
                else
                    busSelectorHandle=add_block('simulink/Commonly Used Blocks/Bus Selector',[newModelName,'/busSelector'],'MakeNameUnique','on');
                    set_param(busSelectorHandle,'OutputSignals',signalCommaSepList);

                    Simulink.ModelReference.Conversion.CopySubsystemToNewModel.setPositionAssociatesWithPorts(false,newModelName,newFromBlockObj.PortHandles.Outport,busSelectorHandle,newFromBlockObj.Orientation,signalNameFromLabel);
                end

                busSelectorOutports=get_param(busSelectorHandle,'PortHandles');
                busSelectorOutports=busSelectorOutports.Outport;

                isSampleTimeIndependent=Simulink.ModelReference.Conversion.SampleTimeUtils.isSampleTimeIndependent(newModel,this.ConversionData.ConversionParameters.ExportedFcn);

                if numel(signalVecs)>=1
                    busElementOut=add_block('simulink/Ports & Subsystems/Out Bus Element',[newModelName,'/Out Bus Element'],'MakeNameUnique','on','CreateNewPort','on','Element',signalVecs{1});
                    Simulink.ModelReference.Conversion.CopySubsystemToNewModel.setPositionAssociatesWithPorts(false,newModelName,busSelectorOutports(1),busElementOut,newFromBlockObj.Orientation,'');
                    Simulink.ModelReference.Conversion.PortUtils.setBEPsExpandedFromPureVirtualBus(busElementOut,expandedPortInfo(1),this.ConversionData.ConversionParameters.RightClickBuild);
                    if~isSampleTimeIndependent
                        set_param(busElementOut,'SampleTime',mat2str(expandedPortInfo(1).Attribute.SampleTime));
                    end
                end

                for sigIdx=2:numel(signalVecs)
                    busElementOutAdded=add_block(busElementOut,[newModelName,'/Out Bus Element'],'MakeNameUnique','on','Element',signalVecs{sigIdx});
                    Simulink.ModelReference.Conversion.CopySubsystemToNewModel.setPositionAssociatesWithPorts(false,newModelName,busSelectorOutports(sigIdx),busElementOutAdded,newFromBlockObj.Orientation,'');
                    Simulink.ModelReference.Conversion.PortUtils.setBEPsExpandedFromPureVirtualBus(busElementOutAdded,expandedPortInfo(sigIdx),this.ConversionData.ConversionParameters.RightClickBuild);
                    if~isSampleTimeIndependent
                        set_param(busElementOutAdded,'SampleTime',mat2str(expandedPortInfo(sigIdx).Attribute.SampleTime));
                    end
                end
                newOutport=busElementOut;
            end
        end
    end

    methods(Access=protected)
        function update(this,subsysH,originalGotoBlock,portInfo)
            gotoTag=get_param(originalGotoBlock,'GotoTag');
            subsystemIndex=this.ConversionData.ConversionParameters.Systems==subsysH;
            newModelName=this.ConversionData.ConversionParameters.ModelReferenceNames{subsystemIndex};
            newModel=get_param(newModelName,'Handle');
            modelBlock=this.ConversionData.ModelBlocks(subsystemIndex);
            if modelBlock==0
                return;
            end
            parentSubsystem=get_param(get_param(modelBlock,'Parent'),'Handle');


            [~,y_pos,x_pos]=Simulink.ModelReference.Conversion.GotoFromFix.guessInitialPosition(newModel);
            [portWidth,portHeight]=Simulink.ModelReference.Conversion.GotoFromFix.guessPortSize(newModel,'Outport');

            if isKey(this.CompiledPortInfoMap,originalGotoBlock)
                compiledPortInfo=this.CompiledPortInfoMap(originalGotoBlock);
                if compiledPortInfo.containsPureVirtualBus
                    [newOutport]=this.addExpandedBEPAtRoot(newModel,newModelName,compiledPortInfo,originalGotoBlock,gotoTag,x_pos,y_pos,portWidth,portHeight);
                else

                    newOutport=this.addGeneralPortAtRoot(newModel,gotoTag,originalGotoBlock,portWidth,portHeight,x_pos,y_pos);
                    Simulink.ModelReference.Conversion.PortUtils.setIOAttributesForPortBlock(newOutport,...
                    compiledPortInfo.compIOInfo.portAttributes,compiledPortInfo.compIOInfo.busName,this.ConversionData.DataAccessor,this.ConversionData.ConversionParameters.RightClickBuild);
                end
            else
                assert(1==2,'Specific goto block is not found');
            end


            modelBlockObj=get_param(modelBlock,'Object');
            orgWarning1=warning('off','Simulink:Bus:EditTimeBusPropFailureInputPort');
            orgWarning2=warning('off','Simulink:blocks:BusSelectorRequiresBusSignal');
            try
                modelBlockObj.refreshModelBlock;
            catch MME
                warning(orgWarning1.state,'Simulink:Bus:EditTimeBusPropFailureInputPort');
                warning(orgWarning2.state,'Simulink:blocks:BusSelectorRequiresBusSignal');








            end
            warning(orgWarning1.state,'Simulink:Bus:EditTimeBusPropFailureInputPort');
            warning(orgWarning2.state,'Simulink:blocks:BusSelectorRequiresBusSignal');

            ph=get_param(modelBlock,'PortHandles');
            blkName=get_param(originalGotoBlock,'Name');
            [~,y_max,x_max]=Simulink.ModelReference.Conversion.GotoFromFix.guessInitialPosition(parentSubsystem);

            newGotoBlock=add_block(originalGotoBlock,[getfullname(parentSubsystem),'/',Simulink.ModelReference.Conversion.Utilities.getARandomName()],'makenameunique','on');



            gotoPos=get_param(newGotoBlock,'Position');
            blkHeight=gotoPos(4)-gotoPos(2);
            blkWidth=gotoPos(3)-gotoPos(1);



            set_param(newGotoBlock,'Position',[x_max-blkWidth,y_max+blkHeight/2,x_max,y_max+3*blkHeight/2]);
            gotoBlockHandles=get_param(newGotoBlock,'PortHandles');
            add_line(parentSubsystem,ph.Outport(end),gotoBlockHandles.Inport,'autorouting','on');


            set_param(ph.Outport(end),'Name',portInfo.RTWSignalIdentifier);


            this.ConversionData.Logger.addInfo(...
            message('Simulink:modelReferenceAdvisor:FixInsideGotoProblem',...
            Simulink.ModelReference.Conversion.MessageBeautifier.beautifyBlockName(getfullname(newOutport),newOutport),...
            Simulink.ModelReference.Conversion.MessageBeautifier.beautifyModelName(newModel),...
            Simulink.ModelReference.Conversion.MessageBeautifier.beautifyBlockName(getfullname(newGotoBlock),newGotoBlock)));
        end
    end

    methods(Static,Access=private)
        function data=cell2mat(data)
            if iscell(data)
                data=cell2mat(data);
            end
        end
    end
end


