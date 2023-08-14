

function addParameterWriterBlockCB(cbinfo)
    if SLStudio.Utils.isLockedSystem(cbinfo)
        return;
    end

    blockInfo=SLStudio.Utils.getSelectedBlocks(cbinfo);
    block=blockInfo.getFullPathName;
    accessorInfo.fontsize=cbinfo.studio.getCurrentFontSize;
    accessorInfo.type='ParameterWriter';
    accessorInfo.name='';
    if~isempty(block)

        if strcmp(get_param(block,'BlockType'),'ModelReference')
            instPInfo=get_param(block,'ParameterArgumentInfo');
            paramNames=arrayfun(@(x)x.ArgName,instPInfo,'UniformOutput',false);
        else
            paramNames=get_param(block,'RuntimeParametersDuringEditTime');
        end
        if~isempty(paramNames)
            if length(paramNames)==1

                accessorInfo.name=regexprep(paramNames{1},'\:[0-9][0-9]*','');
            end
            SLStudio.toolstrip.internal.createAccessorBlockForOwner(block,accessorInfo);
        end
    end
end