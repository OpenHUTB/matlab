function value=getParameter(this,param)


    assert(~strcmp(param,'codegendir'),'Don''t call getParameter(''codegendir'') directly.');

    hINI=this.getINI;
    value=getProp(hINI,param);
