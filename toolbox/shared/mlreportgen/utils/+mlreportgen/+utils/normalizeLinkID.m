function out=normalizeLinkID(in)










    hashVal=mlreportgen.utils.hash(in);
    out=strcat("mw_",hashVal);