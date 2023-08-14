function displayCapacitance(architecture,aNumerator,bNumerator,cNumerator,gNumerator,aDenominator,cDenominator,gNumeratorAll,bNumeratorAll,btype,gtype,unitCapacitance,numberLevel,tag1,tag2)





    architectureLast=upper(architecture(3:4));
    order=length(unitCapacitance);

    switch architectureLast
    case 'FB'
        aNumeratorNew=aNumerator;
        aDenominatorNew=aDenominator;
        bNumeratorNew=bNumerator(1:order);
        cNumeratorNew=[0,cNumerator(1:(order-1))];
    case 'FF'
        cNumeratorNew=cNumerator;
        cDenominatorNew=cDenominator;
        aNumeratorNew=aNumerator;
        aDenominatorNew=aDenominator;
        bNumeratorNew=bNumerator(1:order);

    end

    gNumeratorNew=zeros(1,order);
    if rem(order,2)
        indexG=0;
    else
        indexG=1;
    end
    for x=1:length(gNumerator)
        if gtype(2*x-indexG)~='N'
            gNumeratorNew(2*x-indexG)=gNumeratorAll(x);
        else
            gNumeratorNew(2*x-indexG)=gNumerator(x);
        end
    end
    for x=1:length(btype)
        if btype(x)~='N'
            bNumeratorNew(x)=bNumeratorAll(x);
        end
    end



    figure(tag1)

    set(tag1,'name','Delta Sigma Modulator Switched Capacitors')
    set(tag1,'numbertitle','off');
    set(tag1,'Position',[120,120,900,600]);
    axis off;





    switch architectureLast
    case 'FB'
        text(0.3,1,'Switched Capacitor Values Per Stage','Hor','center','Ver',...
        'Top','FontSize',14,'FontWeight','bold');
        ss=sprintf(['\n                                             \nUnit Capacitance (pF)'...
        ,' \nSampling Capacitor C1 (pF) \nIntegrating Capacitor C2 (pF) \n']);
        text(0.005,0.9,ss,'Hor','center','Ver','Top','FontSize',12);
        for i=1:length(unitCapacitance)
            Csb(i)=bNumeratorNew(i);
            Csc(i)=cNumeratorNew(i);
            Cg(i)=gNumeratorNew(i);
            Cf(i)=aNumeratorNew(i)*(numberLevel-1);
            Ci(i)=aDenominatorNew(i);
            Cin(i)=(Cg(i)+Csb(i)+Csc(i)+Cf(i));
            Cl(i)=(Cg(i)+Csb(i)+Csc(i)+Cf(i))*Ci(i)/...
            (Ci(i)+Csc(i)+Cf(i)+Cg(i)+Csb(i));
            ss=sprintf('Stage %.0f\n****************\n%.3f\n%.3f\n%.3f',i,...
            unitCapacitance(i)*1e-3,Cin(i)*unitCapacitance(i)*1e-3,...
            Cl(i)*unitCapacitance(i)*1e-3);
            text(i*0.15,0.9,ss,'Hor','center','Ver','Top','FontSize',12);
        end


    case 'FF'
        text(0.3,1,'Switched Capacitor Values Per Stage','Hor','center','Ver',...
        'Top','FontSize',14,'FontWeight','bold');
        ss=sprintf(['\n                                             \nUnit Capacitance (pF)'...
        ,' \nSampling Capacitor C1 (pF) \nIntegrating Capacitor C2 (pF) \n']);
        text(0.005,0.9,ss,'Hor','center','Ver','Top','FontSize',12);
        for i=1:length(unitCapacitance)
            Csb(i)=bNumeratorNew(i);
            if i==1
                Csc(i)=cNumeratorNew(i)*(numberLevel-1);
            else
                Csc(i)=cNumeratorNew(i);
            end
            Cg(i)=gNumeratorNew(i);
            Cf(i)=aNumeratorNew(i)*(numberLevel-1);
            Ci(i)=cDenominatorNew(i);
            Cin(i)=(Cg(i)+Csb(i)+Csc(i));
            Cl(i)=(Cg(i)+Csb(i)+Csc(i))*Ci(i)/(Ci(i)+Csc(i)+Cg(i)+Csb(i));
            ss=sprintf('Stage %.0f\n****************\n%.3f\n%.3f\n%.3f',i,...
            unitCapacitance(i)*1e-3,Cin(i)*unitCapacitance(i)*1e-3,...
            Cl(i)*unitCapacitance(i)*1e-3);
            text(i*0.15,0.9,ss,'Hor','center','Ver','Top','FontSize',12);
        end



    end



    figure(tag2);
    set(tag2,'name','Switched Capacitor Circuit')
    set(tag2,'numbertitle','off');






    if ismac
        pwd=matlabroot;
        path=([pwd,'/toolbox/msblks/msblks/+msblks/+ADC']);
        img=imread([path,'/scIntegrator.JPG']);
        imshow(imresize(img,0.95));
    elseif isunix
        pwd=matlabroot;
        path=([pwd,'/toolbox/msblks/msblks/+msblks/+ADC']);
        img=imread([path,'/scIntegrator.JPG']);
        imshow(imresize(img,0.95));
    elseif ispc
        pwd=matlabroot;
        path=([pwd,'\toolbox\msblks\msblks\+msblks\+ADC']);
        img=imread([path,'\scIntegrator.JPG']);
        imshow(imresize(img,0.95));
    end
