function hdlcode=verilogtbcodercodeinit(this,node,level,nname)


    comment_char=hdlgetparameter('comment_char');
    indentedcomment=[' ',comment_char,' '];

    hdlcode=hdlcodeinit;
    hdlcode.entity_comment=this.hdlentityComment(node,level,nname);


    hdlcode.package_comment=this.hdlpackageComment(node,nname);
    hdlcode.arch_functions=sprintf('%sLocal Functions\n',indentedcomment);
    hdlcode.arch_typedefs=sprintf('%sLocal Type Definitions\n',indentedcomment);
    hdlcode.arch_constants=sprintf('%sConstants\n',indentedcomment);
    hdlcode.arch_signals=sprintf('%sSignals\n',indentedcomment);
    hdlcode.arch_body_blocks=sprintf('\n%sBlock Statements\n',indentedcomment);
    hdlcode.arch_body_output_assignments=sprintf('%sAssignment Statements\n',indentedcomment);
    hdlcode.arch_decl='';
    hdlcode.arch_comment='';
    hdlcode.arch_end=['endmodule',indentedcomment,nname,'\n'];
    hdlcode.arch_component_decl='';
    hdlcode.arch_component_config='';
    hdlcode.arch_begin='';
    hdlcode.arch_body_component_instances=['\n',indentedcomment,'Module Instances\n'];
    hdlcode.entity_library='';
    hdlcode.entity_package=['`timescale 1 ns / ',this.HDLSimResolution,' \n\n'];
    if hdlgetparameter('multifiletestbench')
        tbdatafilename=[this.TestBenchName,this.TestBenchDataPostfix,this.TBFileNameSuffix];
        tbpkgfilename=[this.TestBenchName,hdlgetparameter('package_suffix'),this.TBFileNameSuffix];
        hdlcode.entity_decl=sprintf('module %s;\n\n `include "%s"\n `include "%s"\n\n',nname,tbpkgfilename,tbdatafilename);
    else
        hdlcode.entity_decl=sprintf('module %s;\n\n',nname);
    end
    hdlcode.entity_end='';

    if hdlgetparameter('clockinputs')==1
        clkDesc.Name=this.ClockName;
        clkDesc.Ratio=1;
        hdlcode.arch_constants=[hdlcode.arch_constants,genClockConsts(this,clkDesc)];
    else
        for ii=1:length(this.clockTable)
            if this.clockTable(ii).Kind==0
                if this.clockTable(ii).Ratio>1
                    hdlcode.arch_constants=[hdlcode.arch_constants,indentedcomment...
                    ,sprintf('Clock constants for %dx slower clock\n',this.ClockTable(ii).Ratio)];
                end
                hdlcode.arch_constants=[hdlcode.arch_constants,genClockConsts(this,this.clockTable(ii))];
            end
        end
    end
end

function returnString=genClockConsts(this,clkDesc)
    highTime=this.ForceClockHighTime*clkDesc.Ratio;
    lowTime=this.ForceClockLowTime*clkDesc.Ratio;

    returnString=[...
    sprintf(' parameter %-32s = %d;\n',this.hdlclkhigh(clkDesc.Name),highTime),...
    sprintf(' parameter %-32s = %d;\n',this.hdlclklow(clkDesc.Name),lowTime),...
    sprintf(' parameter %-32s = %d;\n',this.hdlclkperiod(clkDesc.Name),highTime+lowTime),...
    sprintf(' parameter %-32s = %d;\n',this.hdlclkhold(clkDesc.Name),this.ForceHoldTime*clkDesc.Ratio),...
    ];
end


