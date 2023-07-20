function[variable_orifice_indices,TLU_lengths,valve_S_TLUs,del_S_TLUs,...
    numAConnections,orificeAPortConnections,numBConnections,orificeBPortConnections]=MwayNposValveConfiguration(num_orifices,OR_type,OR_open_positions,num_positions,...
    area_spec,OR_spool_travel_fully_open,OR_del_S,OR_position_spool_displacements,OR_ports)














































    [variable_orifice_indices,TLU_lengths,valve_S_TLUs,del_S_TLUs]=getOpenOrificeFlags(num_orifices,OR_type,OR_open_positions,num_positions,...
    area_spec,OR_spool_travel_fully_open,OR_del_S,OR_position_spool_displacements);


    [numAConnections,orificeAPortConnections,numBConnections,orificeBPortConnections]=getOrificePortConnections(OR_ports,num_orifices);

end

function[variable_orifice_indices,TLU_lengths,valve_S_TLUs,del_S_TLUs]=getOpenOrificeFlags(num_orifices,OR_type,OR_open_positions,num_positions,...
    area_spec,OR_spool_travel_fully_open,OR_del_S,OR_position_spool_displacements)



































    variable_orifice_indices=find(OR_type(1:num_orifices)==2);




    TLU_lengths=zeros(num_orifices,1);
    valve_S_TLUs=zeros(num_orifices,2*num_positions+1);
    del_S_TLUs=zeros(num_orifices,2*num_positions+1);

























    distance_between_spool_pos=diff(OR_position_spool_displacements);

    for i=variable_orifice_indices'


        OR_open_position=OR_open_positions(i,:);
        OR_open_pos=OR_open_position(~isnan(OR_open_position));












        open_position_flag=zeros(1,num_positions);
        open_position_flag(OR_open_pos)=1;


        num_groups=0;
        next_possible_start_of_open_group=0;
        positions_start_of_open_group=zeros(1,num_positions);
        positions_end_of_open_group=zeros(1,num_positions);

        for z=1:num_positions
            if open_position_flag(z)==1&&z>=next_possible_start_of_open_group


                num_groups=num_groups+1;
                positions_start_of_open_group(num_groups)=z;
                if sum(open_position_flag(z:end))<length(open_position_flag(z:end))


                    positions_end_of_open_group(num_groups)=find(open_position_flag(z:end)==0,1,'first')+z-2;
                    next_possible_start_of_open_group=positions_end_of_open_group(num_groups)+2;
                else

                    positions_end_of_open_group(num_groups)=num_positions;
                    next_possible_start_of_open_group=num_positions+2;
                end
            end
        end


        positions_start_of_open_group(num_groups+1:end)=[];
        positions_end_of_open_group(num_groups+1:end)=[];



        valve_S_full_open_left=zeros(1,num_groups);
        del_S_trans_left=zeros(1,num_groups);
        valve_S_full_open_right=zeros(1,num_groups);
        del_S_trans_right=zeros(1,num_groups);
        for z=1:num_groups
            if positions_start_of_open_group(z)>1
                valve_S_full_open_left(z)=getValveSFullOpen(area_spec,OR_spool_travel_fully_open(i),OR_position_spool_displacements(positions_start_of_open_group(z)),distance_between_spool_pos(positions_start_of_open_group(z)-1),1);
                del_S_trans_left(z)=getValveDelSTransition(area_spec,OR_del_S(i),distance_between_spool_pos(positions_start_of_open_group(z)-1));
            end

            if positions_end_of_open_group(z)<num_positions
                valve_S_full_open_right(z)=getValveSFullOpen(area_spec,OR_spool_travel_fully_open(i),OR_position_spool_displacements(positions_end_of_open_group(z)),distance_between_spool_pos(positions_end_of_open_group(z)),2);
                del_S_trans_right(z)=getValveDelSTransition(area_spec,OR_del_S(i),distance_between_spool_pos(positions_end_of_open_group(z)));
            end

        end








        TLU_length=2*num_groups+1-1*(positions_start_of_open_group(1)==1)-1*(positions_end_of_open_group(end)==num_positions);
        x=zeros(1,TLU_length);
        y=zeros(1,TLU_length);
        k=1;

        for j=1:num_groups
            pos_start_j=positions_start_of_open_group(j);
            pos_end_j=positions_end_of_open_group(j);


            if j==1&&pos_start_j~=1
                x(k)=valve_S_full_open_left(j)-del_S_trans_left(j);
                y(k)=0;
                k=2;
            end







            if pos_start_j==1
                x(k)=valve_S_full_open_right(j);
                y(k)=1;
            elseif pos_end_j==num_positions
                x(k)=valve_S_full_open_left(j);
                y(k)=1;
            else
                mLeft=1/del_S_trans_left(j);
                mRight=1/del_S_trans_right(j);
                x(k)=(mLeft*valve_S_full_open_left(j)+mRight*valve_S_full_open_right(j))/(mLeft+mRight);
                y(k)=mLeft*(x(k)-valve_S_full_open_left(j))+1;
            end
            k=k+1;


            if pos_end_j~=num_positions
                if j==num_groups
                    x(k)=valve_S_full_open_right(j)+del_S_trans_right(j);
                    y(k)=0;
                else



                    mRight=1/del_S_trans_right(j);
                    mLeft=1/del_S_trans_left(j+1);
                    x(k)=(mRight*valve_S_full_open_right(j)+mLeft*valve_S_full_open_left(j+1))/(mRight+mLeft);
                    y(k)=-mRight*(x(k)-valve_S_full_open_right(j))+1;
                end
                k=k+1;
            end
        end

        TLU_lengths(i)=TLU_length;
        valve_S_TLUs(i,1:TLU_length)=x;
        del_S_TLUs(i,1:TLU_length)=y;

    end

end


function valve_S_full_open=getValveSFullOpen(area_spec,del_S_full_open,S_spool_position,distance_between_spool_pos,openingSide)




    if openingSide==1
        if area_spec==1
            valve_S_full_open=S_spool_position-del_S_full_open*distance_between_spool_pos;
        else
            valve_S_full_open=S_spool_position-del_S_full_open/2;
        end

    else
        if area_spec==1
            valve_S_full_open=S_spool_position+del_S_full_open*distance_between_spool_pos;
        else
            valve_S_full_open=S_spool_position+del_S_full_open/2;
        end
    end

end


function valve_S_transition=getValveDelSTransition(area_spec,OR_del_S,distance_between_spool_pos)


    if area_spec==1
        valve_S_transition=OR_del_S*distance_between_spool_pos;
    else
        valve_S_transition=OR_del_S;
    end

end


function[numAConnections,orificeAPortConnections,numBConnections,orificeBPortConnections]=getOrificePortConnections(OR_ports,numOrifices)





















    numAConnections=zeros(1,10);
    orificeAPortConnections=zeros(10,10);
    numBConnections=zeros(1,10);
    orificeBPortConnections=zeros(10,10);

    for port=1:10
        A_connects_to_port=find(OR_ports(1:numOrifices,1)==port);
        numAConnections(port)=numel(A_connects_to_port);
        orificeAPortConnections(1:numAConnections(port),port)=A_connects_to_port;

        B_connects_to_port=find(OR_ports(1:numOrifices,2)==port);
        numBConnections(port)=numel(B_connects_to_port);
        orificeBPortConnections(1:numBConnections(port),port)=B_connects_to_port;
    end


end

