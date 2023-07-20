function tune_param=tunedesign(BackingStructure,Exciter)









    check={'reflector','cavity','cavityCircular','reflectorCircular'...
    ,'reflectorCorner','reflectorGrid'};

    backingtype=strcmpi(BackingStructure,check);

    tune_param=0;


    switch Exciter
    case 'loopCircular'
        if backingtype(1)||backingtype(3)||backingtype(4)
            tune_param=-0.025;
        end
    case 'loopRectangular'
        if backingtype(1)||backingtype(3)||backingtype(4)
            tune_param=-0.04;
        end
    case 'monopole'
        if backingtype(2)
            tune_param=0.05;
        end
    case 'spiralEquiangular'
        if backingtype(1)||backingtype(2)||backingtype(4)...
            ||backingtype(5)
            tune_param=0.07;
        elseif backingtype(3)
            tune_param=0.09;
        end
    case 'spiralArchimedean'
        if backingtype(3)
            tune_param=-0.03;
        elseif backingtype(5)
            tune_param=-0.04;
        end
    case 'invertedFcoplanar'
        if backingtype(1)||backingtype(4)||backingtype(5)
            tune_param=-0.04;
        end
    case 'dipoleMeander'
        if backingtype(1)||backingtype(3)||backingtype(4)
            tune_param=-0.03;
        end
    case 'dipoleFolded'
        if backingtype(1)
            tune_param=-0.03;
        elseif backingtype(2)
            tune_param=-0.01;
        elseif backingtype(3)
            tune_param=-0.04;
        elseif backingtype(4)
            tune_param=-0.035;
        elseif backingtype(5)
            tune_param=-0.015;
        end
    case 'invertedF'
        if backingtype(2)
            tune_param=0.03;
        end
    case 'invertedLcoplanar'
        if backingtype(2)
            tune_param=-0.03;
        end
    case 'dipoleBlade'
        if backingtype(4)||backingtype(5)
            tune_param=0.03;
        end
    case{'biquad'}
        if backingtype(1)||backingtype(5)
            tune_param=0.08;
        elseif backingtype(4)
            tune_param=0.04;
        elseif backingtype(6)
            tune_param=0.022;
        end
    case{'rhombic'}
        if backingtype(1)||backingtype(5)||backingtype(3)||backingtype(4)
            tune_param=0.06;
        elseif backingtype(6)
            tune_param=0.035;
        end
    case 'slot'
        if backingtype(2)
            tune_param=-0.010;
        elseif backingtype(3)
            tune_param=-0.0250;
        elseif backingtype(4)
            tune_param=0.005;
        elseif backingtype(5)
            tune_param=-0.03;
        elseif backingtype(1)
            tune_param=-0.003;
        end
    case 'fractalKoch'
        if backingtype(1)||backingtype(3)||backingtype(4)
            tune_param=-0.01;
        end
    case 'fractalGasket'
        if backingtype(2)||backingtype(3)
            tune_param=-0.04;
        end
    case 'patchMicrostrip'
        if backingtype(1)||backingtype(3)||backingtype(4)...
            ||backingtype(5)
            tune_param=0.03;
        elseif backingtype(2)
            tune_param=0.05;
        end
    case 'patchMicrostripInsetfed'
        if backingtype(1)||backingtype(3)||backingtype(4)...
            ||backingtype(5)
            tune_param=0.01;
        end
    case 'pifa'
        if backingtype(3)
            tune_param=-0.06;
        end
    case 'fractalCarpet'
        if backingtype(2)
            if isunix&&~ismac
                tune_param=0.005;
            else
                tune_param=-0.02;
            end
        end
    case 'helix'
        if backingtype(1)||backingtype(3)||backingtype(4)
            if ismac
            else
                tune_param=0.03;
            end
        elseif backingtype(5)
            tune_param=0.03;
        end






    case 'yagiUda'
        if backingtype(5)
            tune_param=0.01;
        else
            tune_param=0.04;
        end
    case 'monocone'
        if backingtype(3)
            tune_param=0.05;
        end
        if backingtype(2)
            tune_param=0.05;
        end








    case 'sectorInvertedAmos'
        if backingtype(1)||backingtype(4)||backingtype(5)
            tune_param=-0.04;
        elseif backingtype(2)
            tune_param=-0.01;
        elseif backingtype(3)
            tune_param=-0.03;
        end
    case 'waveguideRidge'
        if backingtype(1)||backingtype(4)||backingtype(5)
            tune_param=-0.06;
        end
    case 'waveguideSlotted'
        if backingtype(4)
            tune_param=-0.02;
        end
    case 'bowtieTriangular'
        if backingtype(3)
            tune_param=-0.10;
        end
    case 'bowtieRounded'
        if backingtype(3)
            tune_param=-0.13;
        end
    case 'waveguideCircular'
        if backingtype(3)
            tune_param=0.07;
        elseif backingtype(2)
            tune_param=-0.04;
        end
    end

end
