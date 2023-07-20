function[Ts,BlockChoice,MaskType,varargout]=ExcitationSystemInit(block,Ts,varargin)








    [BlockChoice,Ts,~,CheckErrors]=DetermineBlockChoice(block,Ts,0,0);

    MaskType=get_param(block,'MaskType');

    if CheckErrors
        SanityCheck(block,MaskType,varargin);
    else

        varargout=num2cell(1:nargout);
        return
    end


    inputs=[varargin{:}];


    switch MaskType

    case 'Excitation System'


        varargout=num2cell(inputs(1:end));

    case 'AC1A Excitation System'



        Ke=inputs(3);
        Ve1=inputs(9);
        Ve2=inputs(10);
        SeVe1=inputs(11);
        SeVe2=inputs(12);
        Kc=inputs(17);
        Kd=inputs(18);
        Efd0=inputs(20);

        Ifd0=Efd0;
        Ve0=Ifd0*(1+Kc*0.577);
        Vfe0=Ve0*interp1([0,Ve2,Ve1],[0,SeVe2,SeVe1],Ve0)+Ke*Ve0+Kd*Efd0;

        varargout=num2cell([inputs(1:16),Efd0,Ve0,Vfe0,inputs(19:20)]);

    case 'AC4A Excitation System'



        varargout=num2cell(inputs(1:10));

    case{'AC5A Excitation System','DC1A Excitation System','DC2A Excitation System'}





        varargout=num2cell(inputs(1:16));

        Ke=inputs(3);
        Efd1=inputs(9);
        Efd2=inputs(10);
        SeEfd1=inputs(11);
        SeEfd2=inputs(12);
        v0=varargin{end};


        varargout{end+1}=v0(2)*interp1([0,Efd2,Efd1],[0,SeEfd2,SeEfd1],v0(2))+Ke*v0(2);

    case 'ST1A Excitation System'



        ILR=inputs(16);
        KLR=inputs(17);
        Efd0=inputs(19);

        Ifd0=Efd0;
        VA0=Efd0+KLR*(Ifd0-ILR);

        varargout=num2cell([inputs(1:14),Efd0,VA0,inputs(18:19)]);

    case 'ST2A Excitation System'



        Ke=inputs(3);
        I0=inputs(9);
        Kc=inputs(10);
        KI=inputs(11);
        Kp=inputs(12);
        Xd=inputs(13);
        Vt0=inputs(14);
        Efd0=inputs(15);

        Efdmax=2.75*Xd;
        It0=I0(1);
        Ifd0=Efd0;
        Ve0=sqrt((Kp*Vt0)^2+(KI*It0)^2);
        VB0=Ve0-0.577*Kc*Efd0;
        VR0=(Ke*Efd0)/(VB0);

        varargout=num2cell([inputs(1:8),Efdmax,I0,Ifd0,Ve0,VB0,VR0,inputs(14:15)]);

    end

    function SanityCheck(block,MaskType,In)

        switch MaskType

        case 'AC1A Excitation System'

            errorVector(In{1},'[Ka Ta]',[1,2],block);
            errorVector(In{2},'[Ke Te]',[1,2],block);
            errorVector(In{3},'[Kf Tf]',[1,2],block);
            errorVector(In{4},'[Tb Tc]',[1,2],block);
            errorVector(In{5},'[Ve1 Ve2]',[1,2],block);
            errorVector(In{6},'[SeVe1 SeVe2]',[1,2],block);
            errorVector(In{7},'[VRmin VRmax]',[1,2],block);
            errorVector(In{8},'[VAmin VAmax]',[1,2],block);
            errorScalar(In{9},'Kc',block);
            errorScalar(In{10},'Kd',block);
            errorVector(In{11},'[Vto Efd0]',[1,2],block);

        case 'AC4A Excitation System'

            errorVector(In{1},'[Ka Ta]',[1,2],block);
            errorVector(In{2},'[Tb Tc]',[1,2],block);
            errorVector(In{3},'[VRmin VRmax]',[1,2],block);
            errorVector(In{4},'[VImin VImax]',[1,2],block);
            errorVector(In{5},'[Vto Efd0]',[1,2],block);

        case 'AC5A Excitation System'

            errorVector(In{1},'[Ka Ta]',[1,2],block);
            errorVector(In{2},'[Ke Te]',[1,2],block);
            errorVector(In{3},'[Kf Tf1 Tf2 Tf3]',[1,4],block);
            errorVector(In{4},'[Efd1 Efd2]',[1,2],block);
            errorVector(In{5},'[SeEfd1 SeEfd2]',[1,2],block);
            errorVector(In{6},'[VRmin VRmax]',[1,2],block);
            errorVector(In{6},'[Vto Efd0]',[1,2],block);

        case{'DC1A Excitation System','DC2A Excitation System'}

            errorVector(In{1},'[Ka Ta]',[1,2],block);
            errorVector(In{2},'[Ke Te]',[1,2],block);
            errorVector(In{3},'[Kf Tf]',[1,2],block);
            errorVector(In{4},'[Tb Tc]',[1,2],block);
            errorVector(In{5},'[Efd1 Efd2]',[1,2],block);
            errorVector(In{6},'[SeEfd1 SeEfd2]',[1,2],block);
            errorVector(In{7},'[VRmin VRmax]',[1,2],block);
            errorVector(In{8},'[Vto Efd0]',[1,2],block);

        case 'ST1A Excitation System'

            errorVector(In{1},'[Ka Ta]',[1,2],block);
            errorVector(In{2},'[Kf Tf]',[1,2],block);
            errorVector(In{3},'[Tb Tc Tb1 Tc1]',[1,4],block);
            errorVector(In{4},'[VRmin VRmax]',[1,2],block);
            errorVector(In{5},'[VImin VImax]',[1,2],block);
            errorVector(In{6},'[VAmin VAmax]',[1,2],block);
            errorScalar(In{7},'Kc',block);
            errorScalar(In{8},'ILR',block);
            errorScalar(In{9},'KLR',block);
            errorVector(In{10},'[Vto Efd0]',[1,2],block);

        case 'ST2A Excitation System'

            errorVector(In{1},'[Ka Ta]',[1,2],block);
            errorVector(In{2},'[Ke Te]',[1,2],block);
            errorVector(In{3},'[Kf Tf]',[1,2],block);
            errorVector(In{4},'[VRmin VRmax]',[1,2],block);
            errorScalar(In{5},'IO',block);
            errorScalar(In{6},'Kc',block);
            errorScalar(In{7},'KI',block);
            errorScalar(In{8},'Kp',block);
            errorScalar(In{9},'Xd',block);
            errorVector(In{10},'[Vto Efd0]',[1,2],block);
        end
