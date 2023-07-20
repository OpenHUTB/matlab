

function bindableData=getBindableData(this,selectionHandles,~)


    selectionModelName='';
    validSelectionHandle=-1;
    for idx=1:numel(selectionHandles)
        if(selectionHandles(idx)~=0)
            validSelectionHandle=selectionHandles(idx);
            selectionModelName=get_param(bdroot(selectionHandles(idx)),'Name');
            break;
        end
    end
    sourceModelName=get_param(bdroot(this.sourceElementHandle),'Name');
    bindingSupported=false;
    activeEditor=BindMode.utils.getLastActiveEditor();
    assert(~isempty(activeEditor));
    sourceFullPath=this.hierarchicalPathArray;
    if(strcmp(get_param(validSelectionHandle,'Type'),'port'))
        validSelectionHandle=get_param(get_param(validSelectionHandle,'Parent'),'Handle');
    end
    selectionFullPath=convertToCell(Simulink.BlockPath.fromHierarchyIdAndHandle(activeEditor.getHierarchyId,validSelectionHandle));
    if(BindMode.utils.isSameModelInstance(sourceFullPath,selectionFullPath))
        bindingSupported=true;
    end
    if(~bindingSupported)


        activeEditor=BindMode.utils.getLastActiveEditor();
        BindMode.utils.showHelperNotification(activeEditor,message('SimulinkHMI:HMIBindMode:ModelRefNotSupportedText').string())
        selectionHandles=[];
    end
    bindableData=utils.HMIBindMode.getBindableData(this.sourceElementHandle,this.modelName,selectionHandles);
end