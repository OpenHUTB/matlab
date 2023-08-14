function RBW=getRBW(obj)




    if strcmp(obj.FrequencyResolutionMethod,'RBW')
        if strcmp(obj.RBWSource,'Auto')
            RBW=getSpan(obj)/1024;
        else
            RBW=obj.RBW;
        end
    else
        WL=obj.WindowLength;
        RBW=getENBW(obj,WL)*obj.SampleRate/WL;
    end
end
