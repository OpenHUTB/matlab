function uniform=areBinEdgesUniform(binedges)





    binwidth1=binedges(2)-binedges(1);
    uniform=(isfloat(binedges)&&all(abs(diff(binedges)-binwidth1)<=...
    2*max(eps(binedges([1,end])))))||...
    all(diff(binedges)==binwidth1);
end