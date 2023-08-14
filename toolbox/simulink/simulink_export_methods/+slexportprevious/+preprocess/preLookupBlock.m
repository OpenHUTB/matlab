function preLookupBlock(obj)



    blkType='PreLookup';

    if isR2016aOrEarlier(obj.ver)
        PrelookupBlks=slexportprevious.utils.findBlockType(obj.modelName,blkType);
        if(~isempty(PrelookupBlks))

            for i=1:length(PrelookupBlks)
                blk=PrelookupBlks{i};

                if strcmp(get_param(blk,'OutputSelection'),'Index and fraction as bus')
                    obj.replaceWithEmptySubsystem(blk);
                elseif strcmp(get_param(blk,'OutputSelection'),'Index only')
                    set_param(blk,'OutputOnlyTheIndex','on');
                else
                    set_param(blk,'OutputOnlyTheIndex','off');
                end
            end
        end
    end


    if isR2016aOrEarlier(obj.ver)

        PrelookupBlks=slexportprevious.utils.findBlockType(obj.modelName,blkType);
        if(~isempty(PrelookupBlks))

            for i=1:length(PrelookupBlks)
                blk=PrelookupBlks{i};

                if strcmp(get_param(blk,'BreakpointsSpecification'),'Breakpoint object')
                    obj.replaceWithEmptySubsystem(blk);
                end
            end
        end
    end

    if isR2015aOrEarlier(obj.ver)
        prelookupBlks=slexportprevious.utils.findBlockType(obj.modelName,blkType);
        if(~isempty(prelookupBlks))

            for i=1:length(prelookupBlks)
                blk=prelookupBlks{i};

                if strcmp(get_param(blk,'BreakpointsSpecification'),'Explicit values')
                    continue;
                end

                obj.replaceWithEmptySubsystem(blk);
            end
        end
    end

    if isR2010aOrEarlier(obj.ver)
        preLookupBlocks=slexportprevious.utils.findBlockType(obj.modelName,blkType);

        if~isempty(preLookupBlocks)
            for i=1:length(preLookupBlocks)
                blk=preLookupBlocks{i};
                blkSID=slexportprevious.utils.escapeSIDFormat(get_param(blk,'SID'));

                inputPorts=1;
                outputPorts=2;
                if strcmp(get_param(blk,'BreakpointsDataSource'),'Input port')

                    inputPorts=inputPorts+1;
                end
                if strcmp(get_param(blk,'OutputOnlyTheIndex'),'on')

                    outputPorts=outputPorts-1;
                end
                obj.appendRule(sprintf('1<Block<BlockType|PreLookup><SID|"%s"><Ports:repval [%d, %d]>>',...
                blkSID,inputPorts,outputPorts));
            end
        end
    end

end
