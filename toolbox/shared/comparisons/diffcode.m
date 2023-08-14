function[align1,align2,score]=diffcode(seq1,seq2)










    ret=comparisons_private('diffcode',seq1,seq2);
    [align1,align2,score]=deal(ret{:});
