function out=isModifiable(input)



    input=convertStringsToChars(input);

    import Simulink.ModelReference.ProtectedModel.*;
    if isa(input,'Simulink.ModelReference.ProtectedModel.Information')
        opts=input;
    elseif ischar(input)
        opts=getOptions(input);
    else
        assert(false,'Invalid input');
    end

    if isempty(opts)
        assert(false,'Cannot fetch Information');
    end

    out=opts.isModifyEncrypted;
end
