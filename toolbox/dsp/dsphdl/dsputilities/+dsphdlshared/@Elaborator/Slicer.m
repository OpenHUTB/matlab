function h=Slicer(this,varargin)




    ctx=preCompConst(this,varargin{:});
    h=dsphdlshared.basiccomp.Slicer('Network',this.CurrentNetwork,varargin{:});
    postCompConst(this,h,ctx);
end
