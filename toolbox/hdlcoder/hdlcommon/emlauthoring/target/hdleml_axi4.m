%#codegen
function[awready_o,awaddr_o,...
    wready_o,...
    bid_o,bvalid_o,...
    araddr_o,arready_o,...
    rid_o,rlast_o,...
    aw_transfer_o,w_transfer_o,ar_transfer_o,rd_active_o]=...
...
    hdleml_axi4(awid_i,awaddr_i,awburst_i,awvalid_i,...
    wlast_i,wvalid_i,...
    bready_i,...
    arid_i,araddr_i,arlen_i,arburst_i,arvalid_i,...
    rd_fifo_afull_i,...
    ADDR_WIDTH,ID_WIDTH,LEN_WIDTH)




    coder.allowpcode('plain')

    eml_prefer_const(ADDR_WIDTH);
    eml_prefer_const(ID_WIDTH);
    eml_prefer_const(LEN_WIDTH);

    fm=hdlfimath;


    STATE_WRIDLE=coder.const(0);
    STATE_WRDATA=coder.const(1);
    STATE_WRRESP=coder.const(2);

    STATE_RDIDLE=coder.const(0);
    STATE_RDDATA=coder.const(1);
    STATE_RDFLUSH=coder.const(2);

    persistent wstate wid waddr waddr_inc awtransfer wtransfer;
    if isempty(wstate)
        wstate=uint8(STATE_WRIDLE);
        wid=fi(0,numerictype(0,ID_WIDTH,0),fm);
        waddr=fi(0,numerictype(0,ADDR_WIDTH,0),fm);
        waddr_inc=fi(0,numerictype(0,ADDR_WIDTH,0),fm);
        awtransfer=false;
        wtransfer=false;
    end

    persistent rstate rid raddr raddr_inc rlen ar_transfer rlast rd_active
    if isempty(rstate)
        rstate=uint8(STATE_RDIDLE);
        rid=fi(0,numerictype(0,ID_WIDTH,0),fm);
        raddr=fi(0,numerictype(0,ADDR_WIDTH,0),fm);
        raddr_inc=fi(0,numerictype(0,ADDR_WIDTH,0),fm);
        rlen=fi(0,numerictype(0,LEN_WIDTH,0),hdlfimath());
        ar_transfer=false;
        rlast=false;
        rd_active=false;
    end

    awvalid=logical(awvalid_i);
    wvalid=logical(wvalid_i);
    wlast=logical(wlast_i);
    bready=logical(bready_i);
    arvalid=logical(arvalid_i);
    rd_fifo_afull=logical(rd_fifo_afull_i);

    awaddr_o=waddr;
    aw_transfer_o=awtransfer;
    bid_o=wid;

    rid_o=rid;
    araddr_o=raddr;
    ar_transfer_o=ar_transfer;
    rlast_o=rlast;
    rd_active_o=rd_active;
    w_transfer_o=wtransfer;

    rstate_next=rstate;
    wstate_next=wstate;


    switch uint8(wstate)

    case STATE_WRIDLE

        awready_o=(rstate_next==STATE_RDIDLE);
        wready_o=false;
        bvalid_o=false;
        waddr(:)=awaddr_i;
        wid(:)=awid_i;
        wtransfer=false;
        switch(awburst_i)
        case 0
            waddr_inc(:)=0;
        otherwise
            waddr_inc(:)=4;
        end
        if awvalid&&(rstate==STATE_RDIDLE)
            wstate_next(:)=STATE_WRDATA;
            awtransfer=true;
        else
            wstate_next(:)=STATE_WRIDLE;
            awtransfer=false;
        end

    case STATE_WRDATA

        awready_o=false;
        wready_o=true;
        bvalid_o=false;

        if wvalid
            awtransfer=true;
            waddr(:)=waddr+waddr_inc;
            wtransfer=true;
        else
            awtransfer=false;
            waddr(:)=waddr;
            wtransfer=false;
        end

        if wvalid&&wlast
            wstate_next(:)=STATE_WRRESP;
        else
            wstate_next(:)=STATE_WRDATA;
        end

    case STATE_WRRESP
        wtransfer=false;
        awtransfer=false;
        awready_o=false;
        wready_o=false;
        bvalid_o=true;

        if bready
            wstate_next(:)=STATE_WRIDLE;
        else
            wstate_next(:)=STATE_WRRESP;
        end
    otherwise

        awready_o=false;
        wready_o=false;
        bvalid_o=false;

        wstate_next(:)=STATE_WRIDLE;
    end


    switch uint8(rstate)

    case STATE_RDIDLE

        arready_o=(wstate==STATE_WRIDLE)&&~awvalid;

        raddr(:)=araddr_i;
        rlen(:)=arlen_i;
        rlast=false;
        switch(arburst_i)
        case 0
            raddr_inc(:)=0;
        otherwise
            raddr_inc(:)=4;
        end

        if arvalid&&(wstate==STATE_WRIDLE)&&~awvalid
            rstate_next(:)=STATE_RDDATA;
            rd_active=true;
            rid(:)=arid_i;
        else
            rstate_next(:)=STATE_RDIDLE;
            rd_active=false;
        end

        ar_transfer=false;

    case STATE_RDDATA

        arready_o=false;


        if rlast
            rstate_next(:)=STATE_RDFLUSH;
        else
            rstate_next(:)=STATE_RDDATA;
        end

        if ar_transfer

            raddr(:)=raddr+raddr_inc;
        end


        if~rd_fifo_afull&&~rlast
            ar_transfer=true;
            if rlen==0
                rlast=true;
            end
        else

            ar_transfer=false;
        end

        if~rd_fifo_afull
            rlen(:)=rlen-1;
        end

    case STATE_RDFLUSH
        arready_o=false;



        if~rd_fifo_afull
            rstate_next(:)=STATE_RDIDLE;
        else
            rstate_next(:)=STATE_RDFLUSH;
        end
        rd_active=false;
    otherwise

        arready_o=false;
        rstate_next(:)=STATE_RDIDLE;
    end

    wstate(:)=wstate_next;
    rstate(:)=rstate_next;

end


