%#codegen
function[awvalid_o,awaddr_o,awlen_o,awid_o,...
    fifo_push_o,wlast_o,...
    fifo_rdack_o,...
    wr_transfer_o,...
    wr_complete_o]=...
    hdleml_axi4_wr_master(awready_i,...
    wr_len_i,wr_valid_i,wr_addr_i,wr_awid_i,...
    out_fifo_afull_i,...
    reset_pending_i,...
    DATA_WIDTH,LEN_WIDTH)




    coder.allowpcode('plain')

    fm=hdlfimath;

    NT_USR_LEN=numerictype(fi(wr_len_i));
    NT_ADDR=numerictype(fi(wr_addr_i));
    NT_ID=numerictype(fi(wr_awid_i));
    MAX_BURST=coder.const(2^LEN_WIDTH-1);
    ADDR_INCR=coder.const((DATA_WIDTH/8)*(MAX_BURST+1));

    eml_prefer_const(DATA_WIDTH);
    eml_prefer_const(LEN_WIDTH);
    eml_prefer_const(NT_USR_LEN);
    eml_prefer_const(NT_ADDR);
    eml_prefer_const(NT_ID);
    eml_prefer_const(MAX_BURST);
    eml_prefer_const(ADDR_INCR);

    persistent wr_astate wr_dstate wr_len_reg wr_addr_reg wr_awid_reg last_burst_reg data_done_reg addr_done_reg
    persistent awlen_reg burst_cnt_reg awvalid_reg awaddr_reg awid_reg wvalid_reg wlast_reg
    if isempty(wr_astate)
        wr_astate=uint8(0);
        wr_dstate=uint8(0);
        wr_len_reg=fi(0,numerictype(0,NT_USR_LEN.WordLength,0),fm);
        wr_addr_reg=fi(0,numerictype(0,NT_ADDR.WordLength,0),fm);
        wr_awid_reg=fi(0,numerictype(0,NT_ID.WordLength,0),fm);

        awlen_reg=fi(0,numerictype(0,LEN_WIDTH,0),fm);
        burst_cnt_reg=fi(0,numerictype(0,LEN_WIDTH,0),fm);
        awvalid_reg=false;
        awaddr_reg=fi(0,numerictype(0,NT_ADDR.WordLength,0),fm);
        awid_reg=fi(0,numerictype(0,NT_ID.WordLength,0),fm);
        wvalid_reg=false;
        wlast_reg=false;
        last_burst_reg=false;
        data_done_reg=false;
        addr_done_reg=false;
    end

    awready=logical(awready_i);
    wr_valid=logical(wr_valid_i);
    out_fifo_afull=logical(out_fifo_afull_i);
    reset_pending=logical(reset_pending_i);

    STATE_IDLE=coder.const(0);
    STATE_ADDR=coder.const(1);
    STATE_TRANSFER=coder.const(2);
    STATE_WAITRESP=coder.const(3);

    awvalid_o=awvalid_reg;
    awlen_o=awlen_reg;
    awaddr_o=awaddr_reg;
    awid_o=awid_reg;

    fifo_push_o=wvalid_reg;
    wlast_o=wlast_reg;

    wr_complete_o=last_burst_reg&&wlast_reg&&wvalid_reg;

    wr_len_wire=wr_len_reg;



    switch uint8(wr_astate)
    case STATE_IDLE
        last_burst_reg=false;
        addr_done_reg=false;

        if wr_valid&&~reset_pending
            wr_astate(:)=STATE_ADDR;
        end
        wr_len_reg(:)=wr_len_i;
        wr_addr_reg(:)=wr_addr_i;
        wr_awid_reg(:)=wr_awid_i;

    case STATE_ADDR
        addr_done_reg=false;

        if awvalid_reg&&awready
            awvalid_reg=false;
            wr_astate(:)=STATE_WAITRESP;
        else
            awvalid_reg=true;
        end

        awaddr_reg(:)=wr_addr_reg;
        awid_reg(:)=wr_awid_reg;
        if wr_len_reg>MAX_BURST
            awlen_reg(:)=MAX_BURST;
            last_burst_reg=false;
        else
            awlen_reg(:)=wr_len_reg;
            last_burst_reg=true;
        end

    case STATE_WAITRESP
        if(data_done_reg)

            if last_burst_reg
                wr_astate(:)=STATE_IDLE;
            else
                wr_astate(:)=STATE_ADDR;
            end

            wr_len_reg(:)=wr_len_reg-(MAX_BURST+1);
            wr_addr_reg(:)=wr_addr_reg+ADDR_INCR;

            addr_done_reg=true;
        end

    otherwise
        wr_astate(:)=STATE_IDLE;
    end


    switch uint8(wr_dstate)
    case STATE_IDLE
        fifo_rdack_o=false;
        wr_transfer_o=false;
        data_done_reg=false;

        if wr_valid&&~reset_pending
            wr_dstate(:)=STATE_ADDR;
        end
        wvalid_reg=false;
        wlast_reg=false;

    case STATE_ADDR
        wr_dstate(:)=STATE_TRANSFER;
        data_done_reg=false;

        if wr_len_wire>MAX_BURST
            burst_cnt_reg(:)=MAX_BURST;
        else
            burst_cnt_reg(:)=wr_len_wire;
        end
        fifo_rdack_o=false;
        wr_transfer_o=false;

    case STATE_TRANSFER

        if~out_fifo_afull&&wr_valid

            wvalid_reg(:)=true;
            fifo_rdack_o=true;
            if burst_cnt_reg==0

                wlast_reg=true;
                wr_dstate(:)=STATE_WAITRESP;
                data_done_reg=true;
            end
            burst_cnt_reg(:)=burst_cnt_reg-1;
        else
            wvalid_reg(:)=false;
            fifo_rdack_o=false;
        end
        wr_transfer_o=true;

    case STATE_WAITRESP

        if(addr_done_reg)
            if last_burst_reg

                wr_dstate(:)=STATE_IDLE;
            else

                wr_dstate(:)=STATE_ADDR;
            end
        end
        wvalid_reg(:)=false;
        wlast_reg=false;
        fifo_rdack_o=false;
        wr_transfer_o=false;
        data_done_reg=true;

    otherwise
        fifo_rdack_o=false;
        wr_transfer_o=false;
        wr_dstate(:)=STATE_IDLE;
    end

end
