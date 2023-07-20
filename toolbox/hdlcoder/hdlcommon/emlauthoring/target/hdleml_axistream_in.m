%#codegen
function[tready,fifo_write,transfer,cache_enb,cache_use]=hdleml_axistream_in(tvalid_in,fifo_full_in)




    coder.allowpcode('plain')

    persistent sistate ready_reg,
    if isempty(sistate)
        sistate=uint8(0);
        ready_reg=false;
    end

    tvalid=logical(tvalid_in);
    fifo_full=logical(fifo_full_in);

    tready=ready_reg;
    fifo_write=~fifo_full&&(sistate==2||sistate==3);
    cache_enb=tvalid&&tready;
    cache_use=sistate==3;

    switch uint8(sistate)

    case 0
        ready_reg=false;
        transfer=false;

        sistate(:)=1;

    case 1
        ready_reg=true;

        if tvalid&&tready
            transfer=true;
            sistate(:)=2;

        else
            transfer=false;
            sistate(:)=1;
        end

    case 2

        if~tvalid&&~fifo_full
            ready_reg=true;
            transfer=false;
            sistate(:)=1;

        elseif tvalid&&fifo_full
            ready_reg=false;
            transfer=false;
            sistate(:)=3;

        elseif~tvalid&&fifo_full
            ready_reg=true;
            transfer=false;
            sistate(:)=2;

        else
            ready_reg=true;
            transfer=true;
            sistate(:)=2;
        end

    case 3

        if~fifo_full
            ready_reg=true;
            transfer=true;
            sistate(:)=2;



        else
            ready_reg=false;
            transfer=false;
            sistate(:)=3;
        end

    otherwise
        ready_reg=false;
        transfer=false;
        sistate(:)=0;

    end

end




