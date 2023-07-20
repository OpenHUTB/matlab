function[SPS,sv,src,out,circ2ssInfo,EquivalentCircuit]=psb2sys(SPS,commandLine,silent,fid_outfile)










    SPS_local=SPS;


    SPS_local.vary_name=[];
    SPS_local.vary_val=[];
    SPS_local.nvary=0;


    SPS_local.outstr=SPS.yout;
    SPS_local.freq_sys=SPS.freq;

    if~silent
        disp('Computing state-space representation of linear electrical circuit ...');
    end


    [data,Y,names,srcnames,outnames,orgEdgeNbrs,idxSrc,idxOut,circ2ssInfo,...
    Lmut,SPS_local]=psb1topsb2(SPS_local,commandLine,fid_outfile);

    nodes=unique(data(:,3:4));


    if all(size(nodes)==[1,2])
        nodes=nodes';
    end


    if any(nodes'~=0:length(nodes)-1)
        message=['Bad node assignment, nodes are not consecutively ','numbered. Nodes obtained are ',num2str(nodes')];
        Erreur.message=message;
        Erreur.identifier='SpecializedPowerSystems:psb2sys:BadNodeAssignment';
        psberror(Erreur);
    end


    [SPS_local,sv,src,out,qty,circ2ssInfo,EquivalentCircuit]=getABCD(data,Y,names,srcnames,...
    outnames,orgEdgeNbrs,idxSrc,idxOut,commandLine,silent,SPS_local,circ2ssInfo,Lmut,fid_outfile);


    SPS.A=full(SPS_local.A);
    SPS.B=full(SPS_local.B);
    SPS.C=full(SPS_local.C);
    SPS.D=full(SPS_local.D);


    if SPS.PowerguiInfo.SPID
        SPS.MgNotRed=SPS_local.MgNotRed;
        SPS.MgColNamesNotRed=SPS_local.MgColNamesNotRed;
        SPS.Mg_nbNotRed=SPS_local.Mg_nbNotRed;
        SPS.Mg=SPS_local.Mg;
        SPS.MgColNames=SPS_local.MgColNames;
        SPS.Mg_nb=SPS_local.Mg_nb;

        SPS.A=SPS_local.A;
        SPS.B=SPS_local.B;
        SPS.C=SPS_local.C;
        SPS.D=SPS_local.D;

        SPS.Aswitch=SPS_local.Aswitch;
        SPS.Bswitch=SPS_local.Bswitch;
        SPS.Cswitch=SPS_local.Cswitch;
        SPS.Dswitch=SPS_local.Dswitch;

        SPS.MatStateDependency=SPS_local.MatStateDependency;
    end