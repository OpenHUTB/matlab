function s=simrfV2_sparams1d_to_3d(sparams,nport,nfreqs)

    n=nport^2*nfreqs;
    validateattributes(sparams,{'numeric'},{'nonempty','size',...
    [1,2*n]},mfilename,'S-parameter data')

    s=sparams(1:n)+1j*sparams(n+1:end);

    s=reshape(s,nport,nport,nfreqs);
    s=permute(s,[2,1,3]);

end

