function[WORDLENGTH,FRACTIONLENGTH,blockInfo]=getTargetSpecificDT(this,blockInfo)





    fullPrecision=getFullPrecisionDT(this,blockInfo);

    XILINX_MAXOUTPUT_WORDLENGTH=blockInfo.XILINX_MAXOUTPUT_WORDLENGTH;
    ALTERA_MAXOUTPUT_WORDLENGTH=blockInfo.ALTERA_MAXOUTPUT_WORDLENGTH;


    WORDLENGTH=fullPrecision.WordLength;
    FRACTIONLENGTH=-fullPrecision.FractionLength;

    hDriver=hdlcurrentdriver;
    blockInfo.synthesisTool=hDriver.getParameter('SynthesisTool');

    if strcmpi(blockInfo.synthesisTool,'Xilinx Vivado')||strcmpi(blockInfo.synthesisTool,'Xilinx ISE')
        WORDLENGTH=max(XILINX_MAXOUTPUT_WORDLENGTH,WORDLENGTH);
    elseif strcmpi(blockInfo.synthesisTool,'Altera Quartus II')
        WORDLENGTH=max(ALTERA_MAXOUTPUT_WORDLENGTH,WORDLENGTH);
    end

