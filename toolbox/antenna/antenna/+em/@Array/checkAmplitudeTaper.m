function checkAmplitudeTaper(obj,numelements)
    if isscalar(obj.AmplitudeTaper)
        setSourceVoltage(obj,obj.AmplitudeTaper,numelements);
    else
        validateattributes(obj.AmplitudeTaper,{'numeric'},...
        {'numel',numelements},class(obj),...
        'AmplitudeTaper');
        setSourceVoltage(obj,obj.AmplitudeTaper);
    end
end