classdef(StrictDefaults)LDPCEncoderCheckType<matlab.System


%#codegen



    methods
        function obj=LdpcEncTypeCheck(varargin)
            coder.allowpcode('plain');
            if coder.target('MATLAB')
                if~(builtin('license','checkout','LTE_HDL_Toolbox'))
                    error(message('whdl:whdl:NoLicenseAvailable'));
                end
            else
                coder.license('checkout','LTE_HDL_Toolbox');
            end
        end
    end

    methods(Access=protected)

        function supported=supportsMultipleInstanceImpl(~)

            supported=true;
        end

        function validateInputsImpl(~,datain,startin,endin,validin,bgn,Z)
            if isempty(coder.target)||~eml_ambiguous_types

                vecLen=64;

                validateattributes(datain,{'logical'},{'binary'},'LDPCEncoder','data');

                if~isscalar(datain)&&(length(datain)~=vecLen)
                    coder.internal.error('whdl:NRLDPCEncoder:InvalidVecLength');
                end

                validateattributes(startin,{'logical'},{'scalar'},'LDPCEncoder','start');
                validateattributes(endin,{'logical'},{'scalar'},'LDPCEncoder','end');
                validateattributes(validin,{'logical'},{'scalar'},'LDPCEncoder','valid');

                validateattributes(bgn,{'logical'},{'scalar'},'LDPCEncoder','bgn');
                validateattributes(Z,{'uint16'},{'scalar'},'LDPCEncoder','Lifting Size');

            end
        end

        function num=getNumInputsImpl(~)

            num=6;
        end

        function num=getNumOutputsImpl(~)
            num=0;
        end
    end

    methods(Static,Access=protected)
        function header=getHeaderImpl
            header=matlab.system.display.Header(mfilename('class'),...
            'ShowSourceLink',false);
        end

        function isVisible=showSimulateUsingImpl
            isVisible=false;
        end
    end
end
