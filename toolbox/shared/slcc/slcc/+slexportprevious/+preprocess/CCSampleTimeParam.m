function CCSampleTimeParam(obj)



    if isR2022aOrEarlier(obj.ver)
        obj.appendRule('<Block<BlockType|"CFunction"><SampleTime:remove>>');
        obj.appendRule('<Block<BlockType|"CCaller"><SampleTime:remove>>');

        cCallerBlocks=obj.findBlocksOfType('CCaller');
        removeSampleTimeParam(cCallerBlocks,obj);
        cFunctionBlocks=obj.findBlocksOfType('CFunction');
        removeSampleTimeParam(cFunctionBlocks,obj);
    end

    function removeSampleTimeParam(blocks,obj)
        for i=1:numel(blocks)
            blk=blocks{i};
            blockSampleTime=get_param(blk,'SampleTime');


            if~strcmp(blockSampleTime,'-1')


                parent=get_param(blk,"Parent");
                subSysName=obj.generateTempName;

                Simulink.BlockDiagram.createSubsystem(getSimulinkBlockHandle(blk),'Name',subSysName);
                subSysPath=[parent,'/',subSysName];

                set_param(subSysPath,'TreatAsAtomicUnit','on');
                set_param(subSysPath,'SystemSampleTime',blockSampleTime);
                set_param(subSysPath,'RTWSystemCode','Inline');
            end
        end
