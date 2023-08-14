classdef SimOutSaveHelper<handle







    properties
saveToMAT
inputsDS
outputsDS
    end

    properties(Access=private)
harnessModel
createForTopModel
topModel
    end

    methods
        function obj=SimOutSaveHelper(isMAT,harnessStruct,createForTop,top)
            obj.inputsDS=Simulink.SimulationData.Dataset;
            obj.outputsDS=Simulink.SimulationData.Dataset;
            obj.saveToMAT=isMAT;
            obj.harnessModel=harnessStruct;
            obj.createForTopModel=createForTop;
            obj.topModel=top;
        end

        function addElementAsSignal(obj,elem,type)
            signal=Simulink.SimulationData.Signal;
            signal.Name=elem.Name;
            signal.BlockPath=elem.BlockPath;
            signal.PortType='outport';
            signal.PortIndex=1;
            signal.Values=elem.Values;
            obj.addElement(signal,type);
        end

        function addElement(obj,sig,type)
            if strcmpi(type,'inputs')
                obj.inputsDS=obj.inputsDS.addElement(sig);
            else
                obj.outputsDS=obj.outputsDS.addElement(sig);
            end
        end

        function[hasInputs,hasBaseline,activeScenario]=save(obj,loc1,loc2,updateScenario)





            activeScenario='';
            if obj.inputsDS.numElements>0
                if(obj.saveToMAT)
                    InputScenario=obj.inputsDS;
                    save(loc1,'InputScenario');
                else

                    if exist(loc1,'file')
                        delete(loc1);
                    end


                    xls.internal.util.writeDatasetToSheet(obj.inputsDS,loc1,loc2,'',xls.internal.SourceTypes.Input);
                end
                hasInputs=exist(loc1,'file');
            else
                hasInputs=false;
            end

            if obj.outputsDS.numElements>0
                obj.setNameAndLocalBlockPathForHarness();
                if(obj.saveToMAT)
                    varDS=obj.outputsDS;
                    save(loc2,'varDS');
                    hasBaseline=exist(loc2,'file');
                else

                    xls.internal.util.writeDatasetToSheet(obj.outputsDS,loc1,loc2,'',xls.internal.SourceTypes.Output);
                    hasBaseline=exist(loc1,'file');
                end
            else
                hasBaseline=false;
            end



            if hasInputs&&~isempty(obj.harnessModel)&&...
                strcmp(obj.harnessModel.origSrc,'Signal Editor')&&updateScenario
                sigEditHdl=find_system(obj.harnessModel.name,...
                'SearchDepth',1,...
                'LoadFullyIfNeeded','off',...
                'FollowLinks','off',...
                'LookUnderMasks','all',...
                'BlockType','SubSystem',...
                'MaskType','SignalEditor');
                activeScenario=stm.internal.ModelUtil.setSigEditorDataAndExtrapolate(sigEditHdl{1},loc1);
            end
        end
    end

    methods(Access=private)
        function setNameAndLocalBlockPathForHarness(obj)
            for indx=1:obj.outputsDS.numElements
                dsBlkPath=obj.outputsDS{indx}.BlockPath;

                if obj.createForTopModel
                    assert(dsBlkPath.getLength==1);
                    outSigs=get_param(dsBlkPath.getBlock(1),'portHandles');

                    if isempty(obj.harnessModel)



                        obj.outputsDS{indx}.Name=get_param(outSigs.Outport(obj.outputsDS{indx}.PortIndex),'DataLoggingName');
                        return;
                    else


                        l=get_param(outSigs.Outport(obj.outputsDS{indx}.PortIndex),'Line');
                        dstBlkHandles=get_param(l,'DstBlockHandle');
                        for i=1:length(dstBlkHandles)
                            bType=get_param(dstBlkHandles(i),'BlockType');
                            if strcmp(bType,'Outport')
                                obj.outputsDS{indx}.PortIndex=str2double(get_param(dstBlkHandles(i),'Port'));
                                break;
                            end
                        end
                    end
                    hrnsBlkPath=[obj.harnessModel.name,'/',obj.topModel];
                    blkHdl=getSimulinkBlockHandle(hrnsBlkPath);
                else
                    if dsBlkPath.getLength==0

                        return;
                    end
                    blockNames=strsplit(dsBlkPath.convertToCell{end},'/');
                    hrnsBlkPath=[obj.harnessModel.name,'/',blockNames{end}];
                    blkHdl=getSimulinkBlockHandle(hrnsBlkPath);
                    if blkHdl==-1

                        hrnsBlkPath=[obj.harnessModel.name,'/',obj.outputsDS{indx}.Name];
                        blkHdl=getSimulinkBlockHandle(hrnsBlkPath);
                    end
                end

                if blkHdl~=-1
                    if Simulink.harness.internal.isHarnessCUT(blkHdl)
                        obj.outputsDS{indx}.BlockPath=Simulink.SimulationData.BlockPath(hrnsBlkPath);


                        outSigs=get_param(hrnsBlkPath,'portHandles');
                        l=get_param(outSigs.Outport(obj.outputsDS{indx}.PortIndex),'Line');
                        srcPortHandle=get_param(l,'SrcPortHandle');
                        set_param(srcPortHandle,'DataLogging','on');
                        obj.outputsDS{indx}.Name=get_param(srcPortHandle,'DataLoggingName');
                    elseif strcmp(get_param(blkHdl,'BlockType'),'Outport')
                        pHdl=get_param(blkHdl,'PortHandles');
                        lineH=get_param(pHdl.Inport,'Line');
                        set_param(lineH,'SignalNameFromLabel',obj.outputsDS{indx}.Name);
                        srcPortHandle=get_param(lineH,'SrcPortHandle');
                        set_param(srcPortHandle,'DataLogging','on');
                        set_param(srcPortHandle,'DataLoggingName',obj.outputsDS{indx}.Name);
                    end
                end
            end
        end
    end
end
