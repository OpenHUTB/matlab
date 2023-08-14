function theta=atan2_fi_lut_private(y,x)




%#codegen

    coder.allowpcode('plain');

    persistent ATAN_UFRAC_LUT;

    ufix16fracNT=numerictype(0,16,16);

    if isempty(ATAN_UFRAC_LUT)




        ATAN_UFRAC_LUT=fi((atan((0:256)./256))',ufix16fracNT);
    end

    localFm=fimath(...
    'RoundMode','floor','OverflowMode','wrap',...
    'ProductMode','FullPrecision','MaxProductWordLength',128,...
    'SumMode','FullPrecision','MaxSumWordLength',128);

    if issigned(y)||issigned(x)



        if isscaleddouble(y)||isscaleddouble(x)
            thetaNT=numerictype(...
            'Signedness','Signed',...
            'WordLength',16,...
            'FractionLength',13,...
            'DataTypeMode','Scaled double: binary point scaling');
        else
            thetaNT=numerictype(1,16,13);
        end

        piOverTwoFi=fi(pi/2,thetaNT,localFm);


        xyFm=fimath(...
        'RoundMode','floor','OverflowMode','saturate',...
        'ProductMode','FullPrecision','MaxProductWordLength',128,...
        'SumMode','FullPrecision','MaxSumWordLength',128);

        thisY=coder.nullcopy(fi(0,numerictype(y),xyFm));
        thisX=coder.nullcopy(fi(0,numerictype(x),xyFm));
        negThisY=coder.nullcopy(fi(0,numerictype(y),xyFm));
        negThisX=coder.nullcopy(fi(0,numerictype(x),xyFm));

        inCodegenMode=~isempty(coder.target);
        if inCodegenMode
            thisY(:)=y;
            thisX(:)=x;
        else
            setElement(thisY,getElement(y,1),1);
            setElement(thisX,getElement(x,1),1);
        end

        if(thisY>0)

            if(thisX==thisY)
                theta=fi(pi/4,thetaNT);
                return;

            elseif(thisX>=0)

                if inCodegenMode

                    if(thisY<=thisX)
                        fracVal=divide(ufix16fracNT,thisY,thisX);
                    else
                        fracVal=divide(ufix16fracNT,thisX,thisY);
                    end
                else

                    if(thisY<=thisX)
                        fracVal=divide(ufix16fracNT,getElement(thisY,1),getElement(thisX,1));
                    else
                        fracVal=divide(ufix16fracNT,getElement(thisX,1),getElement(thisY,1));
                    end
                end
            else

                if inCodegenMode

                    negThisX(:)=-thisX;
                    if(thisY==negThisX)
                        theta=fi(3*pi/4,thetaNT);
                        return;
                    elseif(thisY<negThisX)
                        fracVal=divide(ufix16fracNT,thisY,negThisX);
                    else
                        fracVal=divide(ufix16fracNT,negThisX,thisY);
                    end
                else

                    setElement(negThisX,(-thisX),1);
                    if(thisY==negThisX)
                        theta=fi(3*pi/4,thetaNT);
                        return;
                    elseif(thisY<negThisX)
                        fracVal=divide(ufix16fracNT,getElement(thisY,1),getElement(negThisX,1));
                    else
                        fracVal=divide(ufix16fracNT,getElement(negThisX,1),getElement(thisY,1));
                    end
                end
            end


            idxUFIX16=fi(storedInteger(fracVal),numerictype(0,16,0));


            thPreCorr=coder.nullcopy(fi(0,thetaNT,localFm));
            if inCodegenMode



                thPreCorr(:)=fixed.internal.trig_lut_fi_private(ATAN_UFRAC_LUT,idxUFIX16,'saturate');
            else
                setElement(thPreCorr,fixed.internal.trig_lut_fi_private(ATAN_UFRAC_LUT,idxUFIX16,'saturate'),1);
            end


            thOctCorr=coder.nullcopy(fi(0,thetaNT,localFm));
            if(thisX>=0)
                if(thisX<thisY)
                    if inCodegenMode
                        thOctCorr(:)=piOverTwoFi-thPreCorr;
                    else
                        setElement(thOctCorr,(piOverTwoFi-thPreCorr),1);
                    end
                else
                    if inCodegenMode
                        thOctCorr(:)=thPreCorr;
                    else
                        setElement(thOctCorr,getElement(thPreCorr,1),1);
                    end
                end
            elseif(thisY>negThisX)
                if inCodegenMode
                    thOctCorr(:)=piOverTwoFi+thPreCorr;
                else
                    setElement(thOctCorr,(piOverTwoFi+thPreCorr),1);
                end
            else
                piFiConstant=fi(pi,thetaNT,localFm);
                if inCodegenMode
                    thOctCorr(:)=piFiConstant-thPreCorr;
                else
                    setElement(thOctCorr,(piFiConstant-thPreCorr),1);
                end
            end

            theta=coder.nullcopy(fi(0,thetaNT));
            if inCodegenMode
                theta(:)=thOctCorr;
            else
                setElement(theta,getElement(thOctCorr,1),1);
            end

        elseif(thisY<0)
            if(thisX==thisY)
                theta=fi((-3*pi/4),thetaNT);
                return;

            else

                if(thisX>=0)

                    if inCodegenMode

                        negThisY(:)=-thisY;
                        if(negThisY==thisX)
                            theta=fi(-pi/4,thetaNT);
                            return;
                        elseif(negThisY<thisX)
                            fracVal=divide(ufix16fracNT,negThisY,thisX);
                        else
                            fracVal=divide(ufix16fracNT,thisX,negThisY);
                        end
                    else

                        setElement(negThisY,(-thisY),1);
                        if(negThisY==thisX)
                            theta=fi(-pi/4,thetaNT);
                            return;
                        elseif(negThisY<thisX)
                            fracVal=divide(ufix16fracNT,getElement(negThisY,1),getElement(thisX,1));
                        else
                            fracVal=divide(ufix16fracNT,getElement(thisX,1),getElement(negThisY,1));
                        end
                    end
                else

                    if inCodegenMode

                        negThisX(:)=-thisX;
                        negThisY(:)=-thisY;
                        if(negThisY<=negThisX)
                            fracVal=divide(ufix16fracNT,negThisY,negThisX);
                        else
                            fracVal=divide(ufix16fracNT,negThisX,negThisY);
                        end
                    else

                        setElement(negThisX,(-thisX),1);
                        setElement(negThisY,(-thisY),1);
                        if(negThisY<=negThisX)
                            fracVal=divide(ufix16fracNT,getElement(negThisY,1),getElement(negThisX,1));
                        else
                            fracVal=divide(ufix16fracNT,getElement(negThisX,1),getElement(negThisY,1));
                        end
                    end
                end
            end


            idxUFIX16=fi(storedInteger(fracVal),numerictype(0,16,0));


            thPreCorr=coder.nullcopy(fi(0,thetaNT,localFm));
            if inCodegenMode



                thPreCorr(:)=fixed.internal.trig_lut_fi_private(ATAN_UFRAC_LUT,idxUFIX16,'saturate');
            else
                setElement(thPreCorr,fixed.internal.trig_lut_fi_private(ATAN_UFRAC_LUT,idxUFIX16,'saturate'),1);
            end


            thOctCorr=coder.nullcopy(fi(0,thetaNT,localFm));
            if(thisX>=0)
                if(negThisY<=thisX)
                    if inCodegenMode
                        thOctCorr(:)=-thPreCorr;
                    else
                        setElement(thOctCorr,(-thPreCorr),1);
                    end
                else
                    if inCodegenMode
                        thOctCorr(:)=thPreCorr-piOverTwoFi;
                    else
                        setElement(thOctCorr,(thPreCorr-piOverTwoFi),1);
                    end
                end
            elseif(negThisY>negThisX)
                if inCodegenMode
                    thOctCorr(:)=-(thPreCorr+piOverTwoFi);
                else
                    setElement(thOctCorr,-(thPreCorr+piOverTwoFi),1);
                end
            else
                piFiConstant=fi(pi,thetaNT,localFm);
                if inCodegenMode
                    thOctCorr(:)=thPreCorr-piFiConstant;
                else
                    setElement(thOctCorr,(thPreCorr-piFiConstant),1);
                end
            end

            theta=coder.nullcopy(fi(0,thetaNT));
            if inCodegenMode
                theta(:)=thOctCorr;
            else
                setElement(theta,getElement(thOctCorr,1),1);
            end

        else

            if(thisX>=0)
                theta=fi(0,thetaNT);
            else
                theta=fi(pi,thetaNT);
            end
        end
    else




        if isscaleddouble(y)||isscaleddouble(x)
            thetaNT=numerictype(...
            'Signedness','Unsigned',...
            'WordLength',16,...
            'FractionLength',15,...
            'DataTypeMode','Scaled double: binary point scaling');
        else
            thetaNT=numerictype(0,16,15);
        end

        piOverTwoFi=fi(pi/2,thetaNT,localFm);

        thisY=coder.nullcopy(fi(0,numerictype(y),localFm));
        thisX=coder.nullcopy(fi(0,numerictype(x),localFm));

        inCodegenMode=~isempty(coder.target);
        if inCodegenMode
            thisY(:)=y;
            thisX(:)=x;
        else
            setElement(thisY,getElement(y,1),1);
            setElement(thisX,getElement(x,1),1);
        end

        if(thisY==0)

            theta=fi(0,thetaNT);
        elseif(thisX==thisY)
            theta=fi(pi/4,thetaNT);
        else

            thPreCorr=coder.nullcopy(fi(0,thetaNT,localFm));
            theta=coder.nullcopy(fi(0,thetaNT));

            if inCodegenMode

                if(thisY<thisX)
                    fracVal=divide(ufix16fracNT,thisY,thisX);
                else
                    fracVal=divide(ufix16fracNT,thisX,thisY);
                end


                idxUFIX16=fi(storedInteger(fracVal),numerictype(0,16,0));





                thPreCorr(:)=fixed.internal.trig_lut_fi_private(ATAN_UFRAC_LUT,idxUFIX16,'saturate');


                if(thisX<thisY)
                    thOctCorr=coder.nullcopy(fi(0,thetaNT,localFm));
                    thOctCorr(:)=piOverTwoFi-thPreCorr;
                    theta(:)=thOctCorr;
                else
                    theta(:)=thPreCorr;
                end
            else

                if(thisY<thisX)
                    fracVal=divide(ufix16fracNT,getElement(thisY,1),getElement(thisX,1));
                else
                    fracVal=divide(ufix16fracNT,getElement(thisX,1),getElement(thisY,1));
                end


                idxUFIX16=fi(storedInteger(fracVal),numerictype(0,16,0));





                setElement(thPreCorr,fixed.internal.trig_lut_fi_private(ATAN_UFRAC_LUT,idxUFIX16,'saturate'),1);


                if(thisX<thisY)
                    thOctCorr=coder.nullcopy(fi(0,thetaNT,localFm));
                    setElement(thOctCorr,(piOverTwoFi-thPreCorr),1);
                    setElement(theta,getElement(thOctCorr,1),1);
                else
                    setElement(theta,getElement(thPreCorr,1),1);
                end
            end
        end
    end

end
