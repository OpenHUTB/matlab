function h=Mux(this,varargin)




    ctx=preCompConst(this,varargin{:});
    h=dsphdlshared.basiccomp.Mux('Network',this.CurrentNetwork,varargin{:});
    postCompConst(this,h,ctx);
end
