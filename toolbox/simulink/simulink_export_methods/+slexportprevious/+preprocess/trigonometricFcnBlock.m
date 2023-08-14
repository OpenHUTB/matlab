function trigonometricFcnBlock(obj)






    modelNameNoPath=obj.modelName;
    verobj=obj.ver;

    import slexportprevious.utils.findBlockType;


    if isR2021bOrEarlier(obj.ver)
        obj.appendRule('<Block<BlockType|Trigonometry><InterpMethod:remove>>');
        obj.appendRule('<Block<BlockType|Trigonometry><TableDataTypeStr:remove>>');
    end

    if isR2020bOrEarlier(obj.ver)
        obj.appendRule('<Block<BlockType|Trigonometry><RemoveProtectionAgainstOutOfRangeInput:remove>>');
        obj.appendRule('<Block<BlockType|Trigonometry><AngleUnit:remove>>');
        obj.appendRule('<Block<BlockType|Trigonometry><NumberOfDataPoints:remove>>');

        trigFcnBlks=findBlockType(modelNameNoPath,'Trigonometry','ApproximationMethod','Lookup');
        for i=1:length(trigFcnBlks)
            blk=trigFcnBlks{i};
            set_param(blk,'ApproximationMethod','Cordic');
        end

    end

    if isR2010bOrEarlier(obj.ver)
        trigFcnBlks=findBlockType(modelNameNoPath,'Trigonometry','Operator','cos + jsin');
        for i=1:length(trigFcnBlks)
            blk=trigFcnBlks{i};
            set_param(blk,'Operator','sin');
        end
    end

    if isR2008aOrEarlier(verobj)
        trigFcnBlks=findBlockType(modelNameNoPath,'Trigonometry','Operator','sincos');
        n2bReplaced=length(trigFcnBlks);
        if n2bReplaced>0
            [newModel,newBlkPath]=create_sincos_model();
            for i=1:n2bReplaced
                blk=trigFcnBlks{i};
                blkName=get_param(blk,'Name');
                orient=get_param(blk,'Orientation');
                pos=get_param(blk,'Position');
                outDt=get_param(blk,'OutputSignalType');
                sampleT=get_param(blk,'SampleTime');
                set_param([newBlkPath,'/s'],'OutputSignalType',outDt);
                set_param([newBlkPath,'/c'],'OutputSignalType',outDt);
                set_param([newBlkPath,'/s'],'SampleTime',sampleT);
                set_param([newBlkPath,'/c'],'SampleTime',sampleT);
                delete_block(blk);

                add_block(newBlkPath,blk,...
                'Name',blkName,...
                'Orientation',orient,...
                'Position',pos);
            end
            close_system(newModel,0);
        end
    end
end


function[newModel,blkName]=create_sincos_model()

    newModel=strrep(tempname,tempdir,'msincos_');
    new_system(newModel);
    blkName=[newModel,'/Sub'];
    add_block('built-in/Subsystem',blkName);
    add_block('built-in/Inport',[blkName,'/In1'],'Position',[30,33,60,47]);
    add_block('built-in/Trigonometry',[blkName,'/s'],'Operator','sin','Position',[95,21,145,59]);
    add_block('built-in/Trigonometry',[blkName,'/c'],'Operator','cos','Position',[95,81,145,119]);
    add_block('built-in/Outport',[blkName,'/Out1'],'Position',[175,33,205,47]);
    add_block('built-in/Outport',[blkName,'/Out2'],'Position',[175,93,205,107]);
    add_line(blkName,'In1/1','s/1');
    add_line(blkName,'In1/1','c/1');
    add_line(blkName,'s/1','Out1/1');
    add_line(blkName,'c/1','Out2/1');

end
