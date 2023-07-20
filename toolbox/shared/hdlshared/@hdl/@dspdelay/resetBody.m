function hdlcode=resetBody(this,resetType)





    hdlcode=hdlcodeinit;

    if this.needResetBody(resetType)
        if this.hasAsyncReset
            if this.isVHDL
                rindent=3;
            else
                rindent=4;
            end
        else
            rindent=4;
        end

        for nd=1:length(this.nDelays)
            op=this.outputs{nd};
            rval=this.resetvalues{nd};
            if length(op)==1&&hdlissignalvector(op)
                sizes=hdlsignalsizes(op);
                if all(rval==0)&&sizes(1)~=0&&...
                    (this.isVHDL)
                    hdlcode=hdlcodeconcat([hdlcode,...
                    specialResetBody(this,op,rindent)]);
                else
                    hdlcode=hdlcodeconcat([hdlcode,...
                    hdl.constantassign(op,rval,[],'all',rindent)]);
                end
            else
                for ii=1:length(op)
                    sizes=hdlsignalsizes(op(ii));
                    if all(all(rval==0))&&sizes(1)~=0&&...
                        (this.isVHDL||...
                        (this.isVerilog&&~hdlissignalvector(op(ii))))
                        hdlcode=hdlcodeconcat([hdlcode,...
                        specialResetBody(this,op(ii),rindent)]);
                    else
                        hdlcode=hdlcodeconcat([hdlcode,...
                        hdl.constantassign(op(ii),...
                        rval(ii,:),[],'all',rindent)]);
                    end
                end
            end
        end

        if strcmpi(resetType,'Sync')
            hdlcode.arch_body_blocks=[hdlcode.arch_body_blocks,this.finishSyncResetBody];
        end

    end


    function hdlcode=specialResetBody(this,out,rindent)
        if this.isVHDL
            hdlcode=VHDLemit(out,rindent);
            if hdlsignaliscomplex(out)
                hdlcode=hdlcodeconcat([hdlcode,VHDLemit(hdlsignalimag(out),rindent)]);
            end
        else
            hdlcode=Verilogemit(out,rindent);
            if hdlsignaliscomplex(out)
                hdlcode=hdlcodeconcat([hdlcode,Verilogemit(hdlsignalimag(out),rindent)]);
            end
        end

        function hdlcode=VHDLemit(out,rindent)
            hdlcode=hdlcodeinit;
            [assign_prefix,assign_op]=hdlassignforoutput(out);
            sizes=hdlsignalsizes(out);
            if hdlissignalvector(out)
                if sizes(1)==1
                    zerostr='(OTHERS => ''0'')';
                else
                    zerostr='(OTHERS => (OTHERS => ''0''))';
                end
            else
                if sizes(1)==1
                    zerostr='''0''';
                else
                    zerostr='(OTHERS => ''0'')';
                end
            end
            hdlcode.arch_body_blocks=[hdl.indent(rindent),...
            assign_prefix,hdlsignalname(out),' ',assign_op,' ',...
            zerostr,...
            ';',hdl.newline];

            function hdlcode=Verilogemit(out,rindent)
                hdlcode=hdlcodeinit;
                [assign_prefix,assign_op]=hdlassignforoutput(out);
                hdlcode.arch_body_blocks=[hdl.indent(rindent),...
                assign_prefix,hdlsignalname(out),' ',assign_op,' 0;',hdl.newline];
