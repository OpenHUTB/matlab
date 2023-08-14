function[lpi_checked,err_str]=checkDALUTPartition(this,dalutpart)







    [lpi_checked,err_str]=checkCoeffPartition(this,dalutpart,'DALUTPartition');

    if lpi_checked
        if max(dalutpart)>12
            err_str=['All elements of vector value for ''DALutPartition'' property must be <= 12.'];
            lpi_checked=0;
        end
    end

