function outList=getContourList(~,zmin,zmax,step)






    if zmin<0&&zmax>0
        neg=-step:-step:zmin;
        pos=0:step:zmax;
        outList=[fliplr(neg),pos];
    elseif zmin<0
        start=zmin-(step-mod(-zmin,step));
        outList=start+step:step:zmax;
    else
        start=zmin+(step-mod(zmin,step));
        outList=start:step:zmax;
    end
end
