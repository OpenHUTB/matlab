function hC=getRealImagToComplex(s)







    hC=pirelab.getRealImag2Complex(...
    s.Network,...
    s.Inputs,...
    s.Outputs,...
    'real and imag',...
    s.Name);
