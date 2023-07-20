function data=formatDataAsText(~,data,signed,size,bp)



    if size==0
        data=sprintf('%#18G\n',data);
    else

        if~isa(data,'embedded.fi')
            data=fi(data,signed,size,bp);
        end

        if size==1
            data=bin(data);
        else
            data=hex(data);
        end
    end
