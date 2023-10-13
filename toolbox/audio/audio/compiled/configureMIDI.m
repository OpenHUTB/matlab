function configureMIDI(varargin)


    import matlab.internal.lang.capability.Capability;
    Capability.require(Capability.LocalClient);

    if nargin>0
        [varargin{:}]=convertStringsToChars(varargin{:});
    end

    privConfigureMIDI(varargin{:});