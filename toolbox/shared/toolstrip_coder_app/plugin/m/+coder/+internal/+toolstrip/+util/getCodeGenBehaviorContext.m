function ctx=getCodeGenBehaviorContext(mdl)


    ctx='';
    cgb=get_param(mdl,'CodeGenBehavior');
    if strcmp(cgb,'None')
        ctx='NoCodeGen';
    end
