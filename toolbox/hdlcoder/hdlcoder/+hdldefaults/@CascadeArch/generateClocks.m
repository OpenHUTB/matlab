function generateClocks(this,hN,hC)





    reporterrors(this,hC);




    decomposition=this.getDecomposition();
    in=hC.PirInputPorts(1).Signal;
    invectsize=max(hdlsignalvector(in));
    userData.decompose_vector=hdlcascadedecompose(invectsize,decomposition);

    if isempty(userData.decompose_vector)
        Up=0;
    else
        Up=userData.decompose_vector(1);
    end

    Down=1;
    Phase=1;

    if Up>1
        hS=this.findSignalWithValidRate(hC.Owner,hC,...
        [hC.PirInputPorts(1).Signal,...
        hC.PirOutputPorts(1).Signal]);
        [c,enb,r]=hdlgetclockbundle(hN,hC,hS,1,1,1);%#ok
        [c,outVld,r]=hdlgetclockbundle(hC.Owner,hC,hS,1,1,0);%#ok
        if(invectsize>2)
            [c,enb,r]=hdlgetclockbundle(hN,hC,hS,Up,Down,Phase);%#ok
        end
    end

    if Up>=1
        userData.Latency=1;
    else
        userData.Latency=0;
    end

    if Up>1
        userData.doutVld=outVld;
    end
    userData.Down=Down;
    userData.Phase=Phase;

    this.setHDLUserData(hC,userData);
