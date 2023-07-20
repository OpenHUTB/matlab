function[ClsdLpFuelMult,ClsdLpFuelIntgBias]=autoblksclfuelcontrol(ClsdLpFuelEn,OpenLpDitherEn,LambdaCmd,O2MeasVoltSen,ClsdLpFuelRearTrimBias,ClsdLpFuelAdaptBias,ClsdLpFuelAdaptOfsVolt,ClsdLpFuelPGain,ClsdLpFuelIGain,ClsdLpFuelIntgLmt,UpdatePeriod,LambdaDitherAmp,LambdaDitherFrq,O2ResetStoichVoltSen,O2ResetMinVoltSen,O2ResetMaxVoltSen,O2LearnUpdatePerSen,O2AmpMinVoltSen,O2ReadyVoltSen,O2NotReadyVoltSen)
%#codegen
    coder.allowpcode('plain');


    persistent RichCount;
    persistent LeanCount;
    persistent DitherCount;
    persistent O2VoltLearnTimeSen;
    persistent O2OfsVoltSen;
    persistent O2StoichVoltSen;
    persistent O2MinVoltSen;
    persistent O2MaxVoltSen;
    persistent O2ReadySen;
    persistent O2VoltLastSen;
    persistent ClsdLpFuelIntgLast;


    if isempty(RichCount)
        RichCount=0;
        LeanCount=0;
        DitherCount=0;
        O2VoltLearnTimeSen=0;
        O2OfsVoltSen=0;
        O2StoichVoltSen=O2ResetStoichVoltSen;
        O2MinVoltSen=O2ResetMaxVoltSen;
        O2MaxVoltSen=O2ResetMinVoltSen;
        O2ReadySen=0;
        O2VoltLastSen=0;
        ClsdLpFuelIntgLast=0;
    end



    if O2MeasVoltSen>=O2NotReadyVoltSen
        O2ReadySen=0;
    end

    if O2MeasVoltSen<O2ReadyVoltSen
        O2ReadySen=1;
    end


    O2VoltSen=O2MeasVoltSen-O2OfsVoltSen;
    ClsdLpFuelMult=1;
    ClsdLpFuelDitherMult=1;


    DitherPeriodCounts=1/(UpdatePeriod*LambdaDitherFrq);

    if OpenLpDitherEn||(ClsdLpFuelEn&&O2ReadySen&&(abs(LambdaCmd-1)<LambdaDitherAmp))

        if DitherCount>DitherPeriodCounts
            DitherCount=1;
        end

        ClsdLpFuelDitherMult=1+LambdaDitherAmp*sin(2*pi*LambdaDitherFrq*DitherCount*UpdatePeriod);
        DitherCount=DitherCount+1;

    else

        DitherCount=1;

    end

    if(ClsdLpFuelEn&&O2ReadySen&&(abs(LambdaCmd-1)<LambdaDitherAmp))


        LeanCountTarget=(pi-asin(-(LambdaCmd-1)/LambdaDitherAmp))/(2*pi*UpdatePeriod*LambdaDitherFrq);
        RichCountTarget=DitherPeriodCounts-LeanCountTarget;


        if O2VoltSen>O2StoichVoltSen

            if O2VoltLastSen<=O2StoichVoltSen
                RichCount=1;
                if LeanCount<LeanCountTarget
                    ClsdLpFuelError=1;
                else
                    if RichCount>RichCountTarget
                        ClsdLpFuelError=1;
                    else
                        ClsdLpFuelError=0;
                    end
                end
            else
                RichCount=RichCount+1;
                if RichCount>RichCountTarget
                    ClsdLpFuelError=1;
                else
                    ClsdLpFuelError=0;
                end
            end

        elseif O2VoltSen<O2StoichVoltSen

            if O2VoltLastSen>=O2StoichVoltSen
                LeanCount=1;
                if RichCount<RichCountTarget
                    ClsdLpFuelError=-1;
                else
                    if LeanCount>LeanCountTarget
                        ClsdLpFuelError=-1;
                    else
                        ClsdLpFuelError=0;
                    end
                end
            else
                LeanCount=LeanCount+1;
                if LeanCount>LeanCountTarget
                    ClsdLpFuelError=-1;
                else
                    ClsdLpFuelError=0;
                end
            end

        else

            ClsdLpFuelError=0;

        end


        if O2MeasVoltSen>O2MaxVoltSen
            O2MaxVoltSen=O2MeasVoltSen;
        end

        if O2MeasVoltSen<O2MinVoltSen
            O2MinVoltSen=O2MeasVoltSen;
        end

        if O2VoltLearnTimeSen>=O2LearnUpdatePerSen
            O2VoltLearnTimeSen=0;
            if(O2MaxVoltSen-O2MinVoltSen)>O2AmpMinVoltSen
                O2OfsVoltSen=O2MinVoltSen;
                O2StoichVoltSen=(O2MaxVoltSen-O2MinVoltSen)/2;
            end
            O2MinVoltSen=O2ResetMaxVoltSen;
            O2MaxVoltSen=O2ResetMinVoltSen;
        else
            O2VoltLearnTimeSen=O2VoltLearnTimeSen+UpdatePeriod;
        end


        ClsdLpFuelIntg=ClsdLpFuelIntgLast+ClsdLpFuelIGain*ClsdLpFuelError*UpdatePeriod;
        if ClsdLpFuelIntg>ClsdLpFuelIntgLmt
            ClsdLpFuelIntg=ClsdLpFuelIntgLmt;
        elseif ClsdLpFuelIntg<-ClsdLpFuelIntgLmt
            ClsdLpFuelIntg=-ClsdLpFuelIntgLmt;
        end
        ClsdLpFuelMult=ClsdLpFuelDitherMult-(ClsdLpFuelPGain*ClsdLpFuelError+ClsdLpFuelIntg)-ClsdLpFuelRearTrimBias-ClsdLpFuelAdaptBias;
        ClsdLpFuelIntgBias=ClsdLpFuelIntg;

    else
        ClsdLpFuelMult=ClsdLpFuelDitherMult-ClsdLpFuelAdaptBias;
        ClsdLpFuelIntgLast=0;
        ClsdLpFuelIntgBias=0.;
        O2VoltLearnTimeSen=0.;
        O2OfsVoltSen=ClsdLpFuelAdaptOfsVolt;
        O2StoichVoltSen=O2ResetStoichVoltSen;
        O2ReadySen=0;
    end

end
