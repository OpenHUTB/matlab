
function mdlPath=getTargetModelPath(this,srcParentPath)




    if~isempty(this.InModelFile)
        infile=this.InModelFile;
    else
        hPir=this.hPir;
        hRootN=hPir.getTopNetwork;
        infile=hRootN.Name;
    end

    mdlPath=regexprep(srcParentPath,['^',infile],this.OutModelFile);

end


