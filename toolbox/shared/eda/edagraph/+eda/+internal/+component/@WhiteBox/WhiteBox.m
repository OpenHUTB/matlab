classdef(ConstructOnLoad)WhiteBox<eda.internal.component.Component








    properties
    end

    properties

        flatten=true;
DescFunc
    end

    properties(Access=private)
signalTable
    end

    methods
        function this=WhiteBox(varargin)
            if~isempty(varargin)
                for i=1:3:length(varargin{:})
                    this.addprop(varargin{1}{i});
                    if strcmpi(varargin{1}{i+2},'ClockPort')
                        this.(varargin{1}{i})=eda.internal.component.ClockPort;
                    elseif strcmpi(varargin{1}{i+2},'ResetPort')
                        this.(varargin{1}{i})=eda.internal.component.ResetPort;
                    elseif strcmpi(varargin{1}{i+2},'ClockEnablePort')
                        this.(varargin{1}{i})=eda.internal.component.ResetPort;
                    elseif strcmpi(varargin{1}{i+1},'INPUT')
                        this.(varargin{1}{i})=eda.internal.component.Inport('FiType',varargin{1}{i+2});
                    elseif strcmpi(varargin{1}{i+1},'OUTPUT')
                        this.(varargin{1}{i})=eda.internal.component.Outport('FiType',varargin{1}{i+2});
                    elseif strcmpi(varargin{1}{i+1},'INOUT')
                        this.(varargin{1}{i})=eda.internal.component.InOutport('FiType',varargin{1}{i+2});
                    else
                        error(message('EDALink:WhiteBox:WhiteBox:InvalidPort'))
                    end
                    this.(varargin{1}{i}).UniqueName=varargin{1}{i};
                end

            end
        end
    end

    methods
        initSignalTable(this);
        implement(this);
    end

end

