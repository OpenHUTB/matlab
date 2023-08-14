classdef QPSKDemodulator<comm.internal.DemodulatorSoftDecision&comm.internal.ConstellationBase

















































































%#function mcompskdemod

%#ok<*EMCLS>
%#ok<*EMCA>

    properties(Nontunable)






        DecisionMethod='Hard decision';





        VarianceSource='Property';




        PhaseOffset=pi/4;







        SymbolMapping='Gray';












        DerotateFactorDataType='Same word length as input';







        CustomDerotateFactorDataType=numerictype([],16);
    end

    properties(Nontunable)








        BitOutput=false;
    end

    properties(Constant,Hidden)
        SymbolMappingSet=comm.CommonSets.getSet('BinaryOrGray');
        DecisionMethodSet=comm.CommonSets.getSet('DecisionOptions');
        VarianceSourceSet=comm.CommonSets.getSet('SpecifyInputs');
        DerotateFactorDataTypeSet=dsp.CommonSets.getSet(...
        'FixptModeUnscaled');
    end

    methods

        function obj=QPSKDemodulator(varargin)
            coder.allowpcode('plain');
            obj@comm.internal.DemodulatorSoftDecision('mcompskdemod');
            setProperties(obj,nargin,varargin{:},'PhaseOffset');
        end

        function set.CustomDerotateFactorDataType(obj,val)
            validateCustomDataType(obj,'CustomDerotateFactorDataType',val,...
            {'AUTOSIGNED','NOTSCALED'});
            obj.CustomDerotateFactorDataType=val;
        end
    end

    methods(Hidden)
        function setParameters(obj)

            outputFormatIdx=~obj.BitOutput+1;
            symbolMappingIdx=getIndex(obj.SymbolMappingSet,...
            obj.SymbolMapping);
            outputDataTypeIdx=getOutputDataTypeIndex(obj);
            decisionMethodIdx=getIndex(obj.DecisionMethodSet,...
            obj.DecisionMethod);
            varianceSourceIdx=getIndex(obj.VarianceSourceSet,...
            obj.VarianceSource);
            derotateFactorDataTypeIdx=getIndex(obj.DerotateFactorDataTypeSet,...
            obj.DerotateFactorDataType);




            obj.compSetParameters({...
            4,...
            outputFormatIdx,...
            symbolMappingIdx,...
            0:3,...
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
            if~obj.BitOutput

                props(end+1:end+3)=[{'DecisionMethod'},{'VarianceSource'},...
                {'Variance'}];
            elseif strcmp(obj.DecisionMethod,'Hard decision')

                props(end+1:end+2)=[{'VarianceSource'},{'Variance'}];
            elseif strcmp(obj.VarianceSource,'Input port')


                props(end+1:end+2)=[{'Variance'},{'OutputDataType'}];
            else


                props{end+1}='OutputDataType';
            end





            if(obj.BitOutput&&~strcmp(obj.DecisionMethod,'Hard decision'))
                props=[props,{...
                'DerotateFactorDataType','CustomDerotateFactorDataType'}];
            else
                if~matlab.system.isSpecifiedTypeMode(obj.DerotateFactorDataType)
                    props{end+1}='CustomDerotateFactorDataType';
                end
            end
            flag=ismember(prop,props);
        end
    end

    methods(Static)
        function helpFixedPoint






            matlab.system.dispFixptHelp('comm.QPSKDemodulator',...
            comm.QPSKDemodulator.getDisplayFixedPointPropertiesImpl);
        end
    end

    methods(Static,Hidden)
        function a=getAlternateBlock
            a='commdigbbndpm3/QPSK Demodulator Baseband';
        end

        function props=getDisplayPropertiesImpl()
            props={...
            'PhaseOffset',...
            'BitOutput',...
            'SymbolMapping',...
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

