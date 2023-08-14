function out=getStatus(obj,~,~)



    out=3;
    for i=1:length(obj.ProductNames)
        product=obj.ProductNames{i};
        if dig.isProductInstalled(product)
            out=0;
            break;
        end
    end

