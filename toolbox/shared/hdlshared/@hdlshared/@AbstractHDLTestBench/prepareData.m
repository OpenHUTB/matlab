function[data,ismod4]=prepareData(~,data,len0,vectorSize,iosigned,iosize,iobp)


    if len0==1
        data=data(1,:);
    end
    data=reshape(data',vectorSize*len0,1);

    ismod4=0;

    if iosize~=0
        if~isa(data,'embedded.fi')
            data=fi(data(:),iosigned,iosize,iobp);
        end
        if iosize==1
            data=bin(data(:));
        else
            data=hex(data(:));
            ismod4=(mod(iosize,4)==0);
        end
    end
