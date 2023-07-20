function X1=clipData(X1,min,max)




%#codegen

    coder.allowpcode('plain');
    parfor iElem=1:numel(X1)
        temp=X1(iElem);
        if temp<min
            X1(iElem)=min;
        elseif temp>max
            X1(iElem)=max;
        end
    end
end
