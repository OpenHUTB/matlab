function orig_coeffs=setProcIntCoeffs(this,varargin)






    if nargin>1
        coeffs=varargin{1};
        this.Coefficients=coeffs;
        orig_coeffs=[];
    else
        orig_coeffs=this.Coefficients;
        if~strcmpi(this.getHDLParameter('filter_coefficient_source'),'internal')
            nonzero_coeffs_index=find(orig_coeffs);
            zero_coeff=~any(orig_coeffs,1);

            for coeff_count=1:ceil(length(orig_coeffs)/2)

                if zero_coeff(coeff_count)
                    this.Coefficients(coeff_count)=orig_coeffs(nonzero_coeffs_index(1));
                    this.Coefficients(end-coeff_count+1)=orig_coeffs(nonzero_coeffs_index(end));
                end
            end
        end
    end


