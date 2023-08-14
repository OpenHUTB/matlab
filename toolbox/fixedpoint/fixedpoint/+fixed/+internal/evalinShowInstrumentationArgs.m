function I=evalinShowInstrumentationArgs(A)







    I=false(size(A));

    argc=1;
    N=numel(A);
    while argc<=N
        arg=A{argc};
        argc=argc+1;
        if ischar(arg)&&argc<=N
            arg=strtrim(arg);
            if coder.internal.isOptionPrefix(arg(1))
                op=arg(2:end);
                switch lower(op)
                case{'defaultdt','percentsafetymargin','prototypefimath'}
                    I(argc)=ischar(A{argc});
                    argc=argc+1;
                end
            end
        end
    end

    I=find(I);

end
