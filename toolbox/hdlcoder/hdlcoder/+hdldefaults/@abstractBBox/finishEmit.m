function hdlcode=finishEmit(this,hC)





    Name=hdllegalname(this.getImplParams('EntityName'));
    if isempty(Name)
        Name=hC.Name;
    end

    archname=hdllegalname(this.getImplParams('VHDLArchitectureName'));
    if isempty(archname)
        archname=hdlgetparameter('vhdl_architecture_name');
    end

    libname=hdllegalname(this.getImplParams('VHDLComponentLibrary'));
    if hC.getIsProtectedModel
        protectedModelLibName=hC.ImplementationData.VHDLLibraryName;
        if~isempty(protectedModelLibName)
            libname=protectedModelLibName;
        end
    end
    if isempty(libname)
        libname=hdlgetparameter('vhdl_library_name');
    end

    config=this.getImplParams('InlineConfigurations');
    if isempty(config)
        PIRconfig='Default';
    elseif strcmpi(config,'on')
        PIRconfig='ForceInline';
    else
        PIRconfig='ForceNotInline';
    end

    hdlcode.entity_name=Name;
    hdlcode.library_name=libname;
    hdlcode.arch_name=archname;
    hdlcode.component_name=Name;
    hdlcode.inline_config=PIRconfig;


