function hdlRestoreMode(this,mode,package)%#ok





    hdlcodegenmode(mode);
    hdlsetparameter('vhdl_package_required',package);
