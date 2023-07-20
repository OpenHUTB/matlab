function[ram_addr_valid,ram_addr,dma_write_ready,wr_addr,wr_len,wr_valid,stateOut]=dnnfpgaTblibDdrWriteCtrl2(length_in,start,wr_ready,wr_complete)
%#codegen



    coder.allowpcode('plain');


    persistent burst_stop
    if(isempty(burst_stop))
        burst_stop=uint32(0);
    end
    persistent burst_count;
    if(isempty(burst_count))
        burst_count=uint32(0);
    end
    persistent state;
    if(isempty(state))
        state=fi(0,0,4,0);
    end


    stateOut=state;


    IDLE=fi(0,0,4,0);
    DATA_COUNT=fi(1,0,4,0);
    ACK_WAIT=fi(2,0,4,0);






    switch(state)
    case IDLE

        wr_addr=uint32(0);
        wr_len=uint32(0);
        wr_valid=false;


        ram_addr_valid=false;
        ram_addr=uint32(0);
        dma_write_ready=true;


        burst_stop=uint32(length_in);
        burst_count=uint32(0);
    case DATA_COUNT

        wr_addr=uint32(0);
        wr_len=uint32(burst_stop);
        wr_valid=wr_ready;


        ram_addr_valid=wr_ready;
        ram_addr=uint32(burst_count);
        dma_write_ready=false;


        if wr_ready
            burst_count=uint32(burst_count+1);
        end
    case ACK_WAIT

        wr_addr=uint32(0);
        wr_len=uint32(0);
        wr_valid=false;


        ram_addr_valid=false;
        ram_addr=uint32(0);
        dma_write_ready=false;
    otherwise

        wr_addr=uint32(0);
        wr_len=uint32(0);
        wr_valid=false;


        ram_addr_valid=false;
        ram_addr=uint32(0);
        dma_write_ready=false;

    end


    switch(state)
    case IDLE
        if(start)
            nextState=DATA_COUNT;
        else
            nextState=IDLE;
        end
    case DATA_COUNT
        if(burst_count==burst_stop)
            nextState=ACK_WAIT;
        else
            nextState=DATA_COUNT;
        end
    case ACK_WAIT
        if(wr_complete)
            nextState=IDLE;
        else
            nextState=ACK_WAIT;
        end
    otherwise
        nextState=IDLE;
    end

    if(wr_ready)
        state=nextState;
    end

end
