function noCodeGen(cbinfo,action)


    mdl=cbinfo.editorModel.handle;
    cgb=get_param(mdl,'CodeGenBehavior');

    if strcmp(cgb,'None')
        action.selected=true;
    else
        action.selected=false;
    end


