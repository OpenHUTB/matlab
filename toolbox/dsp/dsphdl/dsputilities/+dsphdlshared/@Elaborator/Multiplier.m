function h=Multiplier(this,varargin)




    ctx=preCompConst(this,varargin{:});
    h=dsphdlshared.basiccomp.Multiplier('Network',this.CurrentNetwork,varargin{:});
    postCompConst(this,h,ctx);
end
