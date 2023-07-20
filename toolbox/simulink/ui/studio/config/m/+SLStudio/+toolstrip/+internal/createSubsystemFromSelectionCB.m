



function createSubsystemFromSelectionCB(userData,cbinfo)
    editor=cbinfo.studio.App.getActiveEditor;
    if~editor.isLocked

        selectedItem=SLStudio.Utils.getSingleSelection(cbinfo);
        if SLStudio.Utils.objectIsValidArea(selectedItem)&&strcmp(userData,'subsystem')
            cbinfo.domain.createSubsystemFromArea(editor,selectedItem);
        else
            canCreate=false;
            selection=editor.getSelection;
            for i=1:selection.size
                if(isa(selection.at(i),'SLM3I.Block')||isa(selection.at(i),'SLM3I.Annotation'))&&...
                    SLM3I.Util.isValidDiagramElement(selection.at(i))&&...
                    ~Simulink.internal.isArchitectureModel(cbinfo,'AUTOSARArchitecture')
                    canCreate=true;
                    break;
                end
            end

            if canCreate
                switch userData
                case 'subsystem'
                    SLM3I.SLDomain.createSubsystem(editor,editor.getSelection);
                case 'atomic'
                    SLM3I.SLDomain.createAtomicSubsystem(editor,editor.getSelection);
                otherwise
                    SLM3I.SLDomain.createSubsystemWithNewBlock(editor,editor.getSelection,userData);
                end
            end
        end
    end
end
