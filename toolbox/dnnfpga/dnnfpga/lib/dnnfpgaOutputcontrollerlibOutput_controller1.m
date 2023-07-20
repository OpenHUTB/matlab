function[dma_len,dma_offset,dma_start,stateOut,done]=dnnfpgaOutputcontrollerlibOutput_controller1(start,request_length,dma_offset_in,dma_done_in,ddr_ready)
%#codegen




    coder.allowpcode('plain');

    persistent offset_counter;
    if isempty(offset_counter)
        offset_counter=uint32(0);
    end
    persistent state;
    if isempty(state)
        state=uint8(0);
    end


    INIT=uint8(0);
    IDLE=uint8(1);
    START_LOADING=uint8(2);
    LOAD_IMAGE_DATA=uint8(3);
    FINISH_LOADING=uint8(4);




    switch(state)
    case INIT
        dma_len=fi(0,0,32,0);
        dma_offset=fi(0,0,32,0);
        dma_start=false;
        done=false;
    case IDLE
        dma_len=fi(0,0,32,0);
        dma_offset=fi(0,0,32,0);
        dma_start=false;
        done=false;
    case START_LOADING

        dma_len=fi(request_length,0,32,0);
        dma_offset=fi(dma_offset_in,0,32,0);

        dma_start=ddr_ready;
        done=false;
    case LOAD_IMAGE_DATA
        dma_len=fi(request_length,0,32,0);
        dma_offset=fi(dma_offset_in,0,32,0);
        dma_start=false;
        done=false;
    case FINISH_LOADING
        dma_len=fi(0,0,32,0);
        dma_offset=fi(0,0,32,0);
        dma_start=false;
        done=true;
    otherwise

        dma_len=fi(0,0,32,0);
        dma_offset=fi(0,0,32,0);
        dma_start=false;
        done=false;
    end


    switch(state)
    case INIT
        nextState=IDLE;
    case IDLE
        if start
            nextState=START_LOADING;
        else
            nextState=IDLE;
        end
    case START_LOADING
        if ddr_ready
            nextState=LOAD_IMAGE_DATA;
        else
            nextState=START_LOADING;
        end
    case LOAD_IMAGE_DATA
        if dma_done_in
            nextState=FINISH_LOADING;
        else
            nextState=LOAD_IMAGE_DATA;
        end
    case FINISH_LOADING
        nextState=IDLE;
    otherwise
        nextState=INIT;
    end

    stateOut=state;
    state=nextState;

end

