function loop_unrolling=set_loop_unrolling(this,loop_unrolling)



    if~loop_unrolling&&this.isverilog
        loop_unrolling=true;
        warning(message('HDLShared:CLI:invalidSettingLoopUnrolling'));
    end
