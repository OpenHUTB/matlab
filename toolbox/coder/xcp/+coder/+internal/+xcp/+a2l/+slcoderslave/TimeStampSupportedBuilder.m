classdef TimeStampSupportedBuilder<handle







    properties(Constant,Access=private)

        TimeStampTicksDefault=0x01;
        TimeStampSizeDefault='SIZE_DWORD';
        TimeStampResolutionDefault='UNIT_1US';
        TimeStampFixedDefault=false;



        TimeStampTicksMacro='XCP_TIMESTAMP_TICKS';
        TimeStampSizeMacro='XCP_TIMESTAMP_SIZE';
        TimeStampSizeCondition={'(0[Xx])?0*1','SIZE_BYTE';
        '(0[Xx])?0*2','SIZE_WORD';
        '(0[Xx])?0*4','SIZE_DWORD'};

        TimeStampResolutionMacro='XCP_TIMESTAMP_UNIT';
        TimeStampResolutionCondition={'XCP_TIMESTAMP_UNIT_1NS|0[Xx]0*0|0*0','UNIT_1NS';
        'XCP_TIMESTAMP_UNIT_10NS|0[Xx]0*1|0*1','UNIT_10NS';
        'XCP_TIMESTAMP_UNIT_100NS|0[Xx]0*2|0*2','UNIT_100NS';
        'XCP_TIMESTAMP_UNIT_1US|0[Xx]0*3|0*3','UNIT_1US';
        'XCP_TIMESTAMP_UNIT_10US|0[Xx]0*4|0*4','UNIT_10US';
        'XCP_TIMESTAMP_UNIT_100US|0[Xx]0*5|0*5','UNIT_100US';
        'XCP_TIMESTAMP_UNIT_1MS|0[Xx]0*6|0*6','UNIT_1MS';
        'XCP_TIMESTAMP_UNIT_10MS|0[Xx]0*7|0*7','UNIT_10MS';
        'XCP_TIMESTAMP_UNIT_100MS|0[Xx]0*8|0*8','UNIT_100MS';
        'XCP_TIMESTAMP_UNIT_1S|0[Xx]0*9|0*9','UNIT_1S';
        'XCP_TIMESTAMP_UNIT_1PS|0[Xx]0*[aA]|0*10','UNIT_1PS';
        'XCP_TIMESTAMP_UNIT_10PS|0[Xx]0*[bB]|0*11','UNIT_10PS';
        'XCP_TIMESTAMP_UNIT_100PS|0[Xx]0*[cC]|0*12','UNIT_100PS'};

        TimeStampFixedMacro='XCP_TIMESTAMP_FIXED';
        TimeStampFixedCondition={'1',true;...
        '0',false};
    end

    methods
        function obj=TimeStampSupportedBuilder()



        end

        function build(obj,defineMap,timeStampSupported)



            className=mfilename('class');
            validateattributes(defineMap,{'containers.Map'},{},className,'defineMap');
            validateattributes(timeStampSupported,{'asam.mcd2mc.ifdata.xcp.TimeStampSupportedInfo'},{},className,'timeStampSupported');

            defineToA2LConverter=coder.internal.xcp.a2l.DefineToA2LConverter(defineMap);
            timeStampSupported.TimeStampTicks=defineToA2LConverter.getNumericValue(obj.TimeStampTicksMacro,obj.TimeStampTicksDefault);
            timeStampSupported.TimeStampSize=defineToA2LConverter.getEnumValue(obj.TimeStampSizeMacro,obj.TimeStampSizeCondition,obj.TimeStampSizeDefault);
            timeStampSupported.TimeStampResolution=defineToA2LConverter.getEnumValue(obj.TimeStampResolutionMacro,obj.TimeStampResolutionCondition,obj.TimeStampResolutionDefault);
            timeStampSupported.TimeStampFixed=defineToA2LConverter.getEnumValue(obj.TimeStampFixedMacro,obj.TimeStampFixedCondition,obj.TimeStampFixedDefault);
        end
    end
end