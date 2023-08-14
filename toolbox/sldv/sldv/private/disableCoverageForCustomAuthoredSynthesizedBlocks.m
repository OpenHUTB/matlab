function disableCoverageForCustomAuthoredSynthesizedBlocks(maskBlkH)


    disableCoverage(maskBlkH);
    enableCoverageForOriginalBlock(maskBlkH);

    function enableCoverageForOriginalBlock(blkH)
        origBlk=sldvprivate('observableBlockInsideMask',blkH);
        try

            parentName=Simulink.ID.getFullName(blkH);
            set_param([parentName,'/',origBlk],'DisableCoverage','off');
        catch
            return;
        end
    end

    function disableCoverage(blkH)
        blkList=find_system(blkH,'SearchDepth',1,'LookUnderMasks','all');
        for ind=1:numel(blkList)
            if isequal(blkH,blkList(ind))
                continue;
            elseif strcmp('SubSystem',get_param(blkList(ind),'BlockType'))
                set_param(blkList(ind),'DisableCoverage','on');
                disableCoverage(blkList(ind));
            else
                set_param(blkList(ind),'DisableCoverage','on');
            end
        end
    end
end