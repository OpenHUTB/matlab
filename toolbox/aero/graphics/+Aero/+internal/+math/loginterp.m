function yq=loginterp(x,y,xq)




    yq=exp(interp1(log(x),log(y),log(xq),"linear","extrap"));

end

