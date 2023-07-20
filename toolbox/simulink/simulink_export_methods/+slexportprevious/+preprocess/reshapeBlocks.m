function reshapeBlocks(obj)









    if isR2006aOrEarlier(obj.ver)
        reshapeBlks=slexportprevious.utils.findBlockType(obj.modelName,'Reshape');

        if~isempty(reshapeBlks)


            tempLib=getTempLib(obj);
            sfuncReshapeBlk=[tempLib,'/Reshape'];
            add_block('built-in/S-Function',sfuncReshapeBlk);
            set_param(sfuncReshapeBlk,...
            'Mask','on',...
            'FunctionName','sreshape',...
            'Parameters','OutputDimensionality,OutputDimensions',...
            'MaskVariables','OutputDimensionality=@1;OutputDimensions=@2;',...
            'MaskStyleString','popup(1-D array|Column vector|Row vector|Customize),edit',...
            'MaskValueString','1-D array|[1,1]',...
            'MaskType','Reshape');
            save_system(tempLib);

            for i=1:length(reshapeBlks)
                blk=reshapeBlks{i};






                outputOrient=get_param(blk,'OutputDimensionality');
                outputDimensions=get_param(blk,'OutputDimensions');


                switch lower(outputOrient)
                case '1-d array'
                    outputOrient='1-D array';
                case 'column vector (2-d)'
                    outputOrient='Column vector';
                case 'row vector (2-d)'
                    outputOrient='Row vector';
                case{'customize (n-d)','customize'}
                    outputOrient='Customize';
                end

                orient=get_param(blk,'Orientation');
                pos=get_param(blk,'Position');

                delete_block(blk);
                add_block(sfuncReshapeBlk,blk,...
                'OutputDimensionality',outputOrient,...
                'Orientation',orient,...
                'Position',pos);







                try
                    set_param(blk,'OutputDimensions',outputDimensions);
                catch %#ok<CTCH> to remove mlint warning
                end
            end





            reshapeOldRef='simulink/Math\nOperations/Reshape';
            obj.appendRule(slexportprevious.rulefactory.replaceInSourceBlock('SourceBlock',...
            sfuncReshapeBlk,reshapeOldRef));

        end
    end
