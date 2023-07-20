classdef(StrictDefaults)Channelizer<dsphdl.private.AbstractChannelizer
























































































%#codegen
%#ok<*EMCLS>





    properties(Nontunable)



        Normalize(1,1)logical=true;
    end

    properties(Nontunable,Hidden)


        InverseFFT(1,1)logical=false;
        Channelize(1,1)logical=true;
    end



    methods(Static)
        function helpFixedPoint





            matlab.system.dispFixptHelp('dsphdl.Channelizer',...
            dsphdl.Channelizer.getDisplayFixedPointPropertiesImpl);
        end
    end
    methods(Static,Hidden)
        function props=getDisplayPropertiesImpl()
            props={...
'NumberOfFrequencyBands'...
            ,'FilterCoefficients'...
            ,'ComplexMultiplication'...
            ,'OutputSize',...
'Normalize'...
            ,'ResetInputPort'...
            ,'StartOutputPort'...
            ,'EndOutputPort'...
            };

        end
    end






    methods(Access=protected)
        function setPortDataTypeConnections(obj)
            setPortDataTypeConnection(obj,1,1);
        end











        function flag=isInputComplexityMutableImpl(~,~)

            flag=true;
        end
    end

    methods(Static,Access=protected)
        function header=getHeaderImpl
            header=matlab.system.display.Header('dsphdl.Channelizer',...
            'ShowSourceLink',false,...
            'Title','Channelizer',...
            'Text',sprintf(['Channelize multi-channel signal using Polyphase Filter Bank technique.']));
        end
    end







    methods(Access=protected)
        function supported=supportsMultipleInstanceImpl(~)

            supported=true;
        end
    end



    methods

        function obj=Channelizer(varargin)
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


