function schema()






    schema.package('tdkfpgacc');




    name='FPGA_TOOLCHAIN_SELECTION';
    enum={'Xilinx ISE'};
    i_registerEnum(name,enum);


    name='FPGA_WORKFLOW';
    enum={'Project generation','FPGA hardware-in-the-loop'};
    i_registerEnum(name,enum);

    name='FPGA_PROJECTGEN_OUTPUT';
    enum={'ISE project','Tcl script'};
    i_registerEnum(name,enum);


    name='FPGA_HIL_OUTPUT';
    enum={'FPGA bitstream and processor executable'};
    i_registerEnum(name,enum);

    name='FPGA_ASSOCIATE';
    enum={'New ISE project','Existing ISE project'};
    i_registerEnum(name,enum);

    name='FPGA_TCL_OPTIONS';
    enum={'Create new project','Add generated files only'};
    i_registerEnum(name,enum);

    name='FPGA_HARDWARE_BOARD';
    enum={'Avnet Spartan-3A DSP DaVinci'};
    i_registerEnum(name,enum);

    name='FPGAProjectPropTableColEnum';
    enum={'name','value','process'};
    i_registerEnum(name,enum);


    function i_registerEnum(name,enum)
        if isempty(findtype(name))
            schema.EnumType(name,enum);
        end

