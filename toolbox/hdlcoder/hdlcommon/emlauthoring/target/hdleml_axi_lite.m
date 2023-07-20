%#codegen
function[awready,wready,bvalid,arready,rvalid,aw_transfer,w_transfer,ar_transfer]=...
    hdleml_axi_lite(awvalid_in,wvalid_in,bready_in,arvalid_in,rready_in)



    coder.allowpcode('plain')

    persistent wstate
    if isempty(wstate)
        wstate=uint8(0);
    end

    persistent rstate
    if isempty(rstate)
        rstate=uint8(0);
    end

    awvalid=logical(awvalid_in);
    wvalid=logical(wvalid_in);
    bready=logical(bready_in);
    arvalid=logical(arvalid_in);
    rready=logical(rready_in);

    rstate_next=rstate;
    wstate_next=wstate;






    switch uint8(wstate)

    case 0


        awready=(rstate==0);
        wready=false;
        bvalid=false;

        if awvalid&&(rstate==0)
            wstate_next(:)=1;
        else
            wstate_next(:)=0;
        end

    case 1

        awready=false;
        wready=true;
        bvalid=false;

        if wvalid
            wstate_next(:)=2;
        else
            wstate_next(:)=1;
        end

    case 2

        awready=false;
        wready=false;
        bvalid=true;

        if bready
            wstate_next(:)=0;
        else
            wstate_next(:)=2;
        end

    otherwise

        awready=false;
        wready=false;
        bvalid=false;

        wstate_next(:)=0;
    end

    aw_transfer=awvalid&awready;
    w_transfer=wvalid&wready;


    switch uint8(rstate)

    case 0


        arready=(wstate==0)&&~awvalid;
        rvalid=false;

        if arvalid&&(wstate==0)&&~awvalid
            rstate_next(:)=1;
        else
            rstate_next(:)=0;
        end

    case 1

        arready=false;
        rvalid=true;

        if rready
            rstate_next(:)=0;
        else
            rstate_next(:)=1;
        end

    otherwise

        arready=false;
        rvalid=false;

        rstate_next(:)=0;
    end

    ar_transfer=arvalid&arready;
    wstate(:)=wstate_next;
    rstate(:)=rstate_next;

end




