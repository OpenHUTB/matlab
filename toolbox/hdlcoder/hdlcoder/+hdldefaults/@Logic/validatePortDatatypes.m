function v=validatePortDatatypes(this,hC)


















    v=hdlvalidatestruct;

    slbh=hC.SimulinkHandle;




    if strcmpi(get_param(slbh,'OutDataTypeStr'),'Inherit: Logical (see Configuration Parameters: Optimization)')
        mdlname=bdroot(getfullname(slbh));
        if strcmpi(get_param(mdlname,'BooleanDataType'),'off')
            v=hdlvalidatestruct(1,message('hdlcoder:validate:LogicBooleanType'));
        end
    end



    v=[v,this.validateInputOutputPortDatatypes(hC)];


