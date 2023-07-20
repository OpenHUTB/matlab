function[log,unapplied]=applyVarStruct(varargin)














































    switch nargout
    case{0,1}
        log=slprivate('applyBDVarStructImpl',varargin{:});
    case 2
        [log,unapplied]=slprivate('applyBDVarStructImpl',varargin{:});
    end

end



