function h=LUT(this,varargin)




    ctx=preCompConst(this,varargin{:});
    h=dsphdlshared.basiccomp.LUT('Network',this.CurrentNetwork,varargin{:});
    postCompConst(this,h,ctx);
end
