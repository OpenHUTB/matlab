classdef ACCUMLayer<nnet.cnn.layer.Layer&nnet.internal.cnn.layer.Externalizable



















































    properties(Dependent)



Name
    end

    properties(SetAccess=private,Dependent)



InputSize




OutputMode



HasStateInputs



HasStateOutputs
    end


    properties(Dependent)
AccumState
    end

    properties(SetAccess=private,Hidden,Dependent)
OutputSize


OutputState
    end

    methods
        function this=ACCUMLayer(privateLayer)
            this.PrivateLayer=privateLayer;
        end

        function val=get.Name(this)
            val=this.PrivateLayer.Name;
        end

        function this=set.Name(this,val)
            iAssertValidLayerName(val);
            this.PrivateLayer.Name=char(val);
        end

        function val=get.InputSize(this)
            val=this.PrivateLayer.InputSize;
            if isempty(val)
                val='auto';
            end
        end

        function val=get.OutputMode(this)
            val=iGetOutputMode(this.PrivateLayer.ReturnSequence);
        end

        function val=get.HasStateInputs(this)
            val=this.PrivateLayer.HasStateInputs;
        end

        function val=get.HasStateOutputs(this)
            val=this.PrivateLayer.HasStateOutputs;
        end

        function val=get.AccumState(this)
            if this.HasStateInputs
                val=[];
            else
                val=gather(this.PrivateLayer.AccumState.Value);
                if isdlarray(val)
                    val=extractdata(val);
                end
            end
        end

        function this=set.AccumState(this,value)
            if this.HasStateInputs
                error(message('nnet_cnn:layer:LSTMLayer:SettingStateWithStateInputs',"'AccumState'"));
            end
            value=iGatherAndValidateParameter(value,'default',[this.InputSize,1]);

            this.PrivateLayer.InitialAccumState=value;
            this.PrivateLayer.AccumState.Value=value;
        end

        function val=get.OutputSize(this)
            val=this.InputSize;
        end

        function val=get.OutputState(this)
            val=this.AccumState;
        end

        function out=saveobj(this)
            privateLayer=this.PrivateLayer;
            out.Version=5.0;
            out.Name=privateLayer.Name;
            out.InputSize=privateLayer.InputSize;
            out.ReturnSequence=privateLayer.ReturnSequence;
            out.HasStateInputs=privateLayer.HasStateInputs;
            out.HasStateOutputs=privateLayer.HasStateOutputs;
            out.AccumState=toStruct(privateLayer.AccumState);
            out.InitialAccumState=gather(privateLayer.InitialAccumState);
        end
    end

    methods(Static)
        function this=loadobj(in)
            if in.Version<=1.0
                in=iUpgradeVersionOneToVersionTwo(in);
            end
            if in.Version<=2.0
                in=iUpgradeVersionTwoToVersionThree(in);
            end
            if in.Version<=3.0
                in=iUpgradeVersionThreeToVersionFour(in);
            end
            if in.Version<=4.0
                in=iUpgradeVersionFourToVersionFive(in);
            end
            internalLayer=ACCUM(in.Name,...
            in.InputSize,...
            true,...
            in.ReturnSequence,...
            'tanh',...
            'sigmoid',...
            in.HasStateInputs,...
            in.HasStateOutputs);

            internalLayer.AccumState=nnet.internal.cnn.layer.dynamic.TrainingDynamicParameter.fromStruct(in.AccumState);
            internalLayer.InitialAccumState=in.InitialAccumState;

            this=nnet.cnn.layer.ACCUM2Layer(internalLayer);
        end
    end

    methods(Hidden,Access=protected)
        function[description,type]=getOneLineDisplay(obj)
            description='accum';
            type='Accum';
        end

        function groups=getPropertyGroups(this)
            generalParameters={'Name',...
            'InputNames',...
            'OutputNames',...
            'NumInputs',...
            'NumOutputs',...
            'HasStateInputs',...
            'HasStateOutputs'};
            hyperParameters={'InputSize',...
            'OutputMode'};

            learnableParameters={};

            stateParameters={'AccumState'};
            groups=[
            this.propertyGroupGeneral(generalParameters)
            this.propertyGroupHyperparameters(hyperParameters)
            this.propertyGroupLearnableParameters(learnableParameters)
            this.propertyGroupDynamicParameters(stateParameters)
            ];
        end

        function footer=getFooter(this)
            variableName=inputname(1);
            footer=this.createShowAllPropertiesFooter(variableName);
        end

        function val=getFactor(this,val)
            if isscalar(val)

            elseif numel(val)==(4*this.NumHiddenUnits)
                val=val(1:this.NumHiddenUnits:end);
                val=val(:)';
            else

            end
        end

        function val=setFactor(this,val)
            if isscalar(val)

            elseif numel(val)==4


                expandedValues=repelem(val,this.NumHiddenUnits);
                val=expandedValues(:);
            else

            end
        end
    end
end

function messageString=iGetMessageString(varargin)
    messageString=getString(message(varargin{:}));
end

function mode=iGetOutputMode(tf)
    if tf
        mode='sequence';
    else
        mode='last';
    end
end

function iCheckFactorDimensions(value)
    dim=numel(value);
    if~(dim==1||dim==4)
        exception=MException(message('nnet_cnn:layer:LSTMLayer:InvalidFactor'));
        throwAsCaller(exception);
    end
end

function iAssertValidFactor(value)
    validateattributes(value,{'numeric'},{'vector','real','nonnegative','finite'});
end


function initializer=iInitializerFactory(varargin)
    initializer=nnet.internal.cnn.layer.learnable.initializer.initializerFactory(varargin{:});
end

function tf=iIsCustomInitializer(init)
    tf=nnet.internal.cnn.layer.learnable.initializer.util.isCustomInitializer(init);
end

function iAssertValidLayerName(name)
    iEvalAndThrow(@()...
    nnet.internal.cnn.layer.paramvalidation.validateLayerName(name));
end

function S=iUpgradeVersionOneToVersionTwo(S)



    S.Version=2;
    S.AccumState=toStruct(S.AccumState);

end

function S=iUpgradeVersionTwoToVersionThree(S)


    S.Version=3;
end

function S=iUpgradeVersionThreeToVersionFour(S)



    S.Version=4;
end

function S=iUpgradeVersionFourToVersionFive(S)
    S.Version=5;
    S.HasStateInputs=false;
    S.HasStateOutputs=false;
end

function s=iAddInitializerToLearnable(s,name,arguments)
    s.Initializer=struct('Class',...
    "nnet.internal.cnn.layer.learnable.initializer."+name,...
    'ConstructorArguments',arguments);
end

function varargout=iEvalAndThrow(func)

    try
        [varargout{1:nargout}]=func();
    catch exception
        throwAsCaller(exception)
    end
end

function value=iGatherAndValidateParameter(varargin)
    try
        value=nnet.internal.cnn.layer.paramvalidation...
        .gatherAndValidateNumericParameter(varargin{:});
    catch exception
        throwAsCaller(exception)
    end
end

function dlX=iMakeSizeOnlyArray(varargin)
    dlX=deep.internal.PlaceholderArray(varargin{:});
end
