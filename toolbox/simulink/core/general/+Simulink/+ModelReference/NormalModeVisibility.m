function NormalModeVisibility(modelName,varargin)







    mlock;

    if(isempty(varargin))
        command='Open';
    else
        command=varargin{1};
    end

    loc_doCommand(modelName,command);

end



function loc_checkModelType(bd)
    if bdIsLoaded(bd)
        if bdIsLibrary(bd)||bdIsSubsystem(bd)
            DAStudio.error('Simulink:modelReference:NormalModeVisibilityInvalidFileType');
        end
    else
        if Simulink.MDLInfo(bd).BlockDiagramType~="Model"
            DAStudio.error('Simulink:modelReference:NormalModeVisibilityInvalidFileType');
        end
    end
end


function loc_doCommand(modelName,command)
    persistent OpenUIs;

    if(isempty(OpenUIs))
        OpenUIs=containers.Map('KeyType','char','ValueType','any');
    end

    switch command
    case{'Open'}
        loc_checkModelType(modelName);

        foundUI=[];

        if(OpenUIs.isKey(modelName))
            foundUI=OpenUIs(modelName);
        end

        if(~isempty(foundUI)&&isvalid(foundUI))
            foundUI.show();
        else
            try
                ui=Simulink.ModelReference.NormalModeVisibilityUI.UI(modelName);
                OpenUIs(modelName)=ui;
            catch me



                if(~isequal(me.identifier,...
                    'Simulink:modelReference:HierarchyExplorerClosedWhenNotReady'))
                    rethrow(me);
                end
            end
        end

    case{'Close'}
        if(OpenUIs.isKey(modelName))
            OpenUIs.remove(modelName);
        end


    otherwise
        if(ischar(command))
            DAStudio.error('Simulink:modelReference:NormalModeVisibilityUnexpectedCommand',command);
        else
            DAStudio.error('Simulink:modelReference:NormalModeVisibilityUnexpectedCommandType');
        end
    end
end
