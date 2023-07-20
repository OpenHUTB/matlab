function[propValue,propName]=atGetPropertyValue(this,propSrc,obj,objType,propName)





    if strcmpi(objType,'block')


        propValue=rptgen.safeGet(obj,propName,'get_param');


        if this.ShowNamePrompt
            propName=getPromptName(obj,propName);
        end
    else
        [propValue,propName]=getPropValue(propSrc,obj,propName);
    end



    function promptName=getPromptName(obj,propName)

        maskNames=get_param(obj,'MaskNames');
        maskNamesIdx=find(strcmp(maskNames,propName));
        if isempty(maskNamesIdx)
            dParam=get_param(obj,'dialogparameters');
            if isfield(dParam,propName)
                promptName=getfield(getfield(dParam,propName),'Prompt');
                promptName=strrep(promptName,':','');
            else
                promptName=rptgen.prettifyName(propName);
            end
        else
            maskPrompts=get_param(obj,'MaskPrompts');
            promptName=maskPrompts{maskNamesIdx(1)};
            promptName=strrep(promptName,':','');
        end

        if isempty(promptName)
            promptName=propName;
        end
