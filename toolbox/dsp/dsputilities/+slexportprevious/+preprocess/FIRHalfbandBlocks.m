function FIRHalfbandBlocks(obj)



    if isR2021bOrEarlier(obj.ver)


        maskTypeFIRHB={'dsp.simulink.FIRHalfbandDecimator',...
        'dsp.simulink.FIRHalfbandInterpolator'};
        msg={'dsp:system:FIRHalfbandDecimator:',...
        'dsp:system:FIRHalfbandInterpolator:'};
        for i=1:numel(maskTypeFIRHB)

            blksKaiser=obj.findBlocksWithMaskType(maskTypeFIRHB{i},...
            'DesignMethod','Kaiser');

            blksAuto=obj.findBlocksWithMaskType(maskTypeFIRHB{i},...
            'DesignMethod','Auto');
            subsys_msg=DAStudio.message([msg{i},'EmptySubsystem_DesignMethod']);
            subsys_err=DAStudio.message([msg{i},'NewFeaturesNotAvailable_DesignMethod']);

            for idx=1:numel(blksKaiser)

                this_block=blksKaiser{idx};
                obj.replaceWithEmptySubsystem(this_block,subsys_msg,subsys_err);
            end
            for idx=1:numel(blksAuto)
                this_block=blksAuto{idx};
                this_block_handle=getSimulinkBlockHandle(this_block);


                Specification=get_param(this_block_handle,'Specification');
                TransitionWidth=str2double(get_param(this_block_handle,'TransitionWidth'));
                SampleRate=str2double(get_param(this_block_handle,'SampleRate'));
                StopbandAttenuation=str2double(get_param(this_block_handle,'StopbandAttenuation'));
                FilterOrder=str2double(get_param(this_block_handle,'FilterOrder'));

                chosenMethod=dsp.internal.FIRHalfbandBase.computeAutoDesignMethod(...
                Specification,TransitionWidth/SampleRate,...
                StopbandAttenuation,FilterOrder);


                if strcmpi(chosenMethod,'Kaiser')
                    obj.replaceWithEmptySubsystem(this_block,subsys_msg,subsys_err);
                end
            end
        end
    end

    if isR2017bOrEarlier(obj.ver)


        localReplaceCoefSpecBlocks(obj,...
        'dsp.simulink.FIRHalfbandDecimator');
        localReplaceCoefSpecBlocks(obj,...
        'dsp.simulink.FIRHalfbandInterpolator');
    end

end


function localReplaceCoefSpecBlocks(obj,maskTypeFIRHB)


    subsys_msg='EmptySubsystem_SpecCoef';
    subsys_err='NewFeaturesNotAvailable';
    blksToRplc=obj.findBlocksWithMaskType(maskTypeFIRHB,...
    'Specification','Coefficients');

    for idx=1:numel(blksToRplc)
        this_block=blksToRplc{idx};
        obj.replaceWithEmptySubsystem(this_block,subsys_msg,subsys_err);
    end

end
