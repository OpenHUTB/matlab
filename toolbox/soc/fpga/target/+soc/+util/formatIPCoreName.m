function ipcore_name=formatIPCoreName(block_name)

    dut_name=regexprep(block_name,'[\W]*','_');



    outName=lower(matlab.lang.makeValidName(dut_name,'ReplacementStyle','delete','Prefix','dut'));


    outName=regexprep(outName,'(_)+','_');


    outName=regexprep(outName,'^(_*)','');
    outName=regexprep(outName,'(_*)$','');























    ipcore_name=[outName,'_ip'];

end


