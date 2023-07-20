function[registerNumber,aufac,t,warnFlag]=ephRegister(etv,units,ephConstants,de,errorFlag,warnFlag)



































    pjd=zeros(4,1);

    if length(etv)==1
        et2=[etv(1),0];
    elseif length(etv)==2
        et2=etv;
        if etv(2)<0
            switch errorFlag
            case 'error'
                error(message('aero:aeroephemerides:negativeJulianDate'));
            case 'warning'
                if warnFlag(1)==0
                    warning(message('aero:aeroephemerides:negativeJulianDate'));
                    warnFlag(1)=1;
                end
            end
        end
    end

    if strcmpi(units,'AU')
        unitsFactor=ephConstants.JED(3);
        aufac=1/ephConstants.AU;
    else
        unitsFactor=ephConstants.JED(3)*86400;
        aufac=1;
    end

    s=et2(1)-0.5;
    pjd(1:2)=ephSplit(s);
    pjd(3:4)=ephSplit(et2(2));
    pjd(1)=pjd(1)+pjd(3)+0.5;
    pjd(2)=pjd(2)+pjd(4);
    pjd(3:4)=ephSplit(pjd(2));
    pjd(1)=pjd(1)+pjd(3);


    registerNumber=floor((pjd(1)-ephConstants.JED(1))/ephConstants.JED(3))+1;
    if(pjd(1)==ephConstants.JED(2))
        registerNumber=registerNumber-1;
    end


    lowerLimitJED=(pjd(1)+pjd(4))<ephConstants.JED(1);
    upperLimitJED=(pjd(1)+pjd(4))>ephConstants.JED(2);
    if lowerLimitJED||upperLimitJED
        switch errorFlag
        case 'error'
            error(message('aero:aeroephemerides:julianDateRange',num2str(pjd(1)+pjd(4)),de,...
            num2str(ephConstants.JED(1)),num2str(ephConstants.JED(2))));
        case 'warning'
            if warnFlag(2)==0
                warning(message('aero:aeroephemerides:julianDateRange',num2str(pjd(1)+pjd(4)),de,...
                num2str(ephConstants.JED(1)),num2str(ephConstants.JED(2))));
                warnFlag(2)=1;
            end
            if lowerLimitJED
                registerNumber=1;
                fractionalTime=0;
            else
                registerNumber=floor((ephConstants.JED(2)-ephConstants.JED(1))...
                /ephConstants.JED(3));
                fractionalTime=1;
            end
        case 'none'
            if lowerLimitJED
                registerNumber=1;
                fractionalTime=0;
            else
                registerNumber=floor((ephConstants.JED(2)-ephConstants.JED(1))...
                /ephConstants.JED(3));
                fractionalTime=1;
            end
        end
    else
        fractionalTime=((pjd(1)-((registerNumber-1)*ephConstants.JED(3)+ephConstants.JED(1)))+pjd(4))/ephConstants.JED(3);
    end




    t=[fractionalTime,unitsFactor];
