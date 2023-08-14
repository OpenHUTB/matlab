

function addStateReaderBlockCB(cbinfo)
    if SLStudio.Utils.isLockedSystem(cbinfo)
        return;
    end

    blockInfo=SLStudio.Utils.getSelectedBlocks(cbinfo);
    block=blockInfo.getFullPathName;
    accessorInfo.fontsize=cbinfo.studio.getCurrentFontSize;
    accessorInfo.type='StateReader';
    accessorInfo.name='';
    if~isempty(block)

        stateNames=get_param(block,'StateNameList');
        if~isempty(stateNames)
            if length(stateNames)==1

                accessorInfo.name=stateNames{1};
            end
            SLStudio.toolstrip.internal.createAccessorBlockForOwner(block,accessorInfo);
        end
    end
end