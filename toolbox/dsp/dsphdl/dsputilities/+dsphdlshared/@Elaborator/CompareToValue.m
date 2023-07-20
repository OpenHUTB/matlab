function h=CompareToValue(this,varargin)




    ctx=preCompConst(this,varargin{:});
    h=dsphdlshared.basiccomp.CompareToValue('Network',this.CurrentNetwork,varargin{:});
    postCompConst(this,h,ctx);
end
