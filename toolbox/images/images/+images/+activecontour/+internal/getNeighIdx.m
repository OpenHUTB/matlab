function idx=getNeighIdx(d,imgSize,r,c,z)






    signR=sign(d(1));
    if(signR==1)
        r=r+d(1);
        r(r>imgSize(1))=imgSize(1);
    elseif(signR==-1)
        r=r+d(1);
        r(r<1)=1;
    end

    signC=sign(d(2));
    if(signC==1)
        c=c+d(2);
        c(c>imgSize(2))=imgSize(2);
    elseif(signC==-1)
        c=c+d(2);
        c(c<1)=1;
    end

    signZ=sign(d(3));
    if(signZ==1)
        z=z+d(3);
        z(z>imgSize(3))=imgSize(3);
    elseif(signZ==-1)
        z=z+d(3);
        z(z<1)=1;
    end

    idx=sub2ind(imgSize,r,c,z);

end