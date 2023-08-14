classdef(StrictDefaults)PolarEncoderCheckType<matlab.System


%#codegen



    methods
        function obj=PolarEncTypeCheck(varargin)
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

        function validateInputsImpl(~,datain,ctrlin,K,E)
            if isempty(coder.target)||~eml_ambiguous_types


                if~isscalar(datain)
                    coder.internal.error('whdl:PolarCode:NonScalarInput','data');
                end

                if~isreal(datain)
                    coder.internal.error('whdl:PolarCode:NonRealInput','data');
                end

                if~(isa(datain,'double')||isa(datain,'single')||isa(datain,'logical')||isa(datain,'embedded.fi'))
                    coder.internal.error('whdl:PolarCode:InvalidEncDataType',class(datain));
                end

                if(isa(datain,'embedded.fi')&&dsphdlshared.hdlgetwordsizefromdata(datain)>1)
                    coder.internal.error('whdl:PolarCode:InvalidEncDataType',tostringInternalSlName(datain.numerictype));
                end

                if~isscalar(K)
                    coder.internal.error('whdl:PolarCode:NonScalarInput','K');
                end

                if~isreal(K)
                    coder.internal.error('whdl:PolarCode:NonRealInput','K');
                end

                if~isa(K,'embedded.fi')
                    coder.internal.error('whdl:PolarCode:InvalidKDataType',class(K));
                end

                [WL,FL,signed]=dsphdlshared.hdlgetwordsizefromdata(K);
                if(WL~=10||FL~=0||signed~=0)
                    coder.internal.error('whdl:PolarCode:InvalidKDataType',tostringInternalSlName(K.numerictype));
                end

                if~isscalar(E)
                    coder.internal.error('whdl:PolarCode:NonScalarInput','E');
                end

                if~isreal(E)
                    coder.internal.error('whdl:PolarCode:NonRealInput','E');
                end

                if~isa(E,'embedded.fi')
                    coder.internal.error('whdl:PolarCode:InvalidRateDataType',class(E));
                end

                [WL,FL,signed]=dsphdlshared.hdlgetwordsizefromdata(E);
                if(isa(E,'embedded.fi')&&(WL~=14||FL~=0||signed~=0))
                    coder.internal.error('whdl:PolarCode:InvalidRateDataType',tostringInternalSlName(E.numerictype));
                end

                if isstruct(ctrlin)
                    test=fieldnames(ctrlin);
                    truth={'start';'end';'valid'};
                    if isequal(test,truth)
                        validateattributes(ctrlin.start,{'logical'},{'scalar'},'PolarEncoder','startIn');
                        validateattributes(ctrlin.end,{'logical'},{'scalar'},'PolarEncoder','endIn');
                        validateattributes(ctrlin.valid,{'logical'},{'scalar'},'PolarEncoder','validIn');
                    else
                        coder.internal.error('whdl:PolarCode:InvalidCtrlBusType');
                    end
                else
                    coder.internal.error('whdl:PolarCode:InvalidCtrlBusType');
                end
            end
        end

        function num=getNumInputsImpl(~)

            num=4;
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
