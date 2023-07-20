classdef(StrictDefaults)GoldDataCheck<matlab.System




%#codegen

    methods
        function obj=GoldDataCheck(varargin)
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

        function validateInputsImpl(~,enable,load,init)

            validateattributes(load,{'logical','boolean','embedded.fi'},{'scalar','binary'},'GoldDataCheck','load');
            validateattributes(enable,{'logical','boolean','embedded.fi'},{'scalar','binary'},'GoldDataCheck','enable');
            if isa(init,'embedded.fi')
                coder.internal.errorIf(issigned(init)||(dsphdlshared.hdlgetwordsizefromdata(init)~=31),'whdl:GoldGen:InvalidInitType');
            elseif isinteger(init)
                coder.internal.errorIf(dsphdlshared.hdlgetwordsizefromdata(init)~=31,'whdl:GoldGen:InvalidInitType');
            elseif~(isa(init,'embedded.fi')||isinteger(init))
                coder.internal.error('whdl:GoldGen:InvalidInitType');
            end
            if isa(load,'embedded.fi')
                coder.internal.errorIf(dsphdlshared.hdlgetwordsizefromdata(load)>1,'whdl:GoldGen:InvalidLoadType');
            end
            if isa(enable,'embedded.fi')
                coder.internal.errorIf(dsphdlshared.hdlgetwordsizefromdata(enable)>1,'whdl:GoldGen:InvalidEnableType');
            end
        end

        function num=getNumInputsImpl(~)

            num=3;
        end

        function num=getNumOutputsImpl(~)
            num=0;
        end
    end

    methods(Access=protected,Static)
        function flag=showSimulateUsingImpl

            flag=false;
        end
    end
end
