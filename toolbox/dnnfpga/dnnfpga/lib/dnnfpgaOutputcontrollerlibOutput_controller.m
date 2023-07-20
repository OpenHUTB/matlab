function[debug_enable,debug_select,image_valid,image_addr,debug_rdaddr,debug_dma_enable,debug_dma_len,debug_dma_width,debug_dma_offset,debug_dma_direction,debug_dma_start,stateOut,done]=dnnfpgaOutputcontrollerlibOutput_controller(inputStart,image_length,debug_dma_offset_in,debug_dma_width_in,dma_done_in,memSelect,DEBUG_ADDR_WIDTH,DEBUG_ID_ADDRW,DEBUG_BANK_ADDRW)
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


    image_valid=false;
    image_addr=fi(0,0,DEBUG_ADDR_WIDTH,0);
    debug_rdaddr=fi(0,0,DEBUG_ADDR_WIDTH,0);
    debug_select_id=fi(memSelect,0,DEBUG_ID_ADDRW,0);




    switch(state)
    case INIT
        debug_bank=fi(0,0,DEBUG_BANK_ADDRW,0);
        debug_dma_enable=false;
        debug_dma_len=fi(0,0,32,0);
        debug_dma_width=fi(0,0,32,0);
        debug_dma_offset=fi(0,0,32,0);
        debug_dma_direction=false;
        debug_dma_start=false;
        done=false;
        debug_enable=false;
    case IDLE
        debug_bank=fi(0,0,DEBUG_BANK_ADDRW,0);
        debug_dma_enable=false;
        debug_dma_len=fi(0,0,32,0);
        debug_dma_width=fi(0,0,32,0);
        debug_dma_offset=fi(0,0,32,0);
        debug_dma_direction=false;
        debug_dma_start=false;
        done=false;
        debug_enable=false;
    case START_LOADING
        debug_bank=fi(0,0,DEBUG_BANK_ADDRW,0);

        debug_dma_enable=true;
        debug_dma_len=fi(image_length,0,32,0);
        debug_dma_width=fi(debug_dma_width_in,0,32,0);
        debug_dma_offset=fi(debug_dma_offset_in,0,32,0);

        debug_dma_direction=false;
        debug_dma_start=true;
        done=false;
        debug_enable=true;
    case LOAD_IMAGE_DATA
        debug_bank=fi(0,0,DEBUG_BANK_ADDRW,0);
        debug_dma_enable=true;
        debug_dma_len=fi(image_length,0,32,0);
        debug_dma_width=fi(debug_dma_width_in,0,32,0);
        debug_dma_offset=fi(debug_dma_offset_in,0,32,0);
        debug_dma_direction=false;
        debug_dma_start=false;
        done=false;
        debug_enable=true;
    case FINISH_LOADING
        debug_bank=fi(0,0,DEBUG_BANK_ADDRW,0);
        debug_dma_enable=false;
        debug_dma_len=fi(0,0,32,0);
        debug_dma_width=fi(0,0,32,0);
        debug_dma_offset=fi(0,0,32,0);
        debug_dma_direction=false;
        debug_dma_start=false;
        done=true;
        debug_enable=false;
    otherwise

        debug_bank=fi(0,0,DEBUG_BANK_ADDRW,0);
        debug_dma_enable=false;
        debug_dma_len=fi(0,0,32,0);
        debug_dma_width=fi(0,0,32,0);
        debug_dma_offset=fi(0,0,32,0);
        debug_dma_direction=false;
        debug_dma_start=false;
        done=false;
        debug_enable=false;
    end

    debug_select=bitconcat(debug_bank,debug_select_id);


    switch(state)
    case INIT
        nextState=IDLE;
    case IDLE
        if inputStart
            nextState=START_LOADING;
        else
            nextState=IDLE;
        end
    case START_LOADING
        nextState=LOAD_IMAGE_DATA;
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

