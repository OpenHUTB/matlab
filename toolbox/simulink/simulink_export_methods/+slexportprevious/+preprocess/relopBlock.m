function relopBlock(obj)




    modelNameNoPath=obj.modelName;
    verobj=obj.ver;

    if isR2009aOrEarlier(verobj)
        listOfBlks=slexportprevious.utils.findBlockType(modelNameNoPath,...
        'RelationalOperator','Operator','isInf');
        n2bReplaced=length(listOfBlks);
        if n2bReplaced>0
            for i=1:n2bReplaced
                blk=listOfBlks{i};
                blkName=get_param(blk,'Name');
                orient=get_param(blk,'Orientation');
                pos=get_param(blk,'Position');
                bSampleTime=get_param(blk,'SampleTime');
                bOutDataTypeStr=get_param(blk,'OutDataTypeStr');

                newBlkPath=create_inf_model(obj,bSampleTime,bOutDataTypeStr);

                delete_block(blk);

                add_block(newBlkPath,blk,...
                'Name',blkName,...
                'Orientation',orient,...
                'Position',pos);

            end
        end

        listOfBlks=slexportprevious.utils.findBlockType(modelNameNoPath,...
        'RelationalOperator','Operator','isNaN');
        n2bReplaced=length(listOfBlks);
        if n2bReplaced>0
            for i=1:n2bReplaced
                blk=listOfBlks{i};
                blkName=get_param(blk,'Name');
                orient=get_param(blk,'Orientation');
                pos=get_param(blk,'Position');
                bSampleTime=get_param(blk,'SampleTime');
                bOutDataTypeStr=get_param(blk,'OutDataTypeStr');

                newBlkPath=create_nan_model(obj,bSampleTime,bOutDataTypeStr);

                delete_block(blk);

                add_block(newBlkPath,blk,...
                'Name',blkName,...
                'Orientation',orient,...
                'Position',pos);

            end
        end

        listOfBlks=slexportprevious.utils.findBlockType(modelNameNoPath,...
        'RelationalOperator','Operator','isFinite');
        n2bReplaced=length(listOfBlks);
        if n2bReplaced>0
            for i=1:n2bReplaced
                blk=listOfBlks{i};
                blkName=get_param(blk,'Name');
                orient=get_param(blk,'Orientation');
                pos=get_param(blk,'Position');
                bSampleTime=get_param(blk,'SampleTime');
                bOutDataTypeStr=get_param(blk,'OutDataTypeStr');

                newBlkPath=create_isfinite_model(obj,bSampleTime,bOutDataTypeStr);

                delete_block(blk);

                add_block(newBlkPath,blk,...
                'Name',blkName,...
                'Orientation',orient,...
                'Position',pos);

            end
        end
    end
end

function blkName=create_inf_model(obj,bSampleTime,bOutDataTypeStr)

    blkName=[obj.getTempMdl,'/',obj.generateTempName];
    load_system('simulink');
    add_block('built-in/Subsystem',blkName);
    add_block('built-in/Inport',[blkName,'/In'],'Position',[30,32,60,48]);
    add_block('built-in/Abs',[blkName,'/a'],...
    'Position',[95,21,145,59],...
    'SampleTime',bSampleTime);
    add_block('built-in/Constant',[blkName,'/b'],'Value','inf',...
    'Position',[100,85,140,125],'SampleTime','inf');
    add_block('built-in/RelationalOperator',[blkName,'/c'],'relop','==',...
    'Position',[210,49,240,91],...
    'SampleTime',bSampleTime,...
    'OutDataTypeStr',bOutDataTypeStr);
    add_block('built-in/Outport',[blkName,'/Out'],'Position',[305,63,335,77]);
    add_line(blkName,'In/1','a/1');
    add_line(blkName,'a/1','c/1');
    add_line(blkName,'b/1','c/2');
    add_line(blkName,'c/1','Out/1');

end

function blkName=create_nan_model(obj,bSampleTime,bOutDataTypeStr)

    blkName=[obj.getTempMdl,'/',obj.generateTempName];
    load_system('simulink');
    add_block('built-in/Subsystem',blkName);
    add_block('built-in/Inport',[blkName,'/In'],'Position',[30,32,60,48]);
    add_block('built-in/RelationalOperator',[blkName,'/a'],'relop','!=',...
    'Position',[95,21,145,59]);
    add_block('built-in/Outport',[blkName,'/Out'],'Position',[260,33,290,47]);

    add_line(blkName,'In/1','a/1');
    add_line(blkName,'In/1','a/2');
    add_line(blkName,'a/1','Out/1');

    set_param([blkName,'/a'],'SampleTime',bSampleTime);
    set_param([blkName,'/a'],'OutDataTypeStr',bOutDataTypeStr);

end

function blkName=create_isfinite_model(obj,bSampleTime,bOutDataTypeStr)

    blkName=[obj.getTempMdl,'/',obj.generateTempName];
    load_system('simulink');
    add_block('built-in/Subsystem',blkName);
    add_block('built-in/Inport',[blkName,'/In'],'Position',[30,32,60,48]);


    add_block('built-in/Abs',[blkName,'/a1'],...
    'Position',[95,21,145,59],...
    'SampleTime',bSampleTime);
    add_block('simulink/Logic and Bit Operations/Compare To Constant',[blkName,'/a2'],...
    'relop','~=','Const','inf',...
    'Position',[175,21,225,59],...
    'LogicOutDataTypeMode','boolean');
    add_line(blkName,'In/1','a1/1');
    add_line(blkName,'a1/1','a2/1');


    add_block('built-in/RelationalOperator',[blkName,'/b1'],'relop','==',...
    'Position',[95,71,145,109],...
    'SampleTime',bSampleTime);
    add_line(blkName,'In/1','b1/1');
    add_line(blkName,'In/1','b1/2');


    add_block('built-in/Logic',[blkName,'/c'],'Operator','AND',...
    'Position',[300,46,350,80],...
    'SampleTime',bSampleTime,...
    'OutDataTypeStr',bOutDataTypeStr);
    add_block('built-in/Outport',[blkName,'/Out'],'Position',[415,57,445,73]);
    add_line(blkName,'a2/1','c/1');
    add_line(blkName,'b1/1','c/2');
    add_line(blkName,'c/1','Out/1');


end
