function[xc,yc,Ic]=clipLineToRectangle(x,y,xmin,xmax,ymin,ymax)







    I=(1:length(x))';
    x=x(:);
    y=y(:);

    [I,x]=map.internal.clip.clipIndexedSequence(I,x,xmin,xmax);
    yc=map.internal.clip.interpolateWithIndex(y,I);

    J=(1:length(yc));
    [J,yc]=map.internal.clip.clipIndexedSequence(J,yc,ymin,ymax);
    xc=map.internal.clip.interpolateWithIndex(x,J);

    Ic=map.internal.clip.interpolateWithIndex(I,J);
end
