function h=Adder(this,varargin)




    ctx=preCompConst(this,varargin{:});
    h=dsphdlshared.basiccomp.Adder('Network',this.CurrentNetwork,varargin{:});
    postCompConst(this,h,ctx);
end
