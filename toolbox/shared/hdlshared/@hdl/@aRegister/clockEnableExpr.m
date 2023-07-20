function hdlcode=clockEnableExpr(this)





    hdlcode=hdlcodeinit;

    if this.hasClockEnable
        if this.isVHDL
            if this.hasSyncReset
                hdlcode.arch_body_blocks=[hdl.indent(3),'ELSIF ',...
                allClockEnables(this),...
                ' THEN',hdl.newline];
            else
                hdlcode.arch_body_blocks=[hdl.indent(3),'IF ',...
                allClockEnables(this),...
                ' THEN',hdl.newline];
            end
        else
            hdlcode.arch_body_blocks=[hdl.indent(4),'if (',...
            allClockEnables(this),...
            ') begin',hdl.newline];
        end
    else
        if this.isVHDL
            if this.hasSyncReset
                hdlcode.arch_body_blocks=[hdl.indent(3),'ELSE ',...
                hdl.newline];
            end
        end
    end


    function str=allClockEnables(this)
        str=hdlsignalname(this.clockenable(1));
        str=[str,eqOneStr(this,this.clockenable(1))];
        for ii=2:length(this.clockenable)
            str=[str,...
            andStr(this),...
            hdlsignalname(this.clockenable(ii)),...
            eqOneStr(this,this.clockenable(ii))];
        end


        function str=eqOneStr(this,sig)
            sizes=hdlsignalsizes(sig);
            if sizes(1)==1
                if this.isVHDL
                    str=' = ''1''';
                else
                    str=' == 1''b1';
                end
            elseif sizes(1)==0
                if this.isVHDL
                    str=' /= 0.0';
                else
                    str=' != 0.0';
                end
            else
                if this.isVHDL
                    str=' /= 0';
                else
                    str=' != 0';
                end
            end

            function str=andStr(this)
                if this.isVHDL
                    str=' AND ';
                else
                    str=' & ';
                end

