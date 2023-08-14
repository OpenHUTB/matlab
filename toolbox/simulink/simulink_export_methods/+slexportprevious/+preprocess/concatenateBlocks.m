function concatenateBlocks(obj)








    if isR2006bOrEarlier(obj.ver)
        concatBlks=slexportprevious.utils.findBlockType(obj.modelName,'Concatenate');

        if(isempty(concatBlks))
            return;
        end



        tempLib=getTempLib(obj);
        matrixConcatBlk=[tempLib,'/Matrix Concatenation'];
        add_block('built-in/S-Function',matrixConcatBlk);
        set_param(matrixConcatBlk,...
        'Mask','on',...
        'FunctionName','smatrxcat',...
        'Parameters','numInports,catMethod',...
        'MaskVariables','numInports=@1;catMethod=@2;',...
        'MaskValueString','2|Horizontal',...
        'MaskStyleString','edit,popup(Horizontal|Vertical)',...
        'MaskType','Matrix Concatenation');
        save_system(tempLib);

        catMethodList={'Vertical','Horizontal'};

        for i=1:length(concatBlks)
            blk=concatBlks{i};
            mode=get_param(blk,'Mode');
            catDim=strtrim(get_param(blk,'ConcatenateDimension'));
            orient=get_param(blk,'Orientation');
            pos=get_param(blk,'Position');
            portHandles=get_param(blk,'PortHandles');
            nInputPorts=length(portHandles.Inport);



            if isequal(mode,'Vector')













            elseif isequal(mode,'Multidimensional array')&&...
                ismember(catDim,{'1','2'})

















                nInputs=get_param(blk,'NumInputs');
                delete_block(blk);
                add_block(matrixConcatBlk,blk,...
                'Orientation',orient,...
                'numInPorts',sprintf('%d',nInputPorts),...
                'catMethod',catMethodList{eval(catDim)},...
                'GraphicalNumInputPorts',sprintf('%d',nInputPorts),...
                'Position',pos);




                try
                    set_param(blk,'numInPorts',nInputs);
                catch %#ok<CTCH> to remove mlint warning
                end
            else








                obj.replaceWithEmptySubsystem(blk);
            end
        end



        matrixConcatOldRef='simulink/Math\nOperations/Matrix\nConcatenation';
        obj.appendRule(slexportprevious.rulefactory.replaceInSourceBlock('SourceBlock',...
        matrixConcatBlk,matrixConcatOldRef));

    end
