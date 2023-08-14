function list=getdworkarglist(this)




    list=[];
    if~isa(this.object,'RTW.TflCSemaphoreEntry')
        return;
    end

    dworkarglist=this.object.DWorkArgs;

    if isempty(dworkarglist)
        if~isempty(this.object.DWorkAllocatorEntry)
            dworkarglist=this.object.DWorkAllocatorEntry.DWorkArgs;
        end
    end

    if isempty(dworkarglist)
        list={''};
        return;
    end

    for id=1:length(dworkarglist)
        list{id}=dworkarglist(id).Name;%#ok
    end
