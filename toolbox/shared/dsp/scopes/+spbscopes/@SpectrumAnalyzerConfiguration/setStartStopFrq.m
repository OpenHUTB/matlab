function setStartStopFrq(obj)







    if~strcmp(obj.XLimitLocal,'unset')&&~strcmp(obj.XMinLocal,'unset')&&~strcmp(obj.XMaxLocal,'unset')
        if strcmpi(obj.XLimitLocal,'User-defined')

            obj.FrequencySpan='Start and stop frequencies';
            obj.StartFrequency=obj.XMinLocal;
            obj.StopFrequency=obj.XMaxLocal;


            obj.IsFstartFstopSettingDirty=true;
        end
    end
end
