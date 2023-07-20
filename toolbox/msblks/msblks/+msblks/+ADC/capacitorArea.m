function[widths,lengths,unitCapacitance,unitCapacitanceArea]=capacitorArea(capacitance,capacitorDensity,fringeValue,MinGridStep,tag1)






    capacitance=capacitance*10^15;

    realWidths=[];
    realLength=[];
    for i=1:(floor(length(capacitance)/2))
        if((i==1)&&(rem(length(capacitance),2)==1))
            [w,l]=calculateArea(capacitance(1),capacitorDensity,fringeValue);
            realWidths=[realWidths,w];
            realLength=[realLength,l];
        end
        [w,l]=calculateArea([capacitance(rem(length(capacitance),2)+i*2-1),capacitance(rem(length(capacitance),2)+i*2)],capacitorDensity,fringeValue);
        realWidths=[realWidths,w];
        realLength=[realLength,l];
    end

    wSteps=round(realWidths/MinGridStep);
    lSteps=round(realLength/MinGridStep);

    lengths=lSteps*MinGridStep;
    widths=wSteps*MinGridStep;
    unitCapacitance=capacitorDensity.*widths.*lengths+fringeValue.*2.*(widths+lengths);
    unitCapacitanceArea=widths.*lengths./(2.*(lengths+widths));



    figure(tag1)

    set(tag1,'name','Delta Sigma Modulator Switched Capacitors')
    set(tag1,'numbertitle','off');
    set(tag1,'Position',[120,120,900,600]);
    axis off;





    text(0.3,0.5,'Physical dimensions and values of Unit Capacitance','Hor','center','Ver','Top','FontSize',14,'FontWeight','bold');
    ss=sprintf('\n                      \nCalculated Value (fF)\nWidth (um)\nLength(um)\nActual Value (fF)\nArea (um2)');
    text(0,0.4,ss,'Hor','center','Ver','Top','FontSize',12);
    for i=1:length(capacitance)
        ss=sprintf('Stage %.0f\n****************\n%.2f\n%.3f\n%.3f\n%.2f\n%.2f %\n%.3f',i,capacitance(i),widths(i),...
        lengths(i),unitCapacitance(i),widths(i)*lengths(i));
        text(i*0.15,0.4,ss,'Hor','center','Ver','Top','FontSize',12);
    end

    function[realWidth,realLength]=calculateArea(totalCapacitance,capacitorDensity,fringeCapacitance)





        minCapacitance=min(totalCapacitance);
        temp=sqrt(capacitorDensity*minCapacitance+4*fringeCapacitance^2);

        minWidth=(temp-2*fringeCapacitance)/capacitorDensity;
        minWidth=abs(minWidth);
        area=minWidth/4;


        inside=totalCapacitance.^2-16*area*fringeCapacitance.*totalCapacitance-...
        16*area^2*capacitorDensity.*totalCapacitance;
        temp=real(sqrt(inside));
        realLength=(totalCapacitance+temp)./(4*(area*capacitorDensity+fringeCapacitance));
        realWidth=(area.*realLength*2)./(realLength-area*2);

    end

end
