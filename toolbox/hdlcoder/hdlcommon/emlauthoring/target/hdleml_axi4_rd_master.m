%#codegen
function[arvalid_o,araddr_o,arlen_o,rd_arid_o,...
    rd_ack_o]=...
    hdleml_axi4_rd_master(...
    arready_i,...
    rd_len_i,rd_valid_i,rd_addr_i,rd_arid_i,...
    reset_pending_i,...
    DATA_WIDTH,LEN_WIDTH)




    coder.allowpcode('plain')

    fm=hdlfimath;

    NT_USR_LEN=numerictype(fi(rd_len_i));
    NT_ADDR=numerictype(fi(rd_addr_i));
    NT_ID=numerictype(fi(rd_arid_i));
    MAX_BURST=coder.const(2^LEN_WIDTH-1);
    ADDR_INCR=coder.const((DATA_WIDTH/8)*(MAX_BURST+1));

    eml_prefer_const(DATA_WIDTH);
    eml_prefer_const(LEN_WIDTH);
    eml_prefer_const(NT_USR_LEN);
    eml_prefer_const(NT_ADDR);
    eml_prefer_const(NT_ID);
    eml_prefer_const(MAX_BURST);
    eml_prefer_const(ADDR_INCR);

    persistent rd_state rd_len rd_addr last_burst rd_arid
    persistent arvalid_reg araddr_reg arlen_reg rd_arid_reg
    if isempty(rd_state)
        rd_state=uint8(0);
        rd_len=fi(0,numerictype(0,NT_USR_LEN.WordLength,0),fm);
        rd_addr=fi(0,numerictype(0,NT_ADDR.WordLength,0),fm);
        rd_arid=fi(0,numerictype(0,NT_ID.WordLength,0),0);

        arlen_reg=fi(0,numerictype(0,LEN_WIDTH,0),fm);
        arvalid_reg=false;
        araddr_reg=fi(0,numerictype(0,NT_ADDR.WordLength,0),fm);
        rd_arid_reg=fi(0,numerictype(0,NT_ID.WordLength,0),0);
        last_burst=false;
    end

    arready=logical(arready_i);
    rd_valid=logical(rd_valid_i);
    reset_pending=logical(reset_pending_i);

    STATE_IDLE=coder.const(0);
    STATE_ADDR=coder.const(1);
    STATE_INCR=coder.const(2);

    arvalid_o=arvalid_reg;
    arlen_o=arlen_reg;
    araddr_o=araddr_reg;
    rd_arid_o=rd_arid_reg;

    rd_ack_o=false;

    switch uint8(rd_state)

    case STATE_IDLE
        rd_ack_o=true;
        if rd_valid&&~reset_pending
            rd_state(:)=STATE_ADDR;
        end
        arvalid_reg=false;
        last_burst=false;
        rd_len(:)=rd_len_i;
        rd_addr(:)=rd_addr_i;
        rd_arid(:)=rd_arid_i;

    case STATE_ADDR

        rd_ack_o=false;
        if arready&&arvalid_reg

            arvalid_reg=false;
            if last_burst
                rd_state(:)=STATE_IDLE;
            else
                rd_state(:)=STATE_INCR;
            end
        else

            arvalid_reg=true;
        end

        araddr_reg(:)=rd_addr;
        rd_arid_reg(:)=rd_arid;

        if rd_len>MAX_BURST
            arlen_reg(:)=MAX_BURST;
            last_burst=false;
        else
            arlen_reg(:)=rd_len;
            last_burst=true;
        end

    case STATE_INCR

        rd_len(:)=rd_len-(MAX_BURST+1);
        rd_addr(:)=rd_addr+ADDR_INCR;
        rd_state(:)=STATE_ADDR;

    otherwise
        rd_state(:)=STATE_IDLE;
    end

end




