function exception=createVariantContentException(variant,validationResult)












    TYPE_INDEX=1;
    NAME_INDEX=2;
    PROP_INDEX=3;
    VALUE_INDEX=4;
    exception=MException(message('SimBiology:SimFunction:InvalidVariant',variant.Name));
    for contentIndex=1:size(validationResult,2)
        badContents=find(~validationResult(:,contentIndex));
        if isempty(badContents)
            continue
        end
        [type,name,prop,~]=variant.Content{contentIndex}{:};
        for iContent=1:numel(badContents)
            if badContents(iContent)==TYPE_INDEX
                msg=message('SimBiology:bmodel:SB_PATCH_COMPONENT_TYPE_NOT_SUPPORTED',type);


                exception=exception.addCause(MException(msg));
                break
            else
                switch badContents(iContent)
                case NAME_INDEX
                    msg=message('SimBiology:sbservices:SB_UnresolvedPatchObject',type,name);
                case PROP_INDEX
                    msg=message('SimBiology:bmodel:SB_PATCH_INVALID_PROPERTY',prop,type,getPropName(type));
                case VALUE_INDEX
                    msg=message('SimBiology:sbservices:SB_BadPatchComponentProperty',getPropName(type),type,name);
                end
                exception=exception.addCause(MException(msg));
            end
        end
    end
end

function prop=getPropName(type)
    switch lower(type)
    case 'species'
        prop='InitialAmount';
    case 'parameter'
        prop='Value';
    case 'compartment'
        prop='Capacity';
    otherwise
        error(message('SimBiology:Internal:InternalError'))
    end
end
