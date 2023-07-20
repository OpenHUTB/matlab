function[start,debug_dma_offset,stateOut]=dnnfpgaInputcontrollerInput_image_controller(start_in,done_in,image_length,image_count,image_base_addr,IMAGE_COUNT_LIMIT)
%#codegen

    coder.allowpcode('plain');

    persistent image_counter;
    if(isempty(image_counter))
        image_counter=fi(0,0,ceil(log2(IMAGE_COUNT_LIMIT)),0);
    end
    persistent state;
    if isempty(state)
        state=uint8(0);
    end
    persistent debug_dma_offset_reg;
    if isempty(debug_dma_offset_reg)
        debug_dma_offset_reg=fi(0,0,32,0);
    end


    INIT=uint8(0);
    START_CALCULATION=uint8(1);
    WAIT_FOR_DONE=uint8(2);
    COUNTER_INC=uint8(3);
    IDLE=uint8(4);

    debug_dma_offset=debug_dma_offset_reg;
    stateOut=state;
    switch(state)
    case INIT
        start=false;
        debug_dma_offset_reg(:)=image_base_addr;
        image_counter(:)=0;
    case START_CALCULATION
        start=true;
    case WAIT_FOR_DONE
        start=false;


    case COUNTER_INC
        start=false;
        debug_dma_offset_reg(:)=debug_dma_offset_reg+image_length*4;
        image_counter(:)=image_counter+1;
    case IDLE
        start=false;
    otherwise
        start=false;
        image_counter(:)=0;
        debug_dma_offset_reg(:)=0;
    end

    switch(state)
    case INIT
        if start_in
            nextState=START_CALCULATION;
        else
            nextState=INIT;
        end
    case START_CALCULATION
        nextState=WAIT_FOR_DONE;
    case WAIT_FOR_DONE
        if done_in
            nextState=COUNTER_INC;
        else
            nextState=WAIT_FOR_DONE;
        end
    case COUNTER_INC
        nextState=IDLE;
    case IDLE
        if(image_counter==image_count)
            nextState=INIT;
        else
            nextState=START_CALCULATION;
        end
    otherwise
        nextState=INIT;
    end

    state=nextState;

end






