function tf=isPan1D(newlims,oldlims,scale)






    if strcmp(scale,'log')
        tf=abs(diff(log10(abs(newlims))-log10(abs(oldlims))))<=1000*max(eps(log10(abs(newlims))));
    else
        tf=abs(diff(newlims-oldlims))<=1000*max(eps(newlims));
    end
