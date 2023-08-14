function this=edge_detect(varargin)






    this=hdl.edge_detect;
    this.init(varargin{:});

    hN=this.hN;
    emitmode=isempty(hN);

    slrate=this.slrate;

    if emitmode
        booleanhdl=hdlblockdatatype('boolean');

        if strcmpi(hdlsignalvtype(this.input),booleanhdl)

            this.in_notzero=this.input;

        else

            [~,this.in_notzero]=hdlnewsignal([this.input.Name,'_not_eq_zero'],'block',-1,0,1,booleanhdl,'boolean');

        end
        [~,this.in_notzero_delayed]=hdlnewsignal([this.in_notzero.Name,'_del'],'block',-1,0,1,booleanhdl,'boolean');
    else
        booleanhdl=pir_boolean_t;

        if hdlsignalisboolean(this.input)

            this.in_notzero=this.input;

        else

            this.in_notzero=hN.addSignal2('Type',pir_boolean_t,'Name',[this.input.Name,'_not_eq_zero'],...
            'SimulinkRate',slrate);

        end
        this.in_notzero_delayed=hN.addSignal2('Type',pir_boolean_t,'Name',[this.in_notzero.Name,'_del'],...
        'SimulinkRate',slrate);
    end


    switch this.edge_type
    case 'rising'
        this.notin_idx=this.in_notzero_delayed;
        if emitmode
            [~,this.notout_idx]=hdlnewsignal([this.notin_idx.Name,'_neg'],'block',...
            -1,0,1,booleanhdl,'boolean');
        else
            this.notout_idx=hN.addSignal2('Type',pir_boolean_t,'Name',[this.notin_idx.Name,'_neg'],...
            'SimulinkRate',slrate);
        end
        this.op='AND';

        this.opin1=this.in_notzero;
        this.opin2=this.notout_idx;
        this.resetvalue=0;
    case 'falling'
        this.notin_idx=this.in_notzero;
        if emitmode
            [~,this.notout_idx]=hdlnewsignal([this.notin_idx.Name,'_neg'],'block',...
            -1,0,1,booleanhdl,'boolean');
        else
            this.notout_idx=hN.addSignal2('Type',pir_boolean_t,'Name',[this.notin_idx.Name,'_neg'],...
            'SimulinkRate',slrate);
        end
        this.op='AND';

        this.opin1=this.in_notzero_delayed;
        this.opin2=this.notout_idx;
        this.resetvalue=1;
    case 'both'
        this.op='XOR';
        this.notin_idx=[];
        this.opin1=this.in_notzero;
        this.opin2=this.in_notzero_delayed;
        this.resetvalue=0;
        this.notout_idx=[];

    end
