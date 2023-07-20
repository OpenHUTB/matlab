function frameConvBlocks(obj)









    if isR2007bOrEarlier(obj.ver)
        frmconvBlks=slexportprevious.utils.findBlockType(obj.modelName,'FrameConversion');

        if~isempty(frmconvBlks)

            libMdl='dspobslib';
            load_system(libMdl);


            replacementBlk=sprintf([libMdl,'/Frame Status\nConversion']);

            for i=1:length(frmconvBlks)
                blk=frmconvBlks{i};
                mode=get_param(blk,'InheritSamplingMode');



                if isequal(mode,'on')









                    orient=get_param(blk,'Orientation');
                    pos=get_param(blk,'Position');
                    delete_block(blk);
                    add_block(replacementBlk,blk,...
                    'Orientation',orient,...
                    'Position',pos,...
                    'growRefPort','on');
                end

            end

            close_system(libMdl,0);
        end

        obj.appendRule('<Block<BlockType|FrameConversion><InheritSamplingMode:remove>>');
    end
