function errorVector(parameter,name,reference,block)





    if~all(size(parameter)==reference)
        error(message('physmod:powersys:common:InvalidVectorParameter',...
        name,block,num2str(reference(1)),num2str(reference(2))));
    end