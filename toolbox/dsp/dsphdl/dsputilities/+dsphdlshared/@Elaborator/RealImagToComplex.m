function h=RealImagToComplex(this,varargin)




    ctx=preCompConst(this,varargin{:});
    h=dsphdlshared.basiccomp.RealImag2Complex('Network',this.CurrentNetwork,varargin{:});
    postCompConst(this,h,ctx);
end
