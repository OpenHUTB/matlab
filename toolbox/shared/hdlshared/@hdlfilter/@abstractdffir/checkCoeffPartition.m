function[ssi_checked,err_str]=checkCoeffPartition(this,ssi,ipstr)






    fl=this.getfilterlengths;
    len=fl.partitionlen;
    cz_len=fl.czero_len;

    if isscalar(ssi)
        if ssi==cz_len||ssi==-1
            ssi_checked=1;
            err_str='';
        else
            if len~=cz_len
                ssi_checked=0;
                err_str=['Incorrect value specified for ',ipstr,', expecting ',num2str(cz_len),'.\n',...
                'Values of some filter coefficients are zero.'];
            else
                ssi_checked=0;
                err_str=['Incorrect value specified for ',ipstr,', expecting ',num2str(cz_len),'.'];
            end
        end
    else

        if size(ssi,1)>1
            ssi_checked=0;
            err_str=['Illegal value specified for ',ipstr,'.\n',...
            'Expecting scalar or one dimensional vector.'];
            return
        end
        if~all(ssi==floor(ssi))||~isempty(find(ssi<=0))&&~(length(ssi)==1&&ssi==-1)
            ssi_checked=0;
            err_str=['Illegal value specified for ',ipstr,'.\n',...
            'Expecting positive non-zero integers for vector elements.'];
            return
        end
        if sum(ssi)==cz_len
            ssi_checked=1;
            err_str='';
        else
            if len~=cz_len
                ssi_checked=0;
                err_str=['Incorrect value specified for, ',ipstr,'.\n',...
                'Expecting a vector with sum of elements = ',num2str(cz_len),'.\n',...
                'Values of some filter coefficients are zero.'];
            else
                ssi_checked=0;
                err_str=['Incorrect value specified for ',ipstr,'.\n',...
                'Expecting a vector with sum of elements = ',num2str(cz_len),'.'];
            end
        end
    end








