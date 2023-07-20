function out=saturationDynamic(obj)





    out=slexportprevious.RuleSet;
    blkType='Saturation Dynamic';

    import slexportprevious.utils.findBlockType;

    if isR2022aOrEarlier(obj.ver)
        SaturationDynamicBlks=find_system(obj.modelName,...
        'LookUnderMasks','on',...
        'IncludeCommented','on',...
        'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
        'MaskType',blkType);

        if(~isempty(SaturationDynamicBlks))

            for i=1:length(SaturationDynamicBlks)



                blk=SaturationDynamicBlks{i};
                outDTStr=get_param(blk,'OutDataTypeStr');
                set_param(blk,'OutDataType',outDTStr);
                try
                    if(strcmp(outDTStr,'Inherit: Inherit via back propagation')||strcmp(outDTStr,'Inherit: Same as second input'))
                        set_param(blk,'OutputDataTypeScalingMode','Same as second input');
                        set_param(blk,'OutDataTypeStr','Inherit: Same as second input');
                        set_param(blk,'OutDataType','fixdt(1, 16)');
                    elseif(strcmp(outDTStr,'uint64'))
                        set_param(blk,'OutDataType','fixdt(0,64,0)');
                        set_param(blk,'OutputDataTypeScalingMode','Specify via dialog');
                    elseif(strcmp(outDTStr,'int64'))
                        set_param(blk,'OutDataType','fixdt(1,64,0)');
                        set_param(blk,'OutputDataTypeScalingMode','Specify via dialog');
                    elseif fixed.internal.type.isNameOfNumericType(outDTStr)
                        set_param(blk,'OutputDataTypeScalingMode',outDTStr);
                    elseif fixed.internal.type.isFixedOrInteger(outDTStr)
                        set_param(blk,'OutputDataTypeScalingMode','Specify via dialog');
                        set_param(blk,'OutScaling','[]');
                    end
                catch ME
                    if(strcmp(ME.identifier,'fixed:numerictype:unrecogDTNameStr'))



                        set_param(blk,'OutputDataTypeScalingMode','Specify via dialog');
                        set_param(blk,'OutDataType',outDTStr);
                        set_param(blk,'OutScaling','[]');
                    else
                        rethrow(ME);
                    end
                end
            end
        end
    end

end
