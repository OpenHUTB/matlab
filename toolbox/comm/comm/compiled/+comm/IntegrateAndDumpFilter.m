classdef IntegrateAndDumpFilter<matlab.system.SFunSystem

































































%#function mcomintegdump

%#ok<*EMCLS>
%#ok<*EMCA>

    properties(Nontunable)





        IntegrationPeriod=8;













        Offset=0;






        RoundingMethod='Floor';




        OverflowAction='Wrap';





        AccumulatorDataType='Full precision';








        CustomAccumulatorDataType=numerictype([],32,30);




        OutputDataType='Same as accumulator';








        CustomOutputDataType=numerictype([],32,30);















        DecimateOutput(1,1)logical=true;












        FullPrecisionOverride(1,1)logical=true;
    end

    properties(Constant,Hidden)

        RoundingMethodSet=dsp.CommonSets.getSet('RoundingMethod');
        OverflowActionSet=dsp.CommonSets.getSet('OverflowAction');
        AccumulatorDataTypeSet=dsp.CommonSets.getSet(...
        'FixptModeInherit');
        OutputDataTypeSet=dsp.CommonSets.getSet('FixptModeAccum');
    end

    methods
        function obj=IntegrateAndDumpFilter(varargin)
            coder.allowpcode('plain');
            obj@matlab.system.SFunSystem('mcomintegdump');
            setProperties(obj,nargin,varargin{:},'IntegrationPeriod');
            setVarSizeAllowedStatus(obj,false);
        end

        function set.CustomAccumulatorDataType(obj,val)
            validateCustomDataType(obj,'CustomAccumulatorDataType',val,...
            {'AUTOSIGNED','SCALED'});
            obj.CustomAccumulatorDataType=val;
        end

        function set.CustomOutputDataType(obj,val)
            validateCustomDataType(obj,'CustomOutputDataType',val,...
            {'AUTOSIGNED','SCALED'});
            obj.CustomOutputDataType=val;
        end
    end

    methods(Hidden)
        function setParameters(obj)


            if~(isSizesOnlyCall(obj)||obj.FullPrecisionOverride)

                dtInfo=getFixptDataTypeInfo(obj,...
                {'Accumulator','Output'});

                accDTMode=dtInfo.AccumulatorDataType;
                accWLVal=dtInfo.AccumulatorWordLength;
                accFLVal=dtInfo.AccumulatorFracLength;
                outDTMode=dtInfo.OutputDataType;
                outWLVal=dtInfo.OutputWordLength;
                outFLVal=dtInfo.OutputFracLength;
                roundMode=dtInfo.RoundingMethod;
                ovrflMode=dtInfo.OverflowAction;
            else

                accDTMode=5;
                accWLVal=32;
                accFLVal=16;
                outDTMode=4;
                outWLVal=32;
                outFLVal=16;
                roundMode=3;
                ovrflMode=1;
            end






            obj.compSetParameters({...
            obj.IntegrationPeriod,...
            obj.Offset,...
            double(~obj.DecimateOutput),...
            accDTMode,...
            accWLVal,...
            accFLVal,...
            outDTMode,...
            outWLVal,...
            outFLVal,...
            roundMode,...
            ovrflMode});
        end
    end

    methods(Access=protected)

        function flag=isInactivePropertyImpl(obj,prop)
            if obj.FullPrecisionOverride


                props={'RoundingMethod',...
                'OverflowAction',...
                'AccumulatorDataType',...
                'CustomAccumulatorDataType',...
                'OutputDataType',...
                'CustomOutputDataType'};

            elseif(strcmpi(obj.AccumulatorDataType,'Full precision')&&...
                strcmpi(obj.OutputDataType,'Same as accumulator'))



                props={'RoundingMethod',...
                'OverflowAction',...
                'CustomAccumulatorDataType',...
                'CustomOutputDataType'};

            else


                props={};
                if~matlab.system.isSpecifiedTypeMode(obj.AccumulatorDataType)
                    props{end+1}='CustomAccumulatorDataType';
                end
                if~matlab.system.isSpecifiedTypeMode(obj.OutputDataType)
                    props{end+1}='CustomOutputDataType';
                end
            end
            flag=ismember(prop,props);
        end

        function setPortDataTypeConnections(obj)





            if isInputFloatingPoint(obj,1)||...
                strcmp(obj.OutputDataType,'Same as input')||...
                (...
                strcmp(obj.OutputDataType,'Same as accumulator')&&...
                strcmp(obj.AccumulatorDataType,'Same as input')...
                )
                setPortDataTypeConnection(obj,1,1);
            end

        end
    end

    methods(Static)
        function helpFixedPoint






            matlab.system.dispFixptHelp('comm.IntegrateAndDumpFilter',...
            comm.IntegrateAndDumpFilter.getDisplayFixedPointPropertiesImpl);
        end
    end

    methods(Static,Hidden)
        function a=getAlternateBlock
            a='commfilt2/Integrate and Dump';
        end

        function props=getDisplayPropertiesImpl()
            props={...
            'IntegrationPeriod',...
            'Offset',...
            'DecimateOutput'};
        end

        function props=getDisplayFixedPointPropertiesImpl()
            props={...
            'FullPrecisionOverride',...
            'RoundingMethod',...
            'OverflowAction',...
            'AccumulatorDataType',...
            'CustomAccumulatorDataType',...
            'OutputDataType',...
            'CustomOutputDataType'};
        end


        function props=getValueOnlyProperties()
            props={'IntegrationPeriod'};
        end
        function y=hasEmptyGeneratedTerminateFcn()




            y=true;
        end
    end
end
