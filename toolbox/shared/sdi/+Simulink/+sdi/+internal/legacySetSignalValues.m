function legacySetSignalValues(varargin)






    eng=Simulink.sdi.Instance.engine;
    eng.setSignalDataValues(varargin{:});
end