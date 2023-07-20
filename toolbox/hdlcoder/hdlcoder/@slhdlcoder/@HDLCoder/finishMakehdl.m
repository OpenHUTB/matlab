function finishMakehdl(this,hs)





    hdldisp(message('hdlcoder:hdldisp:CodegenComplete'));

    success=true;
    this.cleanup(hs,success);
end
