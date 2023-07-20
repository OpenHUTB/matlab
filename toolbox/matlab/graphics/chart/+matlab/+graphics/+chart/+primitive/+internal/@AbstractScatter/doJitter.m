function[x,y,z]=doJitter(hObj,x,y,z,us)






    jit=hObj.XYZJitter;

    iscart=isa(us.DataSpace,'matlab.graphics.axis.dataspace.CartesianDataSpace');

    x=ApplyJitterToData(x,jit(:,1),iscart&&isequal(us.DataSpace.XScale,'log'));
    y=ApplyJitterToData(y,jit(:,2),iscart&&isequal(us.DataSpace.YScale,'log'));
    z=ApplyJitterToData(z,jit(:,3),iscart&&isequal(us.DataSpace.ZScale,'log'));

    hObj.XYZJittered=[x(:),y(:),z(:)];

end

function data=ApplyJitterToData(data,jitter,islog)
    if isinteger(data)
        data=double(data);
    end
    if~islog
        data=data+jitter;
    else
        doflip=max(data)<=0;


        if doflip
            data=-1*data;
        end

        data=10.^(log10(data)+jitter);
        if doflip
            data=-1*data;
        end
    end
end