function[numWords,words,delim]=splitString(str,hText,updateState)








    [splitStr,delimStr]=strsplit(str,'\s+','DelimiterType','RegularExpression');




    if strcmpi(hText.Interpreter,'latex')
        [words,delim]=recombineIntoValidWords(splitStr,delimStr,hText,updateState);
    else
        delim=delimStr;
        words=splitStr;
    end
    numWords=numel(words);






    function[new_str,new_delim]=recombineIntoValidWords(str,delim,hText,updateState)




        hFont=matlab.graphics.general.Font;
        hFont.Name=hText.FontName;
        hFont.Size=hText.FontSize;
        hFont.Angle=hText.FontAngle;
        hFont.Weight=hText.FontWeight;
        smoothing='on';

        for i=1:numel(str)
            try
                updateState.getStringBounds(str{i},hFont,hText.Interpreter,smoothing);
            catch
                if i==numel(str)
                    updateState.getStringBounds(str{i},hFont,'none',smoothing);
                else

                    str{i+1}=[str{i},delim{i},str{i+1}];
                    str{i}=NaN;
                    delim{i}=NaN;
                end
            end
        end


        new_delim=delim(~cellfun(@(x)(isscalar(x)&&isnan(x)),delim));
        new_str=str(~cellfun(@(x)(isscalar(x)&&isnan(x)),str));