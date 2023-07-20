

function initialStateInfo=getInitialState(widgetID,isLibWidget,mdl,widgetType)



    currSelectedBlks=gsb(gcs,1);


    dialogSourceBlock={};
    bCoreBlock=false;


    filtered_blocks=[];
    for index=1:length(currSelectedBlks)
        block=currSelectedBlks(index);
        isCoreWebBlock=get_param(block,'isCoreWebBlock');
        if~strcmp(isCoreWebBlock,'on')
            filtered_blocks=[filtered_blocks,block];%#ok<AGROW>
        else
            blockSID=Simulink.ID.getSID(block{1});
            dialogSourceBlock=Simulink.ID.getHandle(blockSID);
            bCoreBlock=true;
        end
    end



    if isempty(dialogSourceBlock)
        dlgs=DAStudio.ToolRoot.getOpenDialogs(true);
        for i=1:length(dlgs)
            dlgSrc=dlgs(i).getSource;
            if utils.isWidgetDialog(dlgSrc,widgetID,mdl)
                dialogSourceBlock=dlgSrc.blockObj.Handle;
                isCoreWebBlock=get_param(dialogSourceBlock,'isCoreWebBlock');
                if strcmp(isCoreWebBlock,'on')
                    bCoreBlock=true;
                end
                break;
            end
        end
    end

    if~Simulink.HMI.isLibrary(mdl)
        if bCoreBlock
            binding=get_param(dialogSourceBlock,'Binding');
            if~isempty(binding)
                boundElem=binding;
            else
                boundElem={};
            end
        else
            boundElem=utils.getBoundElement(mdl,widgetID,isLibWidget);
        end
    else
        boundElem={};
    end

    initialStateInfo=utils.getParameterRows(mdl,widgetID,filtered_blocks,boundElem,widgetType);


    initialStateInfo{14}=utils.getInitialTextForWidget(widgetType);
end
