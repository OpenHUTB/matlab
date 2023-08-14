function hdlDUTDecl(this)


    entity_name=hdlentitytop;
    if hdlgetparameter('isvhdl')
        [hdlentityportstmt,~,hdlentityinst]=hdlentityports(entity_name);
        this.hdlcomponentdecl=[this.insertComment({'Component Declarations'}),...
        '  COMPONENT ',entity_name,'\n',...
        hdlentityportstmt,...
        '  END COMPONENT;\n\n'];

        if hdlgetparameter('inline_configurations')
            this.hdlcomponentconf=[this.insertComment({'Component Configuration Statements'}),...
            '  FOR ALL : ',entity_name,'\n',...
            '    USE ENTITY work.',entity_name,'(rtl);\n\n'];
        end
    else
        [~,~,hdlentityinst]=hdlentityports(entity_name);
        this.hdlcomponentdecl='';
        this.hdlcomponentconf='';
    end

    this.hdlcomponentinst=hdlentityinst;
end
