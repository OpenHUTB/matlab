function setGenericsInfo(this,hC)




    genericsListStr=this.getImplParams('GenericList');


    if isempty(genericsListStr)
        return;
    end

    genericsList=getGenericsInfo(this);

    for ii=1:length(genericsList)
        genericInfo=genericsList{ii};


        if isempty(genericInfo)
            continue;
        end

        genericName=genericInfo{1};
        genericValue=genericInfo{2};

        if length(genericInfo)>2
            genericTypeName=genericInfo{3};
        else
            genericTypeName='integer';
        end



        genericNamedType=pir_named_t(genericTypeName);

        hC.addGenericPort(genericName,genericValue,genericNamedType);
    end
end
