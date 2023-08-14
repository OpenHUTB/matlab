function h=ShiftLogical(this,varargin)




    ctx=preCompConst(this,varargin{:});
    h=dsphdlshared.basiccomp.ShiftArith('Network',this.CurrentNetwork,varargin{:});
    postCompConst(this,h,ctx);
end
