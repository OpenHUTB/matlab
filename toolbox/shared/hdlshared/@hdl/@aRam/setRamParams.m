function setRamParams(this,varargin)






    this.isVHDL=hdlgetparameter('isvhdl');
    this.isVerilog=hdlgetparameter('isverilog');
    this.isStdLogicIn=hdlgetparameter('filter_input_type_std_logic');
    this.isStdLogicOut=hdlgetparameter('filter_output_type_std_logic');
    this.hasClkEnable=true;
    this.dataIsComplex=false;

    hdl.setpvpairs(this,varargin{:});

    if isempty(this.entityName)
        error(message('HDLShared:directemit:undefinedentity'));
    end

    if isempty(this.fullFileName)
        error(message('HDLShared:directemit:undefinedfilename'));
    end
