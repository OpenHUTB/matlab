function[sps,Multimeter]=SeriesRLCLoadBlock(nl,sps,Multimeter)







    idx=nl.filter_type('Series RLC Load');
    blocks=sort(spsGetFullBlockPath(nl.elements(idx)));

    for i=1:numel(blocks)
        block=get_param(blocks{i},'Handle');
        SPSVerifyLinkStatus(block);
        BlockName=getfullname(block);
        [Vb,fn,Pn,Ql,Qc]=getSPSmaskvalues(block,{'NominalVoltage','NominalFrequency','ActivePower','InductivePower','CapacitivePower'});
        blocinit(block,{Vb,fn,Pn,Ql,Qc});
        S=sqrt((Ql-Qc)^2+Pn^2);
        Ib=S/Vb;
        R=Pn/(Ib*Ib);
        L=Ql/(Ib*Ib*2*pi*fn)*1e3;
        if Qc==0
            C=0;
        else
            C=Ib*Ib/(2*pi*fn*Qc)*1e6;
        end

        nodes=nl.block_nodes(block);

        if isfield(sps,'LoadFlow')||isfield(sps,'UnbalancedLoadFlow')
            LoadType=getSPSmaskvalues(block,{'LoadType'});
            if LoadType==1

                ADDRLC=1;
                BusType='Z';
            elseif LoadType==2

                ADDRLC=0;
                BusType='PQ';
            else

                ADDRLC=0;
                BusType='I';
            end
        else
            ADDRLC=1;
        end


        if ADDRLC
            sps.rlc(end+1,1:6)=[nodes(1),nodes(2),0,R,L,C];
            sps.rlcnames{end+1}=strrep(BlockName(sps.syslength:end),char(10),' ');
            Multimeter=BlockMeasurements(block,sps.rlc,Multimeter);
        end


        if C~=0&&ADDRLC
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


        if L~=0&&ADDRLC
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

        if isfield(sps,'UnbalancedLoadFlow')


            Fields={'blockType','busType','P','Q','Qmin','Qmax','nodes','handle'};
            Values={'RLC load 1ph',BusType,Pn,(Ql-Qc),-inf,+inf,nodes,block};

            for k=1:length(Values)
                sps.UnbalancedLoadFlow.rlcload.(Fields{k}){i}=Values{k};
            end


            sps.UnbalancedLoadFlow.rlcload.connection{i}='';
            sps.UnbalancedLoadFlow.rlcload.S{i}=0;
            sps.UnbalancedLoadFlow.rlcload.Vt{i}=1;
            sps.UnbalancedLoadFlow.rlcload.I{i}=0;
            sps.UnbalancedLoadFlow.rlcload.vnom{i}=Vb;
            sps.UnbalancedLoadFlow.rlcload.busNumber{i}=NaN;

        end

    end