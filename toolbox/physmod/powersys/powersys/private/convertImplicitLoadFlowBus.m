function varargout=convertImplicitLoadFlowBus(LF)






    for i=1:length(LF.bus)
        if(strncmpi(LF.bus(i).ID,'*',1))
            switch get_param(LF.bus(i).blocks(1),'MaskType')
            case{'Pi Section Line','Three-Phase PI Section Line','Distributed Parameters Line','Distributed Parameters Line Frequency Dependent'}




            otherwise

                position=get_param(LF.bus(i).blocks(1),'Position');
                xinit=position(1)-50;
                yinit=position(2)-50;

                BC=str2num(get_param(LF.powergui,'buscounter'));
                blockname=['Bus*',num2str(BC+1),'*'];
                set_param(LF.powergui,'buscounter',num2str(BC+1));

                ParentName=get_param(LF.bus(i).blocks(1),'parent');
                add_block('powerlib/Measurements/Load Flow Bus',[ParentName,'/',blockname]);
                set_param([ParentName,'/',blockname],'position',[xinit,yinit,xinit+12,yinit+15]);
                set_param([ParentName,'/',blockname],'ID',char(blockname));


                set_param([ParentName,'/',blockname],'Vbase',num2str(LF.bus(i).vbase));
                BlockPortHandles=get_param(LF.bus(i).blocks(1),'PortHandles');
                BusPortHandles=get_param([ParentName,'/',blockname],'PortHandles');

                switch get_param(LF.bus(i).blocks(1),'MaskType')

                case{'Three-Phase Transformer (Two Windings)','Three-Phase Transformer (Three Windings)'}


                    windings=0;
                    position=0;


                    for j=1:length(LF.xfo.handle)
                        if((cell2mat(LF.xfo.handle(j)))==LF.bus(i).blocks(1))
                            windings=windings+1;
                            if(position==0)
                                position=j;
                            end
                        end
                    end

                    switch windings


                    case 2
                        if(position==LF.bus(i).xfo(1))
                            add_line(ParentName,BlockPortHandles.LConn(1),BusPortHandles.LConn(1));
                        else
                            add_line(ParentName,BlockPortHandles.RConn(1),BusPortHandles.LConn(1));
                            set_param([ParentName,'/',blockname],'position',[xinit+100,yinit,xinit+112,yinit+15]);
                        end

                    case 3
                        if(position==(LF.bus(i).xfo(1)))
                            add_line(ParentName,BlockPortHandles.LConn(1),BusPortHandles.LConn(1));
                        elseif(position+1==(LF.bus(i).xfo(1)))
                            add_line(ParentName,BlockPortHandles.RConn(1),BusPortHandles.LConn(1));
                            set_param([ParentName,'/',blockname],'position',[xinit+100,yinit,xinit+112,yinit+15]);
                        else
                            add_line(ParentName,BlockPortHandles.RConn(4),BusPortHandles.LConn(1));
                            set_param([ParentName,'/',blockname],'position',[xinit+100,yinit+100,xinit+112,yinit+115]);
                        end
                    end

                case{'Synchronous Machine','Three-Phase Source'}


                    add_line(ParentName,BlockPortHandles.RConn(1),BusPortHandles.LConn(1));
                    set_param([ParentName,'/',blockname],'position',[xinit+100,yinit,xinit+112,yinit+15]);

                otherwise

                    add_line(ParentName,BlockPortHandles.LConn(1),BusPortHandles.LConn(1));

                end

                LF.bus(i).ID=char(blockname);

            end
        end
    end

    if nargout==1
        varargout{1}=LF;
    end