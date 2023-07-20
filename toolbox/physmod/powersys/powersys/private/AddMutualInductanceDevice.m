function[sps,Multimeter,NewNode]=AddMutualInductanceDevice(BlockNom,NumberOfWindings,ResistanceMatrix,InductanceMatrix,Nodes,NewNode,sps,Multimeter,measure)






    RLCTEMP=[];
    RLCTEMPnames={};

    for winding=1:NumberOfWindings


        R=ResistanceMatrix(winding,winding);
        L=InductanceMatrix(winding,winding)*1e3;

        sps.rlc(end+1,1:6)=[Nodes(winding),Nodes(winding+NumberOfWindings),4,R,L,0];
        sps.rlcnames{end+1}=['winding_',num2str(winding),'_self: ',BlockNom];

        x=size(sps.rlc,1);
        if strcmp('Winding voltages',measure)||strcmp('Winding voltages and currents',measure)
            Multimeter.Yu(end+1,1:2)=sps.rlc(x,1:2);
            Multimeter.V{end+1}=['Uw',num2str(winding),': ',BlockNom];
        end
        if strcmp('Winding currents',measure)||strcmp('Winding voltages and currents',measure)
            Multimeter.Yi{end+1,1}=x;
            Multimeter.I{end+1}=['Iw',num2str(winding),': ',BlockNom];
        end


        for k=winding+1:NumberOfWindings


            R=ResistanceMatrix(winding,k);
            L=InductanceMatrix(winding,k)*1e3;

            RLCTEMP(end+1,1:6)=[NewNode,Nodes(winding+NumberOfWindings),444,R,L,0];%#ok  type 444 will be reset to 0 later in psbsort.
            RLCTEMPnames{end+1}=['mut_',num2str(winding),'_',num2str(k),': ',BlockNom];%#ok

            NewNode=NewNode+1;

        end

    end


    sps.rlc=[sps.rlc;RLCTEMP];
    sps.rlcnames=[sps.rlcnames,RLCTEMPnames];