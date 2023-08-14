function varargout=plot(this,varargin)



















    narginchk(1,2)
    [varargin{:}]=convertStringsToChars(varargin{:});
    ret=cell(1,nargout);


    dsLabel=inputname(1);


    if nargin<2
        viewer='datainspector';
    else
        if~ischar(varargin{1})
            Simulink.SimulationData.utError('viewMustBeChar');
        end
        viewer=lower(varargin{1});
    end


    switch viewer
    case 'preview'
        Simulink.SimulationData.utPlotDataset(this,dsLabel);
    otherwise
        [ret{:}]=Simulink.SimulationData.utPlotDatasetSDI(this,dsLabel);
    end
    varargout=ret;
end
