function TF=isVolume(V)







    sizeV=size(V);

    TF=(ndims(V)==3&&all(sizeV>1))||(ndims(V)==4&&all(sizeV>1)&&sizeV(4)==3);

end