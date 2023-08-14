%#codegen
function[reset_out_o,reset_pending_o]=...
    hdleml_reset_hold(reset_in_i,in_burst_i)




    coder.allowpcode('plain')

    persistent hstate reset_out_reg reset_pending_reg
    if isempty(hstate)
        hstate=uint8(0);
        reset_out_reg=false;
        reset_pending_reg=false;
    end

    reset_in=logical(reset_in_i);
    in_burst=logical(in_burst_i);


    STATE_IDLE=coder.const(0);
    STATE_IN_BURST=coder.const(1);
    STATE_RESET_HOLD=coder.const(2);
    STATE_RESET_RELEASE=coder.const(3);


    reset_out_o=reset_out_reg;
    reset_pending_o=reset_pending_reg;


    switch uint8(hstate)
    case STATE_IDLE

        if in_burst
            reset_out_reg=false;
            if reset_in


                reset_pending_reg=true;
                hstate(:)=STATE_RESET_HOLD;
            else
                reset_pending_reg=false;
                hstate(:)=STATE_IN_BURST;
            end
        else

            reset_out_reg=reset_in;
            reset_pending_reg=false;
        end

    case STATE_IN_BURST

        if~in_burst
            reset_out_reg=reset_in;
            reset_pending_reg=false;
            hstate(:)=STATE_IDLE;
        elseif reset_in
            reset_out_reg=false;
            reset_pending_reg=true;
            hstate(:)=STATE_RESET_HOLD;
        else
            reset_out_reg=false;
            reset_pending_reg=false;
        end

    case STATE_RESET_HOLD

        reset_out_reg=false;
        reset_pending_reg=true;

        if~in_burst
            hstate(:)=STATE_RESET_RELEASE;
        end

    case STATE_RESET_RELEASE

        reset_out_reg=true;
        reset_pending_reg=true;

        hstate(:)=STATE_IDLE;

    otherwise
        hstate(:)=STATE_IDLE;
    end

end




