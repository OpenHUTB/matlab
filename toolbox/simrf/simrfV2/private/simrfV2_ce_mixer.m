function[newData]=simrfV2_ce_mixer(origData)






    newData(length(origData))=struct;
    s_idx=0;
    for n_idx=1:length(origData)
        switch origData(n_idx).Name
        case{'Source_linear_gain','linear_gain','linear_gain_unit',...
            'Zin','Zout','ZLO','Poly_Coeffs','IPType','IP2','IP2_unit',...
            'IP3','IP3_unit','NF','InternalGrounding'}
            s_idx=s_idx+1;
            newData(s_idx).Name=origData(n_idx).Name;
            newData(s_idx).Value=origData(n_idx).Value;
        case 'Source_Poly'
            s_idx=s_idx+1;
            newData(s_idx).Name=origData(n_idx).Name;
            if strncmpi(origData(n_idx).Value,'Derived',7)
                newData(s_idx).Value='Even and odd order';
            else
                newData(s_idx).Value='Odd order';
            end
        case 'classname'
            s_idx=s_idx+1;
            newData(s_idx).Name=origData(n_idx).Name;
            newData(s_idx).Value='mixer';
        end
    end

    newData=newData(1:s_idx);

end