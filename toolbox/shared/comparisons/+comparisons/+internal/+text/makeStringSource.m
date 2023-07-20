function source=makeStringSource(name,data,encoding)




    if nargin<3
        encoding=[];
    end

    source=com.mathworks.comparisons.source.impl.StringSource(name,data,encoding);

end
