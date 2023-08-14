function[sps]=ThreePhaseLoadFlowBar(nl,sps,Option,Pbase,BusNumberOffset)





    if isfield(sps,'LoadFlow')

        switch Option

        case 'get'


            if~isempty(nl)
                idx=nl.filter_type('Load Flow Bus');
            else
                idx=[];
            end

            if isempty(idx)




                sps.LoadFlow.bus=[];


                LFnodes=[...
                sps.LoadFlow.asm.nodes,...
                sps.LoadFlow.sm.nodes,...
                sps.LoadFlow.rlcload.nodes,...
                sps.LoadFlow.pqload.nodes,...
                sps.LoadFlow.vsrc.nodes,...
                sps.LoadFlow.xfo.nodes,...
                sps.LoadFlow.Lines.leftnodes,...
                sps.LoadFlow.Lines.rightnodes];



                LFnodes=unique(cell2mat(LFnodes'),'rows','legacy');
                for i=1:size(LFnodes,1)


                    sps.LoadFlow.bus(i).ID=['*',num2str(i),'*'];
                    sps.LoadFlow.bus(i).vbase=NaN;
                    sps.LoadFlow.bus(i).vref=1;
                    sps.LoadFlow.bus(i).angle=0;
                    sps.LoadFlow.bus(i).handle=NaN;


                    sps.LoadFlow.bus(i).Busnode=LFnodes(i,1);


                    sps.LoadFlow.bus(i).Vbus=0;

                end

            else
                blocks=sort(spsGetFullBlockPath(nl.elements(idx)));


                for i=1:numel(blocks)

                    block=get_param(blocks{i},'Handle');

                    switch get_param(block,'Phases')
                    case 'single'

                        sps.LoadFlow.bus(i).ID=getSPSmaskvalues(block,{'ID'});
                        sps.LoadFlow.bus(i).vbase=getSPSmaskvalues(block,{'Vbase'});

                        Vref=getSPSmaskvalues(block,{'Vref'});
                        Vangle=getSPSmaskvalues(block,{'Vangle'});

                        BlockName=getfullname(block);
                        BlockNom=strrep(BlockName(sps.syslength:end),newline,' ');
                        errorScalar(Vref,'Swing bus or PV bus voltage (pu)',BlockNom);
                        errorScalar(Vangle,'Swing bus voltage angle (degrees)',BlockNom);

                        sps.LoadFlow.bus(i).vref=Vref;
                        sps.LoadFlow.bus(i).angle=Vangle;

                        sps.LoadFlow.bus(i).handle=block;


                        sps.LoadFlow.bus(i).Busnode=nl.block_nodes(block);


                        sps.LoadFlow.bus(i).Vbus=0;
                    otherwise


                        sps.LoadFlow.error='Found unbalanced load flow bus';
                        return
                    end
                end

            end

        case{'connect','OrphanConnect'}

            Devices={'asm','sm','pqload','rlcload','vsrc','xfo'};

            if isempty(sps.LoadFlow.bus)
                return
            end



            [~,I,J]=unique([sps.LoadFlow.bus.Busnode],'legacy');
            if~isequal(I,J)









                if all(isnan([sps.LoadFlow.bus.handle]))
                    sps.LoadFlow.bus=sps.LoadFlow.bus(I);
                end
            end


            CheckbusNames(sps)


            for i=1:length(sps.LoadFlow.bus)

                Noeuds={};

                Busnode=sps.LoadFlow.bus(i).Busnode;



                for k=1:6


                    [blk_i,~]=find(cell2mat(sps.LoadFlow.(Devices{k}).nodes')==Busnode);
                    sps.LoadFlow.bus(i).(Devices{k})=unique(blk_i,'legacy')';



                    Noeuds=[Noeuds,sps.LoadFlow.(Devices{k}).nodes(blk_i)];


                    sps.LoadFlow.(Devices{k}).busNumber(sps.LoadFlow.bus(i).(Devices{k}))={i+BusNumberOffset};


                    sps.LoadFlow.(Devices{k}).busID(sps.LoadFlow.bus(i).(Devices{k}))={sps.LoadFlow.bus(i).ID};

                end




                [blk_l,~]=find(cell2mat(sps.LoadFlow.Lines.leftnodes')==Busnode);
                if~isempty(blk_l)
                    sps.LoadFlow.Lines.LeftbusNumber(unique(blk_l,'legacy')')={i+BusNumberOffset};
                    Noeuds=[Noeuds,sps.LoadFlow.Lines.leftnodes(blk_l)];
                end


                [blk_r,~]=find(cell2mat(sps.LoadFlow.Lines.rightnodes')==Busnode);
                if~isempty(blk_r)
                    sps.LoadFlow.Lines.RightbusNumber(unique(blk_r,'legacy')')={i+BusNumberOffset};
                    Noeuds=[Noeuds,sps.LoadFlow.Lines.rightnodes(blk_r)];
                end

                if size(Noeuds,2)>1
                    if~isequal(Noeuds{:})
                        message=['The Load Flow Bus block labeled ''',sps.LoadFlow.bus(i).ID,''''...
                        ,' is connected to load flow blocks that are not properly connected. ',...
                        'Verify that A, B, and C phase of every block connected to the load flow bus are properly connected to the A,B, and C phases of the network respectively.'];
                        error('SpecializedPowerSystems:Powerloadflow:IncorrectPhaseConnection',message)
                    end
                end

                sps.LoadFlow.bus(i).Lines=unique([blk_l;blk_r],'legacy')';


                sps.LoadFlow.bus(i).blocks=cell2mat(...
                [sps.LoadFlow.asm.handle(sps.LoadFlow.bus(i).asm),...
                sps.LoadFlow.sm.handle(sps.LoadFlow.bus(i).sm),...
                sps.LoadFlow.pqload.handle(sps.LoadFlow.bus(i).pqload),...
                sps.LoadFlow.rlcload.handle(sps.LoadFlow.bus(i).rlcload),...
                sps.LoadFlow.vsrc.handle(sps.LoadFlow.bus(i).vsrc)]);








                if~isempty(sps.LoadFlow.bus(i).asm)
                    nodes=sps.LoadFlow.asm.nodes{sps.LoadFlow.bus(i).asm(1)};
                    ImplicitVbase=sps.LoadFlow.asm.vnom{sps.LoadFlow.bus(i).asm(1)};

                elseif~isempty(sps.LoadFlow.bus(i).sm)
                    nodes=sps.LoadFlow.sm.nodes{sps.LoadFlow.bus(i).sm(1)};
                    ImplicitVbase=sps.LoadFlow.sm.vnom{sps.LoadFlow.bus(i).sm(1)};

                elseif~isempty(sps.LoadFlow.bus(i).pqload)
                    nodes=sps.LoadFlow.pqload.nodes{sps.LoadFlow.bus(i).pqload(1)};
                    ImplicitVbase=sps.LoadFlow.pqload.vnom{sps.LoadFlow.bus(i).pqload(1)};

                elseif~isempty(sps.LoadFlow.bus(i).rlcload)
                    nodes=sps.LoadFlow.rlcload.nodes{sps.LoadFlow.bus(i).rlcload(1)};
                    ImplicitVbase=sps.LoadFlow.rlcload.vnom{sps.LoadFlow.bus(i).rlcload(1)};

                elseif~isempty(sps.LoadFlow.bus(i).vsrc)
                    nodes=sps.LoadFlow.vsrc.nodes{sps.LoadFlow.bus(i).vsrc(1)};
                    ImplicitVbase=sps.LoadFlow.vsrc.vnom{sps.LoadFlow.bus(i).vsrc(1)};

                elseif~isempty(sps.LoadFlow.bus(i).xfo)
                    nodes=sps.LoadFlow.xfo.nodes{sps.LoadFlow.bus(i).xfo(1)};
                    ImplicitVbase=sps.LoadFlow.xfo.vnom{sps.LoadFlow.bus(i).xfo(1)};


                    if isnan(sps.LoadFlow.bus(i).handle)
                        sps.LoadFlow.bus(i).blocks=sps.LoadFlow.xfo.handle{sps.LoadFlow.bus(i).xfo(1)};
                    else
                        sps.LoadFlow.bus(i).blocks=sps.LoadFlow.bus(i).handle;
                    end

                elseif~isempty(sps.LoadFlow.bus(i).Lines)



                    if find(blk_l==sps.LoadFlow.bus(i).Lines(1))

                        nodes=sps.LoadFlow.Lines.leftnodes{sps.LoadFlow.bus(i).Lines(1)};
                    else

                        nodes=sps.LoadFlow.Lines.rightnodes{sps.LoadFlow.bus(i).Lines(1)};
                    end

                    if~isempty(sps.LoadFlow.Lines.Vbase)
                        ImplicitVbase=sps.LoadFlow.Lines.Vbase{sps.LoadFlow.bus(i).Lines(1)};
                    else
                        ImplicitVbase=100e3;
                    end



                    if isnan(sps.LoadFlow.bus(i).handle)
                        sps.LoadFlow.bus(i).blocks=sps.LoadFlow.Lines.handle{sps.LoadFlow.bus(i).Lines(1)};
                    else
                        sps.LoadFlow.bus(i).blocks=sps.LoadFlow.bus(i).handle;
                    end

                else



                    nodes=CheckInEntireSPSblockList(nl,Busnode,sps.ObsoleteNodes);

                    sps.LoadFlow.bus(i).blocks=sps.LoadFlow.bus(i).handle;
                end



                if~isempty(nodes)


                    sps.LoadFlow.bus(i).Busnode=nodes;


                    X=CheckForDuplicatedBus(nodes,sps.LoadFlow.bus,i);
                    if X
                        message=['The Load Flow Bus block labeled ''',sps.LoadFlow.bus(i).ID,...
                        ''' is connected to the same three-phase bus as the Load Flow bus labeled ''',...
                        sps.LoadFlow.bus(X).ID,'''. You need to delete one of the two blocks in order to perform the load flow.'];

                        error('SpecializedPowerSystems:Powerloadflow:DuplicateBus',message)

                    else

                        CheckShortCircuit(sps.LoadFlow.bus(i).ID,nodes);


                        sps.LoadFlow.bus(i).sources=[...
                        0,nodes(1),1,0,0,sps.LoadFlow.freq,99;...
                        0,nodes(2),1,0,0,sps.LoadFlow.freq,99;...
                        0,nodes(3),1,0,0,sps.LoadFlow.freq,99];

                        if isnan(sps.LoadFlow.bus(i).vbase)

                            sps.LoadFlow.bus(i).vbase=ImplicitVbase;
                        end


                        Vbase=sps.LoadFlow.bus(i).vbase;
                        R=Vbase^2/Pbase;

                        sps.rlc(end+1,1:7)=[0,nodes(1),0,R,0,0,size(sps.rlc,1)+1];
                        sps.rlc(end+1,1:7)=[0,nodes(2),0,R,0,0,size(sps.rlc,1)+1];
                        sps.rlc(end+1,1:7)=[0,nodes(3),0,R,0,0,size(sps.rlc,1)+1];

                        sps.rlcnames{end+1}=[sps.LoadFlow.bus(i).ID,'_phaseA'];
                        sps.rlcnames{end+1}=[sps.LoadFlow.bus(i).ID,'_phaseB'];
                        sps.rlcnames{end+1}=[sps.LoadFlow.bus(i).ID,'_phaseC'];


                        sps.LoadFlow.bus(i).YuMeasurement=[nodes(1),0;nodes(2),0;nodes(3),0];

                    end

                else

                    message=['The Load Flow Bus block labeled ''',sps.LoadFlow.bus(i).ID,''' is not properly connected to the network. You need to connect this block to a load flow block, or delete it from your model.'];
                    error('SpecializedPowerSystems:Powerloadflow:UnconnectedBus',message)

                end




                if~isempty(sps.LoadFlow.bus(i).vsrc)
                    Zbase=sps.LoadFlow.bus(i).vbase^2/Pbase;
                    for m=1:length(sps.LoadFlow.bus(i).vsrc)
                        n=sps.LoadFlow.bus(i).vsrc(m);
                        sps.LoadFlow.vsrc.r{n}=sps.LoadFlow.vsrc.r{n}/Zbase;
                        sps.LoadFlow.vsrc.x{n}=(sps.LoadFlow.vsrc.x{n}/Zbase)*2*pi*sps.LoadFlow.freq;
                    end
                end

            end




            switch Option
            case 'connect'

                sps=CheckOrphanLFblocks(sps,Pbase);

                CheckbusNames(sps);
            end
        end
    end

    function nodes=CheckInEntireSPSblockList(nl,Busnode,ObsoleteNodes)



        nodes=[];
        for i=1:length(nl.elements)

            blknodes=nl.nodes(i);
            blknodes=blknodes{1};


            if~isempty(ObsoleteNodes)
                for k=1:length(blknodes)

                    p=find(blknodes(k)==ObsoleteNodes(:,1),1);
                    if~isempty(p)

                        blknodes(k)=ObsoleteNodes(p,2);
                    end
                end
            end

            inodes=find(blknodes==Busnode,1);

            if~isempty(inodes)

                switch get_param(nl.elements(i),'MaskType')

                case{'Three-Phase VI Measurement',...
                    'Three-Phase Series RLC Branch',...
                    'Three-Phase Parallel RLC Branch',...
                    'Three-Phase Mutual Inductance Z1-Z0',...
                    'Three-Phase Breaker',...
                    'Three-Phase Fault',...
                    'Three-Phase Harmonic Filter'}

                    if length(blknodes)==6


                        switch inodes
                        case{1,2,3}
                            nodes=blknodes(1:3);
                        case{4,5,6}
                            nodes=blknodes(4:6);
                        end
                        break
                    elseif length(blknodes)==3
                        nodes=blknodes(1:3);
                        break
                    elseif length(blknodes)==4
                        nodes=blknodes(1:3);
                        break
                    else



                    end

                case{'Three-Phase Transformer (Two Windings)'}
                    if length(blknodes)==6
                        switch inodes
                        case{1,2,3}
                            nodes=blknodes(1:3);
                        case{4,5,6}
                            nodes=blknodes(4:6);
                        end

                    elseif length(blknodes)==7

                        switch get_param(nl.elements(i),'Winding1Connection')
                        case 'Yn'
                            switch inodes
                            case{1,2,3,4}
                                nodes=blknodes(1:3);
                            case{5,6,7}
                                nodes=blknodes(5:7);
                            end
                        otherwise
                            switch inodes
                            case{1,2,3}
                                nodes=blknodes(1:3);
                            case{4,5,6,7}
                                nodes=blknodes(4:6);
                            end
                        end
                    else

                        switch inodes
                        case{1,2,3,4}
                            nodes=blknodes(1:3);
                        case{5,6,7,8}
                            nodes=blknodes(5:7);
                        end

                    end
                    break

                case{'Three-Phase Transformer (Three Windings)'}

                    W1C=get_param(nl.elements(i),'Winding1Connection');
                    W2C=get_param(nl.elements(i),'Winding2Connection');


                    W1=blknodes(1:3);
                    switch W1C
                    case 'Yn'
                        W2=blknodes(5:7);
                        switch W2C
                        case 'Yn'
                            W3=blknodes(9:11);
                        otherwise
                            W3=blknodes(8:10);
                        end
                    otherwise
                        W2=blknodes(4:6);
                        switch W2C
                        case 'Yn'
                            W3=blknodes(8:10);
                        otherwise
                            W3=blknodes(7:9);
                        end
                    end


                    switch inodes
                    case{1,2,3}
                        nodes=W1;
                    case 4
                        switch W1
                        case 'Yn'
                            nodes=W1;
                        otherwise
                            nodes=W2;
                        end
                    case{5,6}
                        nodes=W2;
                    case 7
                        switch W1C
                        case 'Yn'
                            nodes=W2;
                        otherwise
                            switch W2C
                            case 'Yn'
                                nodes=W2;
                            otherwise
                                nodes=W3;
                            end
                        end
                    case 8
                        switch W1C
                        case 'Yn'
                            switch W2C
                            case 'Yn'
                                nodes=W2;
                            otherwise
                                nodes=W3;
                            end
                        otherwise
                            nodes=W3;
                        end
                    otherwise
                        nodes=W3;
                    end
                    break

                end

            end

        end

        function sps=CheckOrphanLFblocks(sps,Pbase)

            LFtypes={'asm','sm','rlcload','pqload','vsrc','xfo'};
            for i=1:length(LFtypes)
                Dummy.LoadFlow.(LFtypes{i}).nodes=[];
                if~isempty(sps.LoadFlow.(LFtypes{i}).busNumber)

                    for k=1:length(sps.LoadFlow.(LFtypes{i}).busNumber)

                        if isnan(sps.LoadFlow.(LFtypes{i}).busNumber{k})

                            Dummy.LoadFlow.(LFtypes{i}).nodes{end+1}=sps.LoadFlow.(LFtypes{i}).nodes{k};
                        end
                    end
                end
            end

            Dummy.LoadFlow.Lines.leftnodes=[];
            Dummy.LoadFlow.Lines.rightnodes=[];
            if~isempty(sps.LoadFlow.Lines.LeftbusNumber)

                for k=1:length(sps.LoadFlow.Lines.LeftbusNumber)

                    sps.LoadFlow.Lines.Vbase{k}=[];



                    if isempty(sps.LoadFlow.Lines.LeftbusNumber{k})

                        Dummy.LoadFlow.Lines.leftnodes{end+1}=sps.LoadFlow.Lines.leftnodes{k};
                        if~isempty(sps.LoadFlow.Lines.RightbusNumber{k})


                            sps.LoadFlow.Lines.Vbase{k}=sps.LoadFlow.bus(sps.LoadFlow.Lines.RightbusNumber{k}).vbase;
                        else
                            sps.LoadFlow.Lines.Vbase{k}=100e3;
                        end
                    end

                    if isempty(sps.LoadFlow.Lines.RightbusNumber{k})

                        Dummy.LoadFlow.Lines.rightnodes{end+1}=sps.LoadFlow.Lines.rightnodes{k};
                        if~isempty(sps.LoadFlow.Lines.LeftbusNumber{k})


                            sps.LoadFlow.Lines.Vbase{k}=sps.LoadFlow.bus(sps.LoadFlow.Lines.LeftbusNumber{k}).vbase;
                        else
                            sps.LoadFlow.Lines.Vbase{k}=100e3;
                        end
                    end

                end
            end


            Dummy=ThreePhaseLoadFlowBar([],Dummy,'get',Pbase);

            if~isempty(Dummy.LoadFlow.bus)

                CurrentBus=sps.LoadFlow.bus;

                sps.LoadFlow.bus=Dummy.LoadFlow.bus;
                sps=ThreePhaseLoadFlowBar([],sps,'OrphanConnect',Pbase,length(CurrentBus));
                sps.LoadFlow.bus=[CurrentBus,sps.LoadFlow.bus];
            end

            function CheckbusNames(sps)

                Nbus=length(sps.LoadFlow.bus);
                Buses=char(sps.LoadFlow.bus.ID);
                [~,I,J]=unique(Buses,'rows','legacy');
                if~isequal(I,J)

                    D=setxor(1:Nbus,I,'legacy');
                    if~isempty(D)
                        message{1}='There are some Load Flow Bus blocks in your model that share the same Bus Identification Label:';
                        message{2}=' ';
                        message{3}=Buses(D,:);
                        message{4}=' ';
                        message{5}='It is recommended to identify the Load Flow bus blocks with unique labels.';
                        warndlg(message);
                    end
                end

                function S=CheckForDuplicatedBus(nodes,Bus,x)

                    S=0;
                    for i=1:x-1
                        if isequal(sort(nodes),sort(Bus(i).Busnode))
                            S=i;
                        end
                    end

                    function CheckShortCircuit(ID,nodes)

                        if nodes(1)==0
                            SC='phase A shorted to the ground';

                        elseif nodes(2)==0
                            SC='phase B shorted to the ground';

                        elseif nodes(3)==0
                            SC='phase C shorted to the ground';

                        elseif nodes(1)==nodes(2)&&nodes(1)~=nodes(3)
                            SC='phase A and B shorted';

                        elseif nodes(1)==nodes(3)&&nodes(1)~=nodes(2)
                            SC='phase A and C shorted';

                        elseif nodes(2)==nodes(3)&&nodes(2)~=nodes(1)
                            SC='phase B and C shorted';

                        elseif nodes(1)==nodes(2)&&nodes(1)==nodes(3)
                            SC='phase A, B, and C shorted';

                        else

                            return
                        end

                        message=['The Load Flow Bus block labeled ''',ID,...
                        ''' is connected to a three-phase bus with ',SC,'. You need to eliminate this short-circuit in order to perform the load flow.'];

                        error('SpecializedPowerSystems:Powerloadflow:ShortCircuitBus',message)