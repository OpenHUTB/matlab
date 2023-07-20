
function programFPGA(fpgaTool,programFile,chainPosition)









    narginchk(3,3);

    assert(ischar(programFile)||isstring(programFile),message('soc:msgs:InvalidBitstreamArgumentType'));

    assert(isnumeric(chainPosition)&&(chainPosition>0),message('soc:msgs:InvalidChainPositionArgumentType'));

    switch lower(fpgaTool)
    case{'intel','altera'}
        soc.internal.programIntelFPGA(programFile,chainPosition);
    case{'xilinx','xilinx vivado'}
        soc.internal.programXilinxFPGA(programFile,chainPosition);
    otherwise
        error(message('soc:msgs:InvalidFpgaVendor',fpgaTool));
    end