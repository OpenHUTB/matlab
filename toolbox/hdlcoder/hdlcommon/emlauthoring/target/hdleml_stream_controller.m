%#codegen
function[fifo_in_read,fifo_out_write,dut_enable,cnt_enable]=hdleml_stream_controller(...
    fifo_in_empty_in,fifo_out_full_in,end_of_stream,extra_delay)













    coder.allowpcode('plain')
    eml_prefer_const(extra_delay);

    persistent scstate delaycnt fifo_out_write_reg dut_enable_reg cnt_enable_reg
    if isempty(scstate)
        scstate=uint8(0);
        delaycnt=uint16(0);
        fifo_out_write_reg=false;
        dut_enable_reg=false;
        cnt_enable_reg=false;
    end

    fifo_in_empty=logical(fifo_in_empty_in);
    fifo_out_full=logical(fifo_out_full_in);

    fifo_out_write=~fifo_out_full&&fifo_out_write_reg;
    dut_enable=~fifo_out_full&&dut_enable_reg;
    cnt_enable=~fifo_out_full&&cnt_enable_reg;

    switch uint8(scstate)

    case 0
        dut_enable_reg=false;
        cnt_enable_reg=false;
        fifo_out_write_reg=false;
        delaycnt(:)=0;
        fifo_in_read=false;

        if~fifo_in_empty&&extra_delay>0
            scstate(:)=1;
        elseif~fifo_in_empty&&extra_delay==0
            scstate(:)=2;
        else
            scstate(:)=0;
        end

    case 1

        fifo_out_write_reg=false;

        if fifo_in_empty
            dut_enable_reg=false;
            cnt_enable_reg=false;
            fifo_in_read=false;
            scstate(:)=6;

        elseif delaycnt>=extra_delay-1
            dut_enable_reg=true;
            cnt_enable_reg=true;
            fifo_in_read=true;
            scstate(:)=2;

        else
            delaycnt(:)=delaycnt+1;
            dut_enable_reg=true;
            cnt_enable_reg=true;
            fifo_in_read=true;
            scstate(:)=1;
        end

    case 2

        delaycnt(:)=0;

        if fifo_in_empty
            dut_enable_reg=false;
            cnt_enable_reg=false;
            fifo_out_write_reg=false;
            fifo_in_read=false;
            scstate(:)=7;
        elseif fifo_out_full
            dut_enable_reg=false;
            cnt_enable_reg=false;
            fifo_out_write_reg=false;
            fifo_in_read=false;
            scstate(:)=8;
        else
            dut_enable_reg=true;
            cnt_enable_reg=true;
            fifo_out_write_reg=true;
            fifo_in_read=true;
            scstate(:)=2;
        end

    case 3







        cnt_enable_reg=false;
        fifo_in_read=false;
        if fifo_out_full
            dut_enable_reg=false;
            fifo_out_write_reg=false;
            scstate(:)=9;
        elseif extra_delay==0||delaycnt>=extra_delay
            dut_enable_reg=false;
            fifo_out_write_reg=false;
            scstate(:)=0;
        else
            delaycnt(:)=delaycnt+1;
            dut_enable_reg=true;
            fifo_out_write_reg=true;
            scstate(:)=3;
        end

    case 6
        dut_enable_reg=false;
        cnt_enable_reg=false;
        fifo_in_read=false;
        fifo_out_write_reg=false;
        delaycnt(:)=delaycnt;

        if~fifo_in_empty
            scstate(:)=1;
        else
            scstate(:)=6;
        end

    case 7
        dut_enable_reg=false;
        cnt_enable_reg=false;
        fifo_in_read=false;
        fifo_out_write_reg=false;
        delaycnt(:)=0;

        if~fifo_in_empty
            scstate(:)=2;
        elseif end_of_stream
            scstate(:)=3;
        else
            scstate(:)=7;
        end

    case 8
        fifo_in_read=false;
        delaycnt(:)=0;

        if~fifo_out_full
            dut_enable_reg=true;
            cnt_enable_reg=true;
            fifo_out_write_reg=true;
            scstate(:)=2;
        else
            dut_enable_reg=false;
            cnt_enable_reg=false;
            fifo_out_write_reg=false;
            scstate(:)=8;
        end

    case 9

        cnt_enable_reg=false;
        fifo_in_read=false;
        delaycnt(:)=delaycnt;
        if~fifo_out_full
            dut_enable_reg=true;
            fifo_out_write_reg=true;
            scstate(:)=3;
        else
            dut_enable_reg=false;
            fifo_out_write_reg=false;
            scstate(:)=9;
        end

    otherwise

        dut_enable_reg=false;
        cnt_enable_reg=false;
        fifo_in_read=false;
        fifo_out_write_reg=false;
        delaycnt(:)=0;
        scstate(:)=0;

    end

end





