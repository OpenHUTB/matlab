function[hdl_arch]=emit_inithdlarch(this)






    nname=hdlgetparameter('filter_name');
    if isempty(nname)
        nname='filter';
    end

    indentedcomment=['  ',hdlgetparameter('comment_char'),' '];

    hdl_arch_functions=[indentedcomment,'Local Functions\n'];
    hdl_arch_typedefs=[indentedcomment,'Type Definitions\n'];
    hdl_arch_constants=[indentedcomment,'Constants\n'];
    hdl_arch_signals=[indentedcomment,'Signals\n'];
    hdl_arch_body_blocks=['\n',indentedcomment,'Block Statements\n'];
    hdl_arch_body_output_assignments=[indentedcomment,'Assignment Statements\n'];


    if hdlgetparameter('isverilog')
        hdl_arch_decl='';
        hdl_arch_comment='';
        hdl_arch_end=['endmodule',indentedcomment,nname,'\n'];
        hdl_arch_component_decl='';
        hdl_arch_component_config='';
        hdl_arch_begin='';
        hdl_arch_body_component_instances='';


    elseif hdlgetparameter('isvhdl')
        hdl_arch_decl=['ARCHITECTURE rtl OF ',nname,' IS\n'];
        if hdlgetparameter('split_entity_arch')==1,
            hdl_arch_comment=this.Comment;
        else
            hdl_arch_comment=hdldefarchheader(nname);
        end
        hdl_arch_end='END rtl;\n';
        hdl_arch_component_decl='';
        hdl_arch_component_config='';
        hdl_arch_begin='\n\nBEGIN\n';
        hdl_arch_body_component_instances='';
    end

    hdl_arch=struct('comment',hdl_arch_comment,...
    'decl',hdl_arch_decl,...
    'component_decl',hdl_arch_component_decl,...
    'component_config',hdl_arch_component_config,...
    'functions',hdl_arch_functions,...
    'typedefs',hdl_arch_typedefs,...
    'constants',hdl_arch_constants,...
    'signals',hdl_arch_signals,...
    'begin',hdl_arch_begin,...
    'body_component_instances',hdl_arch_body_component_instances,...
    'body_blocks',hdl_arch_body_blocks,...
    'body_output_assignments',hdl_arch_body_output_assignments,...
    'end',hdl_arch_end);
