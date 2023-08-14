function initialize(varargin)









    if~isempty(varargin)
        autosar.internal.ara.initialize(varargin{:});
    else
        autosar.internal.ara.initialize();
    end
end
