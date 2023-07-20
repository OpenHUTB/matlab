function y=mean(obj,dim)














    szObj=size(obj);


    if nargin<2
        dim=find(szObj~=1,1);
        if isempty(dim)
            dim=1;
        end
    end


    s=sum(obj,dim);


    if~isempty(obj)
        y=s./szObj(dim);
    else





        emptyDouble=zeros(szObj);
        if nargin<2


            meanEmpty=mean(emptyDouble);
        else
            meanEmpty=mean(emptyDouble,dim);
        end

        if any(isnan(meanEmpty))

            error(message('shared_adlib:OptimizationExpression:MeanOfEmptyNotSupported'));
        else
            y=s;
        end
    end

end