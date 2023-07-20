function h=DataTypeConverter(this,varargin)




    ctx=preCompConst(this,varargin{:});
    h=dsphdlshared.basiccomp.DataTypeConverter('Network',this.CurrentNetwork,varargin{:});
    postCompConst(this,h,ctx);
end
