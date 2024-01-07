function obj=coupledStripLineDesign(obj,f,Zoe,Zoo)

    er=obj.Substrate.EpsilonR;
    c=3e8;
    b=round(sum(obj.Substrate.Thickness),12);
    e=0.0885*er;
    ZoeErAct=sqrt(er)*Zoe;
    ZooErAct=sqrt(er)*Zoo;

    n=500;
    testwb=linspace(0.2,2,n);
    testsb=linspace(0.01,1,n);

    i=1;
    ZoeErCal=zeros(n,n);
    ZooErCal=zeros(n,n);
    for ratiowb=testwb
        j=1;k=1;
        for ratiosb=testsb
            cf1=0.4407*e;
            cfe1=((2/pi)*log(1+(tanh((pi/2)*ratiosb))))*e;

            ZoeErCal(i,j)=94.15/(ratiowb+((1/(2*e))*(cf1+cfe1)));
            cfo1=((2/pi)*log(1+(coth((pi/2)*ratiosb))))*e;

            ZooErCal(i,j)=94.15/(ratiowb+((1/(2*e))*(cf1+cfo1)));
            if ZoeErCal(i,j)>ZoeErAct-0.5&&ZoeErCal(i,j)<ZoeErAct+0.5&&ZooErCal(i,j)>ZooErAct-0.5&&ZooErCal(i,j)<ZooErAct+0.5
                Wb_Calc(k)=ratiowb;%#ok<AGROW>
                Sb_Calc(k)=ratiosb;%#ok<AGROW>
                k=k+1;
            elseif ZoeErCal(i,j)>ZoeErAct-1&&ZoeErCal(i,j)<ZoeErAct+1&&ZooErCal(i,j)>ZooErAct-1&&ZooErCal(i,j)<ZooErAct+1
                Wb_Calc(k)=ratiowb;%#ok<AGROW>
                Sb_Calc(k)=ratiosb;%#ok<AGROW>
                k=k+1;
            end
            j=j+1;
        end
        i=i+1;
    end
    if exist('Wb_Calc','var')==0||exist('Sb_Calc','var')==0
        error(message('rfpcb:rfpcberrors:Unsupported',...
        'Design of coupledStripLine','this combination of Zoe and Zoo'));
    end

    Wb=mean(Wb_Calc);
    Sb=mean(Sb_Calc);

    W=round(Wb*b,12);

    S=round(Sb*b,12);
    lambda=(c/f)*(1/sqrt(er));
    L=round((lambda*0.25),12);
    obj.Length=L;
    obj.Width=W;
    obj.Spacing=S;
    obj.GroundPlaneWidth=4*W+2*S;
end