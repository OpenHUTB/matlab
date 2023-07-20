function resizeFont(action,~)




    delta=1;
    editor=Simulink.typeeditor.app.Editor.getInstance;
    expl=editor.getStudio;
    switch(action)
    case 'GrowFont'
        expl.increaseFontSize(delta);
    case 'ShrinkFont'
        expl.decreaseFontSize(delta);
    otherwise
        assert(false);
    end
    listComp=editor.getListComp;
    listComp.updateFontSize(expl.getCurrentFontSize);
end