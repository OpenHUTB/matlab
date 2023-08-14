%#codegen







function obj=generateConstOverPiTable(func)
    coder.allowpcode('plain');

    if strcmp(func,'sin')
        obj=coder.nullcopy(fi(zeros(16,1),0,38,23));
        for i=1:16
            obj(i)=fi(bitsll(1,i)/pi,0,38,23);
        end

    elseif strcmp(func,'cos')
        obj=coder.nullcopy(fi(zeros(21,1),0,39,24));
        for i=1:5
            obj(i)=fi(2^(i-5)/pi,0,39,24);
        end

        for i=6:21
            obj(i)=fi(bitsll(1,i-5)/pi,0,39,24);
        end

    elseif strcmp(func,'tan')
        obj=coder.nullcopy(fi(zeros(17,1),0,40,24));
        for i=1:17
            obj(i)=fi(bitsll(1,i)/pi,0,40,24);
        end

    end
end
