function fracLength=getBestPrecFracLength(this,values,wordLength,signedness)







    if(wordLength<2)&&signedness||(wordLength<1)&&~signedness
        fracLength=0;
    else
        fracLength=0;
        if~isempty(values)
            valuesCol=double(values(:));
            if isreal(values)
                minVal=min(valuesCol);
                maxVal=max(valuesCol);
            else
                realValues=real(valuesCol);
                imagValues=imag(valuesCol);


                realMinVal=min(realValues);
                imagMinVal=min(imagValues);
                minVal=min([realMinVal;imagMinVal]);


                realMaxVal=max(realValues);
                imagMaxVal=max(imagValues);
                maxVal=max([realMaxVal;imagMaxVal]);
            end



            if abs(minVal)>abs(maxVal)
                valueToUse=minVal;
            else
                valueToUse=maxVal;
            end


            fracLength=-fixed.GetBestPrecisionExponent(valueToUse,double(wordLength),signedness);
        end
    end




