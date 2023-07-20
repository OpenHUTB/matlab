function[timeRes,segLen]=getWinDurationForAGivenRBW(desiredRBW,win,customWin,SLA,Fs)







    ENBW=getENBW(1000,win,customWin,SLA);


    segLen=ceil(ENBW*Fs/desiredRBW);



    count=1;
    segLenVect=segLen;
    while(count<100)
        new_segLen=ceil(getENBW(ceil(segLen),win,customWin,SLA)*Fs/desiredRBW);
        err=abs(new_segLen-segLen);
        if(err==0)
            segLen=new_segLen;
            timeRes=segLen/Fs;
            break;
        end
        if~any(segLenVect==new_segLen)
            segLenVect=[segLenVect,new_segLen];%#ok<AGROW>
            segLen=new_segLen;
            count=count+1;
        else



            L=length(segLenVect);
            computed_RBW=zeros(L,1);
            for ind=1:L

                computed_RBW(ind)=getENBW(segLenVect(ind),win,customWin,SLA)*Fs/segLenVect(ind);
            end


            RBWErr=abs(desiredRBW-computed_RBW);
            [~,ind_min]=min(RBWErr);
            segLen=segLenVect(ind_min);
            timeRes=segLen/Fs;
            break;
        end
    end

    if count==100
        error(message('dspshared:SpectrumAnalyzer:MinTimeResConvergence'));
    end

    function ENBW=getENBW(L,Win,customWin,sideLobeAttn)


        switch Win
        case 'Rectangular'
            ENBW=1;
        case 'Hann'
            w=hann(L);
            ENBW=(sum(w.^2)/sum(w)^2)*L;
        case 'Hamming'
            w=hamming(L);
            ENBW=(sum(w.^2)/sum(w)^2)*L;
        case 'Flat Top'
            w=flattopwin(L);
            ENBW=(sum(w.^2)/sum(w)^2)*L;
        case 'Chebyshev'
            w=chebwin(L,sideLobeAttn);
            ENBW=(sum(w.^2)/sum(w)^2)*L;
        case 'Blackman-Harris'
            w=blackmanharris(L,'periodic');
            ENBW=(sum(w.^2)/sum(w)^2)*L;
        case 'Kaiser'
            SLA=sideLobeAttn;
            if SLA>50
                winParam=0.1102*(SLA-8.7);
            elseif SLA<21
                winParam=0;
            else
                winParam=(0.5842*(SLA-21)^0.4)+0.07886*(SLA-21);
            end
            w=kaiser(L,winParam);
            ENBW=(sum(w.^2)/sum(w)^2)*L;
        case 'Custom'
            switch customWin
            case{'blackman','blackmanharris','flattopwin','hamming','hann','nuttallwin'}


                w=feval(customWin,L,'periodic');
                ENBW=(sum(w.^2)/sum(w)^2)*L;
            otherwise
                w=double(feval(customWin,L));
                ENBW=(sum(w.^2)/sum(w)^2)*L;
            end
        end
