function Data=MwayNposValveDrawIcon(hBlock)











    Data={};%#ok<*AGROW>





    ParamsTable=foundation.internal.mask.getEvaluatedBlockParameters(hBlock,false);
    ssc=cell2struct(ParamsTable.Value,ParamsTable.Row);

    num_positions=double(ssc.num_positions);
    num_ports=double(ssc.num_ports);
    num_orifices=double(ssc.num_orifices);

    error=0;
    if isempty(num_positions)||num_positions<2||num_positions>10
        error=1;
    elseif isempty(num_ports)||num_ports<2||num_ports>10
        error=1;
    elseif isempty(num_orifices)||num_orifices<1||num_orifices>20
        error=1;
    end

    if error




        lineWidth=0;
        margin_border_spool=0.1;
        rectangle_coord=[-margin_border_spool,1+margin_border_spool,1+margin_border_spool,-margin_border_spool;-0.4,-0.4,1.4,1.4];
        Data{end+1}=rectanglePatch(rectangle_coord,lineWidth);



        triangle_margin=0.1;
        triangle_coord=[triangle_margin,1-triangle_margin,0.5
        triangle_margin,triangle_margin,1-triangle_margin];

        WarningPatches=WarningTrianglePatch(triangle_coord);
        Data=horzcat(Data,WarningPatches);
        return;
    end




    orifice_ports=zeros(num_orifices,2);
    orifice_is_open=zeros(num_orifices,num_positions);
    if num_orifices>0
        for i=1:num_orifices
            orifice_i_ports=ssc.(['OR',num2str(i),'_ports']);
            orifice_i_ports_checked=check_orifice_i_ports(orifice_i_ports,num_ports);


            orifice_ports(i,1:2)=orifice_i_ports_checked;

            orifice_i_open_positions=ssc.(['OR',num2str(i),'_open_pos']);
            orifice_i_open_positions_checked=check_orifice_i_open_positions(orifice_i_open_positions,ssc.num_positions);



            orifice_is_open(i,orifice_i_open_positions_checked)=1;
        end
    end



    lineWidth=0;
    width=1;
    margin_border_spool=0.1*num_positions;


    rectangle_coord=[-margin_border_spool,num_positions+margin_border_spool,num_positions+margin_border_spool,-margin_border_spool;-0.4,-0.4,1.4,1.4];
    Data{end+1}=rectanglePatch(rectangle_coord,lineWidth);




    numOddPorts=ceil(num_ports/2);
    odd_ports_x=(1:numOddPorts).*width/(numOddPorts+1);
    numEvenPorts=floor(num_ports/2);
    even_ports_x=(1:numEvenPorts).*width/(numEvenPorts+1);


    if num_ports>3
        T_width=diff(odd_ports_x(1:2))*2/3;
    else
        T_width=0.2;
    end
    T_height=T_width;

    arrow_head_width=T_width;
    arrow_head_length=T_height;

    n_height=T_height;
    n_height_nonadjacent_ports=T_height*1.5;


    triangle_margin=0.1;







    for i=1:num_positions


        rectangle_coord=[[0,1,1,0]+(i-1);[0,0,1,1]];
        Data{end+1}=rectanglePatch(rectangle_coord,lineWidth);


        open_orifice_flag=orifice_is_open(:,i);
        open_orifice_=(1:num_orifices)'.*(open_orifice_flag==1);
        open_orifice=open_orifice_(open_orifice_>0);
        active_ports=orifice_ports(open_orifice,1:2);
        active_ports_vec=unique(active_ports(:));

        if~any(active_ports_vec==0)


            for j=1:numOddPorts
                if~any(active_ports_vec(:)==2*j-1)
                    bottom_T_coord=[[0,T_width/2,-T_width/2]+odd_ports_x(j)+i-1;[0,T_height,T_height]];
                    Data{end+1}=bottomTPatch(bottom_T_coord,lineWidth);
                end
            end


            for j=1:numEvenPorts
                if~any(active_ports_vec(:)==2*j)
                    top_T_coord=[[-T_width/2,T_width/2,0]+even_ports_x(j)+i-1;[1-T_height,1-T_height,1]];
                    Data{end+1}=topTPatch(top_T_coord,lineWidth);
                end
            end


            G=graph(active_ports(:,1),active_ports(:,2));
            [port_groups,port_group_sizes]=conncomp(G);

            for j=1:length(port_group_sizes)
                if port_group_sizes(j)>1

                    ports_in_group=(1:length(port_groups)).*(port_groups==j);
                    connected_ports=ports_in_group(ports_in_group>0);

                    if port_group_sizes(j)==2



                        if sum(active_ports(:,1)==connected_ports(1))
                            first_port=connected_ports(1);
                            second_port=connected_ports(2);
                        else
                            first_port=connected_ports(2);
                            second_port=connected_ports(1);
                        end

                        if mod(first_port,2)==1
                            if mod(second_port,2)==1


                                if abs(diff([first_port,second_port]))==2
                                    n_height_use=n_height;
                                else
                                    n_height_use=n_height_nonadjacent_ports;
                                end
                                n_coord=[[odd_ports_x(ceil(first_port/2))*[1,1],odd_ports_x(ceil(second_port/2))*[1,1]]+i-1
                                [0,n_height_use,n_height_use,0]];
                                Data{end+1}=nPatch(n_coord,lineWidth);
                            else

                                up_arrow_coord=[[odd_ports_x(ceil(first_port/2)),even_ports_x(second_port/2)]+i-1
                                [0,1]];
                                Data{end+1}=arrow(up_arrow_coord,lineWidth,arrow_head_width,arrow_head_length);
                            end
                        else
                            if mod(second_port,2)==1

                                down_arrow_coord=[[even_ports_x(first_port/2),odd_ports_x(ceil(second_port/2))]+i-1
                                [1,0]];
                                Data{end+1}=arrow(down_arrow_coord,lineWidth,arrow_head_width,arrow_head_length);
                            else


                                if abs(diff([first_port,second_port]))==2
                                    u_height_use=n_height;
                                else
                                    u_height_use=n_height_nonadjacent_ports;
                                end
                                u_coord=[[even_ports_x(first_port/2)*[1,1],even_ports_x(second_port/2)*[1,1]]+i-1
                                [1,1-u_height_use,1-u_height_use,1]];
                                Data{end+1}=uPatch(u_coord,lineWidth);
                            end
                        end
                    else



                        odd_connected_ports=connected_ports(mod(connected_ports,2)==1);
                        even_connected_ports=connected_ports(mod(connected_ports,2)==0);

                        h_coord=[[odd_ports_x(ceil(odd_connected_ports/2)),even_ports_x(even_connected_ports/2)]+i-1
                        zeros(1,length(odd_connected_ports)),ones(1,length(even_connected_ports))];
                        hpatches=hPatch(h_coord,length(odd_connected_ports),lineWidth);


                        Data=horzcat(Data,hpatches);
                    end
                end
            end
        else



            triangle_coord=[width*(i-1)+triangle_margin,width*(i)-triangle_margin,width*(i-0.5)
            triangle_margin,triangle_margin,1-triangle_margin];

            WarningPatches=WarningTrianglePatch(triangle_coord);
            Data=horzcat(Data,WarningPatches);
        end
    end

end


function patchPts=rectanglePatch(rectangle_coord,W)





    x=rectangle_coord(1,:);
    y=rectangle_coord(2,:);

    w=W/2;

    patchPts=[x(1)-w,x(2)+w,x(3)+w,x(4)-w,x(1)-w,x(1)+w,x(4)+w,x(3)-w,x(2)-w,x(1)-w
    y(1)-w,y(2)-w,y(3)+w,y(4)+w,y(1)+w,y(1)+w,y(4)-w,y(3)-w,y(2)+w,y(1)+w];

end


function patchPts=bottomTPatch(T_coord,W)





    x=T_coord(1,:);
    y=T_coord(2,:);

    w=W/2;

    patchPts=[x(1)-w,x(1)+w,x(1)+w,x(2)+w,x(2)+w,x(3)-w,x(3)-w,x(1)-w
    y(1)-w,y(1)-w,y(2)-w,y(2)-w,y(2)+w,y(3)+w,y(3)-w,y(3)-w];

end


function patchPts=topTPatch(T_coord,W)





    x=T_coord(1,:);
    y=T_coord(2,:);

    w=W/2;

    patchPts=[x(1)-w,x(2)+w,x(2)+w,x(3)+w,x(3)+w,x(3)-w,x(3)-w,x(1)-w
    y(1)-w,y(2)-w,y(2)+w,y(2)+w,y(3)+w,y(3)+w,y(1)+w,y(1)+w];

end


function rotatedPatchPts=arrow(arrow_coord,W,arrow_head_width,arrow_head_length)





    ports_x=arrow_coord(1,:);
    ports_y=arrow_coord(2,:);


    theta=atan2(diff(ports_y),diff(ports_x))-pi/2;

    element_length=1/abs(cos(theta));


    R=[cos(theta),-sin(theta);sin(theta),cos(theta)];




    arrow_points=[0,0,arrow_head_width/2,0,-arrow_head_width/2
    0,element_length-arrow_head_length,element_length-arrow_head_length,element_length,element_length-arrow_head_length];

    x=arrow_points(1,:);
    y=arrow_points(2,:);


    w=W/2;

    patchPts=[x(1)-w,x(1)+w,x(2)+w,x(3)+w,x(4),x(5)-w,x(2)-w
    y(1)-w,y(1)-w,y(2)-w,y(3)-w,y(4)+w,y(5)-w,y(2)-w];


    rotatedPatchPts=R*patchPts+[ports_x(1);ports_y(1)];

end


function patchPts=nPatch(n_coord,W)





    x=n_coord(1,:);
    y=n_coord(2,:);

    w=W/2;

    patchPts=[x(1)+w,x(1)-w,x(2)-w,x(3)+w,x(4)+w,x(4)-w,x(3)-w,x(2)+w
    y(1)-w,y(1)-w,y(2)+w,y(3)+w,y(4)-w,y(4)-w,y(3)-w,y(2)-w];

end


function patchPts=uPatch(u_coord,W)





    x=u_coord(1,:);
    y=u_coord(2,:);

    w=W/2;

    patchPts=[x(1)+w,x(1)-w,x(2)-w,x(3)+w,x(4)+w,x(4)-w,x(3)-w,x(2)+w
    y(1)+w,y(1)+w,y(2)-w,y(3)-w,y(4)+w,y(4)+w,y(3)+w,y(2)+w];

end


function Data=hPatch(h_coord,num_odd_ports,W)








    w=W/2;

    x_ports=h_coord(1,:);


    x_min=min(x_ports);
    x_max=max(x_ports);




    horizontal_line_patch=[x_min-w,x_max+w,x_max+w,x_min-w
    0.5-w,0.5-w,0.5+w,0.5+w];

    Data{1}=horizontal_line_patch;

    for i=1:length(x_ports)


        if i<=num_odd_ports

            patchPts=[x_ports(i)-w,x_ports(i)+w,x_ports(i)+w,x_ports(i)-w
            0,0,0.5,0.5];
        else

            patchPts=[x_ports(i)-w,x_ports(i)+w,x_ports(i)+w,x_ports(i)-w
            0.5,0.5,1,1];
        end
        Data{end+1}=patchPts;









    end

end


function patchPts=WarningTrianglePatch(triangle_coord)







    period_width=0.12;
    period_height=0.12;
    line_top_gap=0.2;
    line_bot_gap=0.05;

    x=triangle_coord(1,:);
    x_center=mean(x);
    y=triangle_coord(2,:);

    w=period_width;
    h=period_height;
    Ltop=line_top_gap;
    Lbot=line_bot_gap;

    patchPts1=[x_center,x(1),x_center,x_center,x_center-w/2,x_center-w/2,x_center,x_center,x_center-w/2,x_center-w/2,x_center
    y(1),y(1),y(3),y(3)-Ltop,y(3)-Ltop,y(1)+h+w/2+Lbot,y(1)+h+w/2+Lbot,y(1)+h+w/2,y(1)+h+w/2,y(1)+h-w/2,y(1)+h-w/2];



    patchPts2=[x_center,x(2),x_center,x_center,x_center+w/2,x_center+w/2,x_center,x_center,x_center+w/2,x_center+w/2,x_center
    y(1),y(1),y(3),y(3)-Ltop,y(3)-Ltop,y(1)+h+w/2+Lbot,y(1)+h+w/2+Lbot,y(1)+h+w/2,y(1)+h+w/2,y(1)+h-w/2,y(1)+h-w/2];

    patchPts={patchPts1,patchPts2};

end


function orifice_i_ports=check_orifice_i_ports(orifice_i_ports,num_ports)



    if~(length(orifice_i_ports)==2)
        orifice_i_ports=[0,0];
    elseif~(orifice_i_ports(1)~=orifice_i_ports(2))
        orifice_i_ports=[0,0];
    elseif~(all(orifice_i_ports>=1))
        orifice_i_ports=[0,0];
    elseif~(all(orifice_i_ports<=num_ports))
        orifice_i_ports=[0,0];
    end

end


function orifice_i_open_positions=check_orifice_i_open_positions(orifice_i_open_positions,num_positions)





    orifice_i_open_positions=orifice_i_open_positions(orifice_i_open_positions>=1);
    orifice_i_open_positions=orifice_i_open_positions(orifice_i_open_positions<=num_positions);

end