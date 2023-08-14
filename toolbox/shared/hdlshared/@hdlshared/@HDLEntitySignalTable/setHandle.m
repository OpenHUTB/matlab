function setHandle(this,indices,handle)





    if isscalar(indices)
        signal=this.Signals(indices);
        if(handle==-1)
            signal.Port=[];
        else
            signal.Port=get_param(handle,'object');
        end


        this.PortHandles(indices)=handle;

    else
        for n=1:length(indices)
            signal=this.Signals(indices(n));
            if(handle(n)==-1)
                signal.Port=[];
            else
                signal.Port=get_param(handle(n),'object');
            end


            this.PortHandles(indices(n))=handle(n);

        end
    end
