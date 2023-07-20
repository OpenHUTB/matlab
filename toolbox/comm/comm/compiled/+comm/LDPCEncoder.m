classdef LDPCEncoder<matlab.system.SFunSystem




































































%#function mcomldpcencode

    properties(Nontunable)















        ParityCheckMatrix=dvbs2ldpc(1/2);
    end

    properties(Access=private)
NumInfoBits
NumParityBits
EncodingMethod
MatrixA_RowIndices
MatrixA_RowStartLoc
MatrixA_ColumnSum
MatrixB_RowIndices
MatrixB_RowStartLoc
MatrixB_ColumnSum
MatrixL_RowIndices
MatrixL_RowStartLoc
MatrixL_ColumnSum
RowOrder
    end

    methods
        function obj=LDPCEncoder(varargin)
            coder.allowpcode('plain');
            obj@matlab.system.SFunSystem('mcomldpcencode');
            setProperties(obj,nargin,varargin{:},'ParityCheckMatrix');
            setVarSizeAllowedStatus(obj,false);
            determineEncoderParameters(obj,obj.ParityCheckMatrix)
        end
    end

    methods(Hidden)
        function setParameters(obj)





            obj.compSetParameters({...
            obj.NumInfoBits,...
            obj.NumParityBits,...
            obj.EncodingMethod,...
            obj.MatrixA_RowIndices,...
            obj.MatrixA_RowStartLoc,...
            obj.MatrixA_ColumnSum,...
            obj.MatrixB_RowIndices,...
            obj.MatrixB_RowStartLoc,...
            obj.MatrixB_ColumnSum,...
            obj.MatrixL_RowIndices,...
            obj.MatrixL_RowStartLoc,...
            obj.MatrixL_ColumnSum,...
            obj.RowOrder...
            });
        end
    end

    methods(Static,Hidden)
        function a=getAlternateBlock
            a='commblkcod2/LDPC Encoder';
        end

        function props=getDisplayPropertiesImpl()
            props={...
            'ParityCheckMatrix',...
            };
        end


        function props=getValueOnlyProperties()
            props={'ParityCheckMatrix'};
        end
        function y=hasEmptyGeneratedTerminateFcn()




            y=true;
        end
    end

    methods(Access=protected)
        function setPortDataTypeConnections(obj)
            setPortDataTypeConnection(obj,1,1);
        end
    end

    methods
        function set.ParityCheckMatrix(obj,val)
            if issparse(val)
                validateattributes(val,{'numeric','logical'},{'binary'},'','ParityCheckMatrix');%#ok<*EMCA>
            else
                validateattributes(val,{'numeric'},{'ncols',2,'positive','integer','finite'},'','ParityCheckMatrix');
            end

            determineEncoderParameters(obj,val);

            if issparse(val)

                obj.ParityCheckMatrix=logical(val);
            else
                obj.ParityCheckMatrix=val;
            end
        end
    end

    methods(Access=private)
        function determineEncoderParameters(obj,parityMat)
            if~issparse(parityMat)
                parityMat=sparse(double(parityMat(:,1)),double(parityMat(:,2)),1);
            end
            params=getLDPCEncoderParameters(parityMat);
            params=rmfield(params,'BlockLength');
            params=rmfield(params,'EncodingAlgorithm');
            fNames=fieldnames(params);
            for p=1:length(fNames)
                obj.(fNames{p})=params.(fNames{p});
            end
        end
    end
end

