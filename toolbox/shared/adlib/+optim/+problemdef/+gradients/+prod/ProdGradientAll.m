function gradProdAll=ProdGradientAll(domainExpr)







    if isscalar(domainExpr)
        gradProdAll=1;
        return;
    end






    forwardProds=circshift(domainExpr(:),1);
    forwardProds(1)=1;
    backwardProds=circshift(domainExpr(:),-1);
    backwardProds(end)=1;


    forwardProds=cumprod(forwardProds,'forward');
    backwardProds=cumprod(backwardProds,'reverse');



    gradProdAll=matlab.lang.internal.move(forwardProds).*...
    matlab.lang.internal.move(backwardProds);

end