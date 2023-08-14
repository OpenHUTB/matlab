function h=UnaryMinus(this,varargin)




    ctx=preCompConst(this,varargin{:});
    h=dsphdlshared.basiccomp.UnaryMinus('Network',this.CurrentNetwork,varargin{:});
    postCompConst(this,h,ctx);
end
