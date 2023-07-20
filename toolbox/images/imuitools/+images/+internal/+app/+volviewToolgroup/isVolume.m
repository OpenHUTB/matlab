function TF=isVolume(V)







    sizeV=size(V);
    TF=(ndims(V)==3)&&all(sizeV>1);

end