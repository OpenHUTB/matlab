function updateFracLengthFromWordLength(this)




    untranslatedEntries=this.Block.getPropAllowedValues([this.Prefix,'Mode']);
    modeString=untranslatedEntries{this.Mode+1};

    if strcmpi(modeString,'Specify word length')










        try
            wlVal=double(evalin('base',this.WordLength));
        catch
            wlVal=[];
        end

        if~isempty(wlVal)
            if~isempty(this.ParamPropNames)&&~isempty(this.ParamBlock)

                scaleVals=[];
                stringCellArray=this.ParamPropNames;

                if((length(stringCellArray)==1)&&...
                    (strcmp(stringCellArray{1},'intentionally blank')))
                    scaleVals=[];
                else
                    for count=1:length(stringCellArray)

                        nextStr=stringCellArray{count};
                        try
                            temp=eval(this.ParamBlock.(nextStr));
                            nextVals=str2num(this.ParamBlock.(nextStr));
                        catch
                            scaleVals=[];
                            break;
                        end


                        nextVals=nextVals(:);


                        scaleVals=[scaleVals;nextVals];
                    end
                end

                if~isempty(scaleVals)
                    scaleValsCol=double(scaleVals(:));
                    if isreal(scaleVals)
                        minVal=min(scaleValsCol);
                        maxVal=max(scaleValsCol);
                    else
                        realScaleVals=real(scaleValsCol);
                        imagScaleVals=imag(scaleValsCol);


                        realMinVal=min(realScaleVals);
                        imagMinVal=min(imagScaleVals);
                        minVal=min([realMinVal;imagMinVal]);


                        realMaxVal=max(realScaleVals);
                        imagMaxVal=max(imagScaleVals);
                        maxVal=max([realMaxVal;imagMaxVal]);
                    end



                    if abs(minVal)>abs(maxVal)
                        valueToUse=minVal;
                    else
                        valueToUse=maxVal;
                    end


                    fl_best_prec=-fixptbestexp(valueToUse,wlVal,1.0);
                    fl=num2str(fl_best_prec);
                else
                    fl=this.BestPrecString;
                end
            elseif~isnan(this.WordLengthOffset)
                fl=num2str(wlVal-this.WordLengthOffset);
            else
                warning(message('dspshared:updateFracLengthFromWordLength:invalidFcnInput'));
                fl='Internal Error';
            end
        else
            fl=this.BestPrecString;
        end

        this.FracLength=fl;
    else
        this.FracLength=this.FracLengthEdit;
    end
