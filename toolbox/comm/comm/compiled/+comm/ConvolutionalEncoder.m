classdef ConvolutionalEncoder<matlab.system.SFunSystem



























































































%#function mcomconvenc2

%#ok<*EMCLS>
%#ok<*EMCA>

    properties(Nontunable)







        TrellisStructure=poly2trellis(7,[171,133]);






















        TerminationMethod='Continuous';








        PuncturePatternSource='None';







        PuncturePattern=[1;1;0;1;0;1];







        ResetInputPort(1,1)logical=false;








        DelayedResetAction(1,1)logical=false;





        InitialStateInputPort(1,1)logical=false;





        FinalStateOutputPort(1,1)logical=false;
    end

    properties(Constant,Hidden)
        TerminationMethodSet=comm.CommonSets.getSet('TerminationMethod');
        PuncturePatternSourceSet=comm.CommonSets.getSet('NoneOrProperty');
    end

    methods
        function obj=ConvolutionalEncoder(varargin)
            coder.allowpcode('plain');
            obj@matlab.system.SFunSystem('mcomconvenc2');
            setProperties(obj,nargin,varargin{:},'TrellisStructure');
            setEmptyAllowedStatus(obj,true);
        end
    end

    methods(Hidden)
        function setParameters(obj)
            terminationMethodIdx=getIndex(obj.TerminationMethodSet,...
            obj.TerminationMethod);


            if(terminationMethodIdx==1&&obj.ResetInputPort)
                terminationMethodIdx=4;
            end

            [isOk,status]=istrellis(obj.TrellisStructure);
            coder.internal.errorIf(~isOk,'comm:ConvolutionalEncoder:InvalidTrellis',status);
            trellisParams=commblksGetTrellisInfo(obj.TrellisStructure);



            punctureIdx=getIndex(obj.PuncturePatternSourceSet,...
            obj.PuncturePatternSource);
            if punctureIdx==2&&terminationMethodIdx~=3
                punctureCode=1;
            else
                punctureCode=0;
            end



            if obj.InitialStateInputPort&&terminationMethodIdx==2
                inputInitialState=1;
            else
                inputInitialState=0;
            end



            if obj.FinalStateOutputPort&&terminationMethodIdx~=3
                outputFinalState=1;
            else
                outputFinalState=0;
            end





            obj.compSetParameters({...
            trellisParams.k,...
            trellisParams.n,...
            trellisParams.numStates,...
            trellisParams.outputs,...
            trellisParams.nextStates,...
            terminationMethodIdx,...
            inputInitialState,...
            outputFinalState,...
            punctureCode,...
            obj.PuncturePattern,...
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
            switch prop
            case 'ResetInputPort'
                flag=~strcmp(obj.TerminationMethod,'Continuous');
            case 'DelayedResetAction'
                flag=~strcmp(obj.TerminationMethod,'Continuous')||...
                ~obj.ResetInputPort;
            case 'InitialStateInputPort'
                flag=~strcmp(obj.TerminationMethod,'Truncated');
            case{'FinalStateOutputPort','PuncturePatternSource'}
                flag=strcmp(obj.TerminationMethod,'Terminated');
            case 'PuncturePattern'
                flag=strcmp(obj.TerminationMethod,'Terminated')||...
                ~strcmp(obj.PuncturePatternSource,'Property');
            otherwise
                flag=false;
            end
        end

        function setPortDataTypeConnections(obj)
            setPortDataTypeConnection(obj,1,1);
        end
    end

    methods(Static,Hidden)
        function a=getAlternateBlock
            a='commcnvcod2/Convolutional Encoder';
        end

        function props=getDisplayPropertiesImpl()
            props={...
            'TrellisStructure',...
            'TerminationMethod',...
            'ResetInputPort',...
            'DelayedResetAction',...
            'InitialStateInputPort',...
            'FinalStateOutputPort',...
            'PuncturePatternSource',...
            'PuncturePattern'};
        end


        function props=getValueOnlyProperties()
            props={'TrellisStructure'};
        end
        function y=hasEmptyGeneratedTerminateFcn()




            y=true;
        end
    end
end
