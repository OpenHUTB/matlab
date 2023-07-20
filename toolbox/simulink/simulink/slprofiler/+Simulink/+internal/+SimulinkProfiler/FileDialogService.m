classdef FileDialogService<Simulink.internal.SimulinkProfiler.FileDialogServiceInterface
    methods
        function[filename,pathname,filterindex]=getfile(~,varargin)
            [filename,pathname,filterindex]=uigetfile(varargin{:});

        end
        function[filename,pathname,filterindex]=putfile(~,varargin)
            [filename,pathname,filterindex]=uiputfile(varargin{:});
        end
    end
end
