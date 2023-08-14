function hdlcode=hdlcodeinit(this)

    if isfield(this.Partition,'Device')
        Device=this.Partition.Device;
        h=eval(['eda.fpga.',Device.PartInfo.FPGAVendor]);
        hdlcode=h.hdlcodeinit;
    else
        hdlcode.entity_comment='';
        hdlcode.entity_library='';
        hdlcode.entity_package='';
        hdlcode.entity_decl='';
        hdlcode.entity_generic='';
        hdlcode.entity_ports='';
        hdlcode.entity_portdecls='';
        hdlcode.entity_end='';
        hdlcode.arch_comment='';
        hdlcode.arch_decl='';
        hdlcode.arch_component_decl='';
        hdlcode.arch_component_config='';
        hdlcode.arch_functions='';
        hdlcode.arch_typedefs='';
        hdlcode.arch_constants='';
        hdlcode.arch_signals='';
        hdlcode.arch_begin='';
        hdlcode.arch_body_component_instances='';
        hdlcode.arch_body_blocks='';
        hdlcode.arch_body_output_assignments='';
        hdlcode.arch_end='';
        hdlcode.entity_comment='';
    end
end

