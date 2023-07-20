classdef BPSKDemodulator<matlab.system.SFunSystem&comm.internal.ConstellationBase













































































%#function mcompskdemod

%#ok<*EMCLS>
%#ok<*EMCA>

    properties









        Variance=1;
    end

    properties(Nontunable)



        PhaseOffset=0;




        DecisionMethod='Hard decision';





        VarianceSource='Property';



















        OutputDataType='Full precision';










        DerotateFactorDataType='Same word length as input';








        CustomDerotateFactorDataType=numerictype([],16);
    end

    properties(Constant,Hidden)
        DecisionMethodSet=comm.CommonSets.getSet('DecisionOptions');
        VarianceSourceSet=comm.CommonSets.getSet('SpecifyInputs');
        DerotateFactorDataTypeSet=dsp.CommonSets.getSet(...
        'FixptModeUnscaled');
        OutputDataTypeSet=comm.CommonSets.getSet('BitDataType');
    end

    methods

        function obj=BPSKDemodulator(varargin)
            coder.allowpcode('plain');
            obj@matlab.system.SFunSystem('mcompskdemod');
            setProperties(obj,nargin,varargin{:},'PhaseOffset');
            setForceInputRealToComplex(obj,1,true);
        end

        function set.CustomDerotateFactorDataType(obj,val)
            validateCustomDataType(obj,'CustomDerotateFactorDataType',val,...
            {'AUTOSIGNED','NOTSCALED'});
            obj.CustomDerotateFactorDataType=val;
        end
    end

    methods(Hidden)
        function setParameters(obj)

            outputDataTypeIdx=getIndex(obj.OutputDataTypeSet,...
            obj.OutputDataType);
            decisionMethodIdx=getIndex(obj.DecisionMethodSet,...
            obj.DecisionMethod);
            varianceSourceIdx=getIndex(obj.VarianceSourceSet,...
            obj.VarianceSource);
            derotateFactorDataTypeIdx=getIndex(obj.DerotateFactorDataTypeSet,...
            obj.DerotateFactorDataType);




            obj.compSetParameters({...
            2,...
            1,...
            1,...
            [0,1],...
            obj.PhaseOffset,...
            outputDataTypeIdx,...
            decisionMethodIdx,...
            varianceSourceIdx,...
            obj.Variance,...
            derotateFactorDataTypeIdx,...
            obj.CustomDerotateFactorDataType.WordLength...
            });
        end
        function y=supportsUnboundedIO(~)
            y=true;
        end
    end

    methods(Access=protected)

        function flag=isInactivePropertyImpl(obj,prop)
            props={};
            if strcmp(obj.DecisionMethod,'Hard decision')
                props(end+1:end+2)=[{'VarianceSource'},{'Variance'}];
            elseif strcmp(obj.VarianceSource,'Input port')


                props(end+1:end+2)=[{'Variance'},{'OutputDataType'}];
            else


                props{end+1}='OutputDataType';
            end



            if~strcmp(obj.DecisionMethod,'Hard decision')
                props=[props,{...
                'DerotateFactorDataType','CustomDerotateFactorDataType'}];
            else
                if~matlab.system.isSpecifiedTypeMode(obj.DerotateFactorDataType)
                    props{end+1}='CustomDerotateFactorDataType';
                end
            end
            flag=ismember(prop,props);
        end

        function setPortDataTypeConnections(obj)




            if~strcmp(obj.DecisionMethod,'Hard decision')||...
                (strcmp(obj.OutputDataType,'Full precision')&&isInputFloatingPoint(obj,1))
                setPortDataTypeConnection(obj,1,1);
            end

        end
    end

    methods(Static)
        function helpFixedPoint






            matlab.system.dispFixptHelp('comm.BPSKDemodulator',...
            comm.BPSKDemodulator.getDisplayFixedPointPropertiesImpl);
        end
    end

    methods(Static,Hidden)
        function a=getAlternateBlock
            a='commdigbbndpm3/BPSK Demodulator Baseband';
        end

        function props=getDisplayPropertiesImpl()
            props={...
            'PhaseOffset',...
            'DecisionMethod',...
            'VarianceSource',...
            'Variance',...
            'OutputDataType',...
            };
        end

        function props=getDisplayFixedPointPropertiesImpl()
            props={...
            'DerotateFactorDataType',...
'CustomDerotateFactorDataType'
            };
        end



        function tunePropsMap=getTunablePropertiesMap()
            tunePropsMap.Variance=8;
        end


        function props=getValueOnlyProperties()
            props={'PhaseOffset'};
        end
        function y=hasEmptyGeneratedTerminateFcn()




            y=true;
        end
    end
end

