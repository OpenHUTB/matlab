



function openVariantActionCB(userdata,cbinfo)

    blocks=SLStudio.Utils.getSelectedBlocks(cbinfo);
    assert(isscalar(blocks));
    blockH=blocks.handle;
    variantValue=userdata;

    if ishandle(blockH)
        if contains(variantValue,'active variant')
            variantValue=get_param(blockH,'ActiveVariant');

            if(isempty(variantValue))



                open_system(blockH);
                return;
            end
        else

            [variantValue]=strtok(variantValue,'(');
            variantValue=strtrim(variantValue);
        end

        blockType=get_param(blockH,'BlockType');

        if strcmp(blockType,'ModelReference')||...
            strcmp(blockType,'SubSystem')
            allVars=get_param(blockH,'Variants');
            idx=find(strcmp({allVars.Name},variantValue));
            if~isempty(idx)
                if(strcmp(blockType,'ModelReference'))
                    sysName=allVars(idx).ModelName;
                else
                    sysName=allVars(idx).BlockName;
                end
                open_system(sysName);
            end
        end

    end
end