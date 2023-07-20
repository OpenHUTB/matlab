function d=minorArcLengthOnCircle(a,b)


















    n=mod(a-b,360);
    p=mod(b-a,360);
    sgn=sign(b-a);
    sgn(n<p)=-1;
    sgn(n>p)=1;
    d=sgn.*min(n,p);
end
