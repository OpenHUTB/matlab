function out=replaceBitIndexWithBITTxt(endsWithDotBit)
    out=regexprep(endsWithDotBit,'\.(\d+)','.xxx__BIT$1');
end