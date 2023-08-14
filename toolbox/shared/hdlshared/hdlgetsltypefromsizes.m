function sltype=hdlgetsltypefromsizes(insize,inbp,insigned)






    if insize==0
        sltype='double';
    elseif inbp==0
        sltype=['fix',num2str(insize)];
    elseif inbp<0
        sltype=['fix',num2str(insize),'_E',num2str(-inbp)];
    else
        sltype=['fix',num2str(insize),'_En',num2str(inbp)];
    end

    if insize~=0
        if insigned==1
            sltype=['s',sltype];
        else
            sltype=['u',sltype];
        end
    end


