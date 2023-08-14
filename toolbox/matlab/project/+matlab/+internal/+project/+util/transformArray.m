function transformed=transformArray(source,converter)








    for idx=numel(source):-1:1
        transformed{idx}=converter(source(idx));
    end

    transformed=[transformed{:}];

end