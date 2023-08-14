function clearlinks(this)





    if isa(this.object,'RTW.TflCSemaphoreEntry')
        if this.allocatesdwork

            for i=1:length(this.parentnode.children)
                if isa(this.parentnode.children(i).object,'RTW.TflCSemaphoreEntry')
                    dWorkAllocatorEntry=this.parentnode.children(i).object.DWorkAllocatorEntry;
                    if dWorkAllocatorEntry==this.object
                        this.parentnode.children(i).object.DWorkAllocatorEntry=[];
                    end
                end
            end

        end
    end

