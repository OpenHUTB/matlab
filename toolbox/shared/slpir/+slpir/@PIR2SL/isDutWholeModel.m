function codingForModel=isDutWholeModel(this)



    if this.DUTMdlRefHandle>0
        codingForModel=true;
    else
        if isempty(this.InModelFile)
            codingForModel=true;
        else
            codingForModel=strcmp(this.RootNetworkName,this.InModelFile);
        end
    end

end
