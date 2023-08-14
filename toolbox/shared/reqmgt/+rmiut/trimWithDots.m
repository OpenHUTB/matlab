function out=trimWithDots(in,limit,trim)



    if nargin<3
        trim=limit;
    end

    if~ischar(in)
        error(message('Slvnv:rmipref:InvalidArgument',class(in)));
    end
    if~isnumeric(limit)||~isnumeric(trim)||length(trim)>2
        error(message('Slvnv:rmipref:InvalidArgument','LENGTHS'));
    end
    if sum(trim)>limit
        error(message('Slvnv:rmipref:InvalidArgument','TRIM>LENGTH'));
    end

    if length(in)<=limit

        out=in;

    elseif length(trim)==1||trim(2)==0

        out=[in(1:trim),'...'];

    elseif trim(1)==0

        out=['...',in(end-trim(2)+1:end)];

    else

        out=[in(1:trim(1)),'...',in(end-trim(2)+1:end)];
    end

end
