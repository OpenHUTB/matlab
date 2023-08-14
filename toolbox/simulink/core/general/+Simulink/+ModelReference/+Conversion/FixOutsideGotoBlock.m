classdef FixOutsideGotoBlock<Simulink.ModelReference.Conversion.GotoFromFix




    properties(SetAccess=private,GetAccess=private)
SubsystemConversionCheck
    end

    methods(Access=public)
        function this=FixOutsideGotoBlock(subsys,gotoBlocks,portInfos,params,check,portInfoMap)
            this@Simulink.ModelReference.Conversion.GotoFromFix(subsys,gotoBlocks,portInfos,params,portInfoMap);
            this.SubsystemConversionCheck=check;
        end
    end


    methods(Access=protected)
        function update(this,subsysH,originalGotoBlock,portInfo)
            gotoTag=get_param(originalGotoBlock,'GotoTag');
            subsysIndex=this.ConversionData.ConversionParameters.Systems==subsysH;
            newModelName=this.ConversionData.ConversionParameters.ModelReferenceNames{subsysIndex};
            newModel=get_param(newModelName,'Handle');
            modelBlock=this.ConversionData.ModelBlocks(subsysIndex);
            if modelBlock==0
                return;
            end
            parentSubsystem=get_param(get_param(modelBlock,'Parent'),'Handle');

            [x_pos,y_pos]=Simulink.ModelReference.Conversion.GotoFromFix.guessInitialPosition(newModel);
            [portWidth,portHeight]=Simulink.ModelReference.Conversion.GotoFromFix.guessPortSize(newModel,'Inport');
            isSampleTimeIndependent=Simulink.ModelReference.Conversion.SampleTimeUtils.isSampleTimeIndependent(newModel,this.ConversionData.ConversionParameters.ExportedFcn);
            if isKey(this.CompiledPortInfoMap,originalGotoBlock)
                compiledPortInfo=this.CompiledPortInfoMap(originalGotoBlock);
                if iscell(compiledPortInfo)
                    compiledPortInfo=compiledPortInfo{:};
                end
                if compiledPortInfo.containsPureVirtualBus
                    expandedPortInfo=Simulink.ModelReference.Conversion.PortUtils.expandCompIOInfo(compiledPortInfo.compIOInfo,true,false);
                    addRTB=compiledPortInfo.addRTB;
                    originalGotBlockObj=get_param(originalGotoBlock,'Object');

                    gotoBlkName=get_param(originalGotoBlock,'Name');
                    newGotoBlock=add_block(originalGotoBlock,[newModelName,'/',Simulink.ModelReference.Conversion.Utilities.getARandomName()],...
                    'makenameunique','on');
                    set_param(newGotoBlock,'Name',gotoBlkName);
                    newGotoBlockObj=get_param(newGotoBlock,'Object');
                    gotoPosition=newGotoBlockObj.Position;
                    gotoWidth=gotoPosition(3)-gotoPosition(1);
                    gotoHeight=gotoPosition(4)-gotoPosition(2);
                    x=x_pos;
                    y=y_pos+2*portWidth;
                    x=x+2*portWidth;
                    newGotoBlockObj.Position=[x,y-gotoHeight/2,x+gotoWidth,y+gotoHeight/2];

                    portName='';

                    signalHierarchy=get_param(originalGotBlockObj.PortHandles.Inport,'SignalHierarchy');

                    index=1;
                    [newInport,~]=Simulink.ModelReference.Conversion.BusExpansionBlock.drawExpandedvirtualBusCreator(newModel,signalHierarchy,...
                    newGotoBlockObj.PortHandles.Inport,...
                    '',...
                    newGotoBlockObj.Orientation,true,0,portName,addRTB,expandedPortInfo,index,true,this.ConversionData.ConversionParameters.RightClickBuild,isSampleTimeIndependent);
                else

                    newInport=this.addBlock(newModel,'Inport','built-in/Inport');
                    gotoBlock=add_block(originalGotoBlock,[newModelName,'/',get_param(originalGotoBlock,'Name')],...
                    'makenameunique','on');

                    gotoPosition=get_param(gotoBlock,'Position');
                    gotoWidth=gotoPosition(3)-gotoPosition(1);
                    gotoHeight=gotoPosition(4)-gotoPosition(2);
                    x=x_pos;
                    y=y_pos+2*portWidth;

                    set_param(newInport,'Position',[x,y-portHeight/2,x+portWidth,y+portHeight/2]);


                    newInportPh=get_param(newInport,'PortHandles');
                    set_param(newInportPh.Outport,'Name',portInfo.RTWSignalIdentifier);

                    x=x+2*portWidth;
                    set_param(gotoBlock,'Position',[x,y-gotoHeight/2,x+gotoWidth,y+gotoHeight/2]);

                    inportHandles=get_param(newInport,'PortHandles');
                    gotoHandles=get_param(gotoBlock,'PortHandles');

                    add_line(newModel,inportHandles.Outport,gotoHandles.Inport);

                    if isempty(compiledPortInfo.compIOInfo.bus)
                        compiledPortInfo.compIOInfo.bus.busObjectName='';
                    end

                    Simulink.ModelReference.Conversion.PortUtils.setIOAttributesForPortBlock(newInport,...
                    compiledPortInfo.compIOInfo.portAttributes,...
                    compiledPortInfo.compIOInfo.bus.busObjectName,this.SubsystemConversionCheck.DataAccessor,this.ConversionData.ConversionParameters.RightClickBuild);


                    Simulink.ModelReference.Conversion.SampleTimeUtils.setSampleTimeForPort(newModel,portInfo,originalGotoBlock,newInport,...
                    this.SubsystemConversionCheck.ConversionParameters.ExportedFcn,this.SubsystemConversionCheck.ConversionParameters.RightClickBuild);
                end
            else

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
            [x_pos,y_pos]=Simulink.ModelReference.Conversion.GotoFromFix.guessInitialPosition(parentSubsystem);

            fromBlock=this.addBlock(parentSubsystem,'From','built-in/From');
            ph=get_param(modelBlock,'PortHandles');
            fromHandles=get_param(fromBlock,'PortHandles');

            x=x_pos;
            y=y_pos+2*gotoHeight;
            set_param(fromBlock,'Position',[x,y-gotoHeight/2,x+gotoWidth,y+gotoHeight/2])
            set_param(fromBlock,'GotoTag',gotoTag);
            add_line(parentSubsystem,fromHandles.Outport,ph.Inport(end),'autorouting','on');


            this.ConversionData.Logger.addInfo(...
            message('Simulink:modelReferenceAdvisor:FixOutsideGotoProblem',...
            Simulink.ModelReference.Conversion.MessageBeautifier.beautifyBlockName(getfullname(newInport),newInport),...
            Simulink.ModelReference.Conversion.MessageBeautifier.beautifyModelName(newModel),...
            Simulink.ModelReference.Conversion.MessageBeautifier.beautifyBlockName(getfullname(fromBlock),fromBlock)));
        end
    end
end


