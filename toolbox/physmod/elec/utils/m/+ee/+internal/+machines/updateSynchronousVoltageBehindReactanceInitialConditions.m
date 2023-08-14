function ic=updateSynchronousVoltageBehindReactanceInitialConditions(ic,s)%#codegen







    coder.allowpcode('plain');





    ic.eddd0=(s.Xq-s.Xqdd)*ic.pu_iq0;
    ic.eqd0=ic.pu_fd_Efd0-(s.Xd-s.Xdd)*ic.pu_id0;
    ic.eqdd0=ic.eqd0-(s.Xdd-s.Xddd)*ic.pu_id0;
end