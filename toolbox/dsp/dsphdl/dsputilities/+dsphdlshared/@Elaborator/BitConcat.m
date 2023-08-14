function h=BitConcat(this,varargin)




    ctx=preCompConst(this,varargin{:});
    h=dsphdlshared.basiccomp.BitConcat('Network',this.CurrentNetwork,varargin{:});
    postCompConst(this,h,ctx);
end
