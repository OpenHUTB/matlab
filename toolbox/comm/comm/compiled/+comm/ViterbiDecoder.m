classdef ViterbiDecoder<matlab.system.SFunSystem



































































































%#function mcomviterbi2

%#ok<*EMCLS>
%#ok<*EMCA>

    properties(Nontunable)







        TrellisStructure=poly2trellis(7,[171,133]);






















        InputFormat='Unquantized';




        SoftInputWordLength=4;






        InvalidQuantizedInputAction='Ignore';













        TracebackDepth=34;















        TerminationMethod='Continuous';






        PuncturePatternSource='None';







        PuncturePattern=[1;1;0;1;0;1];







        OutputDataType='Full precision';
























        StateMetricDataType='Custom';







        CustomStateMetricDataType=numerictype([],16);







        ResetInputPort(1,1)logical=false;








        DelayedResetAction(1,1)logical=false;










        ErasuresInputPort(1,1)logical=false;
    end

    properties(Constant,Hidden)
        InputFormatSet=matlab.system.StringSet({'Unquantized','Hard','Soft'});
        InvalidQuantizedInputActionSet=matlab.system.StringSet(...
        {'Ignore','Error'});
        TerminationMethodSet=comm.CommonSets.getSet('TerminationMethod');
        PuncturePatternSourceSet=comm.CommonSets.getSet('NoneOrProperty');
        OutputDataTypeSet=comm.CommonSets.getSet('BitDataType');
        StateMetricDataTypeSet=dsp.CommonSets.getSet('FixptModeInheritUnscaled');
    end

    methods
        function obj=ViterbiDecoder(varargin)
            coder.allowpcode('plain');
            obj@matlab.system.SFunSystem('mcomviterbi2');
            setProperties(obj,nargin,varargin{:},'TrellisStructure');

        end

        function set.CustomStateMetricDataType(obj,val)
            validateCustomDataType(obj,'CustomStateMetricDataType',val,...
            {'AUTOSIGNED','NOTSCALED'});
            obj.CustomStateMetricDataType=val;
        end
    end

    methods(Hidden)
        function setParameters(obj)
            inputFormatIdx=getIndex(obj.InputFormatSet,...
            obj.InputFormat);
            terminationMethodIdx=getIndex(obj.TerminationMethodSet,...
            obj.TerminationMethod);
            outputDataTypeIdx=getIndex(obj.OutputDataTypeSet,...
            obj.OutputDataType);
            invalidQuantizedInputActionIdx=...
            getIndex(obj.InvalidQuantizedInputActionSet,...
            obj.InvalidQuantizedInputAction)-1;


            [isOk,status]=istrellis(obj.TrellisStructure);
            coder.internal.errorIf(~isOk,'comm:ViterbiDecoder:InvalidTrellis',status);
            trellisParams=commblksGetTrellisInfo(obj.TrellisStructure);


            if terminationMethodIdx==1
                resetPort=double(obj.ResetInputPort);
            else
                resetPort=0;
            end


            punctureIdx=getIndex(obj.PuncturePatternSourceSet,...
            obj.PuncturePatternSource);
            if punctureIdx==2
                punctureCode=1;
            else
                punctureCode=0;
            end


            stateMetricWordLength=obj.CustomStateMetricDataType.WordLength;






            obj.compSetParameters({...
            trellisParams.k,...
            trellisParams.n,...
            trellisParams.numStates,...
            trellisParams.outputs,...
            trellisParams.nextStates,...
            inputFormatIdx,...
            obj.SoftInputWordLength,...
            obj.TracebackDepth,...
            terminationMethodIdx,...
            resetPort,...
outputDataTypeIdx...
            ,invalidQuantizedInputActionIdx,...
            punctureCode,...
            obj.PuncturePattern,...
            double(obj.ErasuresInputPort),...
            stateMetricWordLength,...
            double(obj.DelayedResetAction)...
            });
        end
        function y=supportsUnboundedIO(obj)
            if strcmp(obj.PuncturePatternSource,'None')
                y=true;
            else
                y=false;
            end
        end
    end

    methods(Access=protected)
        function flag=isInactivePropertyImpl(obj,prop)
            props={};
            switch obj.InputFormat
            case 'Unquantized'
                props=[props,...
                {'InvalidQuantizedInputAction',...
                'SoftInputWordLength',...
                'StateMetricDataType',...
                'CustomStateMetricDataType'}];
            case 'Hard'
                props=[props,...
                {'SoftInputWordLength'}];

            end
            if~strcmp(obj.TerminationMethod,'Continuous')
                props=[props,...
                {'ResetInputPort','DelayedResetAction'}];
            end
            if strcmp(obj.PuncturePatternSource,'None')
                props=[props,{'PuncturePattern'}];
            end

            if~matlab.system.isSpecifiedTypeMode(obj.StateMetricDataType)
                props{end+1}='CustomStateMetricDataType';
            end

            if~obj.ResetInputPort
                props=[props,{'DelayedResetAction'}];
            end
            flag=ismember(prop,props);

        end

        function setPortDataTypeConnections(obj)


            if strcmp(obj.OutputDataType,'Full precision')&&isInputFloatingPoint(obj,1)
                setPortDataTypeConnection(obj,1,1);
            end

        end
    end

    methods(Static)
        function helpFixedPoint






            matlab.system.dispFixptHelp('comm.ViterbiDecoder',...
            comm.ViterbiDecoder.getDisplayFixedPointPropertiesImpl);
        end
    end

    methods(Static,Hidden)
        function a=getAlternateBlock
            a='commcnvcod2/Viterbi Decoder';
        end

        function props=getDisplayPropertiesImpl()
            props={...
            'TrellisStructure',...
            'InputFormat',...
            'SoftInputWordLength',...
            'InvalidQuantizedInputAction',...
            'TracebackDepth',...
            'TerminationMethod',...
            'ResetInputPort',...
            'DelayedResetAction',...
            'PuncturePatternSource',...
            'PuncturePattern',...
            'ErasuresInputPort',...
            'OutputDataType'};
        end

        function props=getDisplayFixedPointPropertiesImpl()
            props={'StateMetricDataType','CustomStateMetricDataType'};

        end


        function props=getValueOnlyProperties()
            props={'TrellisStructure'};
        end
        function y=hasEmptyGeneratedTerminateFcn()




            y=true;
        end
    end

end

