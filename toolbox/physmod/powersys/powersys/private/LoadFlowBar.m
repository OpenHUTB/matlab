function[sps,YuMeasurement,YuSwitches,YuNonlinear,YuImpedance,Multimeter,Ycurr]=LoadFlowBar(nl,sps,Option,YuMeasurement,YuSwitches,YuNonlinear,YuImpedance,Multimeter,LoadFlowAnalysis,UnbalancedLoadFlowAnalysis,Ycurr)





    idx=nl.filter_type('Load Flow Bus');
    blocks=sort(spsGetFullBlockPath(nl.elements(idx)));

    switch Option

    case 'short-circuit'



        NodeTable=[];


        for i=1:numel(blocks)

            block=get_param(blocks{i},'Handle');

            switch get_param(block,'Connectors')
            case 'on both sides'
                nodes=nl.block_nodes(block);
                switch length(nodes)
                case 6
                    NodeTable(end+1,1:2)=[nodes(1),nodes(4)];
                    NodeTable(end+1,1:2)=[nodes(2),nodes(5)];
                    NodeTable(end+1,1:2)=[nodes(3),nodes(6)];
                case 4
                    NodeTable(end+1,1:2)=[nodes(1),nodes(3)];
                    NodeTable(end+1,1:2)=[nodes(2),nodes(4)];
                case 2
                    NodeTable(end+1,1:2)=[nodes(1),nodes(2)];
                end
            end

        end


        if~isempty(NodeTable)
            for i=1:size(NodeTable,1)
                Keep=NodeTable(i,1);
                Leave=NodeTable(i,2);


                k=(NodeTable==Leave);
                NodeTable(k)=Keep;


                if~isempty(sps.rlc)
                    k=(sps.rlc(:,1:2)==Leave);
                    sps.rlc(k)=Keep;
                end
                if~isempty(sps.source)
                    k=(sps.source(:,1:2)==Leave);
                    sps.source(k)=Keep;
                end
                if~isempty(sps.switches)
                    k=(sps.switches(:,1:2)==Leave);
                    sps.switches(k)=Keep;
                end
                if~isempty(YuMeasurement)
                    k=(YuMeasurement(:,1:2)==Leave);
                    YuMeasurement(k)=Keep;
                end
                if~isempty(YuSwitches)
                    k=(YuSwitches(:,1:2)==Leave);
                    YuSwitches(k)=Keep;
                end
                if~isempty(YuNonlinear)
                    k=(YuNonlinear(:,1:2)==Leave);
                    YuNonlinear(k)=Keep;
                end
                if~isempty(YuImpedance)
                    k=(YuImpedance(:,1:2)==Leave);
                    YuImpedance(k)=Keep;
                end
                if~isempty(Multimeter.Yu)
                    k=(Multimeter.Yu(:,1:2)==Leave);
                    Multimeter.Yu(k)=Keep;
                end
                if~isempty(Ycurr)
                    k=(Ycurr(:,1:2)==Leave);
                    Ycurr(k)=Keep;
                end


                if LoadFlowAnalysis
                    for j=1:length(sps.LoadFlow.bus)
                        if sps.LoadFlow.bus(j).Busnode==Leave;
                            sps.LoadFlow.bus(j).Busnode=Keep;
                        end
                    end
                    LFblocks={'asm','sm','pqload','rlcload','vsrc','xfo'};
                    for x=1:length(LFblocks)
                        for j=1:length(sps.LoadFlow.(LFblocks{x}).nodes)
                            k=sps.LoadFlow.(LFblocks{x}).nodes{j}==Leave;
                            sps.LoadFlow.(LFblocks{x}).nodes{j}(k)=Keep;
                        end
                    end

                    for j=1:length(sps.LoadFlow.Lines.leftnodes)
                        k=sps.LoadFlow.Lines.leftnodes{j}==Leave;
                        sps.LoadFlow.Lines.leftnodes{j}(k)=Keep;
                        k=sps.LoadFlow.Lines.rightnodes{j}==Leave;
                        sps.LoadFlow.Lines.rightnodes{j}(k)=Keep;
                    end
                end


                if UnbalancedLoadFlowAnalysis


                    for j=1:length(sps.UnbalancedLoadFlow.asm.nodes)
                        k=sps.UnbalancedLoadFlow.asm.nodes{j}==Leave;
                        sps.UnbalancedLoadFlow.asm.nodes{j}(k)=Keep;
                    end


                    for j=1:length(sps.UnbalancedLoadFlow.sm.nodes)
                        k=sps.UnbalancedLoadFlow.sm.nodes{j}==Leave;
                        sps.UnbalancedLoadFlow.sm.nodes{j}(k)=Keep;
                    end


                    for j=1:length(sps.UnbalancedLoadFlow.rlcload.nodes)
                        k=sps.UnbalancedLoadFlow.rlcload.nodes{j}==Leave;
                        sps.UnbalancedLoadFlow.rlcload.nodes{j}(k)=Keep;
                    end


                    for j=1:length(sps.UnbalancedLoadFlow.pqload.nodes)
                        k=sps.UnbalancedLoadFlow.pqload.nodes{j}==Leave;
                        sps.UnbalancedLoadFlow.pqload.nodes{j}(k)=Keep;
                    end


                    for j=1:length(sps.UnbalancedLoadFlow.vsrc.nodes)
                        k=sps.UnbalancedLoadFlow.vsrc.nodes{j}==Leave;
                        sps.UnbalancedLoadFlow.vsrc.nodes{j}(k)=Keep;
                    end


                    for j=1:length(sps.UnbalancedLoadFlow.Lines.leftnodes)
                        k=sps.UnbalancedLoadFlow.Lines.leftnodes{j}==Leave;
                        sps.UnbalancedLoadFlow.Lines.leftnodes{j}(k)=Keep;
                    end
                    for j=1:length(sps.UnbalancedLoadFlow.Lines.rightnodes)
                        k=sps.UnbalancedLoadFlow.Lines.rightnodes{j}==Leave;
                        sps.UnbalancedLoadFlow.Lines.rightnodes{j}(k)=Keep;
                    end


                    for j=1:length(sps.UnbalancedLoadFlow.Transfos.W1nodes)
                        k=sps.UnbalancedLoadFlow.Transfos.W1nodes{j}==Leave;
                        sps.UnbalancedLoadFlow.Transfos.W1nodes{j}(k)=Keep;
                    end
                    for j=1:length(sps.UnbalancedLoadFlow.Transfos.W2nodes)
                        k=sps.UnbalancedLoadFlow.Transfos.W2nodes{j}==Leave;
                        sps.UnbalancedLoadFlow.Transfos.W2nodes{j}(k)=Keep;
                    end
                    for j=1:length(sps.UnbalancedLoadFlow.Transfos.W3nodes)
                        k=sps.UnbalancedLoadFlow.Transfos.W3nodes{j}==Leave;
                        sps.UnbalancedLoadFlow.Transfos.W3nodes{j}(k)=Keep;
                    end

                end

            end
        end

    case 'get'


        for i=1:numel(blocks)

            block=get_param(blocks{i},'Handle');

            switch get_param(block,'Phases')
            case 'single'


                sps.UnbalancedLoadFlow.error='Found three-phase balanced load flow bus';
                return
            otherwise
            end


            ID=getSPSmaskvalues(block,{'ID'});

            PhaseLabels=get_param(block,'Phases');
            Nphases=length(PhaseLabels);


            nodes=nl.block_nodes(block);

            Vref=getSPSmaskvalues(block,{'Vref'});
            Vangle=getSPSmaskvalues(block,{'Vangle'});

            BlockName=getfullname(block);
            BlockNom=strrep(BlockName(sps.syslength:end),char(10),' ');
            errorVector(Vref,['Swing bus or PV bus voltage, per phase (pu) in Load Flow Bus ',ID],[1,Nphases],BlockNom);
            errorVector(Vangle,['Swing bus voltage angle, per phase (degrees) in Load Flow Bus ',ID],[1,Nphases],BlockNom);

            for j=1:Nphases

                sps.UnbalancedLoadFlow.bus(end+1).ID=[ID,'_',lower(PhaseLabels(j))];
                sps.UnbalancedLoadFlow.bus(end).vbase=getSPSmaskvalues(block,{'Vbase'});
                sps.UnbalancedLoadFlow.bus(end).vref=Vref(j);
                sps.UnbalancedLoadFlow.bus(end).angle=Vangle(j);
                sps.UnbalancedLoadFlow.bus(end).handle=block;

                if j==1
                    sps.UnbalancedLoadFlow.bus(end).NumberOfPhases=Nphases;
                else
                    sps.UnbalancedLoadFlow.bus(end).NumberOfPhases=0;
                end

                sps.UnbalancedLoadFlow.bus(end).Busnode=nodes(j);

                sps.UnbalancedLoadFlow.bus(end).Vbus=0;
                sps.UnbalancedLoadFlow.bus(end).Transfos=[];
                sps.UnbalancedLoadFlow.bus(end).Lines=[];
                sps.UnbalancedLoadFlow.bus(end).rlcload=[];
                sps.UnbalancedLoadFlow.bus(end).vsrc=[];
                sps.UnbalancedLoadFlow.bus(end).asm=[];
                sps.UnbalancedLoadFlow.bus(end).sm=[];
                sps.UnbalancedLoadFlow.bus(end).pqload=[];
            end

        end

    case 'connect'

        if isempty(sps.UnbalancedLoadFlow.bus)
            return
        end

        CheckbusNames(sps)

        for i=1:length(sps.UnbalancedLoadFlow.bus)

            sps.UnbalancedLoadFlow.bus(i).blocks=[];

            Busnode=sps.UnbalancedLoadFlow.bus(i).Busnode;


            for j=1:length(sps.UnbalancedLoadFlow.asm.nodes)
                blk_i=find(sps.UnbalancedLoadFlow.asm.nodes{j}==Busnode);
                if~isempty(blk_i)

                    sps.UnbalancedLoadFlow.asm.busNumber{j}(blk_i)=i;
                    sps.UnbalancedLoadFlow.bus(i).asm(end+1)=j;
                end
            end


            for j=1:length(sps.UnbalancedLoadFlow.sm.nodes)
                blk_i=find(sps.UnbalancedLoadFlow.sm.nodes{j}==Busnode);
                if~isempty(blk_i)

                    sps.UnbalancedLoadFlow.sm.busNumber{j}(blk_i)=i;
                    sps.UnbalancedLoadFlow.bus(i).sm(end+1)=j;
                end
            end


            for j=1:length(sps.UnbalancedLoadFlow.pqload.nodes)
                blk_i=find(sps.UnbalancedLoadFlow.pqload.nodes{j}==Busnode);
                if~isempty(blk_i)

                    sps.UnbalancedLoadFlow.pqload.busNumber{j}(blk_i)=i;
                    sps.UnbalancedLoadFlow.bus(i).pqload(end+1)=j;
                end
            end


            for j=1:length(sps.UnbalancedLoadFlow.vsrc.nodes)
                blk_i=find(sps.UnbalancedLoadFlow.vsrc.nodes{j}==Busnode);
                if~isempty(blk_i)

                    sps.UnbalancedLoadFlow.vsrc.busNumber{j}(blk_i)=i;
                    sps.UnbalancedLoadFlow.bus(i).vsrc(end+1)=j;
                    if length(sps.UnbalancedLoadFlow.vsrc.nodes{j})==2

                        phase_id=sps.UnbalancedLoadFlow.bus(i).ID(end);
                        sps.UnbalancedLoadFlow.vsrc.connection{j}(end+1)=phase_id;
                    end
                end
            end


            for j=1:length(sps.UnbalancedLoadFlow.rlcload.nodes)
                blk_i=find(sps.UnbalancedLoadFlow.rlcload.nodes{j}==Busnode);
                if~isempty(blk_i)

                    sps.UnbalancedLoadFlow.rlcload.busNumber{j}(blk_i)=i;
                    sps.UnbalancedLoadFlow.bus(i).rlcload(end+1)=j;
                    if length(sps.UnbalancedLoadFlow.rlcload.nodes{j})==2

                        phase_id=sps.UnbalancedLoadFlow.bus(i).ID(end);
                        sps.UnbalancedLoadFlow.rlcload.connection{j}(end+1)=phase_id;
                    end
                end
            end


            for j=1:length(sps.UnbalancedLoadFlow.Transfos.W1nodes)
                blk_i=find(sps.UnbalancedLoadFlow.Transfos.W1nodes{j}==Busnode);
                if~isempty(blk_i)

                    sps.UnbalancedLoadFlow.Transfos.W1busNumber{j}(blk_i)=i;
                    sps.UnbalancedLoadFlow.bus(i).Transfos(end+1)=j;
                end
            end
            for j=1:length(sps.UnbalancedLoadFlow.Transfos.W2nodes)
                blk_i=find(sps.UnbalancedLoadFlow.Transfos.W2nodes{j}==Busnode);
                if~isempty(blk_i)

                    sps.UnbalancedLoadFlow.Transfos.W2busNumber{j}(blk_i)=i;
                    sps.UnbalancedLoadFlow.bus(i).Transfos(end+1)=j;
                end
            end
            for j=1:length(sps.UnbalancedLoadFlow.Transfos.W3nodes)
                blk_i=find(sps.UnbalancedLoadFlow.Transfos.W3nodes{j}==Busnode);
                if~isempty(blk_i)

                    sps.UnbalancedLoadFlow.Transfos.W3busNumber{j}(blk_i)=i;
                    sps.UnbalancedLoadFlow.bus(i).Transfos(end+1)=j;
                end
            end


            for j=1:length(sps.UnbalancedLoadFlow.Lines.leftnodes)
                blk_i=find(sps.UnbalancedLoadFlow.Lines.leftnodes{j}==Busnode);
                if~isempty(blk_i)

                    sps.UnbalancedLoadFlow.Lines.LeftbusNumber{j}(blk_i)=i;
                    sps.UnbalancedLoadFlow.bus(i).Lines(end+1)=j;
                end
            end
            for j=1:length(sps.UnbalancedLoadFlow.Lines.rightnodes)
                blk_i=find(sps.UnbalancedLoadFlow.Lines.rightnodes{j}==Busnode);
                if~isempty(blk_i)

                    sps.UnbalancedLoadFlow.Lines.RightbusNumber{j}(blk_i)=i;
                    sps.UnbalancedLoadFlow.bus(i).Lines(end+1)=j;
                end
            end





            node=sps.UnbalancedLoadFlow.bus(i).Busnode;
            sps.UnbalancedLoadFlow.bus(i).sources=[0,node,1,0,0,sps.UnbalancedLoadFlow.freq,99];


            sps.UnbalancedLoadFlow.bus(i).YuMeasurement=[node,0];


            Vbase=sps.UnbalancedLoadFlow.bus(i).vbase;
            R=Vbase^2/sps.UnbalancedLoadFlow.Pbase;
            sps.rlc(end+1,1:7)=[0,node,0,R,0,0,size(sps.rlc,1)+1];
            sps.rlcnames{end+1}=[sps.UnbalancedLoadFlow.bus(i).ID];

        end


        for device={'rlcload','vsrc'}

            for j=1:length(sps.UnbalancedLoadFlow.(device{:}).connection)

                if length(sps.UnbalancedLoadFlow.(device{:}).connection{j})==1&&length(sps.UnbalancedLoadFlow.(device{:}).nodes{j})==2

                    if find(sps.UnbalancedLoadFlow.(device{:}).nodes{j}==0)

                        sps.UnbalancedLoadFlow.(device{:}).connection{j}(end+1)='g';


                        if sps.UnbalancedLoadFlow.(device{:}).nodes{j}(1)==0&&isnan(sps.UnbalancedLoadFlow.(device{:}).busNumber{j}(1))


                            sps.UnbalancedLoadFlow.(device{:}).busNumber{j}=sps.UnbalancedLoadFlow.(device{:}).busNumber{j}(2);
                        end
                    else

                        if any(isnan(sps.UnbalancedLoadFlow.(device{:}).busNumber{j}))
                            sps.UnbalancedLoadFlow.(device{:}).connection{j}='not_allowed';
                        else
                            if TheNeutralNodeIsValid(sps,device{:},j)
                                sps.UnbalancedLoadFlow.(device{:}).connection{j}(end+1)='n';
                            else
                                sps.UnbalancedLoadFlow.(device{:}).connection{j}='not_allowed';
                            end
                        end
                    end
                end



                if NotConnectedToTheSameBusHandle(sps,device{:},j)
                    sps.UnbalancedLoadFlow.(device{:}).connection{j}='not_allowed';
                end


                ReverseOrder=0;
                switch sps.UnbalancedLoadFlow.(device{:}).connection{j}
                case 'ba'
                    sps.UnbalancedLoadFlow.(device{:}).connection{j}='ab';
                    ReverseOrder=1;
                case 'cb'
                    sps.UnbalancedLoadFlow.(device{:}).connection{j}='bc';
                    ReverseOrder=1;
                case 'ac'
                    sps.UnbalancedLoadFlow.(device{:}).connection{j}='ca';
                    ReverseOrder=1;
                end
                if ReverseOrder
                    sps.UnbalancedLoadFlow.(device{:}).busNumber{j}(1:2)=sps.UnbalancedLoadFlow.(device{:}).busNumber{j}(2:-1:1);
                    sps.UnbalancedLoadFlow.(device{:}).nodes{j}(1:2)=sps.UnbalancedLoadFlow.(device{:}).nodes{j}(2:-1:1);
                end
            end

        end


        for i=1:length(sps.UnbalancedLoadFlow.Transfos.handle)
            switch sps.UnbalancedLoadFlow.Transfos.Type{i}
            case{'SinglePhase','SinglePhaseSat'}
                if length(sps.UnbalancedLoadFlow.Transfos.W1busNumber{i})==1


                    if isempty(find(sps.UnbalancedLoadFlow.Transfos.W1nodes{i}==0,1))

                        sps.UnbalancedLoadFlow.Transfos.W1busNumber{i}(end+1)=NaN;
                    else

                        sps.UnbalancedLoadFlow.Transfos.W1busNumber{i}(end+1)=0;
                    end
                else


                    if~isempty(find(sps.UnbalancedLoadFlow.Transfos.W1busNumber{i}==0,1))
                        if sps.UnbalancedLoadFlow.Transfos.W1nodes{i}(1)~=0
                            sps.UnbalancedLoadFlow.Transfos.W1busNumber{i}(1)=NaN;
                        end
                    end
                end
                if length(sps.UnbalancedLoadFlow.Transfos.W2busNumber{i})==1


                    if isempty(find(sps.UnbalancedLoadFlow.Transfos.W2nodes{i}==0,1))

                        sps.UnbalancedLoadFlow.Transfos.W2busNumber{i}(end+1)=NaN;
                    else

                        sps.UnbalancedLoadFlow.Transfos.W2busNumber{i}(end+1)=0;
                    end
                else


                    if~isempty(find(sps.UnbalancedLoadFlow.Transfos.W2busNumber{i}==0,1))
                        if sps.UnbalancedLoadFlow.Transfos.W2nodes{i}(1)~=0
                            sps.UnbalancedLoadFlow.Transfos.W2busNumber{i}(1)=NaN;
                        end
                    end
                end
                if length(sps.UnbalancedLoadFlow.Transfos.W3busNumber{i})==1


                    if isempty(find(sps.UnbalancedLoadFlow.Transfos.W3nodes{i}==0,1))

                        sps.UnbalancedLoadFlow.Transfos.W3busNumber{i}(end+1)=NaN;
                    else

                        sps.UnbalancedLoadFlow.Transfos.W3busNumber{i}(end+1)=0;
                    end
                else


                    if~isempty(find(sps.UnbalancedLoadFlow.Transfos.W3busNumber{i}==0,1))
                        if sps.UnbalancedLoadFlow.Transfos.W3nodes{i}(1)~=0
                            sps.UnbalancedLoadFlow.Transfos.W3busNumber{i}(1)=NaN;
                        end
                    end
                end
            end
        end

    end

    function CheckbusNames(sps)

        Nbus=length(sps.UnbalancedLoadFlow.bus);
        Buses=char(sps.UnbalancedLoadFlow.bus.ID);
        [~,I,J]=unique(Buses,'rows','legacy');
        if~isequal(I,J)

            D=setxor(1:Nbus,I,'legacy');
            if~isempty(D)
                message{1}='There are some Load Flow Bar blocks in your model that share the same Bus Identification Label:';
                message{2}=' ';
                message{3}=Buses(D,:);
                message{4}=' ';
                message{5}='It is recommended to identify the Load Flow bus blocks with unique labels.';
                warndlg(message);
            end
        end

        function R=TheNeutralNodeIsValid(sps,device,j)

            R=true;

            BranchNodes=sps.UnbalancedLoadFlow.(device).nodes{j};
            BusNumber=sps.UnbalancedLoadFlow.(device).busNumber{j};
            BusNode=sps.UnbalancedLoadFlow.bus(BusNumber).Busnode;
            BusHandle=sps.UnbalancedLoadFlow.bus(BusNumber).handle;
            NeutralNode=BranchNodes(BranchNodes~=BusNode);


            HaveBrothers=0;
            BrotherNodes=sps.UnbalancedLoadFlow.(device).nodes;
            for i=1:length(BrotherNodes)
                if BranchNodes(1)==BranchNodes(2)

                    R=false;
                    return
                end
                k=find(BrotherNodes{i}==NeutralNode,1);
                if~isempty(k)
                    HaveBrothers=HaveBrothers+1;

                    BrotherBus=sps.UnbalancedLoadFlow.(device).busNumber{i};
                    if any(isnan(BrotherBus))
                        R=false;
                        return
                    end
                    BrotherBusHandle=sps.UnbalancedLoadFlow.bus(BrotherBus).handle;
                    if BrotherBusHandle~=BusHandle

                        R=false;
                        return
                    end
                end
            end

            if HaveBrothers<2

                R=false;
                return
            end




            function R=NotConnectedToTheSameBusHandle(sps,device,j)

                R=false;

                if length(sps.UnbalancedLoadFlow.(device).connection{j})==2&&length(sps.UnbalancedLoadFlow.(device).busNumber{j})==2


                    Bus1=sps.UnbalancedLoadFlow.(device).busNumber{j}(1);
                    Bus2=sps.UnbalancedLoadFlow.(device).busNumber{j}(2);
                    if~isequal(sps.UnbalancedLoadFlow.bus(Bus1).handle,sps.UnbalancedLoadFlow.bus(Bus2).handle)
                        R=true;
                    end
                end