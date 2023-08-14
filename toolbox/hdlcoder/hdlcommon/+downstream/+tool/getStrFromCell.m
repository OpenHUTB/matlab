function str_out=getStrFromCell(cell_in,midStr)




    if nargin<2
        midStr='or';
    end

    if length(cell_in)==1
        str_out=sprintf('"%s"',cell_in{1});
    else
        str_out=sprintf('"%s", ',cell_in{1:end-1});
        str_out=sprintf('%s%s "%s"',str_out,midStr,cell_in{end});
    end

end

