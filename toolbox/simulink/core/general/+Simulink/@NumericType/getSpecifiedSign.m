function s=getSpecifiedSign(this)


















    if~isscalar(this)
        DAStudio.error('MATLAB:class:ScalarObjectRequired','getSpecifiedSign');
    end

    s=this.Signed;
    if isempty(s)
        DAStudio.error('fixed:numerictype:signShouldBeSpecified');
    end
