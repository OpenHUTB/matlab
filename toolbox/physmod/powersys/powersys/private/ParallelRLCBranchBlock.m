function[sps,Multimeter]=ParallelRLCBranchBlock(nl,sps,Multimeter)





    idx=nl.filter_type('Parallel RLC Branch');
    blocks=sort(spsGetFullBlockPath(nl.elements(idx)));

    for i=1:numel(blocks)
        block=get_param(blocks{i},'Handle');
        SPSVerifyLinkStatus(block);
        BranchType=get_param(block,'BranchType');

        nodes=nl.block_nodes(block);
        if nodes(1)~=nodes(2)&&~strcmp(BranchType,'Open circuit')

            BlockName=getfullname(block);
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
                if~isreal(C)
                    error(message('physmod:powersys:common:NonRealParameter','Capacitance',BlockName))
                end
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

            sps.rlc(end+1,1:6)=[nodes(1),nodes(2),1,R,L*1e3,C*1e6];
            sps.rlcnames{end+1}=strrep(BlockName(sps.syslength:end),char(10),' ');
            Multimeter=BlockMeasurements(block,sps.rlc,Multimeter);


            if C~=0
                switch get_param(block,'Setx0')
                case 'on'
                    InitialVoltage=getSPSmaskvalues(block,{'InitialVoltage'});
                    sps.BlockInitialState.value{end+1}=InitialVoltage;
                case 'off'
                    sps.BlockInitialState.value{end+1}=NaN;


                end
                sps.BlockInitialState.state{end+1}=['Uc_',sps.rlcnames{end}];
                sps.BlockInitialState.block{end+1}=BlockName;
                sps.BlockInitialState.type{end+1}='Initial voltage';
            end


            if L~=0
                switch get_param(block,'SetiL0');
                case 'on'
                    InitialCurrent=getSPSmaskvalues(block,{'InitialCurrent'});
                    sps.BlockInitialState.value{end+1}=InitialCurrent;
                case 'off'
                    sps.BlockInitialState.value{end+1}=NaN;


                end
                sps.BlockInitialState.state{end+1}=['Il_',sps.rlcnames{end}];
                sps.BlockInitialState.block{end+1}=BlockName;
                sps.BlockInitialState.type{end+1}='Initial current';
            end

        end
    end