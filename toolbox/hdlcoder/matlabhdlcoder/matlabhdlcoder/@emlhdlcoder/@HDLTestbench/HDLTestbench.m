function this=HDLTestbench(slConnection)





    this=emlhdlcoder.HDLTestbench;

    if nargin==1
        this.ModelConnection=slConnection;
    end



    this.doubleErrorMargin='1.0e-9';
    this.fixedPointErrorMargin='0';


    this.initParamsCommon;



