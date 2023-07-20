function hdlcode=bodyExpr(this)





    hdlcode=hdlcodeinit;

    if this.isVHDL
        bodyIndent=4;
    else
        bodyIndent=5;
    end

    reset_str='';
    load_str='';
    cnten_str='';
    endstr='';
    nl=hdl.newline;


    if this.isVHDL
        bodystr='';
        if this.Wordlength==1&&strcmpi(this.Outputdatatype,'Unsigned')
            outstr=[hdlsignalname(this.outputs),' <= NOT(',hdlsignalname(this.outputs),');',nl];
        else
            outstr=[hdlsignalname(this.outputs),' <= ',hdlsignalname(this.outputs),' + ',hdlsignalname(this.StepSignal),';',nl];
        end

        if isempty(this.sync_reset)&&isempty(this.load_en)&&isempty(this.cnt_en)
            cnt_str=[hdl.indent(bodyIndent),outstr];
        else
            ifStr=[hdl.indent(bodyIndent),'IF '];
            if~isempty(this.sync_reset)
                oldSyncReset=this.hasSyncReset;
                this.hasSyncReset=true;

                reset_str=[ifStr,hdlsignalname(this.sync_reset),' = ''1'' THEN',nl,...
                modIndent(this.resetBody('Sync').arch_body_blocks,bodyIndent+1)];
                this.hasSyncReset=oldSyncReset;
                ifStr=[hdl.indent(bodyIndent),'ELSIF '];
            end

            if~isempty(this.load_en)
                load_str=[ifStr,hdlsignalname(this.load_en),' = ''1'' THEN',nl...
                ,hdl.indent(bodyIndent),rmNewLine(hdldatatypeassignment(this.load_value,this.outputs,'Floor',0))];
                ifStr=[hdl.indent(bodyIndent),'ELSIF '];
            end

            if~isempty(this.cnt_en)
                cnten_str=[ifStr,hdlsignalname(this.cnt_en),' = ''1'' THEN',nl];
                cnt_str=[hdl.indent(bodyIndent+1),outstr];
            else
                cnt_str=[hdl.indent(bodyIndent),'ELSE',nl,hdl.indent(bodyIndent+1),outstr];
            end

            endstr=[hdl.indent(bodyIndent),'END IF;',nl];
        end

    else
        bodystr='';
        if this.Wordlength==1&&strcmpi(this.Outputdatatype,'Unsigned')
            outstr=[hdlsignalname(this.outputs),' <= !',hdlsignalname(this.outputs),';',nl];
        else
            outstr=[hdlsignalname(this.outputs),' <= ',hdlsignalname(this.outputs),' + ',hdlsignalname(this.StepSignal),';',nl];
        end

        if isempty(this.sync_reset)&&isempty(this.load_en)&&isempty(this.cnt_en)
            cnt_str=[hdl.indent(bodyIndent),outstr];
        else
            ifStr=[hdl.indent(bodyIndent),'if ('];
            if~isempty(this.sync_reset)
                oldSyncReset=this.hasSyncReset;
                this.hasSyncReset=true;

                reset_str=[ifStr,hdlsignalname(this.sync_reset),' == 1''b1) begin',nl,...
                hdl.indent(2),addIndent(this.resetBody('Sync').arch_body_blocks)];
                this.hasSyncReset=oldSyncReset;

                endstr=[hdl.indent(bodyIndent),'end',nl,endstr];
                ifStr=[hdl.indent(bodyIndent+1),'if ('];
                bodyIndent=bodyIndent+1;
            end

            if~isempty(this.load_en)
                load_str=[ifStr,hdlsignalname(this.load_en),' == 1''b1) begin',nl...
                ,hdl.indent(bodyIndent),rmNewLine(hdldatatypeassignment(this.load_value,this.outputs,'Floor',0)),...
                hdl.indent(bodyIndent),'end',nl,...
                hdl.indent(bodyIndent),'else begin',nl];

                endstr=[hdl.indent(bodyIndent),'end',nl,endstr];
                ifStr=[hdl.indent(bodyIndent+1),'if ('];
                bodyIndent=bodyIndent+1;
            end

            if~isempty(this.cnt_en)
                cnten_str=[ifStr,hdlsignalname(this.cnt_en),' == 1''b1) begin',nl];
                cnt_str=[hdl.indent(bodyIndent+1),outstr];
                endstr=[hdl.indent(bodyIndent),'end',nl,endstr];
            else
                cnt_str=[hdl.indent(bodyIndent),outstr];
            end
        end

    end


    bodystr=[bodystr,...
    reset_str,...
    load_str,...
    cnten_str,...
    cnt_str,...
    endstr];

    hdlcode.arch_body_blocks=[hdlcode.arch_body_blocks,bodystr];


    function str=rmNewLine(str)
        str=strrep(str,'\n\n',hdl.newline);


        function str=modIndent(str,level)


            str=regexprep(str,'^ {2,}(?=\w)',hdl.indent(level));


            function str=addIndent(str)
                str=strrep(str,[hdl.newline,hdl.indent(3)],[hdl.newline,hdl.indent(5)]);
