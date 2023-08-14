function maskFormalPrmTypes(obj)




    unidt='unidt';
    designMin='min';
    designMax='max';
    if isR2009aOrEarlier(obj.ver)




        masks=find_system(obj.modelName,...
        'LookUnderMasks','on',...
        'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
        'FollowLinks','off',...
        'Mask','on');

        for i=1:length(masks)
            if getSimulinkBlockHandle(masks{i})<0
                continue;
            end
            linkStatus=get_param(masks{i},'LinkStatus');
            if isequal(linkStatus,'resolved')
                continue;
            end
            styleChanged=false;
            maskstyles=get_param(masks{i},'MaskStyles');
            for j=1:length(maskstyles)

                if strncmp(maskstyles{j},unidt,length(unidt))||...
                    strncmp(maskstyles{j},designMin,length(designMin))||...
                    strncmp(maskstyles{j},designMax,length(designMax))
                    maskstyles{j}='edit';
                    styleChanged=true;
                end
            end



            if styleChanged




                [maskvalues,valueChanged]=translateMaskValues(get_param(masks{i},'MaskValues'));

                set_param(masks{i},'MaskStyles',maskstyles);
                if valueChanged
                    set_param(masks{i},'MaskValues',maskvalues);
                end
            end
        end
        return;
    end

    if isR2010aOrEarlier(obj.ver)


        masks=find_system(obj.modelName,...
        'LookUnderMasks','on',...
        'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
        'FollowLinks','off',...
        'Mask','on');

        for i=1:length(masks)
            if getSimulinkBlockHandle(masks{i})<0
                continue;
            end
            linkStatus=get_param(masks{i},'LinkStatus');
            if isequal(linkStatus,'resolved')
                continue;
            end

            maskstylestring=get_param(masks{i},'MaskStyleString');

            maskstylestring_new=regexprep(maskstylestring,'\{u=[^}]*\}','');



            maskstylestring_new=regexprep(maskstylestring_new,'unidt\((\{a=[^}]*\})?\)','edit');

            if~isequal(maskstylestring_new,maskstylestring)




                [maskvalues,valueChanged]=translateMaskValues(get_param(masks{i},'MaskValues'));

                set_param(masks{i},'MaskStyleString',maskstylestring_new);


                if(valueChanged)
                    set_param(masks{i},'MaskValues',maskvalues);
                end
            end
        end
        return;
    end

    if isR2019aOrEarlier(obj.ver)




        masks=find_system(obj.modelName,...
        'LookUnderMasks','on',...
        'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
        'FollowLinks','off',...
        'Mask','on');

        for i=1:length(masks)
            blockHandle=getSimulinkBlockHandle(masks{i});
            if blockHandle<0
                continue;
            end
            linkStatus=get_param(masks{i},'LinkStatus');
            if isequal(linkStatus,'resolved')
                continue;
            end

            maskObj=Simulink.Mask.get(blockHandle);
            for j=1:length(maskObj.Parameters)
                maskParam=maskObj.Parameters(j);
                if strcmp(maskParam.Type,'combobox')&&...
                    strcmp(maskParam.Evaluate,'on')
                    comboboxValue=maskParam.Value;
                    maskParam.Type='edit';
                    maskParam.Value=comboboxValue;
                end
            end
        end
        return;
    end

    if isR2020bOrEarlier(obj.ver)




        masks=find_system(obj.modelName,...
        'LookUnderMasks','on',...
        'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
        'FollowLinks','off',...
        'Mask','on');

        for i=1:length(masks)
            blockHandle=getSimulinkBlockHandle(masks{i});
            if blockHandle<0
                continue;
            end
            linkStatus=get_param(masks{i},'LinkStatus');
            if isequal(linkStatus,'resolved')
                continue;
            end

            maskObj=Simulink.Mask.get(blockHandle);
            for j=1:length(maskObj.Parameters)
                maskParam=maskObj.Parameters(j);
                if strcmp(maskParam.Type,'popup')&&isa(maskParam.TypeOptions,'Simulink.Mask.EnumerationTypeOptions')
                    typeOptionElements=maskParam.TypeOptions.EnumerationMembers;
                    stringTypeOptions=cell(numel(typeOptionElements),1);
                    for k=1:numel(stringTypeOptions)
                        stringTypeOptions{k}=typeOptionElements(k).DescriptiveName;
                    end
                    maskParam.TypeOptions=stringTypeOptions;
                end
            end
        end
        return;
    end





    function[newMaskValues,valueChanged]=translateMaskValues(oldMaskValues)

        newMaskValues=cell(size(oldMaskValues));
        for i=1:length(oldMaskValues)

            newMaskValues{i}=regexprep(oldMaskValues{i},'^\s*Bus:\s*','');


            newMaskValues{i}=regexprep(newMaskValues{i},'^\s*Enum:\s*','?');
        end
        if isequal(newMaskValues,oldMaskValues)
            valueChanged=false;
        else
            valueChanged=true;
        end



