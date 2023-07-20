function[oldMode,package]=hdlSetMode(this,mode)





    package=hdlgetparameter('vhdl_package_required');

    oldMode=hdlcodegenmode;
    hdlcodegenmode(mode);

    this.CopyParamsToGlobalPool;

