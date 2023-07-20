function this=addElement(this,varargin)

















































    try
        [varargin{:}]=convertStringsToChars(varargin{:});
        this.verifyDatasetIsScalar;

        if~this.isDatatypeAllowedInDataset(varargin{1})
            Simulink.SimulationData.utError('InvalidDatasetElement');
        end

        this=this.addElementWithoutChecking(varargin{:});


        if nargout<1
            msg=message(...
            'SimulationData:Objects:DatasetUpdateNoLHS',...
            'addElement');
            wState=warning('off','backtrace');
            warning(msg);
            warning(wState);
        end
    catch me
        throwAsCaller(me);
    end
end
