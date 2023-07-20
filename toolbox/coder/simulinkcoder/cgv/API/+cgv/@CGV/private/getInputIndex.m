





























function[index,labelOut]=getInputIndex(this,labelIn)

    if nargin~=2
        DAStudio.error('RTW:cgv:InvalidNumberOfArgs');
    end
    if isempty(labelIn)||iscell(labelIn)
        DAStudio.error('RTW:cgv:BadIndexValue','');
    elseif ischar(labelIn)


        index=i_getNumberString(labelIn);
        if index~=0

            labelOut=labelIn;
        else
            labelOut=labelIn;
            for i=1:length(this.InputData)
                if strcmp(this.InputData(i).label,labelOut)
                    index=i;
                    break;
                end
            end

            if index==0
                for i=1:length(this.InputData)
                    if isempty(this.InputData(i).baselineFile)&&isempty(this.InputData(i).pathAndName)
                        index=i;
                        break;
                    end
                end
            end
        end
    elseif isinf(labelIn)||isnan(labelIn)

        DAStudio.error('RTW:cgv:BadIndex');
    elseif isscalar(labelIn)&&isreal(labelIn)
        if floor(labelIn)~=labelIn
            DAStudio.error('RTW:cgv:BadIndexValue',sprintf('%f',labelIn));
        end

        labelOut=sprintf('%d',labelIn);
        index=labelIn;
        if index<=0||index>4096
            DAStudio.error('RTW:cgv:BadIndexValue',sprintf('%d',index));
        end
    else

        DAStudio.error('RTW:cgv:BadIndexValue','');
    end

end


function retVal=i_getNumberString(labelIn)
    retVal=0;

    if all(isstrprop(labelIn,'digit'))
        retVal=sscanf(labelIn,'%d');
        if retVal==0

            DAStudio.error('RTW:cgv:BadIndexValue',labelIn);
        end
    end
end

