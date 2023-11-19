function MaskWSValues=simrfV2_junction_spars(MaskWSValues,isSimStopped)

    switch MaskWSValues.classname
    case 'circulators'
        deviceType=MaskWSValues.DeviceCirculator;
    case 'dividers'
        deviceType=MaskWSValues.DeviceDivider;
    case 'couplers'
        deviceType=MaskWSValues.DeviceCoupler;
    end

    if strcmpi(deviceType,'Wilkinson power divider')
        num_ports=str2double(MaskWSValues.NumberDividerOutports)+1;
    else
        num_ports=str2double(MaskWSValues.NumPorts);
    end


    if isempty(MaskWSValues.SparamZ0)&&isSimStopped
        Z0=ones(1,num_ports)*50;
    else
        Z0=MaskWSValues.SparamZ0;
        if isscalar(Z0)
            Z0=ones(1,num_ports)*Z0;
        end
        validateattributes(Z0,{'numeric'},...
        {'nonempty','row','size',[1,num_ports],'real','positive',...
        'finite'},'Waveguide junction','Reference impedance')
    end
    MaskWSValues.SparamZ0=Z0;

    switch deviceType
    case 'Circulator clockwise'
        MaskWSValues.Sparam=[0,0,1;1,0,0;0,1,0];
        MaskWSValues.SparamRepresentation='Time domain (rationalfit)';
    case 'Circulator counter clockwise'
        MaskWSValues.Sparam=[0,1,0;0,0,1;1,0,0];
        MaskWSValues.SparamRepresentation='Time domain (rationalfit)';
    case 'Tee H-plane (S11=0)'
        MaskWSValues.Sparam=[0,1,0;1,0,0;0,0,1];
        MaskWSValues.SparamRepresentation='Time domain (rationalfit)';
    case 'Reciprocal phase shifter'
        if isempty(MaskWSValues.Phase12)&&isSimStopped
            phase12=0;
        else
            phase12=exp(1i*MaskWSValues.Phase12);
        end
        if isempty(MaskWSValues.Phase33)&&isSimStopped
            phase33=0;
        else
            phase33=exp(1i*MaskWSValues.Phase33);
        end
        MaskWSValues.Sparam=[0,phase12,0;phase12,0,0;0,0,phase33]*...
        (-1i/sqrt(2));
        MaskWSValues.SparamRepresentation='Frequency domain';
    case 'T power divider'
        z1=Z0(1);
        z2=Z0(2);
        z3=Z0(3);
        z12=z1*z2/(z1+z2);
        z13=z1*z3/(z1+z3);
        z23=z2*z3/(z2+z3);
        s11=(z23-z1)/(z23+z1);
        s22=(z13-z2)/(z13+z2);
        s33=(z12-z3)/(z12+z3);
        s21=(1+s11)*sqrt(z1/z2);
        s31=(1+s11)*sqrt(z1/z3);
        s32=(1+s22)*sqrt(z2/z3);
        MaskWSValues.Sparam=[s11,s21,s31;s21,s22,s32;s31,s32,s33];
        MaskWSValues.SparamRepresentation='Time domain (rationalfit)';
    case 'Resistive power divider'
        MaskWSValues.Sparam=[0,1,1;1,0,1;1,1,0]/2;
        MaskWSValues.SparamRepresentation='Time domain (rationalfit)';
    case 'Wilkinson power divider'
        numOutports=str2double(MaskWSValues.NumberDividerOutports);
        sparTerm=-1i/sqrt(numOutports);
        sTerms=zeros(numOutports+1,numOutports+1);
        sTerms(1,2:numOutports+1)=sparTerm;
        sTerms(2:numOutports+1,1)=sparTerm;
        MaskWSValues.Sparam=sTerms;
        MaskWSValues.SparamRepresentation='Frequency domain';
    case 'Tee H-plane (S33=0)'
        sqrt2=sqrt(2);
        MaskWSValues.Sparam=[-1,1,sqrt2;1,-1,sqrt2;sqrt2,sqrt2,0]/2;
        MaskWSValues.SparamRepresentation='Time domain (rationalfit)';
    case 'Tee E-plane'
        sqrt2=sqrt(2);
        MaskWSValues.Sparam=[1,1,sqrt2;1,1,-sqrt2;sqrt2,-sqrt2,0]/2;
        MaskWSValues.SparamRepresentation='Time domain (rationalfit)';
    case 'Directional coupler'
        if isempty(MaskWSValues.Coupling)&&isSimStopped
            coupling=0;
        else
            coupling=MaskWSValues.Coupling;
            validateattributes(coupling,{'numeric'},...
            {'nonempty','scalar','real','nonnegative','nonnan'},...
            'Waveguide junction','Directional coupler Coupling')
        end
        if isempty(MaskWSValues.InsertionLoss)&&isSimStopped
            insertionLoss=inf;
        else
            insertionLoss=MaskWSValues.InsertionLoss;
            validateattributes(insertionLoss,{'numeric'},...
            {'nonempty','scalar','real','nonnegative','nonnan'},...
            'Waveguide junction','Directional coupler Insertion loss')
        end
        if isempty(MaskWSValues.Directivity)&&isSimStopped
            directivity=inf;
        else
            directivity=MaskWSValues.Directivity;
            validateattributes(directivity,{'numeric'},...
            {'nonempty','scalar','real','nonnegative','nonnan'},...
            'Waveguide junction','Directional coupler Directivity')
        end
        if isempty(MaskWSValues.ReturnLoss)&&isSimStopped
            returnLoss=inf;
        else
            returnLoss=MaskWSValues.ReturnLoss;
            validateattributes(returnLoss,{'numeric'},...
            {'nonempty','scalar','real','nonnegative','nonnan'},...
            'Waveguide junction','Directional coupler Return loss')
        end
        il=10^(-insertionLoss/20);
        c=10^(-coupling/20);
        rl=10^(-returnLoss/20);
        is=10^(-(coupling+directivity)/20);
        spars=[rl,il*1i,is*1i,-c;il*1i,rl,-c,is*1i;...
        is*1i,-c,rl,il*1i;-c,is*1i,il*1i,rl];

        validateattributes(ispassive(spars),{'logical'},...
        {'nonempty','real','nonzero','finite'},...
        'Waveguide junction',...
        'passive test for Directional coupler')
        MaskWSValues.Sparam=spars;
        if isreal(spars)
            MaskWSValues.SparamRepresentation='Time domain (rationalfit)';
        else
            MaskWSValues.SparamRepresentation='Frequency domain';
        end
    case 'Coupler symmetrical'

        if isempty(MaskWSValues.Alpha)&&isSimStopped
            alpha=0;
        else
            alpha=MaskWSValues.Alpha;
            validateattributes(alpha,{'numeric'},...
            {'nonempty','scalar','real','>=',0,'<=',1},...
            'Waveguide junction',...
            'Coupler symmetrical Power transmission coefficient')
        end
        jbeta=1i*sqrt(1-alpha*alpha);
        MaskWSValues.Sparam=[0,alpha,0,jbeta;alpha,0,jbeta,0;...
        0,jbeta,0,alpha;jbeta,0,alpha,0];
        if isreal(MaskWSValues.Sparam)
            MaskWSValues.SparamRepresentation=...
            'Time domain (rationalfit)';
        else
            MaskWSValues.SparamRepresentation='Frequency domain';
        end
    case 'Coupler antisymmetrical'

        if isempty(MaskWSValues.Alpha)&&isSimStopped
            alpha=0;
        else
            alpha=MaskWSValues.Alpha;
            validateattributes(alpha,{'numeric'},...
            {'nonempty','scalar','real','>=',0,'<=',1},...
            'Waveguide junction',...
            'Coupler antisymmetrical Power transmission coefficient')
        end
        beta=sqrt(1-alpha*alpha);
        MaskWSValues.Sparam=[0,alpha,0,beta;alpha,0,-beta,0;...
        0,-beta,0,alpha;beta,0,alpha,0];
        if isreal(MaskWSValues.Sparam)
            MaskWSValues.SparamRepresentation=...
            'Time domain (rationalfit)';
        else
            MaskWSValues.SparamRepresentation='Frequency domain';
        end
    case 'Hybrid quadrature (90 deg)'
        MaskWSValues.Sparam=[0,1i,0,1;1i,0,1,0;0,1,0,1i;1,0,1i,0]*...
        (-1/sqrt(2));
        MaskWSValues.SparamRepresentation='Frequency domain';
    case 'Hybrid rat-race'
        MaskWSValues.Sparam=[0,1,0,1;1,0,-1,0;0,-1,0,1;1,0,1,0]*...
        (-1i/sqrt(2));
        MaskWSValues.SparamRepresentation='Frequency domain';
    case 'Magic tee'
        MaskWSValues.Sparam=[0,0,1,1;0,0,1,-1;1,1,0,0;1,-1,0,0]/...
        sqrt(2);
        MaskWSValues.SparamRepresentation='Time domain (rationalfit)';
    end
end