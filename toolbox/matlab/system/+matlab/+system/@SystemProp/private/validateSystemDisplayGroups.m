

function validateSystemDisplayGroups(systemName,groups)

    validateattributes(groups,{'matlab.system.display.PropertyGroup'},{},'getPropertyGroupsImpl','output');

    mc=meta.class.fromName(systemName);
    metaPropertyList=mc.PropertyList;
    candidateProperties=getCandidateDisplayProperties(metaPropertyList);

    allDisplayProps={};
    for group=groups
        groupPropertyNames=group.getPropertyNames;
        validateProperties(groupPropertyNames,group.DependOnPrivatePropertyList);
        validateActions(group.Actions,groupPropertyNames);
        validateImage(group.Image,groupPropertyNames);

        if isa(group,'matlab.system.display.SectionGroup')
            for sectionGroup=group.Sections
                groupPropertyNames=sectionGroup.getPropertyNames;
                validateProperties(groupPropertyNames,sectionGroup.DependOnPrivatePropertyList);
                validateActions(sectionGroup.Actions,groupPropertyNames);
                validateImage(sectionGroup.Image,groupPropertyNames);
            end
        end
    end

    function validateProperties(groupProps,dependOnPrivateOnlyProps)

        for propInd=1:numel(groupProps)
            propName=groupProps{propInd};


            if isempty(metaPropertyList)||~ismember(propName,{metaPropertyList.Name})
                error(message('MATLAB:system:unknownDisplayProperty',propName));
            end


            if ismember(propName,allDisplayProps)
                error(message('MATLAB:system:duplicateDisplayProperty',propName));
            end


            if isempty(candidateProperties)||~ismember(propName,{candidateProperties.Name})
                error(message('MATLAB:system:invalidDisplayProperty',propName));
            end

            allDisplayProps{end+1}=propName;%#ok<AGROW>
        end

        for propInd=1:numel(dependOnPrivateOnlyProps)

            propName=dependOnPrivateOnlyProps{propInd};
            if~ismember(propName,groupProps)
                error(message('MATLAB:system:unknownDependOnPrivateProperty',propName));
            end
        end
    end

    function validateActions(actions,groupProps)
        for action=actions
            actionPlacement=action.Placement;
            if~ismember(actionPlacement,[{'first','last'},groupProps])
                error(message('MATLAB:system:unknownActionPlacement',actionPlacement));
            end
        end
    end
    function validateImage(image,groupProps)
        for img=image
            imgFile=img.File;
            if isempty(imgFile)

            end

            imagePlacement=img.Placement;
            if~ismember(imagePlacement,[{'first','last'},groupProps])

            end
        end
    end
end
