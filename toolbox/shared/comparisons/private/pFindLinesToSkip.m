function skip=pFindLinesToSkip(match,skip_padding)




















    skip=zeros(size(match));

    matchcount=0;

    for i=1:numel(match)
        if match(i)

            matchcount=matchcount+1;
        elseif matchcount<i-1&&matchcount>=skip_padding+skip_padding+2



            first_skip=i-matchcount+skip_padding;
            skip(first_skip+1:i-skip_padding-1)=1;
            skip(first_skip)=matchcount-(skip_padding*2);
            matchcount=0;
        elseif matchcount==i-1&&matchcount>=skip_padding+2


            skip(1:i-skip_padding-1)=1;
            skip(1)=matchcount-skip_padding;
            matchcount=0;
        elseif matchcount>0
            matchcount=0;
        end
    end
    if matchcount>=skip_padding+2

        if matchcount==length(skip)

            skip(1)=matchcount;
            skip(2:end)=1;
        else
            first_skip=length(skip)+1-matchcount+skip_padding;
            skip(first_skip+1:end)=1;
            skip(first_skip)=matchcount-skip_padding;
        end
    end

