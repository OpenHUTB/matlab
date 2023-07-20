function l=calculateSegmentLength(~,x,y,z)






    d=diff([x,y,z]);
    l=sum(sqrt(sum(d.*d,2)));
end

