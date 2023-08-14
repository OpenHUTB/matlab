classdef ACCUM<nnet.internal.cnn.layer.FunctionalStatefulLayer...
    &nnet.internal.cnn.layer.Recurrent...
    &nnet.internal.cnn.layer.CPUFusableLayer




    properties


        LearnableParameters=nnet.internal.cnn.layer.learnable.PredictionLearnableParameter.empty();

        DynamicParameters=nnet.internal.cnn.layer.dynamic.TrainingDynamicParameter.empty();

InitialAccumState


Name



Learnables
    end

    properties(Constant)

        DefaultName='accum'
    end

    properties(SetAccess=private)

InputSize



ReturnSequence

RememberAccumState


Activation


RecurrentActivation


HasStateInputs


HasStateOutputs
    end

    properties(Dependent)


AccumState


State
    end

    properties(SetAccess=protected,GetAccess={?nnet.internal.cnn.dlnetwork,?nnet.internal.cnn.layer.FusedLayer})
        LearnablesNames=[]
    end

    properties(SetAccess=protected)




        IsInFunctionalMode=false


        StateNames=["AccumState"]
    end

    properties(Dependent,SetAccess=private)



HasSizeDetermined


InputNames


OutputNames


NumStates
    end

    properties(Constant,Access=private)
        AccumStateIndex=1;
    end

    methods
        function this=ACCUM(name,inputSize,...
            rememberAccumState,returnSequence,...
            activation,recurrentActivation,hasStateInputs,hasStateOutputs)


            this.Name=name;


            this.InputSize=inputSize;
            this.RememberAccumState=rememberAccumState;
            this.ReturnSequence=returnSequence;
            this.Activation=activation;
            this.RecurrentActivation=recurrentActivation;
            if nargin<9
                hasStateInputs=false;
                hasStateOutputs=false;
            end
            this.HasStateInputs=hasStateInputs;
            this.HasStateOutputs=hasStateOutputs;


            this.AccumState=nnet.internal.cnn.layer.dynamic.TrainingDynamicParameter();

        end

        function[Z,memory]=forward(this,X)

            if~isa(X,'dlarray')
                sz=size(X);
                switch numel(sz)
                case 1
                    X=reshape(X,sz(1),1,1);

                case 2
                    X=reshape(X,sz(1),sz(2),1);
                case 3

                otherwise
                    error("Unexpected input.")
                end
                X=dlarray(X,'CBT');
            end


            dataSize=size(X,finddim(X,"C"));
            miniBatchSize=size(X,finddim(X,"B"));
            numTimeSteps=size(X,finddim(X,"T"));

            if this.ReturnSequence
                Z=zeros(dataSize,miniBatchSize,numTimeSteps,"like",X);
                Z=dlarray(Z,"CBT");
            end

            accumState=this.AccumState.Value;

            for t=1:numTimeSteps


                if this.ReturnSequence
                    Z(:,:,t)=accumState+X(:,:,t);
                end

                accumState=accumState+X(:,:,t);
            end

            if~this.ReturnSequence
                Z=dlarray(accumState,"CBT");
            end

            if isa(Z,'dlarray')
                Z=extractdata(Z);
            end

            memory=struct();
            memory.AccumState=Z(:,:,end);

        end

        function[Z,state]=predict(this,X)


            if nargout==2
                [Z,state]=forward(this,X);
            else
                Z=forward(this,X);
            end
        end

        function[dX,dW]=backward(this,X,Z,dZ,memory,~)

            dX=0;
            dW=0;
        end

        function Zs=forwardExampleInputs(this,Xs)

            X=Xs{1};


            featureSize=getSizeForDims(X,'SC');
            this.assertInputIsScalarInDAGNetwork(featureSize)
            this.assertIsConsistentWithInferredSize(featureSize)
            if this.HasStateInputs
                this.assertValidStateInput(Xs{2});
                this.assertValidStateInput(Xs{3});
            end

            Z=setSizeForDim(X,'S',[]);
            Z=setSizeForDim(Z,'C',this.InputSize);
            if~this.ReturnSequence
                Z=setSizeForDim(Z,'T',[]);
            end



            if ndims(Z)==1
                Z=setSizeForDim(Z,'U',1);
            end




            if this.HasStateOutputs
                state=setSizeForDim(Z,'T',[]);
                Zs={Z,state,state};
            else
                Zs={Z};
            end
        end

        function this=configureForInputs(this,Xs)

            X=Xs{1};


            featureSize=getSizeForDims(X,'SC');
            this.assertInputIsScalarInDAGNetwork(featureSize)
            this.assertIsConsistentWithInferredSize(featureSize)
            this.InputSize=featureSize;
            if this.HasStateInputs
                this.assertValidStateInput(Xs{2});
                this.assertValidStateInput(Xs{3});
            end


            if~this.HasSizeDetermined
                this.InputSize=prod(featureSize);
            end
        end

        function out=forwardPropagateSequenceLength(~,~,~)
            out={};
            error("Temporary internal error: forwardPropagateSequenceLength "+...
            "should not be called on an LSTM layer anymore")
        end

        function this=initializeLearnableParameters(this,~)

        end

        function this=initializeDynamicParameters(this,precision)


            if isempty(this.InitialAccumState)
                parameterSize=[this.InputSize,1];
                this.InitialAccumState=iInitializeConstant(parameterSize,precision);
            else
                this.InitialAccumState=precision.cast(this.InitialAccumState);
            end

            this.AccumState.Value=this.InitialAccumState;
            this.AccumState.Remember=this.RememberAccumState;

            if this.IsInFunctionalMode
                this.AccumState.Value=dlarray(this.AccumState.Value);
            end
        end

        function state=computeState(this,~,Z,memory,~)
            state=cell(1,1);
            if~this.HasStateInputs
                if this.HasStateOutputs

                else
                    state={memory.AccumState(:,:,end)};
                end
            end
        end

        function this=updateState(this,state)
            if~this.HasStateInputs

                this.DynamicParameters(this.AccumStateIndex).Value=state{this.AccumStateIndex};
            end
        end

        function this=resetState(this)
            if~this.HasStateInputs
                accumState=this.InitialAccumState;
                if this.IsInFunctionalMode
                    accumState=dlarray(accumState);
                end


                this.DynamicParameters(this.AccumStateIndex).Value=accumState;
            end
        end


        function this=prepareForTraining(this)




            this.LearnableParameters=nnet.internal.cnn.layer.learnable.convert2training(this.LearnableParameters);
        end

        function this=prepareForPrediction(this)




            this.LearnableParameters=nnet.internal.cnn.layer.learnable.convert2prediction(this.LearnableParameters);
        end

        function this=setupForHostPrediction(this)
        end

        function this=setupForGPUPrediction(this)
        end

        function this=setupForHostTraining(this)
        end

        function this=setupForGPUTraining(this)
        end

        function state=get.AccumState(this)
            state=this.DynamicParameters(this.AccumStateIndex);
        end

        function this=set.AccumState(this,state)
            this.DynamicParameters(this.AccumStateIndex)=state;
        end


        function tf=get.HasSizeDetermined(this)
            tf=~isempty(this.InputSize);
        end


        function state=get.State(this)
            if this.HasStateInputs
                state=nnet.internal.cnn.layer.util.ParameterMarker.create(3);
            else
                state={this.AccumState.Value};
            end
        end

        function this=set.State(this,state)
            marker=nnet.internal.cnn.layer.util.ParameterMarker.isMarker(state);
            if this.HasStateInputs&&~all(marker)
                error(message('nnet_cnn:internal:cnn:layer:LSTM:SettingStateWithStateInputs'));
            end

            accumState=state{this.AccumStateIndex};

            expectedDataClass={'single'};
            expectedClass=[expectedDataClass,{'dlarray'}];
            expectedAttributes={'size',[this.InputSize,NaN]};
            if~marker(1)
                validateattributes(accumState,expectedClass,expectedAttributes);
                if isdlarray(accumState)
                    nnet.internal.cnn.layer.paramvalidation.validateStateDlarray(accumState,expectedDataClass,this.StateNames{1});
                elseif this.IsInFunctionalMode
                    accumState=dlarray(accumState);
                end
                this.AccumState.Value=accumState;
            end

            if~marker(3)
                validateattributes(accumState,expectedClass,expectedAttributes);
                if isdlarray(accumState)
                    nnet.internal.cnn.layer.paramvalidation.validateStateDlarray(accumState,expectedDataClass,this.StateNames{2});
                elseif this.IsInFunctionalMode
                    accumState=dlarray(accumState);
                end
                this.AccumState.Value=accumState;
            end
        end

        function numStates=get.NumStates(this)
            if this.HasStateInputs
                numStates=0;
            else
                numStates=2;
            end
        end

        function names=get.InputNames(this)
            if this.HasStateInputs
                names={'in','hidden','cell'};
            else
                names={'in'};
            end
        end

        function names=get.OutputNames(this)
            if this.HasStateOutputs
                names={'out','hidden','cell'};
            else
                names={'out'};
            end
        end
    end

    methods(Access=private)

        function memory=computeFunctionalState(this,Z,memory)
            if this.HasStateInputs
                memory=nnet.internal.cnn.layer.util.ParameterMarker.create(2);
            elseif this.HasStateOutputs
                memory={stripdims(Z{2}),stripdims(Z{3})};
            else
                memory={memory.AccumState};
            end
        end

        function assertInputIsScalarInDAGNetwork(this,featureSize)
            if~this.IsInFunctionalMode&&~isscalar(featureSize)
                iThrowNonScalarInputSizeError(featureSize);
            end
        end

        function assertIsConsistentWithInferredSize(this,featureSize)
            assert(~this.HasSizeDetermined||isequal(this.InputSize,prod(featureSize)))
        end

        function assertValidStateInput(this,Xs)
            fmt=dims(Xs);
            if contains(fmt,'S')||contains(fmt,'T')||contains(fmt,'U')
                iThrowStateInputMustBeCB();
            end
            stateSize=getSizeForDims(Xs,'C');
            if~isequal(stateSize,this.InputSize)
                iThrowStateInputMustMatchHiddenSize();
            end
        end
    end

    methods(Access=protected)
        function this=setFunctionalStrategy(this)
        end

        function this=initializeStates(this)

            precision=nnet.internal.cnn.util.Precision('single');
            this=initializeDynamicParameters(this,precision);
        end
    end

    methods(Hidden)
        function layerArgs=getFusedArguments(layer)




            layerArgs={'accum',...
            layer.AccumState.Value,...
            layer.Activation,false,...
            layer.ReturnSequence};
        end

        function tf=isFusable(this)

            tf=false;



            if this.HasStateInputs||this.HasStateOutputs
                tf=false;
            end
        end
    end
end

function parameter=iInitializeConstant(parameterSize,precision)
    parameter=precision.cast(zeros(parameterSize));
end

function initializer=iInternalInitializer(name)
    initializer=nnet.internal.cnn.layer.learnable.initializer.initializerFactory(name);
end

function str=iSizeToString(sz)
    str=join(string(sz),matlab.internal.display.getDimensionSpecifier);
end

function iThrowNonScalarInputSizeError(inputSize)
    error(message('nnet_cnn:internal:cnn:layer:LSTM:NonScalarInputSize',iSizeToString(inputSize)));
end

function iThrowStateInputMustBeCB()
    error(message('nnet_cnn:internal:cnn:layer:LSTM:StateInputMustBeCB'));
end

function iThrowStateInputMustMatchHiddenSize()
    error(message('nnet_cnn:internal:cnn:layer:LSTM:StateInputMustMatchHiddenSize'));
end
