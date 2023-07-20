function[sps,Multimeter,NewNode]=InductanceMatrixTransformerblock(BLOCKLIST,sps,NumberOfTransfoWindings,Multimeter,NewNode)









    switch NumberOfTransfoWindings
    case 2
        idx=BLOCKLIST.filter_type('Three-Phase Transformer Inductance MatrixType (Two Windings)');
    case 3
        idx=BLOCKLIST.filter_type('Three-Phase Transformer Inductance MatrixType (Three Windings)');
    end

    blocks=sort(spsGetFullBlockPath(BLOCKLIST.elements(idx)));

    for i=1:numel(blocks)


        block=get_param(blocks{i},'Handle');
        BlockName=getfullname(block);
        BlockNom=strrep(BlockName(sps.syslength:end),char(10),' ');


        SPSVerifyLinkStatus(block);


        [AutoTransformer,Winding1Connection,Winding2Connection]=getSPSmaskvalues(block,...
        {'AutoTransformer','Winding1Connection','Winding2Connection'});


        if AutoTransformer
            if~(Winding1Connection<=3&&Winding2Connection==Winding1Connection)
                Erreur.message=['Winding 1 & 2 connections of ''',BlockNom,''' block must be both Yg, Yn or Y when  the windings are connected in autotransformer '];
                Erreur.identifier='SpecializedPowerSystems:ImpedanceMatrixTransformer:AutoTransfoConnectionError';
                psberror(Erreur);
            end
        end


        CoreType=get_param(block,'CoreType');

        [NominalPower,VLLnom,WindingResistances]=getSPSmaskvalues(block,{'NominalPower','VLLnom','WindingResistances'});


        WindingConnections='';
        if Winding1Connection<4
            WindingConnections(1)='Y';
        else
            WindingConnections(1)='D';
        end
        if Winding2Connection<4
            WindingConnections(2)='Y';
        else
            WindingConnections(2)='D';
        end
        switch NumberOfTransfoWindings
        case 2
            X12ZeroMeasuredWithW3Delta=0;
        case 3
            X12ZeroMeasuredWithW3Delta=getSPSmaskvalues(block,{'X12ZeroMeasuredWithW3Delta'});
            Winding3Connection=getSPSmaskvalues(block,{'Winding3Connection'});
            if Winding3Connection<4
                WindingConnections(3)='Y';
            else
                WindingConnections(3)='D';
            end
        end


        [NoLoadIexcPos,NoLoadIexcZero,NoLoadPlossPos,NoLoadPlossZero]=getSPSmaskvalues(block,...
        {'NoLoadIexcPos','NoLoadIexcZero','NoLoadPlossPos','NoLoadPlossZero'});

        [ShortCircuitReactancePosAuto,ShortCircuitReactanceZeroAuto]=getSPSmaskvalues(block,...
        {'ShortCircuitReactancePosAuto','ShortCircuitReactanceZeroAuto'});

        if AutoTransformer
            ShortCircuitReactancePos=ShortCircuitReactancePosAuto;
            ShortCircuitReactanceZero=ShortCircuitReactanceZeroAuto;
        else
            [ShortCircuitReactancePos,ShortCircuitReactanceZero]=getSPSmaskvalues(block,...
            {'ShortCircuitReactancePos','ShortCircuitReactanceZero'});
        end


        [ResistanceMatrix,InductanceMatrix,RmagPos,RmagZero]=InductanceMatrixTransformerParam(CoreType,...
        NominalPower,VLLnom,WindingResistances,WindingConnections,AutoTransformer,...
        NoLoadIexcPos,NoLoadIexcZero,NoLoadPlossPos,NoLoadPlossZero,...
        ShortCircuitReactancePos,ShortCircuitReactanceZero,X12ZeroMeasuredWithW3Delta,NumberOfTransfoWindings);




        nodes=BLOCKLIST.block_nodes(block);










        Apos=nodes(1);
        Bpos=nodes(2);
        Cpos=nodes(3);
        if Winding1Connection==2
            N=nodes(4);
            offset1=1;
        else
            N=NaN;
            offset1=0;
        end

        a2pos=nodes(4+offset1);
        b2pos=nodes(5+offset1);
        c2pos=nodes(6+offset1);

        if AutoTransformer


            n2=N;
            offset2=0;
        elseif Winding2Connection==2
            n2=nodes(7+offset1);
            offset2=1;
        else
            n2=NaN;
            offset2=0;
        end

        if NumberOfTransfoWindings==3

            a3pos=nodes(7+offset1+offset2);
            b3pos=nodes(8+offset1+offset2);
            c3pos=nodes(9+offset1+offset2);
            if Winding3Connection==2
                n3=nodes(10+offset1+offset2);
            else
                n3=NaN;
            end
        end







        if AutoTransformer&&VLLnom(2)>VLLnom(1)
            new_Apos=a2pos;
            new_Bpos=b2pos;
            new_Cpos=c2pos;
            a2pos=Apos;
            b2pos=Bpos;
            c2pos=Cpos;
            Apos=new_Apos;
            Bpos=new_Bpos;
            Cpos=new_Cpos;
        end







        switch Winding1Connection

        case 1
            Aneg=NewNode;
            Bneg=NewNode;
            Cneg=NewNode;
            NewNode=NewNode+1;

            ConnectionType{1,1}='n';%#ok
            ConnectionType{1,2}='n';%#ok
            ConnectionType{1,3}='n';%#ok

        case 2
            Aneg=N;
            Bneg=N;
            Cneg=N;

            ConnectionType{1,1}='n';%#ok
            ConnectionType{1,2}='n';%#ok
            ConnectionType{1,3}='n';%#ok

        case 3
            Aneg=0;
            Bneg=0;
            Cneg=0;

            ConnectionType{1,1}='g';%#ok
            ConnectionType{1,2}='g';%#ok
            ConnectionType{1,3}='g';%#ok

        case 4
            Aneg=Bpos;
            Bneg=Cpos;
            Cneg=Apos;

            ConnectionType{1,1}='b';%#ok
            ConnectionType{1,2}='c';%#ok
            ConnectionType{1,3}='a';%#ok

        case 5
            Aneg=Cpos;
            Bneg=Apos;
            Cneg=Bpos;

            ConnectionType{1,1}='c';%#ok
            ConnectionType{1,2}='a';%#ok
            ConnectionType{1,3}='b';%#ok

        end


        if AutoTransformer





            Aneg=a2pos;
            Bneg=b2pos;
            Cneg=c2pos;
        end

        switch Winding2Connection

        case 1
            a2neg=NewNode;
            b2neg=NewNode;
            c2neg=NewNode;
            NewNode=NewNode+1;

            ConnectionType{2,1}='n';%#ok
            ConnectionType{2,2}='n';%#ok
            ConnectionType{2,3}='n';%#ok

        case 2
            a2neg=n2;
            b2neg=n2;
            c2neg=n2;

            ConnectionType{2,1}='n';%#ok
            ConnectionType{2,2}='n';%#ok
            ConnectionType{2,3}='n';%#ok

        case 3
            a2neg=0;
            b2neg=0;
            c2neg=0;

            ConnectionType{2,1}='g';%#ok
            ConnectionType{2,2}='g';%#ok
            ConnectionType{2,3}='g';%#ok

        case 4
            a2neg=b2pos;
            b2neg=c2pos;
            c2neg=a2pos;

            ConnectionType{2,1}='b';%#ok
            ConnectionType{2,2}='c';%#ok
            ConnectionType{2,3}='a';%#ok

        case 5
            a2neg=c2pos;
            b2neg=a2pos;
            c2neg=b2pos;

            ConnectionType{2,1}='b';%#ok
            ConnectionType{2,2}='c';%#ok
            ConnectionType{2,3}='a';%#ok

        end

        if NumberOfTransfoWindings==3

            switch Winding3Connection

            case 1
                a3neg=NewNode;
                b3neg=NewNode;
                c3neg=NewNode;
                NewNode=NewNode+1;

                ConnectionType{3,1}='n';%#ok
                ConnectionType{3,2}='n';%#ok
                ConnectionType{3,3}='n';%#ok

            case 2
                a3neg=n3;
                b3neg=n3;
                c3neg=n3;

                ConnectionType{3,1}='n';%#ok
                ConnectionType{3,2}='n';%#ok
                ConnectionType{3,3}='n';%#ok

            case 3
                a3neg=0;
                b3neg=0;
                c3neg=0;

                ConnectionType{3,1}='g';%#ok
                ConnectionType{3,2}='g';%#ok
                ConnectionType{3,3}='g';%#ok

            case 4
                a3neg=b3pos;
                b3neg=c3pos;
                c3neg=a3pos;

                ConnectionType{3,1}='b';%#ok
                ConnectionType{3,2}='c';%#ok
                ConnectionType{3,3}='a';%#ok

            case 5
                a3neg=c3pos;
                b3neg=a3pos;
                c3neg=b3pos;

                ConnectionType{3,1}='b';%#ok
                ConnectionType{3,2}='c';%#ok
                ConnectionType{3,3}='a';%#ok

            end
        end


        measure='';
        switch CoreType

        case 'Three single-phase cores'


            NumberOfWindings=NumberOfTransfoWindings;



            if NumberOfWindings==2
                RLCbranches=[1,4,7,2,5,8]+size(sps.rlc,1);
            else
                RLCbranches=[1,7,13,2,8,14,3,9,15]+size(sps.rlc,1);
            end

            if NumberOfWindings==2
                Nodes=[Apos,a2pos,Aneg,a2neg];
            else
                Nodes=[Apos,a2pos,a3pos,Aneg,a2neg,a3neg];
            end
            [sps,Multimeter,NewNode]=AddMutualInductanceDevice(BlockNom,NumberOfWindings,ResistanceMatrix,InductanceMatrix,Nodes,NewNode,sps,Multimeter,measure);

            if NumberOfWindings==2
                Nodes=[Bpos,b2pos,Bneg,b2neg];
            else
                Nodes=[Bpos,b2pos,b3pos,Bneg,b2neg,b3neg];
            end
            [sps,Multimeter,NewNode]=AddMutualInductanceDevice(BlockNom,NumberOfWindings,ResistanceMatrix,InductanceMatrix,Nodes,NewNode,sps,Multimeter,measure);

            if NumberOfWindings==2
                Nodes=[Cpos,c2pos,Cneg,c2neg];
            else
                Nodes=[Cpos,c2pos,c3pos,Cneg,c2neg,c3neg];
            end
            [sps,Multimeter,NewNode]=AddMutualInductanceDevice(BlockNom,NumberOfWindings,ResistanceMatrix,InductanceMatrix,Nodes,NewNode,sps,Multimeter,measure);

        case 'Three-limb or five-limb core'


            NumberOfWindings=3*NumberOfTransfoWindings;



            RLCbranches=(1:NumberOfWindings)+size(sps.rlc,1);

            if NumberOfWindings==6
                Nodes=[Apos,Bpos,Cpos,a2pos,b2pos,c2pos,Aneg,Bneg,Cneg,a2neg,b2neg,c2neg];
            else
                Nodes=[Apos,Bpos,Cpos,a2pos,b2pos,c2pos,a3pos,b3pos,c3pos,Aneg,Bneg,Cneg,a2neg,b2neg,c2neg,a3neg,b3neg,c3neg];
            end
            [sps,Multimeter,NewNode]=AddMutualInductanceDevice(BlockNom,NumberOfWindings,ResistanceMatrix,InductanceMatrix,Nodes,NewNode,sps,Multimeter,measure);

        end








        if AutoTransformer


            Nodes_RmagPos=[a2pos,b2pos,c2pos,NewNode,NewNode,NewNode];
            Nodes_RmagNeg=[NewNode,a2neg];
            NewNode=NewNode+1;

            R1=RmagPos(2);
            R0=(RmagZero(2)-RmagPos(2))/3;

            sps=AddResistorDevices(sps,R1,R0,Nodes_RmagPos,Nodes_RmagNeg);

        else

            switch CoreType
            case 'Three single-phase cores'


                Nodes_RmagPos=[Apos,Bpos,Cpos,Aneg,Bneg,Cneg];


                Nodes_RmagNeg=[];

                R1=RmagPos(1);
                R0=NaN;


                sps=AddResistorDevices(sps,R1,R0,Nodes_RmagPos,Nodes_RmagNeg);

            case 'Three-limb or five-limb core'



                switch WindingConnections
                case{'YY','YD','YYY','YYD','YDY','YDD'}


                    Nodes_RmagPos=[Apos,Bpos,Cpos,NewNode,NewNode,NewNode];
                    Nodes_RmagNeg=[NewNode,Aneg];
                    NewNode=NewNode+1;

                    R1=RmagPos(1);
                    R0=(RmagZero(1)-RmagPos(1))/3;

                    sps=AddResistorDevices(sps,R1,R0,Nodes_RmagPos,Nodes_RmagNeg);

                case{'DY','DYY','DYD'}


                    Nodes_RmagPos=[a2pos,b2pos,c2pos,NewNode,NewNode,NewNode];
                    Nodes_RmagNeg=[NewNode,a2neg];
                    NewNode=NewNode+1;

                    R1=RmagPos(2);
                    R0=(RmagZero(2)-RmagPos(2))/3;

                    sps=AddResistorDevices(sps,R1,R0,Nodes_RmagPos,Nodes_RmagNeg);

                case 'DDY'


                    Nodes_RmagPos=[a3pos,b3pos,c3pos,NewNode,NewNode,NewNode];
                    Nodes_RmagNeg=[NewNode,a3neg];
                    NewNode=NewNode+1;

                    R1=RmagPos(3);
                    R0=(RmagZero(3)-RmagPos(3))/3;

                    sps=AddResistorDevices(sps,R1,R0,Nodes_RmagPos,Nodes_RmagNeg);

                otherwise



                    Nodes_RmagPos=[Apos,Bpos,Cpos,Aneg,Bneg,Cneg];
                    Nodes_RmagNeg=[];

                    R1=RmagPos(1);
                    R0=NaN;

                    sps=AddResistorDevices(sps,R1,R0,Nodes_RmagPos,Nodes_RmagNeg);

                end

            end

        end


        if isfield(sps,'UnbalancedLoadFlow')

            sps.UnbalancedLoadFlow.Transfos.Units{end+1}='pu';
            sps.UnbalancedLoadFlow.Transfos.handle{end+1}=block;
            sps.UnbalancedLoadFlow.Transfos.Type{end+1}='MatrixType';
            sps.UnbalancedLoadFlow.Transfos.conW1{end+1}=WindingConnections(1);
            sps.UnbalancedLoadFlow.Transfos.conW2{end+1}=WindingConnections(2);
            if NumberOfTransfoWindings==3
                sps.UnbalancedLoadFlow.Transfos.conW3{end+1}=WindingConnections(3);
            else
                sps.UnbalancedLoadFlow.Transfos.conW3{end+1}=[];
            end

            sps.UnbalancedLoadFlow.Transfos.Pnom{end+1}=NominalPower(1);
            sps.UnbalancedLoadFlow.Transfos.Fnom{end+1}=NominalPower(2);
            sps.UnbalancedLoadFlow.Transfos.W1{end+1}=[];
            sps.UnbalancedLoadFlow.Transfos.W2{end+1}=[];
            sps.UnbalancedLoadFlow.Transfos.W3{end+1}=[];
            sps.UnbalancedLoadFlow.Transfos.W1nodes{end+1}=nodes(1:3);
            sps.UnbalancedLoadFlow.Transfos.W2nodes{end+1}=nodes((4:6)+offset1);
            switch NumberOfTransfoWindings
            case 3
                sps.UnbalancedLoadFlow.Transfos.W3nodes{end+1}=nodes((7:9)+offset1+offset2);
            otherwise
                sps.UnbalancedLoadFlow.Transfos.W3nodes{end+1}=[];
            end
            sps.UnbalancedLoadFlow.Transfos.RmLm{end+1}=[];
            sps.UnbalancedLoadFlow.Transfos.W1busNumber{end+1}=[];
            sps.UnbalancedLoadFlow.Transfos.W2busNumber{end+1}=[];
            sps.UnbalancedLoadFlow.Transfos.W3busNumber{end+1}=[];

        end


        measure=get_param(block,'Measurements');
        if strcmp(measure,'Winding voltages')||(strcmp(measure,'All measurements'))

            Multimeter.Yu(end+1,1:2)=[Apos,Aneg];
            Multimeter.V{end+1}=['Ua',ConnectionType{1,1},'_w1: ',BlockNom];

            Multimeter.Yu(end+1,1:2)=[Bpos,Bneg];
            Multimeter.V{end+1}=['Ub',ConnectionType{1,2},'_w1: ',BlockNom];

            Multimeter.Yu(end+1,1:2)=[Cpos,Cneg];
            Multimeter.V{end+1}=['Uc',ConnectionType{1,3},'_w1: ',BlockNom];

            Multimeter.Yu(end+1,1:2)=[a2pos,a2neg];
            Multimeter.V{end+1}=['Ua',ConnectionType{2,1},'_w2: ',BlockNom];

            Multimeter.Yu(end+1,1:2)=[b2pos,b2neg];
            Multimeter.V{end+1}=['Ub',ConnectionType{2,2},'_w2: ',BlockNom];

            Multimeter.Yu(end+1,1:2)=[c2pos,c2neg];
            Multimeter.V{end+1}=['Uc',ConnectionType{2,3},'_w2: ',BlockNom];
            if NumberOfTransfoWindings==3

                Multimeter.Yu(end+1,1:2)=[a3pos,a3neg];
                Multimeter.V{end+1}=['Ua',ConnectionType{3,1},'_w3: ',BlockNom];

                Multimeter.Yu(end+1,1:2)=[b3pos,b3neg];
                Multimeter.V{end+1}=['Ub',ConnectionType{3,2},'_w3: ',BlockNom];

                Multimeter.Yu(end+1,1:2)=[c3pos,c3neg];
                Multimeter.V{end+1}=['Uc',ConnectionType{3,3},'_w3: ',BlockNom];
            end
        end

        if strcmp(measure,'Winding currents')||(strcmp(measure,'All measurements'))


            Multimeter.Yi{end+1,1}=RLCbranches(1);
            Multimeter.I{end+1}=['Ia',ConnectionType{1,1},'_w1: ',BlockNom];

            Multimeter.Yi{end+1,1}=RLCbranches(2);
            Multimeter.I{end+1}=['Ib',ConnectionType{1,2},'_w1: ',BlockNom];

            Multimeter.Yi{end+1,1}=RLCbranches(3);
            Multimeter.I{end+1}=['Ic',ConnectionType{1,3},'_w1: ',BlockNom];

            Multimeter.Yi{end+1,1}=RLCbranches(4);
            Multimeter.I{end+1}=['Ia',ConnectionType{2,1},'_w2: ',BlockNom];

            Multimeter.Yi{end+1,1}=RLCbranches(5);
            Multimeter.I{end+1}=['Ib',ConnectionType{2,2},'_w2: ',BlockNom];

            Multimeter.Yi{end+1,1}=RLCbranches(6);
            Multimeter.I{end+1}=['Ic',ConnectionType{2,3},'_w2: ',BlockNom];
            if NumberOfTransfoWindings==3

                Multimeter.Yi{end+1,1}=RLCbranches(7);
                Multimeter.I{end+1}=['Ia',ConnectionType{3,1},'_w3: ',BlockNom];

                Multimeter.Yi{end+1,1}=RLCbranches(8);
                Multimeter.I{end+1}=['Ib',ConnectionType{3,2},'_w3: ',BlockNom];

                Multimeter.Yi{end+1,1}=RLCbranches(9);
                Multimeter.I{end+1}=['Ic',ConnectionType{3,3},'_w3: ',BlockNom];
            end

        end


    end



    function sps=AddResistorDevices(sps,R1,R0,Nodes_RmagPos,Nodes_RmagNeg)


        sps.rlc(end+1,1:6)=[Nodes_RmagPos(1),Nodes_RmagPos(4),0,R1,0,0];
        sps.rlcnames{end+1}='RmagPos A: ';

        sps.rlc(end+1,1:6)=[Nodes_RmagPos(2),Nodes_RmagPos(5),0,R1,0,0];
        sps.rlcnames{end+1}='RmagPos B: ';

        sps.rlc(end+1,1:6)=[Nodes_RmagPos(3),Nodes_RmagPos(6),0,R1,0,0];
        sps.rlcnames{end+1}='RmagPos C: ';

        if~isempty(Nodes_RmagNeg)

            sps.rlc(end+1,1:6)=[Nodes_RmagNeg(1),Nodes_RmagNeg(2),0,R0,0,0];
            sps.rlcnames{end+1}='RmagNeg: ';
        end