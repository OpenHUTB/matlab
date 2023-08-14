function[elementVal,name,retIdx]=getElement(this,searchArg,varargin)


























    narginchk(2,inf);
    [varargin{:}]=convertStringsToChars(varargin{:});
    searchArg=convertStringsToChars(searchArg);


    if length(this)~=1
        Simulink.SimulationData.utError('InvalidDatasetArray');
    end

    assert(~isempty(this.Storage_),...
    'Dataset.getElement: storage is empty');

    [elementVal,name,retIdx]=locGetWrapperWithNotFoundWarning(this,{},searchArg,varargin{:});

end
