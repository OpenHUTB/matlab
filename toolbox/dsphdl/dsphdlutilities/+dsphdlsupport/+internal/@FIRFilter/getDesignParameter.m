function[numMults,numMuxInputs,numDlyLine,dlyLineLen,numCoeffTable]=getDesignParameter(this,isSymmetry,params)%#ok<*INUSL>




    Numerator=params.Numerator;
    numTaps=length(Numerator);
    sharing=params.SharingFactor;
    if isSymmetry
        if mod(numTaps,2)
            if sharing>=ceil(numTaps/2)
                numMults=1;
                numMuxInputs=ceil(numTaps/2);
                dlyLineLen=numMuxInputs;
                dlyLineLen=[dlyLineLen,dlyLineLen];
                numDlyLine=length(dlyLineLen);
                numCoeffTable=numMults;
            else
                numTaps=numTaps-1;
                numMults=ceil(numTaps/(2*sharing));
                numMuxInputs=ceil(numTaps/(2*numMults));
                dlyLineLen=numMuxInputs;
                remainingDly=floor(numTaps/2)-numMuxInputs;
                while remainingDly>0
                    if remainingDly>=numMuxInputs
                        dlyLineLen=[dlyLineLen,numMuxInputs];%#ok<*AGROW>
                    else
                        dlyLineLen=[dlyLineLen,remainingDly];
                    end
                    remainingDly=remainingDly-numMuxInputs;
                end
                dlyLineLen=[dlyLineLen,1,fliplr(dlyLineLen)];
                numDlyLine=length(dlyLineLen);
                numMults=numMults+1;
                numCoeffTable=numMults;
            end
        else
            numMults=ceil(numTaps/(2*sharing));
            numMuxInputs=ceil(numTaps/(2*numMults));

            dlyLineLen=numMuxInputs;
            remainingDly=numTaps/2-numMuxInputs;
            while remainingDly>0
                if remainingDly>=numMuxInputs
                    dlyLineLen=[dlyLineLen,numMuxInputs];
                else
                    dlyLineLen=[dlyLineLen,remainingDly];
                end
                remainingDly=remainingDly-numMuxInputs;
            end
            dlyLineLen=[dlyLineLen,fliplr(dlyLineLen)];
            numDlyLine=length(dlyLineLen);
            numCoeffTable=numMults;
        end
    else
        if size(Numerator,1)==1
            numMults=ceil(numTaps/sharing);
            numMuxInputs=ceil(numTaps/numMults);
            numDlyLine=numMults;
            numCoeffTable=numMults;
            dlyLineLen=repmat(numMuxInputs,numDlyLine,1);
        else
            numMults=ceil(numel(Numerator)/sharing);
            numMuxInputs=ceil(size(Numerator,2)/numMults);
            numDlyLine=numMults;
            numCoeffTable=numMults;
            dlyLineLen=repmat(numMuxInputs,numDlyLine,1);
        end
    end

end


