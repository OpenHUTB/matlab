function updatedProductList=updateProducts(productList)




    persistent pProductList;


    if isempty(pProductList)
        pProductList={...
        'SimCircuits','Power_System_Blocks'...
        ,'SimElectronics','Power_System_Blocks'...
        };
    end


    updatedProductList=productList;
    for idx=1:2:numel(pProductList)
        updatedProductList=strrep(updatedProductList,pProductList{idx},pProductList{idx+1});
    end

end


