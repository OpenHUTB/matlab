function toWorkspace(obj)
















    if isR2013bOrEarlier(obj.ver)
        toWksBlks=...
        slexportprevious.utils.findBlockType(obj.modelName,'ToWorkspace');

        numToWksBlks=length(toWksBlks);

        if numToWksBlks>0
            for idx=1:numToWksBlks
                blk=toWksBlks{idx};

                switch get_param(blk,'SaveFormat')
                case{'Array','Structure'}
                    insertFrameBlock(obj,blk);
                end
            end
        end
    end


    function insertFrameBlock(obj,blk)

        if strncmp(get_param(blk,'Save2DSignal'),'2-D',3)
            frameOrSample='Frame-based';
        else
            frameOrSample='Sample-based';
        end


        orient=get_param(blk,'Orientation');
        pos=get_param(blk,'Position');



        ph=get_param(blk,'PortHandles');
        line=get_param(ph.Inport,'Line');
        if isscalar(line)
            if~isequal(line,-1)
                srcH=get_param(line,'SrcPortHandle');
                srcBlk=get_param(srcH,'Parent');
                srcBlkName=get_param(srcBlk,'Name');
                srcBlkPortNum=get_param(srcH,'PortNumber');
                delete_line(line);
            end
        else
            return;
        end


        translateToWorkspace(blk,pos,orient);


        newBlkName=obj.generateTempName;
        par=get_param(blk,'Parent');
        newBlk=[par,'/',newBlkName];
        frameBlkHdl=add_block('built-in/FrameConversion',newBlk,...
        'Position',pos,...
        'Orientation',orient,...
        'ShowName','off',...
        'OutFrame',frameOrSample);


        toWksBlkName=get_param(blk,'Name');
        frameBlkName=get_param(frameBlkHdl,'Name');
        if~isequal(line,-1)
            add_line(par,[srcBlkName,'/',num2str(srcBlkPortNum)],...
            [frameBlkName,'/1'],'autorouting','on');
        end
        add_line(par,[frameBlkName,'/1'],[toWksBlkName,'/1'],...
        'autorouting','on');


        function translateToWorkspace(blk,blkPos,blkOrient)

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

            set_param(blk,'Position',newBlkPos);
