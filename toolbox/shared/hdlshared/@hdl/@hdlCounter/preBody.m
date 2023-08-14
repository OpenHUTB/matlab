function hdlcode=preBody(this)





    hdlcode=hdlcodeinit;

    hdlcode.arch_body_blocks=blockComment(this);

    if~(this.Wordlength==1&&strcmpi(this.Outputdatatype,'Unsigned'))
        hdlcode=hdlcodeconcat([hdlcode,this.getStepSignal]);

        hdlcode=hdlcodeconcat([hdlcode,this.driveStepSignal]);
    end


    function str=blockComment(this)

        nl=hdl.newline;
        if strcmpi(this.CounterType,'Free running')
            count_to_value='';
        else
            count_to_value=[...
            ' count to value  = ',num2str(this.CountToValue),nl];
        end

        comment=['----------------------------------------------------------------',nl...
        ,this.Countertype,', ',this.Outputdatatype,' HDL Counter',nl...
        ,' initial value   = ',num2str(this.resetvalues),nl...
        ,' step value      = ',num2str(this.Stepvalue),nl...
        ,count_to_value...
        ,' word length     = ',bitStr(this.Wordlength),nl...
        ,' fraction length = ',bitStr(this.Fractionlength),nl];

        if~isempty(this.sync_reset)
            comment=[comment...
            ,' local reset     = ',hdlsignalname(this.sync_reset),nl];
        end

        if~isempty(this.load_en)
            comment=[comment...
            ,' load enable     = ',hdlsignalname(this.load_en),nl];
        end

        if~isempty(this.cnt_en)
            comment=[comment...
            ,' count enable    = ',hdlsignalname(this.cnt_en),nl];
        end

        if~isempty(this.cnt_dir)
            comment=[comment...
            ,' count direction = ',hdlsignalname(this.cnt_dir),nl];
        end

        comment=[comment...
        ,'----------------------------------------------------------------'];

        str=[hdlformatcomment(comment,2),nl];



        function str=bitStr(length)
            if length>1
                str=[num2str(length),' bits'];
            else
                str=[num2str(length),' bit'];
            end

