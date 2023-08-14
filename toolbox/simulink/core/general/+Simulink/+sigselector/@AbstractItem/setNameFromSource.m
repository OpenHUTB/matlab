function obj=setNameFromSource(obj)










    blkname=obj.Source.Block;
    portnum=obj.Source.PortNumber;
    signame=obj.Source.SignalName;


    blkname=regexprep(blkname,'\n',' ');
    blkstr=[blkname,' : ',num2str(portnum)];
    str=blkstr;
    if~isempty(signame)
        str=[blkstr,' (',signame,')'];
    end

    charlimit=45;
    if numel(str)>charlimit

        sep=findstr(blkstr,'/');
        strlen=numel(blkstr);
        seplen=strlen-sep+3;
        if isempty(signame)
            sepind=find(seplen<charlimit,1,'first');
            str=['.../',blkstr(sep(sepind)+1:end)];
        else
            charlimit=charlimit-numel(signame)-3;
            sepind=find(seplen<charlimit,1,'first');
            str=['.../',blkstr(sep(sepind)+1:end),'(',signame,')'];
        end
    end

    obj.Name=str;


