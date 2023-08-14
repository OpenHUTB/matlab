function runGenerateCGIR(this,p)



    if this.getParameter('isvhdl')
        langStr='VHDL';
    elseif this.getParameter('isverilog')
        langStr='Verilog';
    else

        langStr='SystemVerilog';
    end
    hdldisp(message('hdlcoder:hdldisp:BeginCodegen',langStr,p.ModelName));


    p.createCGIR;
end


