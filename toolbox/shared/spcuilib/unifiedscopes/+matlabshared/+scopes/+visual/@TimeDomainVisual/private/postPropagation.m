

function postPropagation(this)


    [result,~]=builtin('license','checkout','Signal_Blocks');


    if~result
        [result,~]=license('checkout','Motor_Control_Blockset');
        if~result
            this.FrameProcessingAllowed=false;
        else
            this.FrameProcessingAllowed=true;
        end
    else
        this.FrameProcessingAllowed=true;
    end

end
