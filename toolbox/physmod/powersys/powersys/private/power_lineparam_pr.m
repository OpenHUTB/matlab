function varargout=power_lineparam_pr(varargin)







    if~pmsl_checklicense('Power_System_Blocks')
        error(message('physmod:pm_sli:sl:InvalidLicense',pmsl_getproductname('Power_System_Blocks'),'power_lineparam'));
    end

    DisplayError=true;
    if nargin==2
        switch varargin{2}
        case 'NoError'
            DisplayError=false;
        end
    end


    if ischar(varargin{1})
        if isequal('new',lower(varargin{1}))
            DATA.comments='Template structure to define new line geometry';
            DATA.units='metric';
            DATA.frequency=60;
            DATA.groundResistivity=100;
            DATA.Geometry.NPhaseBundle=3;
            DATA.Geometry.NGroundBundle=2;
            DATA.Geometry.PhaseNumber=[1,2,3,0,0];
            DATA.Geometry.X=[-12,0,12,-8,8];
            DATA.Geometry.Ytower=[20,20,20,33,33];
            DATA.Geometry.Ymin=[20,20,20,33,33];
            DATA.Geometry.ConductorType=[1,1,1,2,2];
            DATA.Conductors.Diameter=[3.55,1.27];
            DATA.evaluatedFrom='T/D ratio';
            DATA.Conductors.ThickRatio=[0.37,0.5];
            DATA.Conductors.GMR=[];
            DATA.Conductors.Xa=[];
            DATA.Conductors.Res=[0.043,3.106];
            DATA.Conductors.Mur=[1,1];
            DATA.Conductors.Nconductors=[4,1];
            DATA.Conductors.BundleDiameter=[65,0];
            DATA.Conductors.AngleConductor1=[45,0];
            DATA.Conductors.skinEffect='yes';
            varargout{1}=DATA;
            return
        end
    end


    if ischar(varargin{1})
        MATfileSpecified=true;
        try
            load(varargin{1})
        catch ME

            SPSroot=which('powersysdomain');
            if exist(fullfile(SPSroot(1:end-16),'LineParameters',varargin{1}),'file')
                load(fullfile(SPSroot(1:end-16),'LineParameters',varargin{1}));
            else
                if DisplayError
                    Erreur.message=ME.message;
                    Erreur.identifier='SpecializedPowerSystems:powerCableParam:UndefinedMATfile';
                    error(Erreur.message,Erreur.identifier);
                else
                    varargout{1}=[];
                end
                return
            end
        end
        if exist('Comments','var')&&exist('Conductors','var')&&exist('GMRuser','var')&&exist('Geometry','var')&&exist('NGroundBundle','var')&&exist('NPhaseBundle','var')&&exist('freq','var')&&exist('rho','var')
            if exist('skineffect','var')
                SE=skineffect;
            elseif exist('SkinEffect','var')
                SE=SkinEffect;
            else
                SE=1;
            end
            if exist('units','var')
                UN=units;
            elseif exist('Units','var')
                UN=Units;
            else
                UN='metric';
            end
            if exist('xa','var')
                XX=xa;
            elseif exist('Xa','var')
                XX=Xa;
            else
                XX=[];
            end
            DATA=ConvertOldDATA(Comments,Conductors,GMRuser,Geometry,NGroundBundle,NPhaseBundle,SE,UN,XX,freq,rho);
        end
        if~exist('DATA','var')
            if DisplayError
                Erreur.message='The specified MAT file does not contain valid line parameters';
                Erreur.identifier='SpecializedPowerSystems:powerLineParam:UndefinedMATfile';
                error(Erreur.message,Erreur.identifier);
            else
                varargout{1}=[];
            end
            return
        end
    else
        MATfileSpecified=false;
        DATA=varargin{1};
    end
    if~exist('GUI','var')
        GUI=[];
    end
    DATA=UpgradeFormat(DATA,GUI);


    if~ValidLineDATA(DATA,'ToComputeRLC')
        if DisplayError
            Erreur.message='The specified MAT file does not contain valid line parameters';
            Erreur.identifier='SpecializedPowerSystems:powerLineParam:UndefinedMATfile';
            error(Erreur.message,Erreur.identifier);
        else
            varargout{1}=[];
        end
        return
    end

    if MATfileSpecified
        if ValidLineDATA(DATA,'ToUseRLCWB')


            varargout{1}=DATA;
            return
        end
    end


    [~,i,j]=unique([DATA.Geometry.X',DATA.Geometry.Ytower'],'rows');
    if length(i)<length(DATA.Geometry.X)
        for s=1:length(j)
            indices=find(j==j(s));
            if length(indices)>1
                Erreur.message=['Conductors ',num2str(indices(1)),' and ',num2str(indices(2)),' have the same X/Y coordinates'];
                Erreur.identifier='SpecializedPowerSystems:PowerLineParam:ParameterError';
                psberror(Erreur);
            end
        end
    end


    UserSetting=unique(DATA.Geometry.PhaseNumber(DATA.Geometry.PhaseNumber>0));
    LimiteTest=max(DATA.Geometry.PhaseNumber);
    MissingPhases=setdiff(1:LimiteTest,UserSetting);
    if~isempty(MissingPhases)
        if length(MissingPhases)==1
            Erreur.message=['The Phase number ',num2str(MissingPhases),' is not specified for any conductor or bundle.'];
            Erreur.identifier='SpecializedPowerSystems:PowerLineParam:ParameterError';
            psberror(Erreur);
        else
            Erreur.message=['The Phase numbers ',mat2str(MissingPhases),' are not specified for any conductor or bundle.'];
            Erreur.identifier='SpecializedPowerSystems:PowerLineParam:ParameterError';
            psberror(Erreur);
        end
        return
    end

    for i=1:length(DATA.Conductors.Res)
        switch DATA.evaluatedFrom
        case 'T/D ratio'
            switch DATA.units
            case 'metric'
                Rdc_SI=DATA.Conductors.Res(i)/1000;
                Radius_ext=DATA.Conductors.Diameter(i)/2*1e-2;
            case 'english'
                Rdc_SI=DATA.Conductors.Res(i)/1609.3;
                Radius_ext=DATA.Conductors.Diameter(i)/2*2.54e-2;
            end
            Radius_int=Radius_ext*(1-2*DATA.Conductors.ThickRatio(i));
            mur=DATA.Conductors.Mur(i);
            [~,Xint]=skin(DATA.frequency,Rdc_SI,mur,Radius_ext,Radius_int,1);
            DATA.Conductors.GMR(i)=Radius_ext*exp(-Xint/(4*pi*1e-7*DATA.frequency));
            switch DATA.units
            case 'metric'
                DATA.Conductors.GMR(i)=DATA.Conductors.GMR(i)*100;
            case 'english'
                DATA.Conductors.GMR(i)=DATA.Conductors.GMR(i)/2.54e-2;
            end
        case 'GMR'

        case 'Xa'
            if isnan(DATA.Conductors.Xa(i))
                DATA.Conductors.GMR(i)=NaN;
            else
                switch DATA.units
                case 'metric'

                    Xa_SI=DATA.Conductors.Xa(i)/1000;
                    DATA.Conductors.GMR(i)=exp(-Xa_SI/(4*pi*1e-7*DATA.frequency));
                    DATA.Conductors.GMR(i)=DATA.Conductors.GMR(i)*100;
                case 'english'

                    Xa_SI=DATA.Conductors.Xa(i)/1609.3;
                    DATA.Conductors.GMR(i)=12*2.54e-2*exp(-Xa_SI/(4*pi*1e-7*DATA.frequency));
                    DATA.Conductors.GMR(i)=DATA.Conductors.GMR(i)*12;
                end
            end
        end

    end

    switch DATA.units
    case 'english'

        cm2inches=0.3937008;
        meter2feet=3.28083;
        km2mile=0.6213712;
        DATA.Geometry.X=DATA.Geometry.X/meter2feet;
        DATA.Geometry.Ytower=DATA.Geometry.Ytower/meter2feet;
        DATA.Geometry.Ymin=DATA.Geometry.Ymin/meter2feet;
        DATA.Conductors.Res=DATA.Conductors.Res*km2mile;
        DATA.Conductors.GMR=DATA.Conductors.GMR/cm2inches;
        DATA.Conductors.Diameter=DATA.Conductors.Diameter/cm2inches;
        DATA.Conductors.BundleDiameter=DATA.Conductors.BundleDiameter/cm2inches;
    end
    DATA.Conductors.Diameter=DATA.Conductors.Diameter/100;
    DATA.Conductors.BundleDiameter=DATA.Conductors.BundleDiameter/100;
    DATA.Conductors.GMR=DATA.Conductors.GMR/100;

    DATA.Geometry.PhaseNumber(end-DATA.Geometry.NGroundBundle+1:end)=0;

    w=2*pi*DATA.frequency;
    k_eps0=17.975109e6;



    Nwires=0;
    for no_bundle=1:DATA.Geometry.NPhaseBundle+DATA.Geometry.NGroundBundle
        CondType=DATA.Geometry.ConductorType(no_bundle);
        DeltaAngle=360/DATA.Conductors.Nconductors(CondType)*pi/180;
        AngleCond=DATA.Conductors.AngleConductor1(CondType)*pi/180;
        for no_wire=1:DATA.Conductors.Nconductors(CondType)
            Nwires=Nwires+1;
            X(Nwires)=DATA.Geometry.X(no_bundle)+DATA.Conductors.BundleDiameter(CondType)/2*cos(AngleCond);
            Y(Nwires)=(2*DATA.Geometry.Ymin(no_bundle)+DATA.Geometry.Ytower(no_bundle))/3+DATA.Conductors.BundleDiameter(CondType)/2*sin(AngleCond);
            AngleCond=AngleCond+DeltaAngle;
            ConductorType(Nwires)=DATA.Geometry.ConductorType(no_bundle);
            ConductorPhaseNumber(Nwires)=DATA.Geometry.PhaseNumber(no_bundle);
        end
    end


    [ConductorPhaseNumber,n]=sort(ConductorPhaseNumber);
    ConductorType=ConductorType(n);
    X=X(n);
    Y=Y(n);

    n=find(ConductorPhaseNumber==0);
    NGroundWires=length(n);
    n=[NGroundWires+1:Nwires,1:NGroundWires];
    ConductorPhaseNumber=ConductorPhaseNumber(n);
    ConductorType=ConductorType(n);
    X=X(n);
    Y=Y(n);



    Zseries=zeros(Nwires,Nwires);
    Pshunt=zeros(Nwires,Nwires);
    d=zeros(Nwires,Nwires);
    D=zeros(Nwires,Nwires);
    for i=1:Nwires
        Radius=DATA.Conductors.Diameter(ConductorType(i))/2;
        InternalRadius=Radius*(1-2*DATA.Conductors.ThickRatio(ConductorType(i)));
        r=DATA.Conductors.Res(ConductorType(i));
        mur=DATA.Conductors.Mur(ConductorType(i));
        [Rint,Xint]=skin(DATA.frequency,r/1000,mur,Radius,InternalRadius,DATA.Conductors.skinEffect);
        r=Rint*1000;
        for k=i:Nwires
            if i==k
                switch DATA.evaluatedFrom
                case 'GMR'


                    Zseries(i,i)=r+1i*w*2e-7*log(2*Y(i)/DATA.Conductors.GMR(ConductorType(i)))*1000;
                otherwise


                    Zseries(i,i)=r+1i*(w*2e-7*log(2*Y(i)/Radius)+Xint)*1000;
                end
                if DATA.groundResistivity>0
                    [DR,DX]=carson(2*Y(i),0,DATA.frequency,DATA.groundResistivity);
                    Zseries(i,i)=Zseries(i,i)+DR+1i*DX;
                end
                Pshunt(i,i)=k_eps0*log(2*Y(i)/Radius);
            else

                d(i,k)=sqrt((X(i)-X(k))^2+(Y(i)-Y(k))^2);

                D(i,k)=sqrt((X(i)-X(k))^2+(Y(i)+Y(k))^2);
                Zseries(i,k)=1i*w*2e-7*log(D(i,k)/d(i,k))*1000;
                if DATA.groundResistivity>0
                    phi=acos((Y(i)+Y(k))/D(i,k));
                    [DR,DX]=carson(D(i,k),phi,DATA.frequency,DATA.groundResistivity);
                    Zseries(i,k)=Zseries(i,k)+DR+1i*DX;
                end
                Zseries(k,i)=Zseries(i,k);
                Pshunt(i,k)=k_eps0*log(D(i,k)/d(i,k));
                Pshunt(k,i)=Pshunt(i,k);
            end
        end

    end

    Yshunt=1i*w*inv(Pshunt);



    Yseries=inv(Zseries);
    Nphases=max(ConductorPhaseNumber);
    index_red=[];
    i=1;

    for no_phase=1:Nphases
        n=find(ConductorPhaseNumber==no_phase);
        if length(n)>1
            Yseries(i,:)=sum(Yseries(n,:),1);
            Yshunt(i,:)=sum(Yshunt(n,:),1);
        end
        index_red=[index_red,i];
        i=i+length(n);
    end

    i=1;
    for no_phase=1:Nphases
        n=find(ConductorPhaseNumber==no_phase);
        if length(n)>1
            Yseries(:,i)=sum(Yseries(:,n),2);
            Yshunt(:,i)=sum(Yshunt(:,n),2);
        end
        i=i+length(n);
    end

    Zred=inv(Yseries(index_red,index_red));
    Yred=Yshunt(index_red,index_red);


    Zred=(Zred+Zred.')/2;
    Yred=(Yred+Yred.')/2;

    DATA.R=real(Zred);
    DATA.L=imag(Zred)/w;
    DATA.C=imag(Yred)/w;


    a=exp(1i*2*pi/3);T=1/3*[1,1,1;1,a,a^2;1,a^2,a];
    if Nphases==3
        Zseq=T*Zred/(T);
        Yseq=T*Yred/(T);
        DATA.R10=real([Zseq(2,2),Zseq(1,1)]);
        DATA.L10=imag([Zseq(2,2),Zseq(1,1)])/w;
        DATA.C10=imag([Yseq(2,2),Yseq(1,1)])/w;
    elseif Nphases==6
        T2=[T,zeros(3,3);zeros(3,3),T];
        Zseq=T2*Zred/(T2);
        Yseq=T2*Yred/(T2);
        DATA.R10=real([Zseq(2,2),Zseq(1,1),Zseq(1,4),Zseq(5,5),Zseq(4,4)]);
        DATA.L10=imag([Zseq(2,2),Zseq(1,1),Zseq(1,4),Zseq(5,5),Zseq(4,4)])/w;
        DATA.C10=imag([Yseq(2,2),Yseq(1,1),Yseq(1,4),Yseq(5,5),Yseq(4,4)])/w;
    else
        DATA.R10=[];
        DATA.L10=[];
        DATA.C10=[];
    end


    switch DATA.units
    case 'metric'
        DATA.Conductors.Diameter=DATA.Conductors.Diameter*100;
        DATA.Conductors.BundleDiameter=DATA.Conductors.BundleDiameter*100;
        DATA.Conductors.GMR=DATA.Conductors.GMR*100;
    end

    if nargin==2&&nargout==0




        if isstruct(varargin{1})

            L=power_lineparam_pr(varargin{1});
            Phases=size(L.R,1);

            block=varargin{2};
            try
                MaskType=get_param(block,'MaskType');
            catch ME
                Erreur.message=ME.message;
                Erreur.identifier='SpecializedPowerSystems:PowerLineParam:DisplaySequences';
                psberror(Erreur);
                return
            end
            switch MaskType
            case 'Pi Section Line'
                if Phases==1
                    set_param(block,'Frequency',mat2str(L.frequency),'Resistance',mat2str(L.R,5),'Inductance',mat2str(L.L,5),'Capacitance',mat2str(L.C,5));
                else
                    error('SpecializedPowerSystems:PowerLineParam:InvalidArgument',...
                    'The specified block must be a transmission line with more that one phase (Pi Section Cable, Three-Phase PI Section Line, or Distributed Parameter Line.)')
                end
            case 'Pi Section Cable'
                set_param(block,'Resistance',mat2str(L.R,5),'Inductance',mat2str(L.L,5),'Capacitance',mat2str(L.C,5));
            case 'Three-Phase PI Section Line'
                if Phases==3
                    if~isempty(L.R10)
                        set_param(block,'Frequency',mat2str(L.frequency),'Resistances',mat2str(L.R10,5),'Inductances',mat2str(L.L10,5),'Capacitances',mat2str(L.C10,5));
                    end
                end
            case 'Distributed Parameters Line'
                if~isempty(L.R10)
                    set_param(block,'Frequency',mat2str(L.frequency),'Resistance',mat2str(L.R10,5),'Inductance',mat2str(L.L10,5),'Capacitance',mat2str(L.C10,5),'Phases',mat2str(Phases));
                else
                    set_param(block,'Frequency',mat2str(L.frequency),'Resistance',mat2str(L.R,5),'Inductance',mat2str(L.L,5),'Capacitance',mat2str(L.C,5),'Phases',mat2str(Phases));
                end
            otherwise
                error('SpecializedPowerSystems:PowerLineParam:InvalidArgument',...
                'The specified block is not a transmission line (Pi Section Line, Pi Section Cable, Three-Phase PI Section Line, or Distributed Parameter Line.)');
            end
            return
        end
    else
        varargout{1}=DATA;
    end
end

function DATA=UpgradeFormat(DATA,GUI)








































    if~isfield(DATA,'units')
        if isfield(GUI,'Units')
            DATA.units=GUI.Units;
        else
            DATA.units='metric';
        end
    end
    if isfield(DATA,'Frequency')
        DATA.frequency=DATA.Frequency;
        DATA=rmfield(DATA,'Frequency');
    end
    if isfield(DATA,'rho')
        DATA.groundResistivity=DATA.rho;
        DATA=rmfield(DATA,'rho');
    end
    if isfield(DATA,'LineLength')
        DATA.length=DATA.LineLength;
        DATA=rmfield(DATA,'LineLength');
    end
    if isfield(DATA,'FrequencyRange')
        DATA.frequencyRange=DATA.FrequencyRange;
        DATA=rmfield(DATA,'FrequencyRange');
    end










    if isfield(DATA,'Phases')
        DATA.Geometry.NPhaseBundle=DATA.Phases;
        DATA=rmfield(DATA,'Phases');
    end
    if isfield(DATA,'Grounds')
        DATA.Geometry.NGroundBundle=DATA.Grounds;
        DATA=rmfield(DATA,'Grounds');
    end













    if isfield(DATA,'Skineffect')
        DATA.Conductors.skinEffect=DATA.Skineffect;
        DATA=rmfield(DATA,'Skineffect');
    end

    if~isfield(DATA,'evaluatedFrom')
        if isfield(GUI,'EvaluatedFrom')
            DATA.evaluatedFrom=GUI.EvaluatedFrom;
        else
            DATA.evaluatedFrom='GMR';
        end
    end

    if~isfield(DATA,'comments')
        if isfield(GUI,'Comments')
            DATA.comments=GUI.Comments;
        else
            DATA.comments='';
        end
    end

end

function[DR,DX]=carson(D,phi,f,rho)





















    w=2*pi*f;

    rho_cgs=rho*1e11;
    D_cgs=D*100;
    a=2*pi*sqrt(2)*D_cgs*sqrt(f/rho_cgs);
    if a<=0.25
        P=pi/8-1/3/sqrt(2)*a*cos(phi)+a^2/16*cos(2*phi)*(0.6728+log(2/a))+a^2/16*phi*sin(2*phi);
        Q=-0.0386+1/2*log(2/a)+1/3/sqrt(2)*a*cos(phi);
    elseif a>0.25&&a<5
        s2=0;s2p=0;
        s4=0;s4p=0;
        sig1=0;sig3=0;
        sig2=0;sig4=0;
        n=2;
        signe=+1;
        ksig1=1/3;
        ksig3=1/3^2/5;
        ksig2=1+1/2;
        ksig4=1+1/2+1/3;
        nterm=0;
        for i=2:4:18
            nterm=nterm+1;



            k2=1/(factorial(n-1)*factorial(n));
            s2=s2+signe*k2*(a/2)^i*cos(i*phi);
            s2p=s2p+signe*k2*(a/2)^i*sin(i*phi);

            k4=1/(factorial(n)*factorial(n+1));
            s4=s4+signe*k4*(a/2)^(i+2)*cos((i+2)*phi);
            s4p=s4p+signe*k4*(a/2)^(i+2)*sin((i+2)*phi);

            sig1=sig1+signe*ksig1*a^(i-1)*cos((i-1)*phi);
            sig3=sig3+signe*ksig3*a^(i+1)*cos((i+1)*phi);

            sig2=sig2+signe*(ksig2-1/(2*n))*k2*(a/2)^i*cos(i*phi);
            sig4=sig4+signe*(ksig4-1/(2*(n+1)))*k4*(a/2)^(i+2)*cos((i+2)*phi);

            ksig1=ksig1*1/((i+1)*(i+3)^2*(i+5));
            ksig3=ksig3*1/((i+3)*(i+5)^2*(i+7));
            n=n+2;
            ksig2=ksig2+1/(n-1)+1/n;
            ksig4=ksig4+1/(n)+1/(n+1);
            signe=-signe;
        end
        gamma=1.7811;
        P=pi/8*(1-s4)+1/2*log(2/(gamma*a))*s2+1/2*phi*s2p...
        -1/sqrt(2)*sig1+1/2*sig2+1/sqrt(2)*sig3;
        Q=1/4+1/2*log(2/(gamma*a))*(1-s4)-1/2*phi*s4p...
        +1/sqrt(2)*sig1-pi/8*s2+1/sqrt(2)*sig3-1/2*sig4;
    else
        P=cos(phi)/a-sqrt(2)*cos(2*phi)/a^2+cos(3*phi)/a^3+3*cos(5*phi)/a^5;
        Q=cos(phi)/a-cos(3*phi)/a^3+3*cos(5*phi)/a^5;
        P=P/sqrt(2);
        Q=Q/sqrt(2);
    end

    DR=4*w*P*1e-4;
    DX=4*w*Q*1e-4;
end

function DATA=ConvertOldDATA(Comments,Conductors,GMRuser,Geometry,NGroundBundle,NPhaseBundle,skineffect,units,xa,freq,rho)

    DATA.comments=Comments;
    switch units
    case 1
        DATA.units='metric';
    case 2
        DATA.units='english';
    end
    DATA.frequency=freq;
    DATA.groundResistivity=rho;
    DATA.Geometry.NPhaseBundle=NPhaseBundle;
    DATA.Geometry.NGroundBundle=NGroundBundle;
    DATA.Geometry.PhaseNumber=Geometry.PhaseNumber;
    DATA.Geometry.X=Geometry.X;
    DATA.Geometry.Ytower=Geometry.Ytower;
    DATA.Geometry.Ymin=Geometry.Ymin;
    DATA.Geometry.ConductorType=Geometry.ConductorType;
    DATA.Conductors.Diameter=Conductors.Diameter;
    DATA.evaluatedFrom='T/D ratio';
    DATA.Conductors.ThickRatio=Conductors.ThickRatio;
    if all(isnan(GMRuser))
        DATA.Conductors.GMR=[];
    else
        DATA.Conductors.GMR=GMRuser;
    end
    if all(isnan(xa))
        DATA.Conductors.Xa=[];
    else
        DATA.Conductors.Xa=GMRuser;
    end
    DATA.Conductors.Res=Conductors.Res;
    DATA.Conductors.Mur=Conductors.Mur;
    DATA.Conductors.Nconductors=Conductors.Nconductors;
    DATA.Conductors.BundleDiameter=Conductors.BundleDiameter;
    DATA.Conductors.AngleConductor1=Conductors.AngleConductor1;
    switch skineffect
    case 1
        DATA.Conductors.skinEffect='yes';
    case 2
        DATA.Conductors.skinEffect='no';
    end
end

function Answer=ValidLineDATA(DATA,CheckType)


    Answer=false;

    ComputationFields={'R','L','C','WB','frequency','length','comments'};
    TopFields={'frequency','evaluatedFrom','units','groundResistivity','Geometry','Conductors'};
    GeometryFields={'X','Ytower','Ymin','PhaseNumber','NGroundBundle','NPhaseBundle','ConductorType'};
    ConductorsFields={'Res','Diameter','ThickRatio','Mur','Xa','GMR','BundleDiameter','AngleConductor1','Nconductors','skinEffect'};

    if isstruct(DATA)
        switch CheckType

        case 'ToComputeRLC'
            if all(isfield(DATA,TopFields))
                if all(isfield(DATA.Geometry,GeometryFields))
                    if all(isfield(DATA.Conductors,ConductorsFields))

                        Answer=true;


                    end
                end
            end

        case 'ToUseRLCWB'
            if all(isfield(DATA,ComputationFields))

                Answer=true;


            end
        end
    end
end