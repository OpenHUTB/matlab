function paramsToReturn=copyValues(dstObj,parameters)


















    paramsToReturn={};


    for i=1:size(parameters,1)
        try
            set(dstObj,parameters{i,1},parameters{i,2});
            paramsToReturn=[paramsToReturn;parameters(i,:)];%#ok<AGROW>
        catch E %#ok<NASGU>

        end
    end

end
