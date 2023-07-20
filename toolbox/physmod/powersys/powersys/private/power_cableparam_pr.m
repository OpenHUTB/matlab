function varargout=power_cableparam_pr(varargin)






    if~pmsl_checklicense('Power_System_Blocks')
        error(message('physmod:pm_sli:sl:InvalidLicense',pmsl_getproductname('Power_System_Blocks'),'power_cableparam'));
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
            powersysdomain=which('powersysdomain');
            SPSroot=powersysdomain(1:end-16);
            MATfile=[SPSroot,'CableParameters',filesep,'Param_4cablesUnderground2cond.mat'];
            load(MATfile,'DATA');


            DATA=rmfield(DATA,{'R','L','G','C','WB'});
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
            if exist(fullfile(SPSroot(1:end-16),'CableParameters',varargin{1}),'file')
                load(fullfile(SPSroot(1:end-16),'CableParameters',varargin{1}));
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
        if exist('CableData','var')
            DATA=CableData;
        end
        if~exist('DATA','var')
            if DisplayError
                Erreur.message='The specified MAT file does not contain valid cable parameters';
                Erreur.identifier='SpecializedPowerSystems:powerCableParam:UndefinedMATfile';
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


    if isfield(DATA,'GMD_phi')
        if MATfileSpecified
            varargout{1}=DATA;
        else
            [varargout{1:nargout}]=ComputeCableParametersAsInR22a(DATA);
        end
        return
    end

    if nargout>1
        Erreur.message='Too many output arguments. Starting with R2022b, the function returns a single structure variable that contains both geometric cable data and the computed parameters. For more informations, see the documentation of the function.';
        Erreur.identifier='SpecializedPowerSystems:powerCableParam:tooManyOutputs';
        error(Erreur.identifier,Erreur.message);
    end


    if~ValidCableDATA(DATA,'ToComputeRLCWB')
        if DisplayError
            Erreur.message='The specified MAT file does not contain valid cable parameters';
            Erreur.identifier='SpecializedPowerSystems:powerCableParam:UndefinedMATfile';
            error(Erreur.identifier,Erreur.message);
        else
            varargout{1}=[];
        end
        return
    end

    if MATfileSpecified
        if ValidCableDATA(DATA,'ToUseRLCWB')


            varargout{1}=DATA;
            return
        end
    end

    [DATA.R,DATA.L,DATA.G,DATA.C]=cable_main(DATA,DATA.frequency);
    Z=DATA.R+1i*DATA.L*(2*pi*DATA.frequency);

    if~isempty(DATA.frequencyRange)

        Range=DATA.frequencyRange;
        fmin=Range(1);
        fmax=Range(2);
        Nfs=Range(3);
        if Nfs>1000
            Nfs=1000;
        end
        f=logspace(fmin,fmax,Nfs);
        Nfreq=length(f);
        for n=1:Nfreq
            [R,L,~,C]=cable_main(DATA,f(n));
            Rcube(1:size(R,1),1:size(R,1),n)=R;
            Lcube(1:size(L,1),1:size(L,1),n)=L;
            Ccube(1:size(C,1),1:size(C,1),n)=C;
            Z(1:size(R,1),1:size(R,1),n)=(R+1i*L*2*pi*f(n))/1000;
            Y(1:size(C,1),1:size(C,1),n)=(0+1i*C*2*pi*f(n))/1000;
        end

        errlim=0.001;
        modegroup=1;
        scaleyes=1;
        bound=100;
        KM2M=1e3;
        [WB.YcPls,WB.YcRes,WB.YcstD,WB.Hpls,WB.HRes,WB.tau,WB.Ng,WB.NH,NYcA]=WideBandLineFitter(Z,Y,DATA.length*KM2M,size(R,1),Nfs,f,errlim,modegroup,scaleyes,bound);
        WB.Nc=size(R,1);
        WB.NYc=NYcA(1);
        WB.NYc_res=WB.NYc*WB.Nc*WB.Nc;
        WB.NH_res=sum(WB.NH)*WB.Nc*WB.Nc;
        WB.tau=WB.tau(1:WB.Ng).';
        WB.R=Rcube;
        WB.L=Lcube;
        WB.C=Ccube;
        WB.Frequency=f;
        DATA.WB=WB;
    else
        DATA.WB=[];
    end
    varargout{1}=DATA;
end
function[R,L,C,Z,G]=ComputeCableParametersAsInR22a(CableData)





































































    [isCableValid,CableData]=InvalidCableParameters(CableData);

    if isCableValid
        R=[];
        L=[];
        C=[];
        G=[];
        Z=[];
        return
    end


    R_a=CableData.D_a/2;


    S_a=CableData.n_ba*pi*CableData.d_ba^2/4;


    R_phi=CableData.rho_ba*1000/S_a;


    R_e=pi^2*10^(-4)*CableData.f;


    k_1=0.0529*CableData.f/(0.3048*60);


    D_e=1650*sqrt(CableData.rho_e/(2*pi*CableData.f));


    GMR_phi=R_a*exp(-CableData.mu_r_ba/4);


    R_N=CableData.rho_x*1000/CableData.S_x;


    GMR_N=CableData.d_x/2+(CableData.D_x-CableData.d_x)/4;


    DN_2=CableData.d_x/2+(CableData.D_x/2-CableData.d_x/2)/2;

    Z.aa=R_phi+R_e+1i*k_1*log10(D_e/GMR_phi);
    Z.xx=R_N+R_e+1i*k_1*log10(D_e/GMR_N);
    Z.ab=R_e+1i*k_1*log10(D_e/CableData.GMD_phi);
    Z.ax=R_e+1i*k_1*log10(D_e/DN_2);
    R.aa=real(Z.aa);
    R.xx=real(Z.xx);
    R.ab=real(Z.ab);
    R.ax=real(Z.ax);
    L.aa=imag(Z.aa)/(2*pi*CableData.f);
    L.xx=imag(Z.xx)/(2*pi*CableData.f);
    L.ab=imag(Z.ab)/(2*pi*CableData.f);
    L.ax=imag(Z.ax)/(2*pi*CableData.f);

    C.ax=1/0.3048*((0.00736*CableData.epsilon_iax)/(log10(CableData.D_iax/CableData.d_iax)));
    C.xe=1/0.3048*((0.00736*CableData.epsilon_ixe)/(log10(CableData.D_ixe/CableData.d_ixe)));
    C.ax=C.ax*1e-6;

    C.xe=C.xe*1e-6;

    G=[];
end
function[E,CableData]=InvalidCableParameters(CableData)








    if isfield(CableData,'d_ba_units')
        CableData.d_ba=CableData.d_ba*unitsm(CableData.d_ba_units);
        CableData.D_a=CableData.D_a*unitsm(CableData.D_a_units);
        CableData.S_x=CableData.S_x*unitsm(CableData.S_x_units);
        CableData.d_x=CableData.d_x*unitsm(CableData.d_x_units);
        CableData.D_x=CableData.D_x*unitsm(CableData.D_x_units);
        CableData.GMD_phi=CableData.GMD_phi*unitsm(CableData.GMD_phi_units);
        CableData.d_iax=CableData.d_iax*unitsm(CableData.d_iax_units);
        CableData.D_iax=CableData.D_iax*unitsm(CableData.D_iax_units);
        CableData.d_ixe=CableData.d_ixe*unitsm(CableData.d_ixe_units);
        CableData.D_ixe=CableData.D_ixe*unitsm(CableData.D_ixe_units);
    end
    E=0;
    Erreur.identifier='SpecializedPowerSystems:PowerCableParam:ParameterError';

    V={'N','n_ba','f','rho_e','rho_ba','mu_r_ba','rho_x','epsilon_iax',...
    'epsilon_ixe','S_x','d_ba','D_a','d_iax','D_iax','d_x','d_ixe','D_ixe',...
    'GMD_phi'};
    S={'Number of phases','Number of strands','Frequency','Ground resistivity',...
    'Phase conductor resistivity','Phase conductor permittivity','Screen conductor resistivity',...
    'Phase insulator permittivity','Screen insulator permittivity','Total section',...
    'Strand diameter','Conductor external diameter','Internal diameter of phase insulator',...
    'External diameter of phase insulator','Internal diameter of screen conductor',...
    'Internal diameter of screen insulator','External diameter of screen insulator',...
    'Geometric mean distance between conductors'};
    for n=1:length(V)
        if CableData.(V{n})<=0||isnan(CableData.(V{n}))||isinf(CableData.(V{n}))||isempty(CableData.(V{n}))
            if n==18&&CableData.N==1

            else
                Erreur.message=['The ',S{n},' must be greater than zero and have a finite value.'];
                psberror(Erreur.message,Erreur.identifier,'nowait');
                E=1;
            end
        end
    end

    if CableData.d_ba<=0
        Erreur.message='Strand diameter must be greater than zero.';
        psberror(Erreur.message,Erreur.identifier,'nowait');
        E=1;
    end
    if CableData.D_a<CableData.d_ba
        Erreur.message='Conductor external diameter must be greater or equal to strand diameter.';
        psberror(Erreur.message,Erreur.identifier,'nowait');
        E=1;
    end
    if CableData.d_iax<CableData.D_a
        Erreur.message='Internal diameter of phase insulator must be greater or equal to external diameter of phase conductor.';
        psberror(Erreur.message,Erreur.identifier,'nowait');
        E=1;
    end
    if CableData.D_iax<=CableData.d_iax
        Erreur.message='External diameter of phase insulator must be greater than internal diameter of phase insulator.';
        psberror(Erreur.message,Erreur.identifier,'nowait');
        E=1;
    end
    if CableData.d_x<CableData.D_iax
        Erreur.message='Internal diameter of screen conductor must be greater or equal to external diameter of phase insulator.';
        psberror(Erreur.message,Erreur.identifier,'nowait');
        E=1;
    end
    if CableData.D_x<=CableData.d_x
        Erreur.message='External diameter of screen conductor must be greater than internal diameter of screen conductor.';
        psberror(Erreur.message,Erreur.identifier,'nowait');
        E=1;
    end
    if CableData.d_ixe<CableData.D_x
        Erreur.message='Internal diameter of screen insulator must be greater or equal to external diameter of screen conductor.';
        psberror(Erreur.message,Erreur.identifier,'nowait');
        E=1;
    end
    if CableData.D_ixe<CableData.d_ixe
        Erreur.message='External diameter of screen insulator must be greater than internal diameter of screen insulator.';
        psberror(Erreur.message,Erreur.identifier,'nowait');
        E=1;
    end
    if CableData.N>1&&(CableData.GMD_phi<CableData.D_ixe)
        Erreur.message='Geometric mean distance between phase conductors must be greater than external diameter of screen insulator.';
        psberror(Erreur.message,Erreur.identifier,'nowait');
        E=1;
    end
end
function K=unitsm(units)
    switch units
    case 'm'
        K=1;
    case 'cm'
        K=0.01;
    case 'mm'
        K=0.001;
    case 'm^2'
        K=1;
    case 'cm^2'
        K=0.01*0.01;
    case 'mm^2'
        K=0.001*0.001;
    end
end
function Answer=ValidCableDATA(DATA,CheckType)


    Answer=false;

    ComputationFields={'R','L','C','WB','frequency','length','comments'};
    WBfields={'YcPls','YcRes','YcstD','Hpls','HRes','tau','Ng','NH','Nc','NYc','NYc_res','NH_res','R','L','C','Frequency'};
    MinimalRequiredFields={'configuration','cables','types','pipe','crossbondTheSheaths','frequency','frequencyRange','length','groundResistivity','comments'};
    CablesFields={'Vdist','Hdist','R_out','type','phase'};
    TypesFields={'conductors'};
    ConductorsFields={'R_in','R_out','Rho','MUE','MUE_IN','EPS_IN','LFCT_IN'};
    PipeFields={'R_in','R_out','R_ext','V_dpth','Rho','MUE','MUE_in','EPS_in','LFCT_in','MUE_out','EPS_out','LFCT_out','phase'};

    if isstruct(DATA)
        switch CheckType

        case 'ToComputeRLCWB'
            if all(isfield(DATA,MinimalRequiredFields))
                if all(isfield(DATA.cables,CablesFields))
                    if all(isfield(DATA.types,TypesFields))
                        if all(isfield(DATA.pipe,PipeFields))
                            if all(isfield(DATA.types(1).conductors,ConductorsFields))

                                Answer=true;


                            end
                        end
                    end
                end
            end

        case 'ToUseRLCWB'
            if all(isfield(DATA,ComputationFields))
                if all(isfield(DATA.WB,WBfields))

                    Answer=true;


                end
            end
        end
    end
end