function SignalToWorkspaceBlock(obj)






    if isR2010bOrEarlier(obj.ver)

        stwsBlks=obj.findBlocksOfType('SignalToWorkspace');

        numStwBlks=length(stwsBlks);
        if numStwBlks>0

            for idx=1:numStwBlks



                blk=stwsBlks{idx};
                blkName=get_param(blk,'Name');
                orient=get_param(blk,'Orientation');
                pos=get_param(blk,'Position');
                Save2DSignal=get_param(blk,'Save2DSignal');
                SaveFormat=get_param(blk,'SaveFormat');
                paramPairs=GetStwsParamPairs(blk);


                delete_block(blk);

                if(...
                    (strcmp(Save2DSignal,...
                    'Inherit from input (this choice will be removed - see release notes)')||...
                    strcmp(Save2DSignal,...
                    '2-D array (concatenate along first dimension)'))||...
                    ~(strcmp(SaveFormat,'Array')||strcmp(SaveFormat,'Structure')));

















                    blkHdl=add_block('built-in/ToWorkspace',blk,...
                    'Name',blkName,...
                    'Orientation',orient,...
                    'Position',pos,...
                    'SampleTime','-1',...
                    paramPairs{:});

                else








                    newBlkName=obj.generateTempName;


                    load_system('dspsigattribs');



                    blkHdl=add_block('dspsigattribs/Frame Conversion',blk,...
                    'Name',newBlkName,...
                    'Position',pos,...
                    'Orientation',orient,...
                    'ShowName','off',...
                    'OutFrame','Sample-based');




                    blkHdl=CreateNewTWSBlockForSaveAs(blkHdl,blk,paramPairs);

                end
            end
        end
    end



    function paramPairs=GetStwsParamPairs(blk)



        paramNames=fields(get_param(blk,'IntrinsicDialogParameters'));
        paramPairs=cell(2*length(paramNames)-2,1);

        j=1;
        for i=1:length(paramNames)

            if~strcmp(paramNames{i},'Save2DSignal')
                if strcmp(paramNames{i},'SaveFormat')

                    saveFormat=get_param(blk,paramNames{i});
                    if(strcmp(saveFormat,'Array')||...
                        strcmp(saveFormat,'Structure')||...
                        strcmp(saveFormat,'Structure With Time'))
                        paramPairs{j}='SaveFormat';
                        paramPairs{j+1}=saveFormat;
                    else


                        paramPairs{j}='SaveFormat';
                        paramPairs{j+1}='Structure';
                    end
                else
                    paramPairs{j}=paramNames{i};
                    paramPairs{j+1}=get_param(blk,paramNames{i});
                end

                j=j+2;
            end
        end



        function newBlkHandle=CreateNewTWSBlockForSaveAs(fromBlk,toBlk,paramPairs)









            blkParentName=get_param(fromBlk,'Parent');

            fromBlkName=get_param(fromBlk,'Name');


            blkPos=get_param(fromBlk,'Position');
            blkOrient=get_param(fromBlk,'Orientation');
            blkCenter=mean([blkPos(1:2);blkPos(3:4)]);
            blkWidth=blkPos(3)-blkPos(1);
            blkHeight=blkPos(4)-blkPos(2);
            newBlkHOffset=40;
            newBlkVOffset=0;

            if strcmpi(blkOrient,'left')||strcmpi(blkOrient,'right')
                sign=strcmpi(blkOrient,'right');
                sign=sign*2-1;
                newBlkCenter=[blkCenter(1)+sign*(blkWidth/2+newBlkHOffset),...
                blkCenter(2)-newBlkVOffset];
                newBlkWidth=blkHeight;
                newBlkHeight=blkHeight;
            elseif(strcmpi(blkOrient,'up')||strcmpi(blkOrient,'down'))
                sign=strcmpi(blkOrient,'down');
                sign=sign*2-1;
                newBlkCenter=[blkCenter(1)-newBlkVOffset,...
                blkCenter(2)+sign*(blkHeight/2+newBlkHOffset)];
                newBlkWidth=blkWidth;
                newBlkHeight=blkWidth;
            end

            newBlkPos=[newBlkCenter(1)-newBlkWidth/2,...
            newBlkCenter(2)-newBlkHeight/2,...
            newBlkCenter(1)+newBlkWidth/2,...
            newBlkCenter(2)+newBlkHeight/2];


            newBlkHandle=add_block('built-in/ToWorkspace',toBlk,...
            'Position',newBlkPos,...
            'Orientation',blkOrient,...
            'ShowName','on',...
            'SampleTime','-1',...
            paramPairs{:});



            toBlkName=regexprep(get_param(toBlk,'Name'),'/','//');
            add_line(blkParentName,[fromBlkName,'/1'],...
            [toBlkName,'/1'],...
            'autorouting','on');



