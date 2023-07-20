function source=makeVariableSource(name,evalString,cleanupString)




    if nargin==2
        source=com.mathworks.comparisons.source.impl.VariableSource(name,evalString);
    elseif nargin==3
        source=com.mathworks.comparisons.source.impl.VariableSource(name,evalString,cleanupString);
    end

end
