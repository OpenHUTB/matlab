function hC=getGain(s)







    hC=pirelab.getGainComp(...
    s.Network,...
    s.Inputs,...
    s.Outputs,...
    s.GainVal,...
    0,...
    1,...
    s.RoundingMethod,...
    s.OverflowAction,...
    s.Name);
