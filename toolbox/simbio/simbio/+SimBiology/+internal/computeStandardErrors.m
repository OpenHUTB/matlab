function[se_phi,cov_phi]=computeStandardErrors(beta,covb,paramtransform)














    numParam=length(paramtransform);
    beta=beta(:);
    se_phi=nan(numParam,1);
    cov_phi=nan(numParam,numParam);

    if~isempty(covb)&&~all(isnan(covb(:)))










        J_diag=ones(length(beta),1);
        deriv_fcn_inv=SimBiology.internal.transformParameters(paramtransform,'deriv_inv');





        J_diag(1:numParam)=deriv_fcn_inv(beta(1:numParam));




        cov_phi=J_diag'.*covb.*J_diag;
        se_phi=realsqrt(diag(cov_phi));
    end
end
