function signals=findSignalFromName(this,names)



    if~iscell(names)
        names={names};
    end


    signals=zeros(1,length(names));
    for ii=1:length(names)
        currentName=names{ii};
        if this.Names.isKey(currentName)
            idx=this.Names(currentName);
            signals(ii)=idx;
        end
    end

    signals=signals(signals~=0);
