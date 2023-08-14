function h=Subtractor(this,varargin)




    ctx=preCompConst(this,varargin{:});
    h=dsphdlshared.basiccomp.Subtractor('Network',this.CurrentNetwork,varargin{:});
    postCompConst(this,h,ctx);
end
