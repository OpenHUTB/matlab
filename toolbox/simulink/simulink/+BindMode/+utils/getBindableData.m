

function rowInfo=getBindableData(modelName,activeDropDownValue)


    bMObj=BindMode.BindMode.getInstance();
    bMSourceDataObj=bMObj.bindModeSourceDataObj;
    clientName=bMSourceDataObj.clientName;
    bMSelectionDataObj=bMObj.bindModeSelectionDataObj;
    selectionContext=BindMode.SelectionContextEnum.SIMULINK;
    if(strcmp(modelName,''))

        selectionContext=BindMode.SelectionContextEnum.STANDALONE;
    end

    rowInfo.bindableRows={};
    hasErrorOccurred=false;

    if selectionContext==BindMode.SelectionContextEnum.SIMULINK
        if isequal(clientName,BindMode.ClientNameEnum.INJECTORS)
            rootHandle=bMObj.modelObj.Handle;
            activeEditor=BindMode.utils.getLastActiveEditor();
            if~isempty(activeEditor)
                csRefBlkH=getSimulinkBlockHandle(get_param(activeEditor.getStudio.App.blockDiagramHandle,'CoSimContext'));
                if csRefBlkH~=-1&&bdroot(csRefBlkH)==rootHandle
                    BindMode.utils.showHelperNotification(activeEditor,message('simulink_ui:bind_mode:resources:CannotBindInsideObserverInjector').getString());
                    hasErrorOccurred=true;
                end
            end
        else
            if~ismember(clientName,[BindMode.ClientNameEnum.ASSESSMENTS,BindMode.ClientNameEnum.STMSIGSELECTOR,BindMode.ClientNameEnum.TESTCLIENT])


                rootHandle=bMObj.modelObj.Handle;
                activeEditor=BindMode.utils.getLastActiveEditor();
                if~isempty(activeEditor)
                    obsRefBlkH=getSimulinkBlockHandle(get_param(activeEditor.getStudio.App.blockDiagramHandle,'ObserverContext'));
                    if obsRefBlkH~=-1&&bdroot(obsRefBlkH)==rootHandle
                        BindMode.utils.showHelperNotification(activeEditor,message('simulink_ui:bind_mode:resources:CannotBindInsideObserver').getString());
                        hasErrorOccurred=true;
                    end
                end
            end
            if~isequal(clientName,BindMode.ClientNameEnum.TESTCLIENT)


                rootHandle=bMObj.modelObj.Handle;
                activeEditor=BindMode.utils.getLastActiveEditor();
                if~isempty(activeEditor)
                    injRefBlkH=getSimulinkBlockHandle(get_param(activeEditor.getStudio.App.blockDiagramHandle,'InjectorContext'));
                    if injRefBlkH~=-1&&bdroot(injRefBlkH)==rootHandle
                        BindMode.utils.showHelperNotification(activeEditor,message('simulink_ui:bind_mode:resources:CannotBindInsideInjector').getString());
                        hasErrorOccurred=true;
                    end
                end
            end
        end

        if~bMSourceDataObj.modelLevelBinding
            isSelectionAboveSource=false;
            sourceFullPath=bMSourceDataObj.hierarchicalPathArray;
            if(~isempty(bMSelectionDataObj.selectionHandles))

                validSelectionHandle=-1;
                for idx=1:numel(bMSelectionDataObj.selectionHandles)
                    if(bMSelectionDataObj.selectionHandles(idx)~=0)
                        validSelectionHandle=bMSelectionDataObj.selectionHandles(idx);
                        break;
                    end
                end
                activeEditor=BindMode.utils.getLastActiveEditor();
                assert(~isempty(activeEditor));
                if(strcmp(get_param(validSelectionHandle,'Type'),'port'))
                    validSelectionHandle=get_param(get_param(validSelectionHandle,'Parent'),'Handle');
                end
                selectionFullPath=convertToCell(Simulink.BlockPath.fromHierarchyIdAndHandle(activeEditor.getHierarchyId,validSelectionHandle));
                isSelectionAboveSource=BindMode.utils.isSelectionAboveSource(sourceFullPath,selectionFullPath);
            elseif(~isempty(bMSelectionDataObj.selectionBackendIds))

                selectionContext=BindMode.SelectionContextEnum.STATEFLOW;


            end
            if(isSelectionAboveSource)
                BindMode.utils.showHelperNotification(activeEditor,message('simulink_ui:bind_mode:resources:SelectionAboveSource').getString());
                hasErrorOccurred=true;
            end
        end
    end

    if~hasErrorOccurred

        if(selectionContext==BindMode.SelectionContextEnum.SIMULINK)
            rowInfo=bMSourceDataObj.getBindableData(bMSelectionDataObj.selectionHandles,activeDropDownValue);
        elseif(selectionContext==BindMode.SelectionContextEnum.STATEFLOW)
            rowInfo=bMSourceDataObj.getSFBindableData(bMSelectionDataObj.selectionBackendIds,activeDropDownValue);
        elseif(selectionContext==BindMode.SelectionContextEnum.STANDALONE)
            rowInfo=bMSourceDataObj.getStandaloneBindableData(activeDropDownValue);
        end


        if bMSourceDataObj.requiresDropDownMenu&&...
            isprop(bMSourceDataObj,'dropDownElements')
            rowInfo.dropDownRequired=true;
            rowInfo.dropDownValues=bMSourceDataObj.dropDownElements;
        end
    end

end
