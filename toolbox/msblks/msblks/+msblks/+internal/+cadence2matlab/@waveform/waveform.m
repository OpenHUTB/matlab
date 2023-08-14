classdef waveform<handle




    properties(Access=public)
analysisType
xData
xLabel
xScale
xUnit
yData
yLabel
yScale
yUnit
outputName

    end

    methods
        function obj=waveform(varargin)

            narginchk(0,10)

            if nargin==0
                warning('Need at least 10 Input arguments for a waveform object');

            elseif nargin>=10
                    obj.analysisType=varargin{1};
                    obj.xData=varargin{2};
                    obj.xLabel=varargin{3};
                    obj.xScale=varargin{4};
                    obj.xUnit=varargin{5};
                    obj.yData=varargin{6};
                    obj.yLabel=varargin{7};
                    obj.yScale=varargin{8};
                    obj.yUnit=varargin{9};
                    obj.outputName=varargin{10};
                end
            end
        end
    end
end








