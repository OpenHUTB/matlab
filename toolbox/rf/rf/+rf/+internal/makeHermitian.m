function out=makeHermitian(in)




    out=in+conj(permute(in,[2,1,3]));