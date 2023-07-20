function codegendir=hdlGetBaseCodegendir(this)


    if this.DUTMdlRefHandle>0
        mdlName=this.OrigModelName;
        snn=this.OrigStartNodeName;
    else
        mdlName=this.ModelName;
        snn=this.getStartNodeName;
    end

    hINI=this.getINI;
    targetdir=getProp(hINI,'codegendir');


    targetsubdir=getProp(hINI,'codegensubdir');

    codegendir=getcodegenbasedir(mdlName,snn,targetdir,targetsubdir);
end