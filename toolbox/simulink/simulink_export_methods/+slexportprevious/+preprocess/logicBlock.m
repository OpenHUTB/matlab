function logicBlock(obj)





    modelNameNoPath=obj.modelName;
    verobj=obj.ver;

    if isR2008bOrEarlier(verobj)
        listOfBlks=slexportprevious.utils.findBlockType(modelNameNoPath,'Logic','Operator','NXOR');

        n2bReplaced=length(listOfBlks);
        if n2bReplaced>0
            for i=1:n2bReplaced
                blk=listOfBlks{i};
                blkName=get_param(blk,'Name');
                orient=get_param(blk,'Orientation');
                pos=get_param(blk,'Position');
                bPorts=get_param(blk,'Ports');
                bInputs=get_param(blk,'Inputs');
                bIconShape=get_param(blk,'IconShape');
                bSampleTime=get_param(blk,'SampleTime');
                bAllPortsSameDT=get_param(blk,'AllPortsSameDT');
                bOutDataTypeStr=get_param(blk,'OutDataTypeStr');

                newBlkPath=create_nxor_model(obj,bPorts,bInputs,bIconShape,bSampleTime,bAllPortsSameDT,bOutDataTypeStr);

                delete_block(blk);

                add_block(newBlkPath,blk,...
                'Name',blkName,...
                'Orientation',orient,...
                'Position',pos);
            end
        end
    end
end


function blkName=create_nxor_model(obj,bPorts,bInputs,bIconShape,bSampleTime,bAllPortsSameDT,bOutDataTypeStr)


    blkName=[obj.getTempMdl,'/',obj.generateTempName];
    XORblk=[blkName,'/x'];
    NOTblk=[blkName,'/n'];
    add_block('built-in/Subsystem',blkName);
    add_block('built-in/Logic',XORblk,'Operator','XOR','Position',[95,21,145,59]);
    add_block('built-in/Logic',NOTblk,'Operator','NOT','Position',[175,21,225,59]);
    add_block('built-in/Outport',[blkName,'/Out'],'Position',[260,33,290,47]);
    add_line(blkName,'x/1','n/1');
    add_line(blkName,'n/1','Out/1');
    set_param(XORblk,'Inputs',bInputs);
    set_param(NOTblk,'Inputs','1');
    Ninputs=bPorts(1);
    for i=1:Ninputs
        bIName=['In',num2str(i)];
        add_block('built-in/Inport',[blkName,'/',bIName],'Position',[30,-7+30*i,60,7+30*i]);
        add_line(blkName,[bIName,'/1'],['x/',num2str(i)]);
    end


    set_param(XORblk,'IconShape',bIconShape);
    set_param(NOTblk,'IconShape',bIconShape);
    set_param(XORblk,'SampleTime',bSampleTime);
    set_param(NOTblk,'SampleTime',bSampleTime);
    set_param(XORblk,'OutDataTypeStr',bOutDataTypeStr);
    set_param(NOTblk,'OutDataTypeStr',bOutDataTypeStr);
    set_param(XORblk,'AllPortsSameDT',bAllPortsSameDT);
    set_param(NOTblk,'AllPortsSameDT',bAllPortsSameDT);

end
