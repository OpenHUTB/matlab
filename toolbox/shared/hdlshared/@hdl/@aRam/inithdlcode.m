function hdlcode=inithdlcode(this)






    hdlcode=hdlcodeinit;
    hdlcode.entity_name=this.entityName;
    hdlcode.arch_name=hdlgetparameter('vhdl_architecture_name');
    hdlcode.library_name=hdlgetparameter('vhdl_library_name');
    hdlcode.component_name=this.entityName;
    hdladdtoentitylist([this.fullPathName],this.entityName,'','');

    this.fileHeader=this.ramFileHeader;