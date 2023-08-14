function[CarrFreqSorted,PhNoFreq,phNoLevIntNorm,...
    step,phNoOffFull,phNoLevFull,stepSource]=...
    simrfV2getphasenoise(block,MaskWSValues,CarrierFreq,step)





    if nargin<4
        MaskWSValues=simrfV2getblockmaskwsvalues(block);


        if isfield(MaskWSValues,'LOFreq')
            CarrierFreq=MaskWSValues.LOFreq;
            CarrierFreq_unit=MaskWSValues.LOFreq_unit;
            AutoImpulseLength=strcmp(MaskWSValues.AutoImpulseLengthPN,'on');
            ImpulseLength=MaskWSValues.ImpulseLengthPN;
            ImpulseLength_unit=MaskWSValues.ImpulseLength_unitPN;
        else
            CarrierFreq=MaskWSValues.CarrierFreq;
            CarrierFreq_unit=MaskWSValues.CarrierFreq_unit;
            AutoImpulseLength=MaskWSValues.AutoImpulseLength;
            ImpulseLength=MaskWSValues.ImpulseLength;
            ImpulseLength_unit=MaskWSValues.ImpulseLength_unit;
        end
        CarrierFreq=simrfV2checkfreqs(CarrierFreq,'gtez');
        CarrierFreq=simrfV2convert2baseunit(CarrierFreq,CarrierFreq_unit);
        top_sys=bdroot(block);
        [~,solverblock,~,~,~,step]=...
        simrfV2_find_solverparams(top_sys,block,true,true);
    else
        AutoImpulseLength=MaskWSValues.AutoImpulseLength;
        ImpulseLength=MaskWSValues.ImpulseLength;
        ImpulseLength_unit=MaskWSValues.ImpulseLength_unit;
    end

    phNoLevFull=MaskWSValues.PhaseNoiseLevel;
    phNoOffFull=MaskWSValues.PhaseNoiseOffset;


    validateattributes(phNoOffFull,{'numeric'},...
    {'nonempty','2d','positive','finite'},'',...
    'Phase noise frequency offsets');
    validateattributes(phNoLevFull,{'numeric'},...
    {'nonempty','2d','real'},'',...
    'Phase noise level');
    if any(size(phNoOffFull)~=size(phNoLevFull))
        error(message(['simrf:simrfV2errors:'...
        ,'MatrixSizeNotSameAs'],...
        'Phase noise frequency offsets',...
        'Phase noise level'))
    end

    if(size(phNoOffFull,1)==1)
        phNoLevFull=phNoLevFull';
        phNoOffFull=phNoOffFull';
    end
    [CarrFreqSorted,CarrFreqSortInd]=...
    sort(CarrierFreq(CarrierFreq~=0));
    carrNum=length(CarrFreqSorted);



    if((size(phNoOffFull,2)==1)&&(carrNum>1))
        phNoOffFull=repmat(phNoOffFull,1,carrNum);
        phNoLevFull=repmat(phNoLevFull,1,carrNum);
    end

    if nargin<4&&isempty(solverblock)
        step=1/estimateSampleRate(phNoOffFull);
        stepSource='Estimated Sample Rate';
    else
        stepSource='Configuration block Envelope Bandwidth';
    end



    if(any(phNoLevFull(:)~=-inf))

        if(size(phNoOffFull,2)~=carrNum)


            if(carrNum==0)


                error(message(['simrf:simrfV2errors:'...
                ,'PhaseNoiseDataInDC'],block))
            else

                error(message(['simrf:simrfV2errors:'...
                ,'PhaseNoiseColumnsNotEqCarr'],block))
            end
        end

        maxDuraton=0;
        for carrInd=1:carrNum
            carrierIndUnsorted=CarrFreqSortInd(carrInd);
            phNoOffHalf=phNoOffFull(:,carrierIndUnsorted);
            phNoOffHalf=simrfV2checkparam(phNoOffHalf,...
            'Phase noise frequency offset','gtez');

            if(length(phNoOffHalf)~=...
                length(unique(phNoOffHalf)))
                error(message(['simrf:simrfV2errors:'...
                ,'FreqsNotUnique'],...
                'Phase noise frequency offsets'))
            end


            if(max(phNoOffHalf)>1/(2*step))
                error(message(['simrf:simrfV2errors:'...
                ,'FreqsOutOfBand'],...
                'Phase noise frequency offsets'))
            end



            maxDuraton=max(maxDuraton,...
            2/min(diff([0;phNoOffHalf])));
        end

        impTSLenMAX=pow2(16);

        impTSLenMIN=pow2(7);
        if AutoImpulseLength


            impTSLen=max(1,floor(maxDuraton/step+0.5));
            impTSLen=2^ceil(log2(impTSLen));

            impTSLen=max(impTSLenMIN,impTSLen);
            if impTSLen>impTSLenMAX
                impTSLen=impTSLenMAX;
                [maxDuratonVal,~,maxDuratonUnitstr]=...
                engunits(impTSLen*step);
                warning(message(['simrf:simrfV2errors:'...
                ,'OffsetFreqsResolutionTooHighAuto'],...
                block,num2str(maxDuratonVal,['%g '...
                ,maxDuratonUnitstr,'s'])));
            end
        else
            validateattributes(ImpulseLength,{'numeric'},...
            {'nonempty','scalar','real','finite'},'',...
            'Phase noise impulse response duration');
            impulse_length=simrfV2convert2baseunit(ImpulseLength,...
            ImpulseLength_unit);
            if(impulse_length<0)
                error(message(['simrf:'...
                ,'simrfV2errors:'...
                ,'NegativePhNoiseImpulseLength'],block));
            end
            impTSLen=max(1,floor(impulse_length/step+0.5));
            impTSLen=2^ceil(log2(impTSLen));

            if ssc_rf_set_global_parameter('estimatememory')
                memData=memory;
                if impTSLen*carrNum>memData.MaxPossibleArrayBytes/8/200




                    error(message(['simrf:'...
                    ,'simrfV2errors:'...
                    ,'PhNoiseImpulseLengthTooLong'],block));
                end
            elseif impTSLen>impTSLenMAX
                error(message(['simrf:'...
                ,'simrfV2errors:'...
                ,'PhNoiseImpulseLengthTooLong'],block));
            end




            if maxDuraton/2>(step*impTSLen)
                [maxDuratonVal,~,maxDuratonUnitstr]=...
                engunits(maxDuraton/2);
                warning(message(['simrf:simrfV2errors:'...
                ,'OffsetFreqsResolutionTooHigh'],...
                block,num2str(maxDuratonVal,['%g '...
                ,maxDuratonUnitstr,'s'])));
            end
        end





        if(impTSLen==1)
            phNoOffHalfInt=min(min(phNoOffFull));
            impTSLen=2;
        else
            phNoOffHalfInt=(1:(impTSLen/2))/(impTSLen*step);
        end
        PhNoFreq=zeros(carrNum,impTSLen);
        phNoLevIntNorm=zeros(carrNum,impTSLen);
        for carrInd=1:carrNum
            carrierIndUnsorted=CarrFreqSortInd(carrInd);
            phNoOffHalf=phNoOffFull(:,carrierIndUnsorted);
            phNoOffHalf=simrfV2checkparam(phNoOffHalf,...
            'Phase noise frequency offset','gtez');

            if(length(phNoOffHalf)~=...
                length(unique(phNoOffHalf)))
                error(message(['simrf:simrfV2errors:'...
                ,'FreqsNotUnique'],...
                'Phase noise frequency offsets'))
            end


            if(max(phNoOffHalf)>1/(2*step))
                error(message(['simrf:simrfV2errors:'...
                ,'FreqsOutOfBand'],...
                'Phase noise frequency offsets'))
            end
            phNoLevHalf=phNoLevFull(:,carrierIndUnsorted);


            if any((~isfinite(phNoLevHalf))&...
                ((phNoLevHalf~=-inf)))
                error(message(['simrf:simrfV2errors:'...
                ,'PhaseNoiseLevelIsInf']))
            end
            maxOffIntFreq=phNoOffHalfInt(end)+...
            2/(impTSLen*step);



            [phNoOffHalf,phNoOffHalfInd]=sort(phNoOffHalf);
            phNoLevHalf=phNoLevHalf(phNoOffHalfInd);
            if(phNoOffHalfInt(1)<min(phNoOffHalf))

                extrapPhNoLev=phNoLevHalf(1);



                phNoLevHalfInt=interp1(...
                log10([phNoOffHalfInt(1),phNoOffHalf'...
                ,maxOffIntFreq]),[extrapPhNoLev...
                ,phNoLevHalf',phNoLevHalf(end)],...
                log10(phNoOffHalfInt));
            else
                phNoLevHalfInt=interp1(...
                log10([phNoOffHalf',maxOffIntFreq]),...
                [phNoLevHalf',phNoLevHalf(end)],...
                log10(phNoOffHalfInt));
            end
            phNoOffInt=[-fliplr(phNoOffHalfInt),0...
            ,phNoOffHalfInt(1:end-1)];
            phNoLevInt=[fliplr(phNoLevHalfInt)...
            ,phNoLevHalfInt(1),phNoLevHalfInt(1:end-1)];
            PhNoFreq(carrInd,:)=phNoOffInt;
            phNoLevIntNorm(carrInd,:)=(10.^(phNoLevInt/10));
        end
    else
        PhNoFreq=[];
        phNoLevIntNorm=[];
    end

end

function sampleRate=estimateSampleRate(freqOffsets)
    sampleRate=2.5*max(freqOffsets,[],'all');
end