function obj=filterHairpinDesign(obj,f,Zo,FBW,FilterType,RippleFactor)
    if strcmp(FilterType,'Butterworth')
        RippleFactor=3.0103;
    end
    f1=f-(FBW/200)*f;
    f2=f+(FBW/200)*f;
    delta=(f2-f1)/f;
    filt=rffilter('FilterType',FilterType,'ResponseType','LowPass',...
    'Implementation','LC pi','FilterOrder',obj.FilterOrder,'PassbandFrequency',1/(2*pi),...
    'PassbandAttenuation',RippleFactor,'Zin',1,'Zout',1,'Name','Filter');
    Cvals=filt.DesignData.Capacitors;
    Lvals=filt.DesignData.Inductors;
    j=1;k=1;
    values=zeros(1,obj.FilterOrder);
    for i=1:obj.FilterOrder
        if rem(i,2)==1
            values(i)=Cvals(j);
            j=j+1;
        else
            values(i)=Lvals(k);
            k=k+1;
        end
    end
    values(end+1)=1;
    Ele_val=values;
    JZo=zeros(1,numel(Ele_val));
    for i=1:numel(Ele_val)
        if i==1
            JZo(i)=sqrt((pi*delta)/(2*Ele_val(i)));
        elseif i==numel(Ele_val)
            JZo(i)=sqrt((pi*delta)/(2*Ele_val(i-1)*Ele_val(i)));
        else
            JZo(i)=(pi*delta)/(2*sqrt(Ele_val(i-1)*Ele_val(i)));
        end
    end
    Zoe=Zo.*(1+JZo+(JZo).^2);
    Zoo=Zo.*(1-JZo+(JZo).^2);



    if strcmp(obj.FeedType,'Coupled')

        t=35e-6;
        h=obj.Height;
        er=obj.Substrate.EpsilonR;
        eta0=120*pi;









        testw=linspace(1e-6,15e-3,200);
        tests=linspace(1e-6,15e-3,200);
        i=1;
        Zeventest=zeros(200,200);
        Zoddtest=zeros(200,200);
        for w=testw
            j=1;
            for s=tests
                [Zeventest(i,j),Zoddtest(i,j)]=rfpcb.internal.coupledlineCalc(w,s,t,h,er,eta0);
                j=j+1;
            end
            i=i+1;
        end
        Width=zeros(1,obj.FilterOrder+1);
        Spacing1=zeros(1,obj.FilterOrder+1);
        for count=1:numel(Zoe)
            Zevendiff=Zeventest-Zoe(count);
            [~,b1]=min(abs(Zevendiff));
            Zodddiff=Zoddtest-Zoo(count);
            [~,b2]=min(abs(Zodddiff));
            diff1=b1-b2;
            [~,b3]=min(abs(diff1));
            CommonIndex=b1(b3);
            if CommonIndex<3||CommonIndex>198
                error(message('rfpcb:rfpcberrors:Unsupported',...
                'Design of filterHairpin','this FBW'));
            end
            wCalc=linspace(testw(CommonIndex-2),testw(CommonIndex+2),25);
            sCalc=linspace(1e-6,5e-3,10000);

            i=1;
            ZevenTotal=zeros(numel(wCalc),numel(sCalc));
            ZoddTotal=zeros(numel(wCalc),numel(sCalc));
            for w=wCalc
                j=1;k=1;
                for s=sCalc
                    [Zeven,Zodd,epsilonReff]=rfpcb.internal.coupledlineCalc(w,s,t,h,er,eta0);
                    if Zeven>Zoe(count)-0.5&&Zeven<Zoe(count)+0.5&&Zodd>Zoo(count)-0.5&&Zodd<Zoo(count)+0.5
                        Width_Calc(k)=w;%#ok<AGROW>
                        Spacing_Calc(k)=s;%#ok<AGROW>
                        k=k+1;
                    end
                    ZevenTotal(i,j)=Zeven;
                    ZoddTotal(i,j)=Zodd;
                    j=j+1;
                end
                i=i+1;
            end
            if exist('Width_Calc','var')==0
                error(message('rfpcb:rfpcberrors:Unsupported',...
                'Design of filterHairpin','this FBW'));
            end
            if exist('Spacing_Calc','var')==0
                error(message('rfpcb:rfpcberrors:Unsupported',...
                'Design of filterHairpin','this FBW'));
            end
            Width(count)=mean(Width_Calc);
            Spacing1(count)=mean(Spacing_Calc);
            clear Width_Calc Spacing_Calc
        end

        Length=(0.25*(3e8/f)*(1/sqrt(epsilonReff)));
        if f>10e9

            Length=3*Length;
        end
        if~isequal(numel(obj.Resonator),obj.FilterOrder)
            updateNumResonator(obj);
        end


        for i=1:numel(Width)
            if i<numel(Width)
                obj.Resonator{i}.Width(2)=Width(i);
            end
            if i==1
                obj.Resonator{i}.Width(1)=Width(i);
                obj.CoupledLineWidth=Width(i);
            elseif i==numel(Width)
                obj.Resonator{i-1}.Width(3)=Width(i);
            else
                obj.Resonator{i-1}.Width(3)=Width(i);
                obj.Resonator{i}.Width(1)=Width(i);
            end
        end




        if rem(obj.FilterOrder,2)==0
            temp=obj.Resonator{end}.Width(1);
            obj.Resonator{end}.Width(1)=obj.Resonator{end}.Width(3);
            obj.Resonator{end}.Width(3)=temp;
        end

        for i=1:numel(obj.Resonator)
            obj.Resonator{i}.Length(1)=Length;
            obj.Resonator{i}.Length(2)=Length/4;
            obj.Resonator{i}.Length(3)=Length;
        end


        for i=1:numel(obj.Resonator)
            if ismember(class(obj.Resonator{i}),{'ubendCurved'})
                obj.Resonator{i}.CurveRadius=min(obj.Resonator{i}.Width)/2;
            end
            if ismember(class(obj.Resonator{i}),{'ubendMitered'})
                obj.Resonator{i}.MiterDiagonal=min(obj.Resonator{i}.Width)/2;
            end
        end

        obj.Spacing=Spacing1(2:end-1);
        obj.CoupledLineSpacing=[Spacing1(1),Spacing1(end)];



        mline=microstripLine;
        mline.Substrate.EpsilonR=obj.Substrate.EpsilonR;
        mline.Substrate.LossTangent=obj.Substrate.LossTangent;
        mline.Height=obj.Height;
        mline=design(mline,f,'Z0',Zo,'LineLength',0.125);
        if f>10e9
            mline=design(mline,f,'Z0',Zo,'LineLength',0.25);
        end
        obj.CoupledLineLength=Length;
        obj.PortLineLength=mline.Length/2;
        obj.PortLineWidth=mline.Width;
        obj.GroundPlaneWidth=2*Length;
        obj.FeedOffset=[-mline.Width/2+(Length)/2,-mline.Width/2+(Length)/2];
        obj.ResonatorOffset=zeros(1,obj.FilterOrder);
    end
    if strcmp(obj.FeedType,'Tapped')







        CouplingCoeff=zeros(1,obj.FilterOrder-1);
        for i=1:obj.FilterOrder-1
            CouplingCoeff(i)=FBW/(Ele_val(i)*Ele_val(i+1));
        end


        QL=Ele_val(1)/delta;
        mline1=microstripLine;
        mline1.Substrate.EpsilonR=obj.Substrate.EpsilonR;
        mline1.Substrate.LossTangent=obj.Substrate.LossTangent;
        mline1.Height=obj.Height;
        mline1=design(mline1,f,'Z0',Zo,'LineLength',0.0625);
        mline2=microstripLine;
        mline2.Substrate.EpsilonR=obj.Substrate.EpsilonR;
        mline2.Substrate.LossTangent=obj.Substrate.LossTangent;
        mline2.Height=obj.Height;
        mline2=design(mline2,f,'Z0',Zo*sqrt(2),'LineLength',0.25);
        L=mline2.Length;



        if f>10e9
            mline1=microstripLine;
            mline1.Substrate.EpsilonR=obj.Substrate.EpsilonR;
            mline1.Substrate.LossTangent=obj.Substrate.LossTangent;
            mline1.Height=obj.Height;
            mline1=design(mline1,f,'Z0',Zo,'LineLength',0.0625*3);
            mline2=microstripLine;
            mline2.Substrate.EpsilonR=obj.Substrate.EpsilonR;
            mline2.Substrate.LossTangent=obj.Substrate.LossTangent;
            mline2.Height=obj.Height;
            mline2=design(mline2,f,'Z0',Zo*sqrt(2),'LineLength',0.25*3);
            L=mline2.Length;
        end
        TapLen=L*(2/pi)*asin(sqrt((pi*(Zo/(Zo*sqrt(2))))/(2*QL)));
        if~isequal(imag(TapLen),0)
            error(message('rfpcb:rfpcberrors:Unsupported','Filter design','this FBW'));
        end
        tol=3;
        obj.Resonator.Width=[round(mline2.Width,tol),round(mline2.Width,tol),round(mline2.Width,tol)];
        obj.Resonator.Length=[round(mline2.Length,tol),round(mline2.Length/4,tol),round(mline2.Length,tol)];
        if ismember(class(obj.Resonator),{'ubendCurved'})
            obj.Resonator.CurveRadius=min(obj.Resonator.Width)/2;
        end
        if ismember(class(obj.Resonator),{'ubendMitered'})
            obj.Resonator.MiterDiagonal=min(obj.Resonator.Width)/2;
        end

        obj.PortLineWidth=round(mline1.Width,tol);
        obj.PortLineLength=round(mline1.Length,tol);
        obj.Spacing=ones(1,obj.FilterOrder-1)*0.5e-3;
        obj.FeedOffset=[round(mline1.Width/2-mline2.Length/2+TapLen,tol),round(mline1.Width/2-mline2.Length/2+TapLen,tol)];
        obj.GroundPlaneWidth=round(mline2.Length*2,tol);
        setSubstrateLength(obj,obj.Substrate);
        obj.ResonatorOffset=zeros(1,obj.FilterOrder);
    end
end