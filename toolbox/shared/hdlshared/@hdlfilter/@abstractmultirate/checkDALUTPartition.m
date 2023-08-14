function[lpi_checked,err_str]=checkDALUTPartition(this,lpi)







    polyc=this.polyphasecoefficients;

    phases=size(polyc);
    firlen=phases(2);
    phases=phases(1);
    if size(lpi,1)==1
        if sum(lpi)==firlen||(isscalar(lpi)&&lpi==-1)
            if max(lpi)>12
                lpi_checked=0;
                err_str='All elements of vector value for ''DALutPartition'' property must be <= 12.';
            else
                lpi_checked=1;
                err_str='';
            end
        else
            lpi_checked=0;
            err_str=['Incorrect value specified for''DALUTPartition''.',newline,...
            'Expecting ',num2str(firlen),' or a vector with sum of elements = ',num2str(firlen),'.',newline,];
        end
    else

        if~(size(lpi,1)==phases)
            lpi_checked=0;
            err_str=['Incorrect value specified for''DALUTPartition''.',newline,...
            'Value must be a vector with 1 or ',num2str(phases),' rows.',newline];
            return
        end
        for n=1:phases
            len=length(find(polyc(n,:)));
            if sum(lpi(n,:))==len
                if max(lpi(n,:))>12
                    lpi_checked=0;
                    err_str='All elements of vector value for ''DALutPartition'' property must be <= 12.';
                    return
                else
                    lpi_checked=1;
                    err_str='';
                end
            else
                if firlen==len
                    lpi_checked=0;
                    err_str=['Incorrect value specified for ''DalutPartition''','.',newline,...
                    'Expecting a vector with sum of elements = ',num2str(len),' for row ',num2str(n),' (polyphase subfilter #',num2str(n),').'];
                    return
                else
                    lpi_checked=0;
                    err_str=['Incorrect value specified for''DalutPartition''','.',newline,...
                    'Expecting a vector with sum of elements = ',num2str(len),' for row ',num2str(n),' (polyphase subfilter # ',num2str(n),').',newline,...
                    'Values of some polyphase coefficients for this phase are zero.'];
                    return
                end
            end
        end
    end


