%#codegen
function[tvalid,fifo_read,transfer,cache_enb,cache_use]=hdleml_axistream_out(tready_in,fifo_empty_in_t)




    coder.allowpcode('plain')

    persistent sostate fifo_read_reg fifo_empty_reg
    if isempty(sostate)
        sostate=uint8(0);
        fifo_read_reg=false;
        fifo_empty_reg=false;
    end

    tready=logical(tready_in);
    fifo_empty_in=logical(fifo_empty_in_t);

    fifo_empty=fifo_empty_reg;
    fifo_read=fifo_read_reg;
    tvalid=tready&&(sostate==2||sostate==3);
    cache_enb=~fifo_empty&&fifo_read;
    cache_use=sostate==3;

    switch uint8(sostate)

    case 0
        fifo_read_reg=false;
        transfer=false;

        sostate(:)=1;

    case 1
        fifo_read_reg=true;

        if~fifo_empty&&fifo_read
            transfer=true;
            sostate(:)=2;

        else
            transfer=false;
            sostate(:)=1;
        end

    case 2

        if fifo_empty&&tready
            fifo_read_reg=true;
            transfer=false;
            sostate(:)=1;

        elseif~fifo_empty&&~tready
            fifo_read_reg=false;
            transfer=false;
            sostate(:)=3;

        elseif fifo_empty&&~tready
            fifo_read_reg=true;
            transfer=false;
            sostate(:)=2;

        else
            fifo_read_reg=true;
            transfer=true;
            sostate(:)=2;
        end

    case 3

        if tready
            fifo_read_reg=true;
            transfer=true;
            sostate(:)=2;



        else
            fifo_read_reg=false;
            transfer=false;
            sostate(:)=3;
        end

    otherwise
        fifo_read_reg=false;
        transfer=false;
        sostate(:)=0;

    end

    fifo_empty_reg=fifo_empty_in;

end




