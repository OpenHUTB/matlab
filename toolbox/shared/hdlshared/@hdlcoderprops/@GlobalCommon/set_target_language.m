function tl=set_target_language(this,tl)






    switch lower(tl)
    case 'vhdl'
        this.isvhdl=true;
        this.isverilog=false;
        this.issystemverilog=false;
    case 'verilog'
        this.isvhdl=false;
        this.isverilog=true;
        this.issystemverilog=false;
    case 'systemverilog'
        this.isvhdl=false;
        this.isverilog=false;
        this.issystemverilog=true;
    end


