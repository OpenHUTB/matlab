classdef MatFileNameGenerator<handle




    properties
        m_nameMap;
    end


    methods
        function self=MatFileNameGenerator()
            self.m_nameMap=containers.Map('KeyType','char','ValueType','any');
            self.initializeMap();
        end

        function self=initializeMap(self)

            self.addImplComponents('hdldefaults.Abs','abs_comp');
            self.addImplComponents('hdldefaults.BitShift','bitshift_comp');
            self.addImplComponents('hdldefaults.BitOps','bitwiseop_comp');
            self.addImplComponents('hdldefaults.DataTypeConversion','datatypeconvert_comp');
            self.addImplComponents('hdldefaults.Deserializer1D','deserializer_comp');
            self.addImplComponents('hdldefaults.Logic','logic_comp');
            self.addImplComponents('hdldefaults.LookupTableND','lookuptable_comp');
            self.addImplComponents('hdldefaults.MultiPortSwitch','multiportswitch_comp');
            self.addImplComponents('hdldefaults.HDLCounter','hdlcounter_comp');
            self.addImplComponents('hdldefaults.Product','mul_comp');
            self.addImplComponents('hdldefaults.RateTransition','ratetransition_comp');
            self.addImplComponents('hdldefaults.ReciprocalNewton','recip_comp');
            self.addImplComponents('hdldefaults.RecipSqrtNewton','recipsqrtnewton_comp');
            self.addImplComponents('hdldefaults.RecipSqrtNewtonSingleRate','recipsqrtnewtonsinglerate_comp');
            self.addImplComponents('hdldefaults.RelationalOperator','relop_comp');
            self.addImplComponents('hdldefaults.Saturation','saturation_comp');
            self.addImplComponents('hdldefaults.Serializer1D','serializer_comp');
            self.addImplComponents('hdldefaults.SqrtNewton','sqrtNewton_comp');
            self.addImplComponents('hdldefaults.SqrtNewtonSingleRate','sqrtNewtonSingleRate_comp');
            self.addImplComponents('hdldefaults.Sum','add_comp');
            self.addImplComponents('hdldefaults.Switch','switch_comp');
            self.addImplComponents('hdldefaults.TappedDelay','tappeddelay_comp');
            self.addImplComponents('hdldefaults.UnitDelay','unitdelay_comp');
            self.addImplComponents('hdldefaults.UnitDelayEnabled','unitdelayenabled_comp');
            self.addImplComponents('hdldefaults.UnitDelayResettable','unitdelayresettable_comp');










            self.addImplComponents('hdldefaults.Abs','nfp_abs_comp');
            self.addImplComponents('hdldefaults.DataTypeConversion','nfp_conv_fi2fl_comp','nfp_conv_fl2fi_comp','nfp_conv_fl2fl_comp');
            self.addImplComponents('hdldefaults.Gain','nfp_gain_pow2_comp');
            self.addImplComponents('hdldefaults.MathFunction','nfp_exp_comp','nfp_log_comp','nfp_pow10_comp','nfp_log10_comp',...
            'nfp_recip_comp','nfp_mod_comp','nfp_rem_comp','nfp_pow_comp',...
            'nfp_hypot_comp');
            self.addImplComponents('hdldefaults.NFPReinterpretCast','nfp_cast_comp');
            self.addImplComponents('hdldefaults.Product','nfp_mul_comp','nfp_div_comp');
            self.addImplComponents('hdldefaults.ReciprocalNewtonSingleRate','nfp_hdlrecip_comp');
            self.addImplComponents('hdldefaults.RelationalOperator','nfp_relop_comp');
            self.addImplComponents('hdldefaults.RoundingFunction','nfp_floor_comp','nfp_ceil_comp','nfp_round_comp','nfp_fix_comp');
            self.addImplComponents('hdldefaults.Signum','nfp_signum_comp');
            self.addImplComponents('hdldefaults.SqrtFunction','nfp_sqrt_comp','nfp_rsqrt_comp');
            self.addImplComponents('hdldefaults.Sum','nfp_add_comp');
            self.addImplComponents('hdldefaults.TrigonometricFunction','nfp_sin_comp','nfp_cos_comp','nfp_tan_comp','nfp_asin_comp',...
            'nfp_acos_comp','nfp_sinh_comp','nfp_cosh_comp','nfp_tanh_comp','nfp_atan_comp','nfp_asinh_comp','nfp_acosh_comp',...
            'nfp_atanh_comp','nfp_atan2_comp','nfp_sincos_comp');
            self.addImplComponents('hdldefaults.UnaryMinus','nfp_uminus_comp');

        end



        function addImplComponents(self,implName,varargin)

            if self.m_nameMap.isKey(implName)
                compList=self.m_nameMap(implName);
                compList=[compList,varargin(:)'];
                self.m_nameMap(implName)=compList;
            else
                self.m_nameMap(implName)=varargin;
            end

        end


        function compList=getCompsFromImpl(self,implName)
            if~self.m_nameMap.isKey(implName)
                error('Implementation to Pir mapping does not exist');
            end
            compList=self.m_nameMap(implName{:});
        end

        function paramStr=concatParamValues(self,configInfo)
            pt=coder.internal.tools.TML;
            paramStr='';
            for i=2:2:numel(configInfo.currentParamSettings)
                paramStr=[paramStr,'_',pt.tostr(configInfo.currentParamSettings{i})];
            end

        end
    end
end
