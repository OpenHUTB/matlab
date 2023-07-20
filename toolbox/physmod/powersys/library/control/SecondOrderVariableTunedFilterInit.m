function[WantBlockChoice,Ts,sps]=SecondOrderVariableTunedFilterInit(varargin)






    sps=[];

    block=varargin{1};

    if size(varargin,2)>5

        [FilterType,Fo,Zeta,Initialize,Par_Init,Vdc,Ts]=varargin{2:end};

    else

        MV=get_param(block,'MaskVisibilities');
        if strcmp(get_param(block,'Initialize'),'on')
            MV{6}='on';
            MV{7}='on';
        else
            MV{6}='off';
            MV{7}='off';
        end
        set_param(block,'MaskVisibilities',MV)
        return;

    end

    switch FilterType
    case 1,
        sps.X=[0,1,2,3,4];
        sps.Y=[-1.5,-1.5,-2.75,-4,-4];
    case 2,
        sps.X=[0,1,2,3,4];
        sps.Y=[-4,-4,-2.75,-1.5,-1.5];
    case 3,
        sps.X=[0,1,2,3,4,5];
        sps.Y=[-3,-3,-1.5,-1.5,-3,-3];
    case 4,
        sps.X=[0,1,2,3,4,5];
        sps.Y=[-1.5,-1.5,-3,-3,-1.5,-1.5];
    end

    [WantBlockChoice,Ts,~,Init]=DetermineBlockChoice(block,Ts,0,0);

    if Init

        Erreur.identifier='SpecializedPowerSystems:SecondOrderVariableTunedFilterBlock:ParameterError';
        BK=strrep(block,char(10),char(32));

        if any(Fo<=0)
            Erreur.message=sprintf('Parameter error in the ''%s'' block: The Initial cut-off frequencies must be >0.',BK);
            psberror(Erreur);
            return
        end

        if length(Fo)~=length(Zeta)
            Erreur.message=sprintf('Parameter error in the ''%s'' block: The length of the "Initial cut-off frequency" and "Damping factor" vectors must be the same.',BK);
            psberror(Erreur);
            return
        end

        if Initialize&&size(Par_Init,2)~=3
            Erreur.message=sprintf('Parameter error in the ''%s'' block: The number of columns of the "AC initial input" matrix must be 3.',BK);
            psberror(Erreur);
            return
        end

        if Initialize&&~(length(Fo)==size(Par_Init,1)||length(Fo)==1||size(Par_Init,1)==1)
            Erreur.message=sprintf('Parameter error in the ''%s'' block: The number of lines of the "AC initial input" matrix must be 1 or equal to the length of the "Initial cut-off frequency" and "Damping factor" vectors.',BK);
            psberror(Erreur);
            return
        end

        if Initialize&&~(length(Fo)==length(Vdc)||length(Fo)==1||length(Vdc)==1)
            Erreur.message=sprintf('Parameter error in the ''%s'' block: The length of the "DC initial input" vector must be 1 or equal to the length of the "Cut-off frequency" and "Damping factor" vectors.',BK);
            psberror(Erreur);
            return
        end

        if Initialize&&~(size(Par_Init,1)==length(Vdc))
            Erreur.message=sprintf('Parameter error in the ''%s'' block: The number of lines of the "AC initial input" matrix and the length of the "DC initial input" vector must correspond to the size of the input signal.',BK);
            psberror(Erreur);
        end

        sps.FilterType=FilterType;
        sps.Zeta=Zeta;
        sps.Correction=3.549e6*Ts*Ts/60/60/60;


        if Initialize==1
            Vin=(Par_Init(:,1).*(cos(Par_Init(:,2)*pi/180)+1i*sin(Par_Init(:,2)*pi/180))).';
            Wo=2*pi*Fo;
            W=2*pi*Par_Init(:,3).';
            R=2.*Zeta.*Wo;
            L=1;
            C=1./Wo.^2;
            I=Vin./(R+1i*W*L-1i./C./W);
            sps.Iinit=imag(I);
            sps.VL=imag(I*1i.*W.*L);
            sps.VC=imag(I.*-1i./W./C)+Vdc;
        else
            sps.VC=0;
            sps.VL=0;
            sps.Iinit=0;
        end
    end
