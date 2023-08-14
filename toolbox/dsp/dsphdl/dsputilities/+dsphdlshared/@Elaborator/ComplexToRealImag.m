function h=ComplexToRealImag(this,varargin)




    ctx=preCompConst(this,varargin{:});
    h=dsphdlshared.basiccomp.ComplexToRealImag('Network',this.CurrentNetwork,varargin{:});
    postCompConst(this,h,ctx);
end
