function deniedProducts=denyProductLicense(products)






    persistent fProducts

    if nargin>0
        fProducts=products;
    end

    deniedProducts=fProducts;


