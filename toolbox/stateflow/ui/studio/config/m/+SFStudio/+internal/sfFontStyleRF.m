



function sfFontStyleRF(userdata,cbinfo,action)
    action.enabled=false;
    action.selected=0;

    selection=cbinfo.selection;
    for j=1:selection.size
        obj=selection.at(j);


        obj=cbinfo.selection.at(j);
        if~isempty(obj)&&~isa(obj,'StateflowDI.Junction')
            switch userdata
            case 'bold'
                action.enabled=true;
                if strcmp(obj.font.Weight,'Normal')

                    action.selected=0;
                    return;
                end
                action.selected=1;
            case 'italic'
                action.enabled=true;
                if strcmp(obj.font.Style,'Normal')

                    action.selected=0;
                    return;
                end
                action.selected=1;
            case 'latex'
                if isa(obj,'StateflowDI.State')&&obj.isNote
                    action.enabled=true;
                    if obj.noteInterpretMode~=StateflowDI.NoteInterpretMode.Tex

                        action.selected=0;
                        return;
                    end
                    action.selected=1;
                end
            otherwise
                error('Bad option passed to sfFontStyleRF');
            end
        end
    end
end
