function out=checkCompatibility(obj,src)




    out=true;

    top=src.studio.App.blockDiagramHandle;
    current=src.editor.blockDiagramHandle;

    if top==current
        return;
    end


    activeHarness=Simulink.harness.internal.getHarnessList(current,'active');
    if~isempty(activeHarness)
        out=false;
    else
        if~slfeature('GRTCodePerspective')


            if strcmp(get_param(top,'IsERTTarget'),'off')&&...
                strcmp(get_param(current,'IsERTTarget'),'on')
                out=false;
            end
        end
    end

    if~out
        text=message('SimulinkCoderApp:codeperspective:CompatibilityCheckQuestText',...
        get_param(top,'Name'),get_param(current,'Name')).getString();
        btn1=message('SimulinkCoderApp:codeperspective:CompatibilityCheckBtnOpen').getString;
        btn2=message('SimulinkCoderApp:codeperspective:CompatibilityCheckBtnCancel').getString;

        answer=questdlg(text,'',btn1,btn2,btn2);
        if strcmp(answer,btn1)
            open_system(current);
            obj.turnOnPerspective(current);
        end
    end

