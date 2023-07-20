function[sps,Multimeter]=ThreePhaseParallelRLCBranchBlock(nl,sps,Multimeter)





    idx=nl.filter_type('Three-Phase Parallel RLC Branch');
    blocks=sort(spsGetFullBlockPath(nl.elements(idx)));

    for i=1:numel(blocks)
        block=get_param(blocks{i},'Handle');
        SPSVerifyLinkStatus(block);
        BranchType=get_param(block,'BranchType');
        if~strcmp(BranchType,'Open circuit')
            BlockName=getfullname(block);
            BlockNom=strrep(BlockName(sps.syslength:end),newline,' ');
            [R,L,C]=getSPSmaskvalues(block,{'Resistance','Inductance','Capacitance'});


            OpenCircuitIsAnError=false;

            switch BranchType

            case 'R'

                blocinit(block,{R,1,1});
                if~isreal(R)
                    error(message('physmod:powersys:common:NonRealParameter','Resistance',BlockName))
                end

                if abs(R)==inf&&OpenCircuitIsAnError

                    errorZeroInf('Resistance',BlockName);
                end
                L=0;
                C=0;

            case 'L'

                blocinit(block,{1,L,1});
                if~isreal(L)
                    error(message('physmod:powersys:common:NonRealParameter','Inductance',BlockName))
                end

                if abs(L)==inf&&OpenCircuitIsAnError

                    errorZeroInf('Inductance',BlockName);
                end
                R=0;
                C=0;

            case 'C'

                blocinit(block,{1,1,C});
                if~isreal(C)
                    error(message('physmod:powersys:common:NonRealParameter','Capacitance',BlockName))
                end

                if C==0&&OpenCircuitIsAnError

                    errorZeroInf('Capacitance',BlockName);
                end
                L=0;
                R=0;

            case 'RL'

                blocinit(block,{R,L,1});
                if~isreal(R)
                    error(message('physmod:powersys:common:NonRealParameter','Resistance',BlockName))
                end
                if~isreal(L)
                    error(message('physmod:powersys:common:NonRealParameter','Inductance',BlockName))
                end
                if~isreal(C)
                    error(message('physmod:powersys:common:NonRealParameter','Capacitance',BlockName))
                end
                if abs(R)==inf&&abs(L)==inf&&OpenCircuitIsAnError

                    errorOpenCircuit(BlockName);
                end
                C=0;

            case 'RC'

                blocinit(block,{R,1,C});
                if~isreal(R)
                    error(message('physmod:powersys:common:NonRealParameter','Resistance',BlockName))
                end
                if~isreal(C)
                    error(message('physmod:powersys:common:NonRealParameter','Capacitance',BlockName))
                end
                if abs(R)==inf&&C==0&&OpenCircuitIsAnError

                    errorOpenCircuit(BlockName);
                end
                L=0;

            case 'LC'

                blocinit(block,{1,L,C});
                if~isreal(L)
                    error(message('physmod:powersys:common:NonRealParameter','Inductance',BlockName))
                end
                if abs(L)==inf&&C==0&&OpenCircuitIsAnError

                    errorOpenCircuit(BlockName);
                end
                R=0;

            case 'RLC'

                blocinit(block,{R,L,C});
                if~isreal(R)
                    error(message('physmod:powersys:common:NonRealParameter','Resistance',BlockName))
                end
                if~isreal(L)
                    error(message('physmod:powersys:common:NonRealParameter','Inductance',BlockName))
                end
                if~isreal(C)
                    error(message('physmod:powersys:common:NonRealParameter','Capacitance',BlockName))
                end
                if abs(R)==inf&&abs(L)==inf&&C==0&&OpenCircuitIsAnError

                    errorOpenCircuit(BlockName);
                end

            end


            if abs(R)==inf
                R=0;
            end
            if abs(L)==inf
                L=0;
            end
            if abs(C)==inf
                C=0;
            end

            if R==0&&L==0&&C==0


                continue
            end


            nodes=nl.block_nodes(block);
            sps.rlc(end+1:end+3,1:6)=[...
            nodes(1),nodes(4),1,R,L*1e3,C*1e6;
            nodes(2),nodes(5),1,R,L*1e3,C*1e6;
            nodes(3),nodes(6),1,R,L*1e3,C*1e6];
            sps.rlcnames{end+1}=['phase_A: ',BlockNom];
            sps.rlcnames{end+1}=['phase_B: ',BlockNom];
            sps.rlcnames{end+1}=['phase_C: ',BlockNom];
            Multimeter=BlockMeasurements(block,sps.rlc,Multimeter);
        end
    end