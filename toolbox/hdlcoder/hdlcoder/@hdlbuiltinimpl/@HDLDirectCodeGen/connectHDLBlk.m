function connectHDLBlk(this,handle,input,output)







    for ii=1:length(input)
        insig=input(ii);
        insig.addReceiver(handle,ii-1);
    end

    for ii=1:length(output)
        outsig=output(ii);
        outsig.addDriver(handle,ii-1);
    end
