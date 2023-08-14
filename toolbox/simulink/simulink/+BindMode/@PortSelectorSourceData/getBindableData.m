function bindableData=getBindableData(this,selectionHandles,~)








    selectionModelName='';
    for idx=1:numel(selectionHandles)
        if(selectionHandles(idx)~=0)
            validSelectionHandle=selectionHandles(idx);
            selectionModelName=get_param(bdroot(selectionHandles(idx)),'Name');
            break;
        end
    end
    sourceModelName=this.modelName;
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
        selectionHandles=[];
        BindMode.utils.showHelperNotification(activeEditor,message('Spcuilib:scopes:ModelRefNotSupportedTextSiggen').string());
    end

    bindableData=slsignalselector.PortSelectorBindMode.getBindableData(this,selectionHandles);