function FusionReplacements(obj)




    if isR2022aOrEarlier(obj.ver)
        obj.removeLibraryLinksTo('trackingscenarioandsensormodelslib/Fusion Radar Sensor');
        obj.removeLibraryLinksTo('trackingscenarioandsensormodelslib/Scenario To Platform');
    end

    if isR2021bOrEarlier(obj.ver)
        blks=obj.findBlocksWithMaskType('fusion.simulink.trackerGNN');
        msgs='fusion:trackerGNN:';
        for idx=1:numel(blks)
            thisBlk=blks{idx};
            isReplaced=false;
            isReplaced=isReplaced||updateMemoryManagement(thisBlk,msgs);
            isReplaced=isReplaced||updateAssignmentClustering(thisBlk,msgs);
        end

        blks=obj.findBlocksWithMaskType('fusion.simulink.trackerJPDA');
        msgs='fusion:trackerJPDA:';
        for idx=1:numel(blks)
            thisBlk=blks{idx};
            updateMemoryManagement(thisBlk,msgs);
        end

        blks=obj.findBlocksWithMaskType('fusion.simulink.trackOSPAMetric');
        msgs='fusion:simulink:trackOSPAMetric:';
        for idx=1:numel(blks)
            thisBlk=blks{idx};
            updateOSPA2Metric(thisBlk,msgs);
        end
    end

    if isR2021aOrEarlier(obj.ver)

        obj.removeLibraryLinksTo('trackingscenarioandsensormodelslib/Tracking Scenario Reader');
        obj.removeLibraryLinksTo('motalgorithmslib/Grid-Based Multi Object Tracker');
    end

    if isR2020bOrEarlier(obj.ver)
        blks=obj.findBlocksWithMaskType('fusion.simulink.trackerGNN');
        msg='fusion:trackerGNN:';
        for idx=1:numel(blks)
            this_blk=blks{idx};
            isReplaced=false;
            isReplaced=isReplaced||updateEmptyTrackerIndex(this_blk,msg);
            isReplaced=isReplaced||updateEmptyStateParametersSource(this_blk,msg);
            blks{idx}=this_blk;
        end

        blks=obj.findBlocksWithMaskType('fusion.simulink.trackerJPDA');
        msg='fusion:trackerJPDA:';
        for idx=1:numel(blks)
            this_blk=blks{idx};
            isReplaced=false;
            isReplaced=isReplaced||updateEmptyTrackerIndex(this_blk,msg);
            isReplaced=isReplaced||updateEmptyMaxNumEventsSimulink(this_blk,msg);
            isReplaced=isReplaced||updateEmptyStateParametersSource(this_blk,msg);
            blks{idx}=this_blk;
        end

        blks=obj.findBlocksWithMaskType('fusion.simulink.trackerTOMHT');
        msg='fusion:simulink:trackerTOMHT:';
        for idx=1:numel(blks)
            this_blk=blks{idx};
            updateEmptyStateParametersSource(this_blk,msg);
            blks{idx}=this_blk;
        end

        obj.removeLibraryLinksTo('motalgorithmslib/Track-To-Track Fuser');
        obj.removeLibraryLinksTo('trackmetricslib/Generalized Optimal Subpattern Assignment Metric');
        obj.removeLibraryLinksTo('motalgorithmslib/Probability Hypothesis Density Tracker');
    end

    if isR2019bOrEarlier(obj.ver)
        obj.removeLibraryLinksTo('motalgorithmslib/Track-Oriented Multi-Hypothesis Tracker');
    end

    if isR2019aOrEarlier(obj.ver)
        obj.removeLibraryLinksTo('motalgorithmslib/Global Nearest Neighbor Multi Object Tracker');
        obj.removeLibraryLinksTo('motalgorithmslib/Joint Probabilistic Data Association Multi Object Tracker');
    end

    function isReplaced=updateEmptyTrackerIndex(this_blk,msg)

        trkrInd=get_param(this_blk,'TrackerIndex');
        isReplaced=eval(trkrInd)~=0;
        if isReplaced


            subsys_msg=DAStudio.message([msg,'EmptySubsystem_Trkr21a']);
            subsys_err=DAStudio.message([msg,'NewFeaturesNotAvailable']);
            obj.replaceWithEmptySubsystem(this_blk,subsys_msg,subsys_err);
        end
    end


    function isReplaced=updateEmptyStateParametersSource(this_blk,msg)
        stateParamSource=get_param(this_blk,'HasStateParametersInput');
        isReplaced=strcmp(stateParamSource,'on');
        if isReplaced


            subsys_msg=DAStudio.message([msg,'EmptySubsystem_Trkr21a']);
            subsys_err=DAStudio.message([msg,'NewFeaturesNotAvailable']);
            obj.replaceWithEmptySubsystem(this_blk,subsys_msg,subsys_err);
        end
    end

    function isReplaced=updateEmptyMaxNumEventsSimulink(this_blk,msg)

        maxNumEvents=get_param(this_blk,'MaxNumEvents');
        isReplaced=isfinite(eval(maxNumEvents));
        if isReplaced


            subsys_msg=DAStudio.message([msg,'EmptySubsystem_Trkr21a']);
            subsys_err=DAStudio.message([msg,'NewFeaturesNotAvailable']);
            obj.replaceWithEmptySubsystem(this_blk,subsys_msg,subsys_err);
        end
    end

    function isReplaced=updateMemoryManagement(this_blk,msg)
        enableMemManagement=get_param(this_blk,'EnableMemoryManagement');
        isReplaced=strcmpi(enableMemManagement,'on');
        if isReplaced

            subsys_msg=DAStudio.message('fusion:internal:TrackerMemoryManagementUtilities:MemoryManagementSimulink22a');
            subsys_err=DAStudio.message([msg,'NewFeaturesNotAvailable']);
            obj.replaceWithEmptySubsystem(this_blk,subsys_msg,subsys_err);
        end
    end

    function isReplaced=updateAssignmentClustering(this_blk,msg)
        assignmentClustering=get_param(this_blk,'AssignmentClustering');
        isReplaced=strcmpi(assignmentClustering,'on');
        if isReplaced

            subsys_msg=DAStudio.message([msg,'AssignmentClusteringSimulink22a']);
            subsys_err=DAStudio.message([msg,'NewFeaturesNotAvailable']);
            obj.replaceWithEmptySubsystem(this_blk,subsys_msg,subsys_err);
        end
    end

    function isReplaced=updateOSPA2Metric(this_blk,msg)
        metric=get_param(this_blk,'Metric');
        isReplaced=strcmpi(metric,'OSPA(2)');
        if isReplaced

            subsys_msg=DAStudio.message([msg,'OSPA2MetricSimulink22a']);
            subsys_err=DAStudio.message([msg,'NewFeaturesNotAvailable']);
            obj.replaceWithEmptySubsystem(this_blk,subsys_msg,subsys_err);
        end
    end

end

