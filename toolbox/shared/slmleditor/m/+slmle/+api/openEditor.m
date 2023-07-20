function ed=openEditor(input)








    ed=slmle.api.getEditor(input);
    if isempty(ed)
        ed=slmle.api.createEditor(input);
    end
    ed.open();
