function map=createBlockMap(valueType)

    if~exist('valueType','var')||isempty(valueType)
        valueType='any';
    end

    map=coder.internal.gui.ExtendedMap('KeyType','coder.internal.mlfb.BlockIdentifier',...
    'ValueType',valueType,...
    'HashFunction',@(identifier)identifier.UniqueKey);
end