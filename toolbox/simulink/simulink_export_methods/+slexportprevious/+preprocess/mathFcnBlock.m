function mathFcnBlock(obj)






    import slexportprevious.utils.findBlockType;

    modelNameNoPath=obj.modelName;
    verobj=obj.ver;

    if isR2009bOrEarlier(verobj)
        aBlks=findBlockType(modelNameNoPath,'Sqrt','Operator','sqrt');

        n2bReplaced=length(aBlks);
        if n2bReplaced>0
            for i=1:n2bReplaced
                blk=aBlks{i};
                blkName=get_param(blk,'Name');
                orient=get_param(blk,'Orientation');
                pos=get_param(blk,'Position');
                outDt=get_param(blk,'OutDataTypeStr');
                sampleT=get_param(blk,'SampleTime');

                delete_block(blk);

                add_block('built-in/Math',blk,'Operator','sqrt',...
                'Name',blkName,...
                'Orientation',orient,...
                'Position',pos,...
                'OutDataTypeStr',outDt,...
                'SampleTime',sampleT);
            end
        end

        aBlks=findBlockType(modelNameNoPath,'Sqrt','Operator','rSqrt');
        n2bReplaced=length(aBlks);

        if n2bReplaced>0
            for i=1:n2bReplaced
                blk=aBlks{i};
                blkName=get_param(blk,'Name');
                orient=get_param(blk,'Orientation');
                pos=get_param(blk,'Position');
                outDt=get_param(blk,'OutDataTypeStr');
                sampleT=get_param(blk,'SampleTime');
                algType=get_param(blk,'AlgorithmType');
                nIterat=get_param(blk,'Iterations');
                intermDT=get_param(blk,'IntermediateResultsDataTypeStr');
                delete_block(blk);

                add_block('built-in/Math',blk,'Operator','1/sqrt',...
                'Name',blkName,...
                'Orientation',orient,...
                'Position',pos,...
                'OutDataTypeStr',outDt,...
                'SampleTime',sampleT,...
                'AlgorithmType',algType,...
                'Iterations',nIterat,...
                'IntermediateResultsDataTypeStr',intermDT);
            end
        end

        aBlks=findBlockType(modelNameNoPath,'Sqrt','Operator','signedSqrt');
        n2bReplaced=length(aBlks);
        if n2bReplaced>0

            newBlkPath=create_signedsqrt_model(obj);

            for i=1:n2bReplaced
                blk=aBlks{i};
                blkName=get_param(blk,'Name');
                orient=get_param(blk,'Orientation');
                pos=get_param(blk,'Position');
                outDt=get_param(blk,'OutDataTypeStr');
                sampleT=get_param(blk,'SampleTime');

                delete_block(blk);



                set_param([newBlkPath,'/Sqrt'],'SampleTime',sampleT);

                set_param([newBlkPath,'/Abs'],'SampleTime',sampleT);

                set_param([newBlkPath,'/Sign'],'SampleTime',sampleT);

                set_param([newBlkPath,'/Product'],'SampleTime',sampleT,...
                'OutDataTypeStr',outDt);


                add_block(newBlkPath,blk,...
                'Name',blkName,...
                'Orientation',orient,...
                'Position',pos);
            end
        end
    end


    if isR2009aOrEarlier(verobj)
        aBlks=findBlockType(modelNameNoPath,'Math','Operator','1/sqrt');

        n2bReplaced=length(aBlks);
        if n2bReplaced>0

            newBlkPath=create_rcpsqrt_model(obj);

            for i=1:n2bReplaced
                blk=aBlks{i};
                blkName=get_param(blk,'Name');
                orient=get_param(blk,'Orientation');
                pos=get_param(blk,'Position');
                outDt=get_param(blk,'OutDataTypeStr');
                sampleT=get_param(blk,'SampleTime');

                set_param([newBlkPath,'/a'],'SampleTime',sampleT,...
                'OutDataTypeStr',outDt);
                set_param([newBlkPath,'/b'],'SampleTime',sampleT,...
                'OutDataTypeStr',outDt);


                delete_block(blk);

                add_block(newBlkPath,blk,...
                'Name',blkName,...
                'Orientation',orient,...
                'Position',pos);
            end
        end
    end

end


function blkName=create_rcpsqrt_model(obj)

    blkName=[obj.getTempMdl,'/',obj.generateTempName];
    add_block('built-in/Subsystem',blkName);
    add_block('built-in/Inport',[blkName,'/In'],'Position',[30,32,60,48]);
    add_block('built-in/Math',[blkName,'/a'],'Operator','sqrt',...
    'Position',[105,21,155,59]);
    add_block('built-in/Math',[blkName,'/b'],'Operator','reciprocal',...
    'Position',[185,21,235,59]);
    add_block('built-in/Outport',[blkName,'/Out'],...
    'Position',[295,33,325,47]);
    add_line(blkName,'In/1','a/1');
    add_line(blkName,'a/1','b/1');
    add_line(blkName,'b/1','Out/1');

end


function blkName=create_signedsqrt_model(obj)

    outDtInternal='Inherit: Inherit via internal rule';

    blkName=[obj.getTempMdl,'/',obj.generateTempName];
    add_block('built-in/Subsystem',blkName);
    add_block('built-in/Inport',[blkName,'/In'],'Position',[30,42,60,58]);
    add_block('built-in/Abs',[blkName,'/Abs'],'Position',[120,35,150,65],...
    'OutDataTypeStr',outDtInternal);
    add_block('built-in/Math',[blkName,'/Sqrt'],'Operator','sqrt','Position',[200,31,250,69],...
    'OutDataTypeStr',outDtInternal);
    add_block('built-in/Signum',[blkName,'/Sign'],'Position',[160,90,190,120]);
    add_block('built-in/Product',[blkName,'/Product'],'Position',[300,20,325,135]);
    add_block('built-in/Outport',[blkName,'/Out'],...
    'Position',[380,73,410,87]);
    add_line(blkName,'In/1','Abs/1');
    add_line(blkName,'Abs/1','Sqrt/1');
    add_line(blkName,'Sqrt/1','Product/1');
    add_line(blkName,'In/1','Sign/1');
    add_line(blkName,'Sign/1','Product/2');
    add_line(blkName,'Product/1','Out/1');

end
