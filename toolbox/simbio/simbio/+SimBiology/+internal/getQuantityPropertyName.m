function quantityPropertyNames=getQuantityPropertyName(object)





    quantityPropertyNames=arrayfun(@localGetQuantityPropertyName,object,...
    'UniformOutput',false);

end

function quantityPropertyName=localGetQuantityPropertyName(object)
    switch class(object)
    case 'SimBiology.Parameter'
        quantityPropertyName='Value';
    case 'SimBiology.Species'
        quantityPropertyName='InitialAmount';
    case 'SimBiology.Compartment'
        quantityPropertyName='Capacity';
    otherwise
        error(message('SimBiology:getQuantityPropertyName:InternalErrorGetQuantityPropertyName'));
    end
end