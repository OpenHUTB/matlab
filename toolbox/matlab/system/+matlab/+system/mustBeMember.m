function mustBeMember(propValue,options)




%#codegen

    coder.allowpcode('plain');

    if coder.target('MATLAB')
        lowerOptions=lower(options);
    else


        lowerOptions=cell(size(options));
        for n=coder.unroll(1:numel(options))
            lowerOptions{n}=lower(options{n});
        end
    end

    mustBeMember(lower(propValue),lowerOptions);
end
