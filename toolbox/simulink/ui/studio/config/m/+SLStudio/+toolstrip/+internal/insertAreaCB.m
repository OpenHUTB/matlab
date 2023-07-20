



function insertAreaCB(userData,cbinfo)

    editor=cbinfo.studio.App.getActiveEditor;
    canvas=editor.getCanvas();
    sceneRect=canvas.SceneRectInView;
    width=100;
    height=50;
    x=(sceneRect(1)+sceneRect(3)-width)/2;
    y=(sceneRect(2)+sceneRect(4)-height)/2;


    if strcmp(userData,'deselect')
        selection=editor.getSelection();
        for i=1:selection.size
            set_param(selection.at(i).handle,'Selected','off');
        end
    end

    SLM3I.SLDomain.createArea(editor,[x,y,width,height]);
end
