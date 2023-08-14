function hdlcode=emit_ram(this,inputSignals,outputSignals,inputNames,outputNames)






    hdlcode=this.inithdlcode;


    iports=getPortStruct(this,inputSignals,inputNames);
    oports=getPortStruct(this,outputSignals,outputNames);

    if this.hasClkEn
        inputOffset=2;
        ce=iports(inputOffset);
    else
        inputOffset=1;
        ce=struct([]);
    end

    if this.dataIsComplex
        complexOffset=1;
    else
        complexOffset=0;
    end

    clk=iports(1);
    di=iports(inputOffset+1:inputOffset+complexOffset+1);
    wa=iports(inputOffset+complexOffset+2);
    we=iports(inputOffset+complexOffset+3);
    ra=iports(inputOffset+complexOffset+4);

    wdo=oports(1:complexOffset+1);
    rdo=oports(complexOffset+2:end);


    str=this.fileHeader;


    if this.isVhdl
        str=[str,ramEntityVhdl(this,iports,oports)];
        str=[str,ramBodyVhdl(this,clk,ce,di,wa,we,ra,wdo,rdo)];
    else
        str=[str,ramEntityVerilog(this,iports,oports)];
        str=[str,ramBodyVerilog(this,clk,ce,di,wa,we,ra,wdo,rdo)];
    end


    writeRamFile(this,str);


