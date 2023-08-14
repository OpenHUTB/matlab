function[w_ptr,r_ptr,T0_start,T1_start,stateOut]=dnnfpgaInterprocessorfifobaselibPointer_state_machine(f0_full,f1_full,r_done)
%#codegen


    coder.allowpcode('plain');

    persistent state;
    if(isempty(state))
        state=fi(0,0,2,0);
    end

    stateOut=state;

    switch(state)

    case 0
        w_ptr=false;
        r_ptr=false;
        T0_start=false;
        T1_start=false;

    case 1
        w_ptr=true;
        r_ptr=false;
        T0_start=true;
        T1_start=false;

    case 2
        w_ptr=true;
        r_ptr=true;
        T0_start=false;
        T1_start=false;

    case 3
        w_ptr=false;
        r_ptr=true;
        T0_start=false;
        T1_start=true;
    otherwise
        w_ptr=false;
        r_ptr=false;
        T0_start=false;
        T1_start=false;
    end

    switch(state)
    case 0
        if f0_full
            nextState=fi(1,0,2,0);
        else
            nextState=fi(0,0,2,0);
        end
    case 1
        if r_done&&f1_full
            nextState=fi(3,0,2,0);
        elseif r_done
            nextState=fi(2,0,2,0);
        else
            nextState=fi(1,0,2,0);
        end
    case 2
        if f1_full
            nextState=fi(3,0,2,0);
        else
            nextState=fi(2,0,2,0);
        end
    case 3
        if r_done&&f0_full
            nextState=fi(1,0,2,0);
        elseif r_done
            nextState=fi(0,0,2,0);
        else
            nextState=fi(3,0,2,0);
        end
    otherwise
        nextState=fi(0,0,2,0);
    end

    state=nextState;
end
