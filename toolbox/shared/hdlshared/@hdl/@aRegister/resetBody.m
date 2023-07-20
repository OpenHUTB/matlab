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

        if length(this.outputs)==1&&hdlissignalvector(this.outputs)
            sizes=hdlsignalsizes(this.outputs);
            if all(this.resetvalues==0)&&sizes(1)~=0&&...
                (this.isVHDL)
                hdlcode=hdlcodeconcat([hdlcode,...
                specialResetBody(this,this.outputs,rindent)]);
            else
                hdlcode=hdlcodeconcat([hdlcode,...
                hdl.constantassign(this.outputs,this.resetvalues,[],'all',rindent)]);
            end
        else
            for ii=1:length(this.outputs)
                sizes=hdlsignalsizes(this.outputs(ii));
                if all(this.resetvalues(ii)==0)&&sizes(1)~=0&&...
                    (this.isVHDL||...
                    (this.isVerilog&&~hdlissignalvector(this.outputs(ii))))
                    hdlcode=hdlcodeconcat([hdlcode,...
                    specialResetBody(this,this.outputs(ii),rindent)]);
                else
                    hdlcode=hdlcodeconcat([hdlcode,...
                    hdl.constantassign(this.outputs(ii),...
                    this.resetvalues(ii,:),[],'all',rindent)]);
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



