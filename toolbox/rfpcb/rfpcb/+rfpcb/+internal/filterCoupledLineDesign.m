function obj=filterCoupledLineDesign(obj,f,Zo,FBW,FilterType,RippleFactor)
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
    Spacing=zeros(1,obj.FilterOrder+1);
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
            'Design of filterCoupledLine','this FBW'));
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
            'Design of filterCouplerLine','this FBW'));
        end
        if exist('Spacing_Calc','var')==0
            error(message('rfpcb:rfpcberrors:Unsupported',...
            'Design of filterCouplerLine','this FBW'));
        end
        Width(count)=mean(Width_Calc);
        Spacing(count)=mean(Spacing_Calc);
        clear Width_Calc Spacing_Calc
    end
    Length=(0.25*(3e8/f)*(1/sqrt(epsilonReff)))*(ones(1,numel(Width)));
    obj.CoupledLineLength=Length;
    obj.CoupledLineWidth=Width;
    obj.CoupledLineSpacing=Spacing;
    totalWidth=cumsum(obj.CoupledLineWidth);
    totalWidth=totalWidth(end);
    totalSpacing=cumsum(obj.CoupledLineSpacing);
    totalSpacing=totalSpacing(end);


    mline=microstripLine;
    mline.Substrate.EpsilonR=obj.Substrate.EpsilonR;
    mline.Substrate.LossTangent=obj.Substrate.LossTangent;
    mline.Height=obj.Height;
    mline=design(mline,f,'Z0',Zo);
    obj.PortLineLength=mline.Length;
    obj.PortLineWidth=mline.Width;
    obj.GroundPlaneWidth=2*(totalWidth+totalSpacing)+obj.PortLineWidth*2.5;
end