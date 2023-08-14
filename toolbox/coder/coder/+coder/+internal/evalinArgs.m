function I=evalinArgs(A)






    I=false(size(A));

    argc=1;
    N=numel(A);
    while argc<=N
        arg=A{argc};
        argc=argc+1;
        if coder.internal.isCharOrScalarString(arg)&&argc<=N
            arg=strtrim(arg);
            if strlength(arg)>0&&coder.internal.isOptionPrefix(arg)
                op=extractAfter(arg,1);
                switch op
                case{'args','global','globals','s','feature','config',...
                    'float2fixed','double2single','N','F','eg','j','class'}
                    I(argc)=coder.internal.isCharOrScalarString(A{argc});
                    argc=argc+1;
                end
            end
        end
    end

    I=find(I);

end
