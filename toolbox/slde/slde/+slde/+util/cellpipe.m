function y=cellpipe(x)










    if ischar(x)
        y=pipe2cell(x);
    elseif iscell(x)
        y=cell2pipe(x);
    else
        des.error('SimEvents:internal:NeedStringOrCellArray');
    end


    function c=pipe2cell(p)






        if isempty(p)
            c={};
            return;
        end

        pidx=[find(p=='|'),(length(p)+1)];


        c={p(1:pidx(1)-1)};


        for i=2:length(pidx)
            next_str=p(pidx(i-1)+1:pidx(i)-1);


            if isempty(next_str)
                next_str='';
            end

            c{i}=next_str;

        end


        function p=cell2pipe(c)


            if isempty(c)
                p='';
                return;
            end


            c=c(:);
            p=c{1};
            for i=2:length(c)
                str=c{i};


                if isempty(str)
                    str='';
                end

                p=[p,'|',str];

            end

