function nl=Netlist(connectivity)








    if(nargin~=1)
        Erreur.message=[mfilename,' takes one argument'];
        Erreur.identifier='SpecializedPowerSystems:PowerSysDomain:InvalidNodalMatrix';
        psberror(Erreur);
    end

    expfields={'ConnectivityMatrix','BlockHandles','PortHandles'};

    for field=expfields
        if(~isfield(connectivity,field))
            Erreur.message=['Argument CONNECTIVITY to ',mfilename,' must have field ',field{:},'.'];
            Erreur.identifier='SpecializedPowerSystems:PowerSysDomain:InvalidNodalMatrix';
            psberror(Erreur);
        end
    end


    nl=POWERSYS.Netlist;


    if getfield(connectivity,'PortHandles')==0

        return
    end

    a=connectivity.ConnectivityMatrix|connectivity.ConnectivityMatrix';
    nl.portToNode=unique(a,'rows');


    nl.ports=connectivity.PortHandles;


    [n,m]=size(nl.portToNode);
    a=zeros(1,m);
    nl.portToNode=[a;nl.portToNode];
    nl.check_nodes(mfilename);


    non_grounds=[];
    Neutrals=[];
    BusBars=[];
    BusBarIndices=[];
    NeutralIndices=[];
    [blocks,i]=unique(connectivity.BlockHandles);
    ports=connectivity.PortHandles(i);

    for i=1:length(blocks)

        block=blocks(i);
        MaskType=get_param(block,'MaskType');

        switch MaskType

        case 'Ground'

            port=ports(i);
            node=nl.port_to_node(port);
            if node~=0
                nl.bind_nodes(0,node);
            end

        case 'Neutral'

            Label=eval(get_param(block,'NodeNumber'));
            port=ports(i);
            node=nl.port_to_node(port);
            Neutrals(end+1,1:2)=[Label,port];

        case 'JunctionPoint'

            BusBars(end+1)=block;
            non_grounds(end+1)=block;

            BusBarIndices(end+1)=length(non_grounds);

        otherwise
            non_grounds(end+1)=block;
        end

    end

    for i=1:size(Neutrals,1)

        Label=Neutrals(i,1);
        ReferenceNeutral=Neutrals(i,2);
        MasterNode=nl.port_to_node(ReferenceNeutral);
        idx=find(Neutrals(:,1)==Label);
        CommonPorts=Neutrals(idx,2);

        if~isempty(MasterNode)
            for j=1:length(CommonPorts)
                NodeToKill=nl.port_to_node(CommonPorts(j));
                MasterNode=nl.port_to_node(ReferenceNeutral);
                if Label==0
                    MasterNode=0;
                end
                if NodeToKill~=MasterNode;
                    nl.bind_nodes(MasterNode,NodeToKill);
                end
                Neutrals(idx(j),2)=NaN;
            end
        end
    end


    nl.reservednode=size(nl.portToNode,1)+1;



    for i=1:length(non_grounds)
        block=non_grounds(i);
        nl.add_block_to_list(block);
    end

    for i=1:length(BusBars)
        BusBarNodes=nl.nodes(BusBarIndices(i));

        MasterNode=BusBarNodes{1}(BusBarNodes{1}==0);

        if isempty(MasterNode)
            MasterNode=BusBarNodes{1}(1);
        end
        for ii=1:length(BusBarNodes{1})
            NodeToKill=BusBarNodes{1}(ii);
            nl.joint_nodes(MasterNode,NodeToKill);
        end
    end
