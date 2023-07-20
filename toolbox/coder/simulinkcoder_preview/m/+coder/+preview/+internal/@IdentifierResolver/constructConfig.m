function out=constructConfig(obj)




    out=NewSFSConfigPkg.NewSFSConfig(obj.mf0);
    for t=obj.Tokens
        out.(['d',t])=obj.(['d',t]);
    end
    out.maxIdLen=obj.maxIdLen;


