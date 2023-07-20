function calculateSegmentLength(obj)




    actualSampleRate=obj.SampleRate;
    if strcmp(obj.FrequencyResolutionMethod,'RBW')
        actualSampleRate=obj.pActualSampleRate;
        desiredRBW=getRBW(obj);




        ENBW=getENBW(obj,1000);

        segLen=ceil(ENBW*obj.pActualSampleRate/desiredRBW);


        count=1;
        segLenVect=segLen;
        while(count<100)
            ENBW=round(getENBW(obj,ceil(segLen))*1e8)/1e8;
            new_segLen=ceil(ENBW*actualSampleRate/desiredRBW);
            err=abs(new_segLen-segLen);
            if(err==0)
                segLen=new_segLen;
                break
            end
            if~any(segLenVect==new_segLen)
                segLenVect=[segLenVect,new_segLen];%#ok<AGROW>
                segLen=new_segLen;
                count=count+1;
            else



                L=length(segLenVect);
                computed_RBW=zeros(L,1);
                for ind=1:L

                    computed_RBW(ind)=getENBW(obj,segLenVect(ind))*actualSampleRate/segLenVect(ind);
                end


                RBWErr=abs(desiredRBW-computed_RBW);
                [~,ind_min]=min(RBWErr);
                segLen=segLenVect(ind_min);
                break
            end
        end
    elseif strcmp(obj.FrequencyResolutionMethod,'WindowLength')

        segLen=obj.WindowLength;
    else

        segLen=obj.pNFFT;
    end
    obj.pSegmentLength=segLen;
    obj.ActualRBW=getENBW(obj,segLen)*actualSampleRate/segLen;
end
