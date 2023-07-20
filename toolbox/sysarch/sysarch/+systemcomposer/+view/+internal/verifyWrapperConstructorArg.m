function verifyWrapperConstructorArg(elemImpl,expectedMetaClass)





    if~iscell(expectedMetaClass)
        expectedMetaClass={expectedMetaClass};
    end

    for i=1:numel(expectedMetaClass)
        if(isa(elemImpl,expectedMetaClass{i}))
            return
        end
    end

    systemcomposer.internal.throwAPIError('InvalidWrapConArg',...
    strjoin(expectedMetaClass,' or '));

end

