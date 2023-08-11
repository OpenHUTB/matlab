function MultiObjectTracker(obj)

    if isR2017aOrEarlier(obj.ver)
        blks=findBlocksWithMaskType(obj,'multiObjectTracker');
        obj.replaceWithEmptySubsystem(blks);
        return
    end

    if isR2019bOrEarlier(obj.ver)
        blks=obj.findBlocksWithMaskType('multiObjectTracker');
        msg='driving:multiObjectTracker:';

        for idx=1:numel(blks)
            this_blk=blks{idx};
            trkrInd=get_param(this_blk,'TrackerIndex');
            if eval(trkrInd)~=0


                subsys_msg=DAStudio.message([msg,'EmptySubsystem_Trkr20a']);
                subsys_err=DAStudio.message([msg,'NewFeaturesNotAvailable']);
                obj.replaceWithEmptySubsystem(this_blk,subsys_msg,subsys_err);
                continue
            end
            stateParams=get_param(this_blk,'StateParametersSimulink');
            if~strcmp(stateParams,'struct')


                subsys_msg=DAStudio.message([msg,'EmptySubsystem_Trkr20a']);
                subsys_err=DAStudio.message([msg,'NewFeaturesNotAvailable']);
                obj.replaceWithEmptySubsystem(this_blk,subsys_msg,subsys_err);
                continue
            end
            delThrsh=get_param(this_blk,'DeletionThreshold');
            [numTokens,validDelThrshTokens]=parseParameter(delThrsh);
            if numTokens>2||(numTokens==2&&~strcmp(validDelThrshTokens{1},validDelThrshTokens{2}))


                subsys_msg=DAStudio.message([msg,'EmptySubsystem_Trkr20a']);
                subsys_err=DAStudio.message([msg,'NewFeaturesNotAvailable']);
                obj.replaceWithEmptySubsystem(this_blk,subsys_msg,subsys_err);
                continue
            end
            asnThrsh=get_param(this_blk,'AssignmentThreshold');
            [numTokens,validAsnThrshTokens]=parseParameter(asnThrsh);
            if numTokens>2||(numTokens==2&&~strcmp(validAsnThrshTokens{2},'Inf'))


                subsys_msg=DAStudio.message([msg,'EmptySubsystem_Trkr20a']);
                subsys_err=DAStudio.message([msg,'NewFeaturesNotAvailable']);
                obj.replaceWithEmptySubsystem(this_blk,subsys_msg,subsys_err);
                continue
            end
            detTrkIDs=get_param(this_blk,'HasDetectableTrackIDsInput');
            if~strcmpi(detTrkIDs,'off')


                subsys_msg=DAStudio.message([msg,'EmptySubsystem_Trkr20a']);
                subsys_err=DAStudio.message([msg,'NewFeaturesNotAvailable']);
                obj.replaceWithEmptySubsystem(this_blk,subsys_msg,subsys_err);
                continue
            end



            set_param(this_blk,'AssignmentThreshold',validAsnThrshTokens{1});
            set_param(this_blk,'DeletionThreshold',validDelThrshTokens{1});
            blks{idx}=this_blk;
        end



    end

    if isR2020bOrEarlier(obj.ver)
        blks=obj.findBlocksWithMaskType('multiObjectTracker');
        msg='driving:multiObjectTracker:';

        for idx=1:numel(blks)
            this_blk=blks{idx};

            stateParamSource=get_param(this_blk,'HasStateParametersInput');
            oosmHandling=get_param(this_blk,'OOSMHandling');
            if~(islogical(stateParamSource)...
                ||strcmpi(oosmHandling,'Terminate')||strcmpi(oosmHandling,'Neglect'))


                subsys_msg=DAStudio.message([msg,'EmptySubsystem_Trkr21a']);
                subsys_err=DAStudio.message([msg,'NewFeaturesNotAvailable']);
                obj.replaceWithEmptySubsystem(this_blk,subsys_msg,subsys_err);
                continue
            end
            blks{idx}=this_blk;
        end
    end
end

function[numTokens,validTokens]=parseParameter(inStr)








    str=char(inStr);
    c=strsplit(str,{' ',',','[',']'});
    validTokens=c(cellfun(@(c)~isempty(c),c));
    numTokens=numel(validTokens);
end
