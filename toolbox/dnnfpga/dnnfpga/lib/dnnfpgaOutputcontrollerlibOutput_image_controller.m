function[start,done,debug_dma_offset,stateOut]=dnnfpgaOutputcontrollerlibOutput_image_controller(start_in,done_in,result_length,result_count,result_base_addr,RESULT_COUNT_LIMIT)
%#codegen


    coder.allowpcode('plain');

    persistent result_counter;
    if(isempty(result_counter))
        result_counter=fi(0,0,ceil(log2(RESULT_COUNT_LIMIT)),0);
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
    ISSUE_DONE=uint8(5);

    debug_dma_offset=debug_dma_offset_reg;
    stateOut=state;
    switch(state)
    case INIT
        debug_dma_offset_reg(:)=result_base_addr;
        result_counter(:)=0;
        start=false;
        done=false;
    case START_CALCULATION
        start=true;
        done=false;
    case WAIT_FOR_DONE


        start=false;
        done=false;
    case COUNTER_INC
        debug_dma_offset_reg(:)=debug_dma_offset_reg+result_length*4;
        result_counter(:)=result_counter+1;
        start=false;
        done=false;
    case IDLE
        done=false;
        start=false;
    case ISSUE_DONE
        debug_dma_offset_reg(:)=result_base_addr;
        result_counter(:)=0;
        done=true;
        start=false;
    otherwise
        result_counter(:)=0;
        debug_dma_offset_reg(:)=0;
        start=false;
        done=false;
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
        if(result_counter==result_count)
            nextState=ISSUE_DONE;
        else
            nextState=START_CALCULATION;
        end
    case ISSUE_DONE
        if start_in
            nextState=START_CALCULATION;
        else
            nextState=ISSUE_DONE;
        end
    otherwise
        nextState=INIT;
    end

    state=nextState;

end






