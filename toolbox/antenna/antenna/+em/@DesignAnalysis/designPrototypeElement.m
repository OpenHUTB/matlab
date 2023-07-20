function designObj=designPrototypeElement(obj,freq,varargin)




    validateattributes(freq,{'numeric'},...
    {'nonempty','scalar','nonnan','finite','real','positive',},...
    'design','frequency');
    em.MeshGeometry.checkFrequency(freq);

    if isprop(obj,'Substrate')&&~isscalar(obj.Substrate.EpsilonR)
        error(message('antenna:antennaerrors:InvalidDesign'));
    end

    if(isempty(varargin))
        tune_param=0;
    else
        tune_param=varargin{1};
    end
    antObjCopy=copy(obj);
    objtype=class(antObjCopy);
    lambda=physconst('lightspeed')/freq;
    switch objtype
    case 'dipole'
        antObjCopy.Length=0.47*lambda;
        antObjCopy.Width=lambda/100;
    case 'dipoleFolded'
        antObjCopy.Length=0.465*(1+tune_param)*lambda;
        antObjCopy.Width=lambda/200;
        antObjCopy.Spacing=lambda/150;
    case 'dipoleBlade'
        antObjCopy.Length=0.272*lambda;
        antObjCopy.Width=0.33*(1+tune_param)*lambda;
        antObjCopy.TaperLength=0.268*lambda;
        antObjCopy.FeedGap=0.007*lambda;
        antObjCopy.FeedWidth=0.007*lambda;
    case 'dipoleCrossed'
        antObjCopy.Element=design(antObjCopy.Element,freq);
        if isa(antObjCopy.Element,'bowtieTriangular')
            antObjCopy.Element.FlareAngle=45;
            antObjCopy.Element.Length=0.3402*lambda;
        elseif isa(antObjCopy.Element,'bowtieRounded')
            antObjCopy.Element.FlareAngle=45;
            antObjCopy.Element.Length=0.345*lambda;
        elseif isa(antObjCopy.Element,'dipoleBlade')
            antObjCopy.Element.Length=0.2562*lambda;
            antObjCopy.Element.TaperLength=0.2442*lambda;
            antObjCopy.Element.Width=0.1401*lambda;
            antObjCopy.Element.FeedWidth=0.001*lambda;
            antObjCopy.Element.FeedGap=.007*lambda;
        end
    case 'bowtieTriangular'
        antObjCopy.Length=0.265*(1+tune_param)*lambda;
    case 'bowtieRounded'
        antObjCopy.Length=0.32*(1+tune_param)*lambda;
    case 'biquad'
        antObjCopy.ArmLength=0.28*(1+tune_param)*lambda;
        antObjCopy.ArmElevation=45;
        antObjCopy.Width=.0095*lambda;
        if antObjCopy.NumLoops==4
            antObjCopy.ArmLength=0.4*lambda;
        end
    case 'cavity'
        antObjCopy=copy(antObjCopy);
        em.DesignAnalysis.chkvaliddesign(class(antObjCopy.Exciter));

        if isa(antObjCopy.Exciter,'dipole')
            antObjCopy.Exciter.Length=0.4228*lambda;
            antObjCopy.Exciter.Width=0.014*lambda;
            antObjCopy.Exciter.Tilt=90;
            antObjCopy.Exciter.TiltAxis='Y';
            antObjCopy.Length=0.5637*lambda;
            antObjCopy.Width=0.5637*lambda;
            antObjCopy.Height=0.2114*lambda;
            antObjCopy.Spacing=0.2114*lambda;

        elseif isa(antObjCopy.Exciter,'dipoleCylindrical')
            antObjCopy.Exciter.Length=0.47*lambda;
            antObjCopy.Exciter.Radius=0.0093*lambda;
            antObjCopy.Exciter.Tilt=90;
            antObjCopy.Exciter.TiltAxis='Y';
            antObjCopy.Length=0.5637*lambda;
            antObjCopy.Width=0.5637*lambda;
            antObjCopy.Height=0.2114*lambda;
            antObjCopy.Spacing=0.28*lambda;

        elseif isa(antObjCopy.Exciter,'rhombic')
            tune_param=em.DesignAnalysis.tunedesign(class(antObjCopy),...
            class(antObjCopy.Exciter));

            antObjCopy.Exciter=designPrototypeElement(antObjCopy.Exciter,...
            freq,tune_param);
            antObjCopy.Exciter.Tilt=0;
            antObjCopy.Exciter.TiltAxis='X';
            antObjCopy.Length=1.8*lambda;
            antObjCopy.Width=1.8*lambda;
            antObjCopy.Height=0.26*lambda;
            antObjCopy.Spacing=0.26*lambda;
        else
            tune_param=em.DesignAnalysis.tunedesign(class(antObjCopy),...
            class(antObjCopy.Exciter));

            antObjCopy.Exciter=designPrototypeElement(antObjCopy.Exciter...
            ,freq,tune_param);

            d=findMaxLinearDistance(antObjCopy.Exciter);
            L=0.8*lambda;
            W=0.8*lambda;
            h=0.25*lambda;
            if 2*d>L
                L=1.01*2*d;
            end
            if 2*d>W
                W=1.01*2*d;
            end
            antObjCopy.Length=L;
            antObjCopy.Width=W;
            antObjCopy.Height=h;
            antObjCopy.Spacing=h;
            fixBackingStructureSpacing(antObjCopy,freq);
        end
    case 'dipoleMeander'
        antObjCopy.Width=.005*lambda;
        antObjCopy.ArmLength=[0.04,0.04,0.04,0.032]...
        *(1+tune_param)*lambda;
        antObjCopy.NotchLength=0.02*lambda;
        antObjCopy.NotchWidth=0.02*lambda;
    case 'dipoleVee'
        antObjCopy.ArmLength=0.2431*lambda.*[1,1];
        antObjCopy.ArmElevation=[45,45];
        antObjCopy.Width=0.0243*lambda;
    case 'dipoleHelix'
        eps_r=antObjCopy.Substrate.EpsilonR;
        lambda_g=lambda/sqrt(eps_r);
        if~(eps_r==1)
            antObjCopy.Radius=0.1205*lambda_g;
            antObjCopy.Width=0.0055*lambda_g;
            antObjCopy.Turns=3;
            antObjCopy.Spacing=0.1917*lambda_g;
        else
            antObjCopy.Radius=0.1143*lambda;
            antObjCopy.Width=0.0105*lambda;
            antObjCopy.Turns=15;
            antObjCopy.Spacing=0.1595*lambda;
            antObjCopy.WindingDirection='CW';
        end
    case 'invertedL'
        antObjCopy.Height=lambda/12.9;
        antObjCopy.Width=lambda/90.4;
        antObjCopy.Length=lambda/5.83;
        antObjCopy.GroundPlaneLength=lambda/1.8;
        antObjCopy.GroundPlaneWidth=lambda/1.8;
    case 'invertedF'
        antObjCopy=invertedF;
        antObjCopy.Height=lambda/12.35;
        antObjCopy.Width=lambda/90;
        antObjCopy.LengthToOpenEnd=(1+tune_param)*lambda/5.58;
        antObjCopy.LengthToShortEnd=lambda/28.85;
        antObjCopy.GroundPlaneLength=lambda/1.73;
        antObjCopy.GroundPlaneWidth=lambda/1.73;
    case 'helix'
        eps_r=antObjCopy.Substrate.EpsilonR;
        lambda_g=lambda/sqrt(eps_r);
        if~(eps_r==1)
            antObjCopy.Radius=0.2410*lambda_g;
            antObjCopy.Width=0.0110*lambda_g;
            antObjCopy.Turns=3;
            antObjCopy.Spacing=0.3834*lambda_g;
            antObjCopy.GroundPlaneRadius=0.8216*lambda_g;
        else
            antObjCopy.Radius=0.2121*lambda;
            antObjCopy.Width=(1+tune_param)*0.008485*lambda;
            antObjCopy.Turns=3;
            antObjCopy.Spacing=0.297*lambda;
            antObjCopy.GroundPlaneRadius=0.63644*lambda;
        end
    case 'loopCircular'
        antObjCopy.Radius=0.1737*(1+tune_param)*lambda;
        antObjCopy.Thickness=0.0055*lambda;
    case 'loopRectangular'
        antObjCopy.Length=0.3556*(1+tune_param)*lambda;
        antObjCopy.Width=0.1778*lambda;
        antObjCopy.Thickness=0.0018*lambda;
    case 'monopole'
        antObjCopy.Height=0.47*(1+tune_param)*lambda/2;
        antObjCopy.Width=lambda/100;
        antObjCopy.GroundPlaneLength=lambda/2;
        antObjCopy.GroundPlaneWidth=lambda/2;
    case 'monopoleTopHat'
        eps_r=antObjCopy.Substrate.EpsilonR;
        num=numel(eps_r);
        if num>1
            error(message('antenna:antennaerrors:InvalidDesign'));
        end
        lambda_g=lambda/sqrt(eps_r);
        if~(eps_r==1)
            antObjCopy.Height=0.2921*lambda_g;
            antObjCopy.Width=0.0029*lambda_g;
            antObjCopy.GroundPlaneLength=0.5842*lambda_g;
            antObjCopy.GroundPlaneWidth=0.5842*lambda_g;
            antObjCopy.TopHatLength=0.073*lambda_g;
            antObjCopy.TopHatWidth=0.073*lambda_g;
        else
            antObjCopy.Height=0.1487*lambda;
            antObjCopy.Width=0.00148*lambda;
            antObjCopy.GroundPlaneLength=0.2975*lambda;
            antObjCopy.GroundPlaneWidth=0.2975*lambda;
            antObjCopy.TopHatLength=0.037192*lambda;
            antObjCopy.TopHatWidth=0.037192*lambda;
        end
    case 'patchMicrostrip'
        eps_r=antObjCopy.Substrate.EpsilonR;
        lambda_g=lambda/sqrt(eps_r);
        L=lambda_g/2;
        h=lambda_g/100;
        W=1.25*L;
        if eps_r>1
            scale=0.97;
        else
            scale=0.96;
        end
        antObjCopy.Length=scale*(1+tune_param)*L;
        antObjCopy.Width=W;
        antObjCopy.GroundPlaneLength=2.0*L;
        antObjCopy.GroundPlaneWidth=2.0*L;
        antObjCopy.Height=h;
        antObjCopy.FeedOffset=[antObjCopy.Length/4.75,0];
    case 'pifa'
        antObjCopy.Length=0.2335*(1+tune_param)*lambda;
        antObjCopy.Width=0.1557*lambda;
        antObjCopy.FeedWidth=0.0156*lambda;
        antObjCopy.Height=0.0778*lambda;
        antObjCopy.GroundPlaneLength=0.2802*lambda;
        antObjCopy.GroundPlaneWidth=0.2802*lambda;
        antObjCopy.ShortPinWidth=0.1557*lambda;
        antObjCopy.FeedOffset=[-0.0156*lambda,0];
    case 'reflector'
        antObjCopy=copy(antObjCopy);
        em.DesignAnalysis.chkvaliddesign(class(antObjCopy.Exciter));

        if isa(antObjCopy.Exciter,'dipole')
            antObjCopy.Exciter.Length=0.4403*lambda;
            antObjCopy.Exciter.Width=0.0147*lambda;
            antObjCopy.Exciter.Tilt=90;
            antObjCopy.Exciter.TiltAxis='Y';
            antObjCopy.GroundPlaneLength=0.5871*lambda;
            antObjCopy.GroundPlaneWidth=0.5871*lambda;
            antObjCopy.Spacing=0.2202*lambda;
        elseif isa(antObjCopy.Exciter,'dipoleCylindrical')
            antObjCopy.Exciter.Length=0.47*lambda;
            antObjCopy.Exciter.Radius=0.0093*lambda;
            antObjCopy.Exciter.Tilt=90;
            antObjCopy.Exciter.TiltAxis='Y';
            antObjCopy.GroundPlaneLength=0.5871*lambda;
            antObjCopy.GroundPlaneWidth=0.5871*lambda;
            antObjCopy.Spacing=0.3*lambda;
        elseif isa(antObjCopy.Exciter,'rhombic')
            tune_param=em.DesignAnalysis.tunedesign(class(antObjCopy),...
            class(antObjCopy.Exciter));

            antObjCopy.Exciter=designPrototypeElement(antObjCopy.Exciter,...
            freq,tune_param);
            antObjCopy.Exciter.Tilt=0;
            antObjCopy.Exciter.TiltAxis='X';
            antObjCopy.GroundPlaneLength=2*lambda;
            antObjCopy.GroundPlaneWidth=2*lambda;
            antObjCopy.Spacing=0.26*lambda;

        else
            tune_param=em.DesignAnalysis.tunedesign(class(antObjCopy),...
            class(antObjCopy.Exciter));

            antObjCopy.Exciter=designPrototypeElement(antObjCopy.Exciter,...
            freq,tune_param);

            d=findMaxLinearDistance(antObjCopy.Exciter);
            L=0.9*lambda;
            W=0.9*lambda;
            h=0.26*lambda;
            if 2*d>L
                L=1.01*2*d;
            end
            if 2*d>W
                W=1.01*2*d;
            end
            antObjCopy.GroundPlaneLength=L;
            antObjCopy.GroundPlaneWidth=W;
            antObjCopy.Spacing=h;
            fixBackingStructureSpacing(antObjCopy,freq);
        end
    case 'spiralArchimedean'

        antObjCopy.OuterRadius=(1+tune_param)*lambda/1.875;
        antObjCopy.InnerRadius=lambda/75;
    case 'spiralEquiangular'

        antObjCopy.GrowthRate=0.45;
        antObjCopy.InnerRadius=0.0464*lambda;
        antObjCopy.OuterRadius=0.4450*(1+tune_param)*lambda;
    case 'slot'
        antObjCopy.Length=0.47*(1+tune_param)*lambda;
        antObjCopy.Width=lambda/20;
        antObjCopy.GroundPlaneLength=lambda/1.5;
        antObjCopy.GroundPlaneWidth=lambda/1.5;
    case 'vivaldi'
        if antObjCopy.OpeningRate==0

            antObjCopy.TaperLength=2.4695*lambda;
            antObjCopy.ApertureWidth=1.0671*lambda;
            antObjCopy.SlotLineWidth=0.0051*lambda;
            antObjCopy.CavityDiameter=0.2439*lambda;
            antObjCopy.CavityToTaperSpacing=0.2337*lambda;
            antObjCopy.GroundPlaneLength=3.0488*lambda;
            antObjCopy.GroundPlaneWidth=1.2703*lambda;
            antObjCopy.FeedOffset=-1.062*lambda;
        else


            antObjCopy.TaperLength=2.4236*lambda;
            antObjCopy.ApertureWidth=1.04*lambda;
            antObjCopy.OpeningRate=15/(9*lambda);
            antObjCopy.SlotLineWidth=0.0050*lambda;

            antObjCopy.CavityDiameter=0.2394*lambda;
            antObjCopy.CavityToTaperSpacing=0.2294*lambda;
            antObjCopy.GroundPlaneLength=2.9921*lambda;
            antObjCopy.GroundPlaneWidth=1.2467*lambda;
            antObjCopy.FeedOffset=-1.0*lambda;
        end

    case 'vivaldiAntipodal'
        eps_r=antObjCopy.Substrate.EpsilonR;
        lambda_g=lambda/sqrt(eps_r);
        L=lambda_g*3.9883;
        h=lambda_g*0.01;
        antObjCopy.BoardLength=(1+tune_param)*L;
        antObjCopy.BoardWidth=lambda_g*2.3689;
        antObjCopy.Height=h;
        antObjCopy.InnerTaperLength=3.695*lambda_g;
        antObjCopy.ApertureWidth=1.6568*lambda_g;
        antObjCopy.OpeningRate=25;
        antObjCopy.StripLineWidth=0.0225*lambda_g;
        antObjCopy.OuterTaperLength=1.5789*lambda_g;
        antObjCopy.Substrate.Thickness=h;
        antObjCopy.GroundPlaneWidth=0.9862*lambda_g;


    case 'yagiUda'
        antObjCopy=yagiUda;
        antObjCopy.Exciter=dipoleFolded;
        antObjCopy.Exciter.Length=0.4358*lambda;
        antObjCopy.Exciter.Width=0.0111*lambda;
        antObjCopy.Exciter.Spacing=.0057*lambda;
        antObjCopy.NumDirectors=6;
        antObjCopy.DirectorLength=0.3783*lambda;
        antObjCopy.DirectorSpacing=0.3153*lambda;
        antObjCopy.ReflectorLength=0.4637*(1+tune_param)*lambda;
        antObjCopy.ReflectorSpacing=0.2318*lambda;
    case 'waveguide'
        antObjCopy.Length=0.9847*lambda;
        antObjCopy.Width=0.9379*lambda;
        antObjCopy.Height=0.4168*lambda;
        antObjCopy.FeedWidth=.0025*lambda;
        antObjCopy.FeedHeight=0.2462*lambda;
        antObjCopy.FeedOffset=[-0.2462*lambda,0];
    case 'horn'
        antObjCopy.FlareLength=1.649174*lambda;
        antObjCopy.FlareWidth=2.192283*lambda;
        antObjCopy.FlareHeight=1.932170*lambda;
        antObjCopy.Length=1.093923*lambda;
        antObjCopy.Width=0.875022*lambda;
        antObjCopy.Height=0.437452*lambda;
        antObjCopy.FeedWidth=cylinder2strip(0.014009*lambda/2);
        antObjCopy.FeedHeight=(lambda/4)-lambda/60;
        antObjCopy.FeedOffset=[-0.321055*lambda,0];
    case 'invertedLcoplanar'
        antObjCopy.Height=lambda/12.9;
        antObjCopy.RadiatorArmWidth=lambda/90.4;
        antObjCopy.FeederArmWidth=lambda/90.4;
        antObjCopy.Length=(1+tune_param)*lambda/6.2;
        antObjCopy.GroundPlaneLength=lambda/1.8;
        antObjCopy.GroundPlaneWidth=lambda/1.8;
    case 'invertedFcoplanar'
        antObjCopy.Height=lambda/15;
        antObjCopy.RadiatorArmWidth=lambda/90;
        antObjCopy.FeederArmWidth=lambda/90;
        antObjCopy.ShortingArmWidth=lambda/90;
        antObjCopy.LengthToOpenEnd=(1+tune_param)*lambda/5.75;
        antObjCopy.LengthToShortEnd=lambda/28.85;
        antObjCopy.GroundPlaneLength=lambda/1.73;
        antObjCopy.GroundPlaneWidth=lambda/1.73;
    case 'dipoleCycloid'
        antObjCopy.Length=lambda*0.1953;
        antObjCopy.Width=lambda*0.0081;
        antObjCopy.Gap=lambda*0.0064;
        antObjCopy.LoopRadius=lambda*0.0496;
    case 'sectorInvertedAmos'
        antObjCopy.ArmWidth=.0327*lambda;
        antObjCopy.ArmLength=[0.7201,0.58,0.597,0.53]*lambda;
        antObjCopy.NotchLength=0.1948*lambda*(1+tune_param);
        antObjCopy.NotchWidth=0.1391*lambda;
        antObjCopy.GroundPlaneLength=2*(0.5*antObjCopy.ArmLength(1)+...
        sum(antObjCopy.ArmLength(2:end))+(numel(antObjCopy.ArmLength)-1)...
        *antObjCopy.NotchLength)*1.02;
        antObjCopy.GroundPlaneWidth=0.6138*lambda;
        antObjCopy.Spacing=0.27*lambda;
    case 'cavityCircular'
        antObjCopy=copy(antObjCopy);
        em.DesignAnalysis.chkvaliddesign(class(antObjCopy.Exciter));

        if isa(antObjCopy.Exciter,'dipole')
            antObjCopy.Exciter.Length=0.4228*lambda;
            antObjCopy.Exciter.Width=0.014*lambda;
            antObjCopy.Exciter.Tilt=90;
            antObjCopy.Exciter.TiltAxis='Y';
            antObjCopy.Radius=0.3*lambda;
            antObjCopy.Height=0.2114*lambda;
            antObjCopy.Spacing=0.2114*lambda;
        elseif isa(antObjCopy.Exciter,'dipoleCylindrical')
            antObjCopy.Exciter.Length=0.4228*lambda;
            antObjCopy.Exciter.Radius=0.0093*lambda;
            antObjCopy.Exciter.Tilt=90;
            antObjCopy.Exciter.TiltAxis='Y';
            antObjCopy.Radius=0.3*lambda;
            antObjCopy.Height=0.2114*lambda;
            antObjCopy.Spacing=0.25*lambda;
        elseif isa(antObjCopy.Exciter,'rhombic')
            tune_param=em.DesignAnalysis.tunedesign(class(antObjCopy),...
            class(antObjCopy.Exciter));
            antObjCopy.Exciter=designPrototypeElement(antObjCopy.Exciter,...
            freq,tune_param);
            antObjCopy.Exciter.Tilt=0;
            antObjCopy.Exciter.TiltAxis='X';
            antObjCopy.Radius=1.8*lambda/2;
            antObjCopy.Height=0.26*lambda;
            antObjCopy.Spacing=0.26*lambda;
        else
            tune_param=em.DesignAnalysis.tunedesign(class(antObjCopy),...
            class(antObjCopy.Exciter));

            antObjCopy.Exciter=designPrototypeElement(antObjCopy.Exciter,...
            freq,tune_param);

            d=findMaxLinearDistance(antObjCopy.Exciter);
            R=0.8*lambda/2;
            h=0.25*lambda;
            if d>R
                R=1.01*d;
            end
            antObjCopy.Radius=R;
            antObjCopy.Height=h;
            antObjCopy.Spacing=h;
            fixBackingStructureSpacing(antObjCopy,freq);
        end
    case 'reflectorCircular'
        antObjCopy=copy(antObjCopy);
        em.DesignAnalysis.chkvaliddesign(class(antObjCopy.Exciter));

        if isa(antObjCopy.Exciter,'dipole')
            antObjCopy.Exciter.Length=0.4403*lambda;
            antObjCopy.Exciter.Width=0.014*lambda;
            antObjCopy.Exciter.Tilt=90;
            antObjCopy.Exciter.TiltAxis='Y';
            antObjCopy.GroundPlaneRadius=0.4*lambda;
            antObjCopy.Spacing=0.2*lambda;
        elseif isa(antObjCopy.Exciter,'rhombic')
            tune_param=em.DesignAnalysis.tunedesign(class(antObjCopy),...
            class(antObjCopy.Exciter));
            antObjCopy.Exciter=designPrototypeElement(antObjCopy.Exciter,...
            freq,tune_param);
            antObjCopy.Exciter.Tilt=0;
            antObjCopy.Exciter.TiltAxis='X';
            antObjCopy.GroundPlaneRadius=1.2*lambda/2;
            antObjCopy.Spacing=0.26*lambda;
        elseif isa(antObjCopy.Exciter,'dipoleCylindrical')
            antObjCopy.Exciter.Length=0.47*lambda;
            antObjCopy.Exciter.Radius=lambda/107;
            antObjCopy.Exciter.Tilt=90;
            antObjCopy.Exciter.TiltAxis='Y';
            antObjCopy.GroundPlaneRadius=0.4*lambda;
            antObjCopy.Spacing=0.3*lambda;
        else
            tune_param=em.DesignAnalysis.tunedesign(class(antObjCopy),...
            class(antObjCopy.Exciter));

            antObjCopy.Exciter=designPrototypeElement(antObjCopy.Exciter,...
            freq,tune_param);

            d=findMaxLinearDistance(antObjCopy.Exciter);
            h=0.26*lambda;
            R=0.9*lambda/2;
            if d>R
                R=1.01*d;
            end
            antObjCopy.GroundPlaneRadius=R;
            antObjCopy.Spacing=h;
            fixBackingStructureSpacing(antObjCopy,freq);
        end
    case 'patchMicrostripCircular'
        eps_r=antObjCopy.Substrate.EpsilonR;
        lambda_g=lambda/sqrt(eps_r);
        L=lambda_g/2;
        h=lambda_g/50;
        antObjCopy.Radius=L*0.59;
        antObjCopy.GroundPlaneLength=2*L;
        antObjCopy.GroundPlaneWidth=2*L;
        antObjCopy.Height=h;
        antObjCopy.FeedOffset=[-antObjCopy.Radius/2,0];
    case 'patchMicrostripElliptical'
        eps_r=antObjCopy.Substrate.EpsilonR;
        lambda_g=lambda/sqrt(eps_r);
        L=lambda_g/2;
        h=lambda_g/18;
        antObjCopy.MajorAxis=L*1.155;
        antObjCopy.MinorAxis=L*1.135;
        antObjCopy.GroundPlaneLength=2.1*L;
        antObjCopy.GroundPlaneWidth=2.1*L;
        antObjCopy.Height=h;
        antObjCopy.FeedOffset=[antObjCopy.MajorAxis/4.8,antObjCopy.MajorAxis/4.8];
    case 'patchMicrostripInsetfed'
        eps_r=antObjCopy.Substrate.EpsilonR;
        lambda_g=lambda/sqrt(eps_r);
        L=lambda_g/2.2;
        h=lambda_g/40;
        if eps_r==1
            scale=0.99;
        else
            scale=1.1;
        end
        antObjCopy.Length=scale*(1+tune_param)*L;
        antObjCopy.Width=scale*L;
        antObjCopy.GroundPlaneLength=lambda_g;
        antObjCopy.GroundPlaneWidth=lambda_g;
        antObjCopy.Height=h;
        antObjCopy.FeedOffset=[-lambda_g/2,0];
        antObjCopy.NotchLength=lambda_g/15;
        antObjCopy.NotchWidth=lambda_g/20;
        antObjCopy.StripLineWidth=lambda_g/35;
    case 'cloverleaf'
        antObjCopy.NumPetals=3;
        antObjCopy.PetalLength=0.95*lambda;
        antObjCopy.PetalWidth=lambda/65;
        antObjCopy.FlareAngle=105;
    case 'dipoleJ'
        antObjCopy.RadiatorLength=0.45*lambda;
        antObjCopy.StubLength=0.2379*lambda;
        antObjCopy.Spacing=0.0221*lambda;
        antObjCopy.FeedOffset=-0.3359*lambda;
        antObjCopy.Width=lambda/100;
    case 'patchMicrostripTriangular'
        eps_r=antObjCopy.Substrate.EpsilonR;
        lambda_g=lambda/sqrt(eps_r);
        L=2*lambda_g/3;
        h=lambda_g/25;
        antObjCopy.Side=1.05*L;
        antObjCopy.GroundPlaneLength=1.5*L;
        antObjCopy.GroundPlaneWidth=1.5*L;
        antObjCopy.Height=h;
        antObjCopy.FeedOffset=[0,L*sind(60)/6];
        antObjCopy.FeedDiameter=lambda_g/80;
    case 'dipoleHelixMultifilar'
        antObjCopy.Radius=0.1*lambda;
        antObjCopy.Width=0.008485*lambda;
        antObjCopy.Turns=5;
        antObjCopy.Spacing=0.3*lambda;
    case 'helixMultifilar'
        eps_r=antObjCopy.Substrate.EpsilonR;
        lambda_g=lambda/sqrt(eps_r);
        if~(eps_r==1)
            antObjCopy.Radius=0.1*lambda_g;
            antObjCopy.Width=0.0046*lambda_g;
            antObjCopy.Turns=3;
            antObjCopy.Spacing=0.1611*lambda_g;
            antObjCopy.GroundPlaneRadius=0.3452*lambda_g;
        else
            antObjCopy.Radius=0.19*lambda;
            antObjCopy.Width=0.008485*lambda;
            antObjCopy.Turns=3;
            antObjCopy.Spacing=0.27*lambda;
            antObjCopy.GroundPlaneRadius=0.65*lambda;
        end
    case 'fractalGasket'
        antObjCopy.Side=0.74*(1+tune_param)*lambda;
        antObjCopy.NeckWidth=0.74*1e-2*lambda;
    case 'fractalKoch'
        if strcmpi(antObjCopy.Type,'dipole')
            antObjCopy.Length=0.171*(1+tune_param)*lambda;
            antObjCopy.Width=0.171*1e-2*lambda;
        else
            antObjCopy.Length=0.247*lambda;
            antObjCopy.Width=0.247*1e-2*lambda;
        end
    case 'fractalCarpet'
        eps_r=antObjCopy.Substrate.EpsilonR;
        lambda_g=lambda/sqrt(eps_r);
        L=lambda_g/2.2;
        h=lambda_g/50;
        scale=0.85;
        antObjCopy.Length=scale*(1+tune_param)*L;
        antObjCopy.Width=scale*L;
        antObjCopy.GroundPlaneLength=scale*lambda_g;
        antObjCopy.GroundPlaneWidth=scale*lambda_g;
        antObjCopy.Height=h;
        antObjCopy.FeedOffset=[-antObjCopy.GroundPlaneLength/2,0];
    case 'fractalIsland'
        eps_r=antObjCopy.Substrate.EpsilonR;
        lambda_g=lambda/sqrt(eps_r);
        L=lambda_g/2.2;
        h=lambda_g/50;
        scale=1.1;
        antObjCopy.Length=scale*L;
        antObjCopy.Width=scale*L;
        antObjCopy.GroundPlaneLength=scale*lambda_g;
        antObjCopy.GroundPlaneWidth=scale*lambda_g;
        antObjCopy.Height=h;
        antObjCopy.SlotLength=0.1*scale*L;
        antObjCopy.SlotWidth=0.1*scale*L;
        antObjCopy.StripLineWidth=0.02*scale*L;
    case 'fractalSnowflake'
        eps_r=antObjCopy.Substrate.EpsilonR;
        lambda_g=lambda/sqrt(eps_r);
        if lambda_g==lambda
            scale=1;
        else
            scale=1.1*(lambda_g/lambda);
        end
        antObjCopy.Length=1.245*scale*lambda;
        antObjCopy.GroundPlaneLength=1.383*scale*lambda;
        antObjCopy.GroundPlaneWidth=1.5217*scale*lambda;
        antObjCopy.Height=0.0208*scale*lambda;
        antObjCopy.FeedOffset=[0,0];
        antObjCopy.FractalCenterOffset=[0,0];
        antObjCopy.FeedDiameter=lambda_g/35;
    case 'discone'
        antObjCopy.Height=0.5180*(1+tune_param)*lambda;
        antObjCopy.ConeRadii=[0.0037*lambda,0.2966*lambda];
        antObjCopy.DiscRadius=0.2070*lambda;
        antObjCopy.FeedWidth=0.0030*lambda;
        antObjCopy.FeedHeight=0.0022*lambda;

    case 'waveguideCircular'
        antObjCopy.Radius=0.3429*(1+tune_param)*lambda;
        antObjCopy.Height=0.8571*lambda;
        antObjCopy.FeedWidth=0.1143*lambda;
        antObjCopy.FeedHeight=0.2143*lambda;
        antObjCopy.FeedOffset=0.2857*lambda;

    case 'hornConical'
        antObjCopy.Radius=0.3762*lambda;
        antObjCopy.WaveguideHeight=0.9404*lambda;
        antObjCopy.FeedWidth=0.094*lambda;
        antObjCopy.FeedHeight=0.2351*lambda;
        antObjCopy.FeedOffset=0.3135*lambda;
        antObjCopy.ConeHeight=1.0909*lambda;
        antObjCopy.ApertureRadius=1.0972*lambda;

    case 'hornConicalCorrugated'
        antObjCopy.Radius=0.3557*lambda;
        antObjCopy.WaveguideHeight=0.97*lambda;
        antObjCopy.FeedWidth=0.1293*lambda;
        antObjCopy.FeedHeight=0.2425*lambda;
        antObjCopy.FeedOffset=0.2425*lambda;
        antObjCopy.ConeHeight=3.68*lambda;
        antObjCopy.ApertureRadius=2.4573*lambda;
        antObjCopy.Pitch=0.2231*lambda;

        antObjCopy.FirstCorrugateDistance=0.9409*lambda;
        antObjCopy.CorrugateDepth=0.2328*lambda;
        antObjCopy.CorrugateWidth=0.1261*lambda;
    case 'hornCorrugated'
        antObjCopy.FlareLength=2.4208*lambda;
        antObjCopy.FlareWidth=4.539*lambda;
        antObjCopy.FlareHeight=4.0347*lambda;
        antObjCopy.Length=1.1549*lambda;
        antObjCopy.Width=0.5144*lambda;
        antObjCopy.Height=0.3783*lambda;
        antObjCopy.FeedWidth=cylinder2strip(0.025*lambda)/25;
        antObjCopy.FeedHeight=0.1866*lambda;
        antObjCopy.FeedOffset=[-0.1009*lambda,0*lambda];
        antObjCopy.Pitch=0.3026*lambda;
        antObjCopy.FirstCorrugateDistance=0.8069*lambda;
        antObjCopy.CorrugateDepth=[0.2522*lambda,0.5043*lambda];
        antObjCopy.CorrugateWidth=0.1513*lambda;

    case 'bicone'
        antObjCopy.ConeHeight=0.1630*lambda;
        antObjCopy.NarrowRadius=0.0099*lambda;
        antObjCopy.BroadRadius=0.2926*lambda;
        antObjCopy.FeedHeight=0.0038*lambda;
        antObjCopy.FeedWidth=0.0076*lambda;

    case 'gregorian'
        antObjCopy=copy(antObjCopy);
        antObjCopy.Exciter=design(antObjCopy.Exciter,round(0.95718*freq,1));
        if isa(antObjCopy.Exciter,'hornConical')
            antObjCopy.Exciter.FeedWidth=2.126*antObjCopy.Exciter.FeedWidth;
            antObjCopy.Exciter.Tilt=270;
            antObjCopy.Exciter.TiltAxis=[1,0,0];
            antObjCopy.Radius=[19.5926*lambda,2.037*lambda];
            antObjCopy.FocalLength=[15.6481*lambda,8.7407*lambda];

        end

    case 'waveguideSlotted'
        antObjCopy=copy(antObjCopy);
        WG_a=(lambda/2)+(lambda*0.2682);
        WG_b=WG_a/2;
        pi=3.1416;
        lambda_cutoff=(2*WG_a);
        lambda_WG=1/sqrt(((1/lambda)^2)-((1/(lambda_cutoff))^2));
        G_slot=1.0/antObjCopy.NumSlots;
        new_G1=2.09*(lambda_WG/lambda)*(WG_a/WG_b)*...
        (cos((0.464*pi*lambda)/lambda_WG)-cos(0.464*pi))^2;
        slotLength=0.210324*G_slot^4-0.338065*G_slot^3+...
        0.12712*G_slot^2+0.034433*G_slot+0.48253;
        antObjCopy.Length=5*lambda_WG*(1+tune_param);
        antObjCopy.Width=(lambda/2)+(lambda*0.2);
        antObjCopy.Height=antObjCopy.Width/2;
        antObjCopy.Slot=antenna.Rectangle('Length',(lambda*slotLength),'Width',(antObjCopy.Width*0.0625)/0.9);
        antObjCopy.SlotToTop=lambda_WG/4;
        antObjCopy.SlotSpacing=lambda_WG/2;
        antObjCopy.SlotOffset=(antObjCopy.Width/pi)*sqrt(asin(G_slot/new_G1));
        antObjCopy.FeedWidth=0.016*lambda;
        antObjCopy.FeedHeight=0.2532*lambda;
        antObjCopy.FeedOffset=[-2.96*lambda,0];

    case 'cassegrain'
        antObjCopy=copy(antObjCopy);
        antObjCopy.Exciter=design(antObjCopy.Exciter,round((0.9556*freq),1));
        if isa(antObjCopy.Exciter,'hornConical')
            antObjCopy.Exciter.FeedWidth=2.1265*antObjCopy.Exciter.FeedWidth;
            antObjCopy.Exciter.Tilt=270;
            antObjCopy.Exciter.TiltAxis=[1,0,0];
            antObjCopy.Radius=[19.5926*lambda,2.037*lambda];
            antObjCopy.FocalLength=[15.6481*lambda,8.7407*lambda];

        end

    case 'reflectorCorner'
        antObjCopy=copy(antObjCopy);
        em.DesignAnalysis.chkvaliddesign(class(antObjCopy.Exciter));

        if isa(antObjCopy.Exciter,'dipole')
            antObjCopy.Exciter.Length=0.4403*lambda;
            antObjCopy.Exciter.Width=0.0147*lambda;
            antObjCopy.Exciter.Tilt=90;
            antObjCopy.Exciter.TiltAxis='Y';
            antObjCopy.GroundPlaneLength=0.5871*lambda;
            antObjCopy.GroundPlaneWidth=2*0.5871*lambda;
            antObjCopy.Spacing=0.2202*lambda;
        elseif isa(antObjCopy.Exciter,'dipoleCylindrical')
            antObjCopy.Exciter.Length=0.44*lambda;
            antObjCopy.Exciter.Radius=0.009*lambda;
            antObjCopy.Exciter.Tilt=90;
            antObjCopy.Exciter.TiltAxis='Y';
            antObjCopy.GroundPlaneLength=0.5871*lambda;
            antObjCopy.GroundPlaneWidth=2*0.5871*lambda;
            antObjCopy.Spacing=0.5*lambda;
        elseif isa(antObjCopy.Exciter,'rhombic')
            tune_param=em.DesignAnalysis.tunedesign(class(antObjCopy),...
            class(antObjCopy.Exciter));

            antObjCopy.Exciter=designPrototypeElement(antObjCopy.Exciter,...
            freq,tune_param);
            antObjCopy.Exciter.Tilt=0;
            antObjCopy.Exciter.TiltAxis='X';
            antObjCopy.GroundPlaneLength=1.8*lambda;
            antObjCopy.GroundPlaneWidth=1.8*lambda;
            antObjCopy.Spacing=0.26*lambda;
            antObjCopy.CornerAngle=140;

        else
            tune_param=em.DesignAnalysis.tunedesign(class(antObjCopy),...
            class(antObjCopy.Exciter));

            antObjCopy.Exciter=designPrototypeElement(antObjCopy.Exciter,...
            freq,tune_param);

            d=findMaxLinearDistance(antObjCopy.Exciter);
            L=0.9*lambda;
            W=0.9*lambda;
            h=0.34*lambda;
            if 2*d>L
                L=1.05*2*d;
            end
            if 2*d>W
                W=1.05*2*d;
            end
            antObjCopy.GroundPlaneLength=L;
            antObjCopy.GroundPlaneWidth=W;
            antObjCopy.CornerAngle=140;
            antObjCopy.Spacing=h;
            fixBackingStructureSpacing(antObjCopy,freq);
        end
    case 'reflectorParabolic'
        antObjCopy=copy(antObjCopy);
        antObjCopy.Exciter=design(antObjCopy.Exciter,freq);
        if isa(antObjCopy.Exciter,'dipole')||isa(antObjCopy.Exciter,'dipoleCylindrical')
            antObjCopy.Exciter.Tilt=90;
            antObjCopy.Exciter.TiltAxis='Y';
            antObjCopy.Radius=5*lambda;
            antObjCopy.FocalLength=0.25*(2*antObjCopy.Radius);








        end
    case 'quadCustom'
        antObjCopy=copy(antObjCopy);

        if isa(antObjCopy.Exciter,'dipole')
            antObjCopy.Exciter.Length=0.4424*lambda;
            antObjCopy.Exciter.Width=0.016*lambda;
            antObjCopy.Exciter.Tilt=90;
            antObjCopy.Exciter.TiltAxis='Y';

            for i=1:numel(antObjCopy.Director)
                antObjCopy.Director{i}.Length=0.3936*lambda;
                antObjCopy.Director{i}.Width=0.016*lambda;
                antObjCopy.Director{i}.Tilt=90;
                antObjCopy.Director{i}.TiltAxis='Y';
            end
            antObjCopy.DirectorSpacing=0.33384*lambda;
            for i=1:numel(antObjCopy.Reflector)
                antObjCopy.Reflector{i}.Length=0.492*lambda;
                antObjCopy.Reflector{i}.Width=0.016*lambda;
                antObjCopy.Reflector{i}.Tilt=90;
                antObjCopy.Reflector{i}.TiltAxis='Y';
            end
            antObjCopy.ReflectorSpacing=0.2464*lambda;
            antObjCopy.BoomLength=1.44*lambda;
            antObjCopy.BoomWidth=0.016*lambda;
            antObjCopy.BoomOffset=[0,0.04*lambda,0.36*lambda];
        elseif isa(antObjCopy.Exciter,'dipoleFolded')
            antObjCopy.Exciter.Length=0.4352*lambda;
            antObjCopy.Exciter.Width=0.0112*lambda;
            antObjCopy.Exciter.Spacing=0.0056*lambda;
            for i=1:numel(antObjCopy.Director)
                antObjCopy.Director{i}.Length=0.3784*lambda;
                antObjCopy.Director{i}.Width=0.0112*lambda;
                antObjCopy.Director{i}.Tilt=90;
                antObjCopy.Director{i}.TiltAxis='Y';
            end
            antObjCopy.DirectorSpacing=0.3152*lambda;
            for i=1:numel(antObjCopy.Reflector)
                antObjCopy.Reflector{i}.Length=0.4632*lambda;
                antObjCopy.Reflector{i}.Width=0.0112*lambda;
                antObjCopy.Reflector{i}.Tilt=90;
                antObjCopy.Reflector{i}.TiltAxis='Y';
            end
            antObjCopy.ReflectorSpacing=0.2320*lambda;
            antObjCopy.BoomLength=1.44*lambda;
            antObjCopy.BoomWidth=0.016*lambda;
            antObjCopy.BoomOffset=[0,0.04*lambda,0.36*lambda];
        elseif isa(antObjCopy.Exciter,'loopCircular')
            antObjCopy.Exciter.Radius=(1.2942*lambda)/(6.283);
            antObjCopy.Exciter.Thickness=0.05422*lambda;
            for i=1:numel(antObjCopy.Director)
                antObjCopy.Director{i}.Radius=(1.0899*lambda)/6.28;
                antObjCopy.Director{i}.Thickness=0.05422*lambda;
            end
            antObjCopy.DirectorSpacing=0.162689*lambda;
            for j=1:numel(antObjCopy.Reflector)
                antObjCopy.Reflector{j}.Radius=(1.397*lambda)/6.283;
                antObjCopy.Reflector{j}.Thickness=0.05422*lambda;
            end
            antObjCopy.ReflectorSpacing=0.58568*lambda;
            antObjCopy.BoomLength=1.44*lambda;
            antObjCopy.BoomWidth=0.016*lambda;
            antObjCopy.BoomOffset=[0,0.04*lambda,0.36*lambda];
        elseif isa(antObjCopy.Exciter,'biquad')
            if antObjCopy.Exciter.NumLoops==4
                antObjCopy.Exciter=design(antObjCopy.Exciter,1.105*freq);
            elseif antObjCopy.Exciter.NumLoops==2
                antObjCopy.Exciter=design(antObjCopy.Exciter,1.14*freq);
            end



            antObjCopy.Exciter.Tilt=90;
            for i=1:numel(antObjCopy.Director)
                antObjCopy.Director{i}.ArmLength=antObjCopy.Exciter.ArmLength;
                antObjCopy.Director{i}.ArmElevation=45;
                antObjCopy.Director{i}.Width=antObjCopy.Exciter.Width;
                antObjCopy.Director{i}.Tilt=90;
            end
            antObjCopy.DirectorSpacing=0.24073*lambda;
            for i=1:numel(antObjCopy.Reflector)
                antObjCopy.Reflector{i}.ArmLength=antObjCopy.Exciter.ArmLength;
                antObjCopy.Reflector{i}.ArmElevation=45;
                antObjCopy.Reflector{i}.Width=antObjCopy.Exciter.Width;
                antObjCopy.Reflector{i}.Tilt=90;
            end
            antObjCopy.ReflectorSpacing=0.24073*lambda;
            antObjCopy.BoomLength=1.0799*lambda;
            antObjCopy.BoomWidth=0.016*lambda;
            antObjCopy.BoomOffset=[0,0.04*lambda,0.2699*lambda];
        elseif isa(antObjCopy.Exciter,'loopRectangular')
            antObjCopy.Exciter.Length=0.2560*lambda;
            antObjCopy.Exciter.Width=0.2498*lambda;
            antObjCopy.Exciter.Thickness=0.004515*lambda;
            for i=1:numel(antObjCopy.Director)
                antObjCopy.Director{i}.Length=0.2560*lambda;
                antObjCopy.Director{i}.Width=0.21952*lambda;
                antObjCopy.Director{i}.Thickness=0.004515*lambda;
            end
            antObjCopy.DirectorSpacing=0.14650*lambda;
            for i=1:numel(antObjCopy.Reflector)
                antObjCopy.Reflector{i}.Length=0.2560*lambda;
                antObjCopy.Reflector{i}.Width=0.2882*lambda;
                antObjCopy.Reflector{i}.Thickness=0.004515*lambda;
            end
            antObjCopy.ReflectorSpacing=0.085499*lambda;
            antObjCopy.BoomLength=0.6244*lambda;
            antObjCopy.BoomWidth=antObjCopy.Exciter.Thickness;
            antObjCopy.BoomOffset=[0,0.04*lambda,0.2699*lambda];
        elseif isa(antObjCopy.Exciter,'dipoleVee')
            antObjCopy.Exciter.ArmLength=0.2431*lambda.*[1,1];
            antObjCopy.Exciter.Width=0.005*lambda;
            antObjCopy.Exciter.ArmElevation=[45,45];
            antObjCopy.Exciter.Tilt=90;
            for i=1:numel(antObjCopy.Director)
                antObjCopy.Director{i}.ArmLength=0.1688*lambda.*[1,1];
                antObjCopy.Director{i}.Width=0.005*lambda;
                antObjCopy.Director{i}.ArmElevation=[45,45];
                antObjCopy.Director{i}.Tilt=90;
            end
            antObjCopy.DirectorSpacing=0.128188*lambda;
            for i=1:numel(antObjCopy.Reflector)
                antObjCopy.Reflector{i}.ArmLength=0.2631*lambda.*[1,1];
                antObjCopy.Reflector{i}.Width=0.005*lambda;
                antObjCopy.Reflector{i}.ArmElevation=[45,45];
                antObjCopy.Reflector{i}.Tilt=90;
            end
            antObjCopy.ReflectorSpacing=0.22675*lambda;
            antObjCopy.BoomLength=0.5*lambda;
            antObjCopy.BoomWidth=0.005*lambda;
            antObjCopy.BoomOffset=[0,0.004*lambda,0.005*lambda];
        end

    case 'spiralRectangular'
        antObjCopy.InitialWidth=0.026*lambda;
        antObjCopy.InitialLength=0.039*lambda;
        antObjCopy.Spacing=0.0286*lambda;
        antObjCopy.StripWidth=0.0105*lambda;

        ArmLength=lambda*0.8478;
        nT=rectspirallength2turns(antObjCopy,ArmLength);
        antObjCopy.NumTurns=nT;

    case 'monocone'
        antObjCopy.Radii=[0.0065*lambda,0.14025*lambda,0.14025*lambda];
        antObjCopy.GroundPlaneRadius=0.414375*lambda;
        antObjCopy.ConeHeight=0.146625*lambda;
        antObjCopy.FeedHeight=0.0065*lambda;
        antObjCopy.Height=0.3250*(1+tune_param)*lambda;
        antObjCopy.FeedWidth=0.0065*lambda;

    case 'waveguideRidge'
        antObjCopy.Length=0.6620*(1+tune_param)*lambda;
        antObjCopy.Width=1.2618*lambda;
        antObjCopy.Height=0.7886*lambda;
        antObjCopy.RidgeLength=0.5899*lambda;
        antObjCopy.RidgeWidth=0.0789*lambda;
        antObjCopy.RidgeGap=0.2760*lambda;
        antObjCopy.FeedHoleRadius=0.0158*lambda;
        antObjCopy.FeedHeight=antObjCopy.Height/2+antObjCopy.RidgeGap/2;
        antObjCopy.FeedWidth=.0032*lambda;

        antObjCopy.FeedOffset=[-0.2129*lambda,0];


    case 'hornRidge'
        antObjCopy.FlareLength=6.534066*lambda;
        antObjCopy.FlareWidth=6.71721611*lambda;
        antObjCopy.FlareHeight=6.3446886*lambda;
        antObjCopy.Length=1.96923076*lambda;
        antObjCopy.Width=1.35531135*lambda;
        antObjCopy.Height=0.65018315*lambda;
        antObjCopy.RidgeLength=1.35531135*lambda;
        antObjCopy.RidgeWidth=0.18315018*lambda;
        antObjCopy.RidgeGap=0.25641025*lambda;
        antObjCopy.FeedHoleRadius=0.01831501*lambda;
        antObjCopy.FeedHeight=antObjCopy.Height/2+antObjCopy.RidgeGap/2;
        antObjCopy.FeedWidth=0.00366300366*lambda;
        antObjCopy.FeedOffset=[-0.279120879*lambda,0];

    case 'disconeStrip'
        pi=3.1416;
        antObjCopy.Height=0.6426*lambda;
        antObjCopy.ConeRadii=[0.0319*lambda,0.3979*lambda];
        antObjCopy.DiscRadius=0.3439*lambda;
        antObjCopy.StripWidth=0.0098*lambda;
        NgapRn=0.0827*lambda;
        antObjCopy.NumStrips=round(((2*pi*antObjCopy.ConeRadii(1))-NgapRn)/antObjCopy.StripWidth);
        antObjCopy.FeedWidth=0.0098*lambda;
        antObjCopy.FeedHeight=0.0147*lambda;
    case 'reflectorCylindrical'
        antObjCopy=copy(antObjCopy);
        em.DesignAnalysis.chkvaliddesign(class(antObjCopy.Exciter));
        if isa(antObjCopy.Exciter,'dipole')
            antObjCopy.Exciter.Length=0.4403*lambda;
            antObjCopy.Exciter.Width=0.0147*lambda;
            antObjCopy.Exciter.Tilt=90;
            antObjCopy.Exciter.TiltAxis='Y';
            antObjCopy.GroundPlaneLength=0.5871*lambda;
            antObjCopy.GroundPlaneWidth=0.5871*lambda;
            antObjCopy.Spacing=0.2202*lambda;
            antObjCopy.Depth=0.2202*lambda;
        elseif isa(antObjCopy.Exciter,'dipoleCylindrical')
            antObjCopy.Exciter.Length=0.45*lambda;
            antObjCopy.Exciter.Radius=0.0093*lambda;
            antObjCopy.Exciter.Tilt=90;
            antObjCopy.Exciter.TiltAxis='Y';
            antObjCopy.GroundPlaneLength=0.5871*lambda;
            antObjCopy.GroundPlaneWidth=0.5871*lambda;
            antObjCopy.Spacing=0.25*lambda;
            antObjCopy.Depth=0.25*lambda;

        elseif isa(antObjCopy.Exciter,'rhombic')
            antObjCopy.Exciter.ArmLength=round(0.85822*(1+tune_param)*lambda,4);
            antObjCopy.Exciter.ArmElevation=20;
            antObjCopy.Exciter.Width=round(0.1716*lambda,4);
            antObjCopy.Exciter.Tilt=0;
            antObjCopy.Exciter.TiltAxis='X';
            antObjCopy.GroundPlaneLength=round(2*lambda,12);
            antObjCopy.GroundPlaneWidth=round(2*lambda,12);
            antObjCopy.Spacing=0.2202*lambda;
            antObjCopy.Depth=0.2202*lambda;
        else
            tune_param=em.DesignAnalysis.tunedesign(class(antObjCopy),...
            class(antObjCopy.Exciter));

            antObjCopy.Exciter=designPrototypeElement(antObjCopy.Exciter,...
            freq,tune_param);

            d=findMaxLinearDistance(antObjCopy.Exciter);
            L=0.9*lambda;
            W=0.9*lambda;
            h=0.26*lambda;
            if 2*d>L
                L=1.01*2*d;
            end
            if 2*d>W
                W=1.01*2*d;
            end
            antObjCopy.GroundPlaneLength=L;
            antObjCopy.GroundPlaneWidth=W;
            antObjCopy.Spacing=h;
            antObjCopy.Depth=h;
            fixBackingStructureSpacing(antObjCopy,freq);
        end

    case 'rhombic'
        antObjCopy.ArmLength=3.4*(1+tune_param)*lambda;
        antObjCopy.ArmElevation=20;
        antObjCopy.Width=0.1717*lambda;






    case 'biconeStrip'
        pi=3.1416;
        antObjCopy.StripWidth=0.0218*lambda;
        antObjCopy.HatHeight=0*lambda;
        antObjCopy.ConeHeight=0.8051*lambda;
        antObjCopy.NarrowRadius=0.0847*lambda;
        antObjCopy.BroadRadius=0.7833*lambda;
        NgapRn=0.1838*lambda;
        antObjCopy.NumStrips=round(((2*pi*antObjCopy.NarrowRadius)-NgapRn)/antObjCopy.StripWidth);
        antObjCopy.FeedHeight=0.0545*lambda;
        antObjCopy.FeedWidth=0.0484*lambda;

    case 'patchMicrostripEnotch'
        eps_r=antObjCopy.Substrate.EpsilonR;
        lambda_g=lambda/sqrt(eps_r);
        L=lambda_g/2;
        h=lambda_g/14.03733;
        W=(lambda_g/2)*sqrt(2/(eps_r+1));

        if eps_r>1
            scale=1.1725;
        else
            scale=1;
        end

        antObjCopy.Length=scale*0.85*L;

        if eps_r>1
            antObjCopy.Width=0.4452*lambda_g;
        else
            antObjCopy.Width=0.89048*W;
        end

        antObjCopy.NotchLength=scale*0.22262*lambda_g;
        antObjCopy.NotchWidth=scale*0.02226*lambda_g;
        antObjCopy.CenterArmNotchLength=scale*0.06233*lambda_g;
        antObjCopy.CenterArmNotchWidth=scale*0.13802*lambda_g;
        antObjCopy.Height=scale*h;
        antObjCopy.GroundPlaneLength=scale*0.55655*lambda_g;
        antObjCopy.GroundPlaneWidth=scale*0.66786*lambda_g;
        antObjCopy.PatchCenterOffset=[0,0];
        antObjCopy.FeedOffset=[scale*-0.07569*lambda_g,0];
        antObjCopy.FeedDiameter=scale*0.02894*lambda_g;

    case 'patchMicrostripHnotch'
        eps_r=antObjCopy.Substrate.EpsilonR;
        lambda_g=lambda/sqrt(eps_r);
        L=lambda_g/2;
        h=lambda_g/54.4127;
        W=(lambda_g/2)*sqrt(2/(eps_r+1));

        if eps_r>1
            scale=1.1069;
        else
            scale=1;
        end

        antObjCopy.Length=scale*0.6768*L;

        if eps_r>1
            antObjCopy.Width=scale*0.8715*W;
        else
            antObjCopy.Width=scale*0.7006*W;
        end

        antObjCopy.NotchLength=scale*0.0758*lambda_g;
        antObjCopy.NotchWidth=scale*0.0887*lambda_g;
        antObjCopy.Height=scale*h;
        antObjCopy.GroundPlaneLength=scale*0.5076*lambda_g;
        antObjCopy.GroundPlaneWidth=scale*0.5254*lambda_g;
        antObjCopy.PatchCenterOffset=[0,0];
        antObjCopy.FeedOffset=[scale*-0.02917*lambda_g,scale*-0.0583*lambda_g];
        antObjCopy.FeedDiameter=scale*0.0117*lambda_g;


    case 'reflectorGrid'
        antObjCopy=copy(antObjCopy);
        em.DesignAnalysis.chkvaliddesign(class(antObjCopy.Exciter));

        if isa(antObjCopy.Exciter,'dipole')||isa(antObjCopy.Exciter,'dipoleCylindrical')
            if isa(antObjCopy.Exciter,'dipole')
                antObjCopy.Exciter.Width=0.01*lambda;
            elseif isa(antObjCopy.Exciter,'dipoleCylindrical')
                antObjCopy.Exciter.Radius=0.01*lambda;
            end







            antObjCopy.Exciter.Length=0.4697*lambda;
            antObjCopy.Exciter.Tilt=90;
            antObjCopy.Exciter.TiltAxis='Y';
            antObjCopy.GroundPlaneLength=0.667*lambda;
            antObjCopy.GroundPlaneWidth=0.667*lambda;
            antObjCopy.Spacing=0.5833*lambda;
            if antObjCopy.GroundPlaneLength<antObjCopy.GridWidth
                antObjCopy.GroundPlaneLength=antObjCopy.GridWidth;
            end
            if antObjCopy.GroundPlaneWidth<antObjCopy.GridWidth
                antObjCopy.GroundPlaneWidth=antObjCopy.GridWidth;
            end
        elseif isa(antObjCopy.Exciter,'rhombic')
            tune_param=em.DesignAnalysis.tunedesign(class(antObjCopy),...
            class(antObjCopy.Exciter));






            antObjCopy.Exciter.ArmLength=round(6.666*(1+tune_param)*lambda,4);
            antObjCopy.Exciter.ArmElevation=20;
            antObjCopy.Exciter.Width=round(0.1716*lambda,4);
            antObjCopy.Exciter.Tilt=0;
            antObjCopy.Exciter.TiltAxis='X';
            antObjCopy.GroundPlaneLength=round(2*lambda,4);
            antObjCopy.GroundPlaneWidth=round(2*lambda,4);
            antObjCopy.Spacing=round(0.26*lambda,6);
            antObjCopy.GridSpacing=round(0.0206*lambda,4);
            antObjCopy.GridWidth=round(0.0343*lambda,4);
            if antObjCopy.GroundPlaneLength<antObjCopy.GridWidth
                antObjCopy.GroundPlaneLength=antObjCopy.GridWidth;
            end
            if antObjCopy.GroundPlaneWidth<antObjCopy.GridWidth
                antObjCopy.GroundPlaneWidth=antObjCopy.GridWidth;
            end
        else
            tune_param=em.DesignAnalysis.tunedesign(class(antObjCopy),...
            class(antObjCopy.Exciter));
            antObjCopy.Exciter=designPrototypeElement(antObjCopy.Exciter,...
            freq,tune_param);

            d=findMaxLinearDistance(antObjCopy.Exciter);
            L=0.9*lambda;
            W=0.9*lambda;
            h=0.26*lambda;
            if 2*d>L
                L=1.01*2*d;
            end
            if 2*d>W
                W=1.01*2*d;
            end
            antObjCopy.GroundPlaneLength=L;
            antObjCopy.GroundPlaneWidth=W;
            antObjCopy.Spacing=h;
            antObjCopy.GridType='HV';
            antObjCopy.GridSpacing=0.133*lambda;
            antObjCopy.GridWidth=0.2*lambda;
            fixBackingStructureSpacing(antObjCopy,freq);
        end
    case 'monopoleRadial'
        antObjCopy.Height=0.252*lambda;
        antObjCopy.Width=0.0025*lambda;
        antObjCopy.NumRadials=12;
        antObjCopy.RadialWidth=0.005*lambda;
        antObjCopy.RadialLength=0.71*lambda;
        antObjCopy.RadialTilt=0;

    case 'reflectorSpherical'
        antObjCopy=copy(antObjCopy);
        antObjCopy.Exciter=design(antObjCopy.Exciter,freq);
        if isa(antObjCopy.Exciter,'dipole')
            antObjCopy.Exciter.Tilt=90;
            antObjCopy.Exciter.TiltAxis='Y';
            antObjCopy.Radius=5.005*lambda;
            antObjCopy.Depth=5.005*lambda;
            antObjCopy.FeedOffset(3)=0.5*(antObjCopy.Radius);
        end

    case 'draRectangular'
        eps_r=antObjCopy.Substrate.EpsilonR;
        num=numel(eps_r);
        if num>1
            error(message('antenna:antennaerrors:InvalidDesign'));
        end
        lambda_g=lambda/sqrt(mean(eps_r));
        antObjCopy.ResonatorLength=0.9836*lambda_g;
        antObjCopy.ResonatorWidth=0.4918*lambda_g;

        antObjCopy.GroundPlaneLength=5.2459*lambda_g;
        antObjCopy.GroundPlaneWidth=3.2787*lambda_g;
        antObjCopy.Substrate.Thickness=0.6557*lambda_g;
        antObjCopy.FeedHeight=0.6557*lambda_g;
        antObjCopy.FeedWidth=0.0193*lambda_g;
        if eps_r<5
            antObjCopy.FeedHeight=0.55*lambda_g;
            antObjCopy.Substrate.Thickness=0.55*lambda_g;
            if eps_r<3
                antObjCopy.FeedHeight=0.582*lambda_g;
                antObjCopy.Substrate.Thickness=0.582*lambda_g;
            end
        end
        antObjCopy.FeedOffset=[0,0];













    case 'draCylindrical'













        eps_r=antObjCopy.Substrate.EpsilonR;
        num=numel(eps_r);
        if num>1
            error(message('antenna:antennaerrors:InvalidDesign'));
        end
        lambda_g=lambda/sqrt(eps_r);
        antObjCopy.ResonatorRadius=0.2451*lambda_g;
        antObjCopy.FeedHeight=0.6127*lambda_g;
        antObjCopy.GroundPlaneLength=1.7157*lambda_g;
        antObjCopy.GroundPlaneWidth=0.9804*lambda_g;
        antObjCopy.Substrate.Thickness=antObjCopy.FeedHeight;
        antObjCopy.FeedWidth=0.0123*lambda_g;
        antObjCopy.FeedOffset=[0,0];
    case 'hornPotter'
        antObjCopy.Radius=0.3939*lambda;
        antObjCopy.WaveguideHeight=1.52*lambda;
        antObjCopy.FeedWidth=0.0063*lambda;
        antObjCopy.FeedHeight=0.2343*lambda;
        antObjCopy.FeedOffset=0.38*lambda;
        antObjCopy.ConeHeight=3.0577*lambda;
        antObjCopy.ApertureRadius=0.7929*lambda;
        antObjCopy.TaperHeight=0.6916*lambda;
        antObjCopy.TaperRadius=0.7929*lambda;

    case 'cassegrainOffset'
        antObjCopy=copy(antObjCopy);
        antObjCopy.Exciter=design(antObjCopy.Exciter,round((0.9556*freq),1));
        if isa(antObjCopy.Exciter,'hornConical')

            antObjCopy.Exciter.Tilt=270;
            antObjCopy.Exciter.TiltAxis=[1,0,0];
        end
        antObjCopy.Radius=[20.6183*lambda,3.8567*lambda];
        antObjCopy.FocalLength=29.6667*lambda;
        antObjCopy.MainReflectorOffset=29.6667*lambda;
        antObjCopy.InterAxialAngle=5;
        antObjCopy.DualReflectorSpacing=2.0767*lambda;
        theta0=-2*(atand(obj.MainReflectorOffset/(2*obj.FocalLength)));
        beta=antObjCopy.InterAxialAngle;
        thetaU=-2*(atand((2*antObjCopy.MainReflectorOffset+2*antObjCopy.Radius(1))/(4*antObjCopy.FocalLength)));
        num=1-(-1*sqrt(((tand(beta/2))/(tand((beta-theta0)/2)))));
        den=1+(-1*sqrt(((tand(beta/2))/(tand((beta-theta0)/2)))));
        e=num/den;
        e=abs(e);
        alpha=2*atand((e+1)*(tand(beta/2))/(e-1));
        seg3=((1-e)/(1+e))*(tand((thetaU-beta)/(2)));
        subtilt=-1*((2*(atand(seg3)))-alpha);
        antObjCopy.ReflectorTilt=[abs(theta0),abs(subtilt)];

    case 'gregorianOffset'
        antObjCopy=copy(antObjCopy);
        antObjCopy.Exciter=design(antObjCopy.Exciter,round((0.9556*freq),1));
        if isa(antObjCopy.Exciter,'hornConical')

            antObjCopy.Exciter.Tilt=270;
            antObjCopy.Exciter.TiltAxis=[1,0,0];
        end
        antObjCopy.Radius=[17.76*lambda,3.552*lambda];
        antObjCopy.FocalLength=14.504*lambda;
        antObjCopy.MainReflectorOffset=15.392*lambda;
        antObjCopy.InterAxialAngle=15;
        antObjCopy.DualReflectorSpacing=2.662*lambda;
        theta0=-2*(atand(obj.MainReflectorOffset/(2*obj.FocalLength)));
        beta=antObjCopy.InterAxialAngle;
        thetaU=-2*(atand((2*antObjCopy.MainReflectorOffset+2*antObjCopy.Radius(1))/(4*antObjCopy.FocalLength)));
        num=1-(1*sqrt(((tand(beta/2))/(tand((beta-theta0)/2)))));
        den=1+(1*sqrt(((tand(beta/2))/(tand((beta-theta0)/2)))));
        e=num/den;
        e=abs(e);
        alpha=2*atand((e+1)*(tand(beta/2))/(e-1));
        seg3=((1-e)/(1+e))*(tand((thetaU-beta)/(2)));
        subtilt=-1*((2*(atand(seg3)))-alpha);
        antObjCopy.ReflectorTilt=[abs(theta0),abs(subtilt)];

    case 'monopoleCylindrical'
        antObjCopy.Height=0.234*lambda;
        antObjCopy.Radius=lambda/107;
        antObjCopy.GroundPlaneLength=lambda/2.15;
        antObjCopy.GroundPlaneWidth=lambda/2.15;

    case 'dipoleCylindrical'
        antObjCopy.Length=0.47*lambda;
        antObjCopy.Radius=lambda/107;

    case 'hornScrimp'
        antObjCopy.Radius=0.3897*lambda;
        antObjCopy.WaveguideHeight=0.3333*lambda;
        antObjCopy.FeedWidth=0.004*lambda;
        antObjCopy.FeedHeight=0.2333*lambda;
        antObjCopy.FeedOffset=0.2667*lambda;
        antObjCopy.ConeHeight=0.4827*lambda;
        antObjCopy.ConeRadius=0.544*lambda;
        antObjCopy.StubHeight=0.1947*lambda;
        antObjCopy.ApertureRadius=0.64*lambda;
        antObjCopy.ApertureHeight=0.3333*lambda;


    case 'vivaldiOffsetCavity'
        antObjCopy.TaperLength=5.6*lambda;
        antObjCopy.ApertureWidth=1.066*lambda;
        antObjCopy.OpeningRate=25;
        antObjCopy.TaperedSlotWidth=0.1066*lambda;
        antObjCopy.CrossTaperLength=0.6986*lambda;
        antObjCopy.TaperOffset=-0.3200*lambda;
        antObjCopy.SlotLineWidth=0.0266*lambda;
        antObjCopy.CavityToTaperSpacing=0.5706*lambda;
        if strcmp(antObjCopy.CavityShape,'Rectangular')
            antObjCopy.CavityLength=0.3893*lambda;
            antObjCopy.CavityWidth=0.3520*lambda;
        elseif strcmp(antObjCopy.CavityShape,'Circular')
            antObjCopy.CavityDiameter=0.5333*lambda;
        end
        antObjCopy.GroundPlaneLength=7.466*lambda;
        antObjCopy.GroundPlaneWidth=1.2800*lambda;
        antObjCopy.FeedOffset=-0.1600*lambda;
        antObjCopy.CavityOffset=[0.2560*lambda,0.1600*lambda];
        if obj.OpeningRate==0
            antObjCopy.OpeningRate=0;
        end

    otherwise
        error(message('antenna:antennaerrors:InvalidOption'));

    end
    designObj=antObjCopy;
end

function d=findMaxLinearDistance(elem)
    createGeometry(elem);
    geom=getGeometry(elem);

    if strcmpi(class(elem),'dipoleCrossed')
        [~,dist]=dsearchn([0,0,0],geom{1}.BorderVertices);
    else
        [~,dist]=dsearchn([0,0,0],geom.BorderVertices);
    end
    d=max(dist);
end

function fixBackingStructureSpacing(obj,freq)

    ftest=freq/10;
    if ftest<1e3
        ftest=1e3;
    end
    lambda_test=physconst('lightspeed')/ftest;
    flag=true;
    mesherror=[];

    I=info(obj);
    if strcmpi(I.HasSubstrate,"true")
        d=obj.Substrate;
        dtest=dielectric;
        obj.Substrate=dtest;
    end
    nominalSpacing=obj.Spacing;
    numChks=2;
    chkIndx=1;
    while flag
        try
            [~]=mesh(obj,'MaxEdgeLength',lambda_test);
            chkIndx=chkIndx+1;
            if isempty(mesherror)&&(chkIndx>numChks)
                flag=false;
            end
            if chkIndx<=numChks
                obj.Spacing=1.1*nominalSpacing;
            end
        catch mesherror
            nominalSpacing=1.1*nominalSpacing;
            obj.Spacing=nominalSpacing;
            mesherror=[];
        end
    end

    if strcmpi(I.HasSubstrate,"true")
        obj.Substrate=d;
    end
    meshconfig(obj,'auto');
    setHasStructureChanged(obj);

    clearGeometryData(obj);
    clearMeshData(obj);
    clearSolutionData(obj);

end
