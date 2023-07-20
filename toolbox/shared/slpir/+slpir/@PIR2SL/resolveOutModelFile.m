function resolveOutModelFile(this,forceClose)

    if this.DUTMdlRefHandle>0
        this.TopOutModelFile=this.OutModelFile;
    end

    outMdlFile=this.getOutModelFile(forceClose);
    this.OutModelFile=outMdlFile;
    this.hPir.GeneratedModelName(outMdlFile);

end

