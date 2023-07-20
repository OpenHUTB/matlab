function h=getJTAGAXIHandle(target,interface,varargin)






    h=[];
    cnt=0;
    while(isempty(h))
        try







            h=aximanager(target,'Interface',interface,'isInvokedInDLHDL',true,varargin{:});
        catch me
            if(cnt>3)
                assert(false,me.message);
            end
            h=[];
        end
        if(~isempty(h))
            break;
        end
        cnt=cnt+1;
    end
end


