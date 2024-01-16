function outMdlFile=getOutModelFile(this,forceClose)

    thisOutMdlFile=this.OutModelFile;
    if this.DUTMdlRefHandle>0||this.nonTopDut
        thisOutMdlFile='';
    end
    inMdlFile=this.InModelFile;
    if isempty(thisOutMdlFile)
        outMdlFile=getGeneratedModelName(this.OutModelFilePrefix,inMdlFile,forceClose);
    else
        outMdlFile=getGeneratedModelName(this.OutModelFilePrefix,thisOutMdlFile,forceClose);
    end

end
