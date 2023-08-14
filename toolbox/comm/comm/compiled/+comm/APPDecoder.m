classdef APPDecoder<matlab.system.SFunSystem































































































%#function mcomapp

%#ok<*EMCLS>
%#ok<*EMCA>

    properties(Nontunable)







        TrellisStructure=poly2trellis(7,[171,133],171);










        TerminationMethod='Truncated';







        Algorithm='Max*';







        NumScalingBits=3;




        CodedBitLLROutputPort(1,1)logical=true;
    end

    properties(Constant,Hidden)
        TerminationMethodSet=matlab.system.StringSet({'Truncated',...
        'Terminated'});
        AlgorithmSet=comm.CommonSets.getSet('Algorithm');
    end

    methods
        function obj=APPDecoder(varargin)
            coder.allowpcode('plain');
            obj@matlab.system.SFunSystem('mcomapp');
            setProperties(obj,nargin,varargin{:},'TrellisStructure');
            setVarSizeAllowedStatus(obj,true);
            setEmptyAllowedStatus(obj,true);
        end
    end

    methods(Hidden)
        function setParameters(obj)
            terminationMethodIdx=getIndex(obj.TerminationMethodSet,...
            obj.TerminationMethod);
            algorithmIdx=getIndex(obj.AlgorithmSet,obj.Algorithm);

            params=commblkapp(obj,'init',...
            obj.TrellisStructure,...
            terminationMethodIdx,...
            algorithmIdx,...
            obj.NumScalingBits);
            if~isempty(params.status)
                coder.internal.errorIf(true,params.id);
            end




            obj.compSetParameters({...
            params.k,...
            params.n,...
            params.numStates,...
            params.outputs,...
            params.nextStates,...
            params.termMethod,...
            algorithmIdx,...
            params.maxStarTable,...
            params.maxStarTableLen,...
            params.maxStarScale,...
            double(~obj.CodedBitLLROutputPort)...
            });
        end
    end

    methods(Access=protected)
        function flag=isInactivePropertyImpl(obj,prop)
            props={};
            if~strcmp(obj.Algorithm,'Max*')
                props={'NumScalingBits'};
            end
            flag=ismember(prop,props);
        end

        function setPortDataTypeConnections(obj)
            setPortDataTypeConnection(obj,1,1);
            if(obj.CodedBitLLROutputPort)
                setPortDataTypeConnection(obj,1,2);
            end
        end
    end

    methods(Static,Hidden)
        function a=getAlternateBlock
            a='commcnvcod2/APP Decoder';
        end

        function props=getDisplayPropertiesImpl()
            props={...
            'TrellisStructure',...
            'TerminationMethod',...
            'Algorithm',...
            'NumScalingBits',...
            'CodedBitLLROutputPort'};
        end


        function props=getValueOnlyProperties()
            props={'TrellisStructure'};
        end
        function y=hasEmptyGeneratedTerminateFcn()




            y=true;
        end
    end
end

