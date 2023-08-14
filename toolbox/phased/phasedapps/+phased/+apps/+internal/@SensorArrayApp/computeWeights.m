function w=computeWeights(obj)





    if~obj.IsSubarray
        nE=getNumElements(obj.CurrentArray);
    else
        nE=getNumSubarrays(obj.CurrentArray);
    end

    Freq=obj.SignalFrequencies;
    Steerang=obj.SteeringAngle;
    Phasebits=getCurrentPhaseQuanBits(obj);

    if any(any(Steerang~=0))
        NumSA=size(Steerang,2);
        NumF=length(Freq);
        NumPSB=length(Phasebits);


        [Steerang,Freq,Phasebits]=obj.makeEqualLength(...
        Steerang,Freq,Phasebits,NumSA,NumF,NumPSB);


        [NumRefPlots,RefPlotAtEndFlag]=...
        obj.computeNumReferencePlots(Phasebits,NumSA,NumF,NumPSB);

        if NumRefPlots>0
            SV_ref=phased.SteeringVector('SensorArray',obj.CurrentArray,...
            'PropagationSpeed',obj.PropagationSpeed,...
            'NumPhaseShifterBits',0);
        end

        w=zeros(nE,length(Freq)+NumRefPlots);
        w_indx=1;


        if(NumPSB==1)
            SV=phased.SteeringVector('SensorArray',obj.CurrentArray,...
            'PropagationSpeed',obj.PropagationSpeed,...
            'NumPhaseShifterBits',Phasebits(1));
            for idx=1:length(Freq)
                w(:,w_indx)=step(SV,Freq(idx),Steerang(:,idx));
                w_indx=w_indx+1;

                if Phasebits(idx)>0
                    w(:,w_indx)=step(SV_ref,Freq(idx),Steerang(:,idx));
                    w_indx=w_indx+1;
                end
            end
        else
            for idx=1:length(Freq)
                SV=phased.SteeringVector('SensorArray',obj.CurrentArray,...
                'PropagationSpeed',obj.PropagationSpeed,...
                'NumPhaseShifterBits',Phasebits(idx));
                w(:,w_indx)=step(SV,Freq(idx),Steerang(:,idx));
                w_indx=w_indx+1;

                if Phasebits(idx)>0&&(NumRefPlots>0)&&...
                    ((~RefPlotAtEndFlag)||((RefPlotAtEndFlag)&&...
                    (idx==length(Freq))))
                    w(:,w_indx)=step(SV_ref,Freq(idx),Steerang(:,idx));
                    w_indx=w_indx+1;
                end
            end
        end

    else
        w=ones(nE,length(Freq));
    end
end
