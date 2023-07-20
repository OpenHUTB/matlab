classdef PNSequence<matlab.system.SFunSystem







































































































%#function mcompnseq3
%#function shift2mask

%#ok<*EMCLS>
%#ok<*EMCA>

    properties(Nontunable)













        Polynomial='z^6 + z + 1'










        InitialConditionsSource='Property'










        InitialConditions=[0,0,0,0,0,1]









        MaskSource='Property'





















        Mask=0







        MaximumOutputSize=[10,1]













        SamplesPerFrame=1




        NumPackedBits=8







        OutputDataType='double'










        VariableSizeOutput(1,1)logical=false





        ResetInputPort(1,1)logical=false








        BitPackedOutput(1,1)logical=false






        SignedOutput(1,1)logical=false
    end

    properties(Constant,Hidden)
        MaskSourceSet=comm.CommonSets.getSet('SpecifyInputs')
        InitialConditionsSourceSet=comm.CommonSets.getSet('SpecifyInputs')
    end

    properties(Hidden,Transient)
        OutputDataTypeSet=matlab.system.StringSet({'double'})
    end

    properties(Hidden,Transient)
pOutputUnpacked
pOutputPacked
    end
    properties(Access=private)
        pOutputUnpackedSet=comm.CommonSets.getSet('DoubleLogicalSmallestUnsigned')
        pOutputPackedSet=matlab.system.StringSet({'double','Smallest integer'})
    end

    methods
        function obj=PNSequence(varargin)
            coder.allowpcode('plain');
            obj@matlab.system.SFunSystem('mcompnseq3');
            setProperties(obj,nargin,varargin{:});
            setVarSizeAllowedStatus(obj,false);
            setFrameStatus(obj,false);
        end

        function value=get.OutputDataTypeSet(obj)
            if obj.BitPackedOutput
                value=obj.pOutputPackedSet;
            else
                value=obj.pOutputUnpackedSet;
            end
        end

        function set.OutputDataTypeSet(~,~)
        end

        function set.SamplesPerFrame(obj,val)
            validateattributes(val,{'numeric'},...
            {'real','positive','finite','scalar'},'','SamplesPerFrame');
            obj.SamplesPerFrame=val;
        end
    end

    methods(Hidden)
        function setParameters(obj)
            initCondSourceIdx=getIndex(obj.InitialConditionsSourceSet,...
            obj.InitialConditionsSource);

            maskSourceIdx=getIndex(obj.MaskSourceSet,obj.MaskSource);

            outputDataTypePackedIdx=getIndex(obj.pOutputPackedSet,...
            obj.OutputDataType);

            outputDataTypeUnpackedIdx=getIndex(obj.pOutputUnpackedSet,...
            obj.OutputDataType);

            if isempty(outputDataTypePackedIdx)
                if obj.BitPackedOutput
                    coder.internal.errorIf(true,'comm:system:PNSequence:invalidOutputDataType',obj.OutputDataType);
                else
                    outputDataTypePackedIdx=1;
                end
            end






            [eStr,poly,shift]=commblkpnseq3([],'init',...
            obj.Polynomial,maskSourceIdx,obj.Mask);
            if eStr.ecode
                coder.internal.errorIf(true,'comm:commblkpnseq3:InvalidGenPoly');
            end

            obj.compSetParameters({...
            poly,...
            initCondSourceIdx,...
            obj.InitialConditions,...
            maskSourceIdx,...
            shift,...
            double(obj.VariableSizeOutput),...
            1,...
            obj.MaximumOutputSize,...
            1/obj.SamplesPerFrame,...
            obj.SamplesPerFrame,...
            double(obj.ResetInputPort),...
            double(obj.BitPackedOutput),...
            outputDataTypeUnpackedIdx,...
            obj.NumPackedBits,...
            double(obj.SignedOutput),...
outputDataTypePackedIdx...
            });
        end
    end

    methods(Access=protected)
        function flag=isInactivePropertyImpl(obj,prop)
            if obj.VariableSizeOutput
                props={'SamplesPerFrame'};
            else
                props={'MaximumOutputSize'};
            end
            if~obj.BitPackedOutput
                props=[props,{'NumPackedBits','SignedOutput'}];
            end
            if strcmp(obj.MaskSource,'Input port')
                props{end+1}='Mask';
            end
            if strcmp(obj.InitialConditionsSource,'Input port')
                props{end+1}='InitialConditions';
                props{end+1}='ResetInputPort';
            end
            flag=ismember(prop,props);
        end

    end

    methods(Static,Hidden)
        function a=getAlternateBlock
            a='commseqgen3/PN Sequence Generator';
        end

        function props=getDisplayPropertiesImpl()
            props={...
            'Polynomial',...
            'InitialConditionsSource',...
            'InitialConditions',...
            'MaskSource',...
            'Mask',...
            'VariableSizeOutput',...
            'MaximumOutputSize',...
            'SamplesPerFrame',...
            'ResetInputPort',...
            'BitPackedOutput',...
            'NumPackedBits',...
            'SignedOutput',...
'OutputDataType'...
            };
        end
        function y=hasEmptyGeneratedTerminateFcn()




            y=true;
        end
    end
end
