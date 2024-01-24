function CrossverFilter(obj)

    verobj=obj.ver;

    if isR2019bOrEarlier(verobj)
        blocks=obj.findBlocksWithMaskType('audio.simulink.crossover');

        numDRBlks=length(blocks);

        if numDRBlks>0
            for blkIdx=1:numDRBlks
                blk=blocks{blkIdx};
                numCrossovers=get_param(blk,'NCrossovers');

                p1=strcmp(get_param(blk,'Crossover1Port'),'on');
                p2=strcmp(get_param(blk,'Crossover2Port'),'on');
                p3=strcmp(get_param(blk,'Crossover3Port'),'on');
                p4=strcmp(get_param(blk,'Crossover4Port'),'on');
                p5=strcmp(get_param(blk,'Order1Port'),'on');
                p6=strcmp(get_param(blk,'Order2Port'),'on');
                p7=strcmp(get_param(blk,'Order3Port'),'on');
                p8=strcmp(get_param(blk,'Order4Port'),'on');

                replace=false;
                switch numCrossovers
                case{1}
                    replace=p1||p5;
                case{2}
                    replace=p1||p5||p2||p6;
                case{3}
                    replace=p1||p5||p2||p6||p3||p7;
                case{4}
                    replace=p1||p5||p2||p6||p3||p7||p4||p8;
                end

                if replace
                    replaceWithEmpty(obj,blk)
                end

            end
        end
    end

end


function replaceWithEmpty(obj,blk)
    blkName=getString(message('audio:crossover:Icon'));
    obj.replaceWithEmptySubsystem(blk,blkName);
    msgStr=DAStudio.message('audio:dynamicrange:NewFeaturesNotAvailable');
    set_param(blk,'InitFcn',sprintf('error(''%s'')',msgStr));

end
