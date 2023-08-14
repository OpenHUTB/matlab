function out=zeroSequence(in)










    out=in;


    zero_sequence_option=in.getValue('zero_sequence');

    blockName=strrep(gcb,newline,' ');
    if~isempty(zero_sequence_option)&&(int32(eval(zero_sequence_option))==int32(ee.enum.park.zerosequence.exclude))
        pm_warning('physmod:ee:library:ZeroSequence',blockName);
    end

end