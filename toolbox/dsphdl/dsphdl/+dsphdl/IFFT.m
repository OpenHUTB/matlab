classdef(StrictDefaults)IFFT<dsphdl.private.AbstractFFT
































































































































%#codegen
%#ok<*EMCLS>
    properties(Nontunable)



        Normalize(1,1)logical=true;
    end



    methods(Static)
        function helpFixedPoint





            matlab.system.dispFixptHelp('dsphdl.IFFT',...
            dsphdl.IFFT.getDisplayFixedPointPropertiesImpl);
        end
    end
    methods(Static,Hidden)
        function props=getDisplayPropertiesImpl()
            props={...
            'Architecture',...
            'ComplexMultiplication',...
'BitReversedOutput'...
            ,'Normalize'...
            ,'FFTLengthSource'...
            ,'FFTLength'...
            ,'StartOutputPort',...
            'EndOutputPort',...
            'ValidOutputPort',...
            };
        end

        function props=getDisplayFixedPointPropertiesImpl()
            props={...
            'RoundingMethod'};%#ok<*EMCA>
        end
    end






    methods(Access=protected)
        function setPortDataTypeConnections(obj)
            setPortDataTypeConnection(obj,1,1);
        end

        function icon=getIconImpl(obj)
            if strcmpi(obj.Architecture,'Streaming Radix 2 (this choice will be removed -see release notes).')
                icon=sprintf('IFFT\nLatency = %d',obj.getLatency(obj.FFTLength,1));
            elseif isempty(getInputVectorSize(obj))
                icon=sprintf('IFFT\nLatency = --');
            else
                icon=sprintf('IFFT\nLatency = %d',obj.getLatency(obj.FFTLength,getInputVectorSize(obj)));
            end
        end

        function flag=isInputComplexityMutableImpl(~,~)

            flag=true;
        end
    end

    methods(Static,Access=protected)
        function header=getHeaderImpl
            header=matlab.system.display.Header('dsphdl.IFFT',...
            'ShowSourceLink',false,...
            'Title','IFFT',...
            'Text',sprintf(['Compute the inverse fast Fourier transform (IFFT) of a complex or real input.\n\n',...
            'The IFFT implementation is optimized for HDL code generation.\n']));
        end
    end

    methods(Access=protected)
        function supported=supportsMultipleInstanceImpl(~)

            supported=true;
        end
    end





    methods

        function obj=IFFT(varargin)
            obj.InverseFFT=true;
            coder.allowpcode('plain');

            if coder.target('MATLAB')
                if~(builtin('license','checkout','DSP_HDL_Toolbox'))
                    error(message('dsphdl:dsphdl:NoLicenseAvailable'));
                end
            else
                coder.license('checkout','DSP_HDL_Toolbox');
            end

            setProperties(obj,nargin,varargin{:});
        end

    end
end


