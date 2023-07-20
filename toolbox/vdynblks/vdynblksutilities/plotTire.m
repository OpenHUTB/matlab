function fig=plotTire(tireData,varargin)






    inType=whos("tireData");
    switch string(inType.class)
    case "tire.tire"
        dataPoints=computeTire(tireData,varargin{:});
    case "struct"
        dataPoints=tireData;
    otherwise
        error("Invalid input parameter. Input must be a data structure or 'tire.tire' class object.")
    end
    sz=width(dataPoints.Long.Fx);
    legNames=string(dataPoints.Long.Fx.Properties.VariableNames);

    set(0,'DefaultFigureWindowStyle','docked')



    fig(1)=figure("Name","Fx vs Slip Ratio");
    ax(1)=axes(fig(1));
    xlabel(ax(1),"Slip Ratio [\kappa]");ylabel(ax(1),'Fx [N]');title(ax(1),"Longitudinal Force vs Slip Ratio");
    hold on;grid on;

    fig(2)=figure("Name","Fy vs Slip Angle");
    ax(2)=axes(fig(2));
    xlabel(ax(2),"Slip Angle [\alpha]");ylabel(ax(2),'Fy [N]');title(ax(2),"Lateral Force vs Slip Angle");
    hold on;grid on;

    fig(3)=figure("Name","Mx vs Slip Angle");
    ax(3)=axes(fig(3));
    xlabel(ax(3),"Slip Angle [\alpha]");ylabel(ax(3),'Mx [N]');title(ax(3),"Overturning Moment vs Slip Angle");
    hold on;grid on;

    fig(4)=figure("Name","My vs Slip Angle");
    ax(4)=axes(fig(4));
    xlabel(ax(4),"Slip Angle [\alpha]");ylabel(ax(4),'My [N]');title(ax(4),"Aligning Moment vs Slip Angle");
    hold on;grid on;


    for i=1:sz
        legendName=col2leg(legNames(i));

        plot(ax(1),dataPoints.Long.Kappa{:,i},dataPoints.Long.Fx{:,i},'LineWidth',2,'DisplayName',legendName);

        plot(ax(2),dataPoints.Lat.Alpha{:,i}*180/pi,dataPoints.Lat.Fy{:,i},'LineWidth',2,'DisplayName',legendName);

        plot(ax(3),dataPoints.Lat.Alpha{:,i}*180/pi,dataPoints.Lat.Mx{:,i},'LineWidth',2,'DisplayName',legendName);

        plot(ax(4),dataPoints.Lat.Alpha{:,i}*180/pi,dataPoints.Lat.My{:,i},'LineWidth',2,'DisplayName',legendName);
    end

    for lg=1:4
        legend(ax(lg),'Location','best');box(ax(lg),'on');
    end
    set(0,'DefaultFigureWindowStyle','normal')


    function n=col2leg(colName)
        try

            colName=replace(colName,'m_s','m/s');

            dec=regexp(colName,'[0-9]_[0-9]');
            for ndec=1:length(dec)
                colName=replaceBetween(colName,dec(ndec)+1,dec(ndec)+1,'.');
            end

            trN=regexp(colName,'[A-Z]_[A-Z]','ignorecase');
            for ntrN=1:length(trN)
                colName=replaceBetween(colName,trN(ntrN)+1,trN(ntrN)+1,"");
            end

            cs=regexp(colName,'[N]__[0-9]');
            if~isempty(cs)
                colName=replaceBetween(colName,cs+2,cs+2,'-');
            end

            colName=regexp(colName,'_','split');
            n="Tire: "+string(colName(1))+" | InflPres: "+string(colName(2))+" | BeltSpeed: "+string(colName(3))+" | Load: "+string(colName(4))+" | Camber: "+string(colName(5)+" | PlySteer: "+string(colName(6)+" | TurnSlip: "+string(colName(8))));
        catch
            error("Cannot create legend names from table column names")
        end
    end

end

