classdef BinaryFileReader<matlab.System&matlab.system.mixin.FiniteSource
%#codegen


    properties(Access=private)
cSFunObject
    end

    properties(Access=private,Nontunable)
ConstructorArgs
    end

    properties(Nontunable)
Filename
VideoFormat
FourCharacterCode
BitstreamFormat
OutputSize
VideoComponentCount
LineOrder
ByteOrder
PlayCount
InterlacedVideo
SignedData
VideoComponentBits
VideoComponentSizes
VideoComponentOrder
    end
    properties
    end
    properties(Access=private)

NoTuningBeforeLockingCodeGenError
    end
    methods
        function obj=BinaryFileReader(cnt_dummy,varargin)%#ok<INUSL>
            coder.allowpcode('plain');
            coder.extrinsic('visioncodegen.BinaryFileReader.propListManager');
            coder.extrinsic('visioncodegen.BinaryFileReader.getFieldFromMxStruct');
            if coder.internal.const(~coder.target('Rtw'))
                obj.NoTuningBeforeLockingCodeGenError=true;
            end
            obj.cSFunObject=vision.BinaryFileReader(varargin{:});
            obj.ConstructorArgs=varargin;
            setProperties(obj,nargin-1,varargin{:},'Filename');
            numValueOnlyProps=coder.internal.const(matlab.system.coder.ProcessConstructorArguments.getLastValueOnlyArgIndex(class(obj),varargin{:}));
            s=visioncodegen.BinaryFileReader.propListManager(numValueOnlyProps,'Filename');
            for i=coder.unroll(numValueOnlyProps+1:2:(nargin-1))
                s=visioncodegen.BinaryFileReader.propListManager(s,varargin{i},true);
            end

            propValues=get(obj.cSFunObject);
            if~coder.internal.const(visioncodegen.BinaryFileReader.propListManager(s,'Filename',false))
                val=coder.internal.const(visioncodegen.BinaryFileReader.getFieldFromMxStruct(propValues,'Filename'));
                obj.Filename=val;
            end
            if~coder.internal.const(visioncodegen.BinaryFileReader.propListManager(s,'VideoFormat',false))
                val=coder.internal.const(visioncodegen.BinaryFileReader.getFieldFromMxStruct(propValues,'VideoFormat'));
                obj.VideoFormat=val;
            end
            if~coder.internal.const(visioncodegen.BinaryFileReader.propListManager(s,'FourCharacterCode',false))
                val=coder.internal.const(visioncodegen.BinaryFileReader.getFieldFromMxStruct(propValues,'FourCharacterCode'));
                obj.FourCharacterCode=val;
            end
            if~coder.internal.const(visioncodegen.BinaryFileReader.propListManager(s,'BitstreamFormat',false))
                val=coder.internal.const(visioncodegen.BinaryFileReader.getFieldFromMxStruct(propValues,'BitstreamFormat'));
                obj.BitstreamFormat=val;
            end
            if~coder.internal.const(visioncodegen.BinaryFileReader.propListManager(s,'OutputSize',false))
                val=coder.internal.const(visioncodegen.BinaryFileReader.getFieldFromMxStruct(propValues,'OutputSize'));
                obj.OutputSize=val;
            end
            if~coder.internal.const(visioncodegen.BinaryFileReader.propListManager(s,'VideoComponentCount',false))
                val=coder.internal.const(visioncodegen.BinaryFileReader.getFieldFromMxStruct(propValues,'VideoComponentCount'));
                obj.VideoComponentCount=val;
            end
            if~coder.internal.const(visioncodegen.BinaryFileReader.propListManager(s,'LineOrder',false))
                val=coder.internal.const(visioncodegen.BinaryFileReader.getFieldFromMxStruct(propValues,'LineOrder'));
                obj.LineOrder=val;
            end
            if~coder.internal.const(visioncodegen.BinaryFileReader.propListManager(s,'ByteOrder',false))
                val=coder.internal.const(visioncodegen.BinaryFileReader.getFieldFromMxStruct(propValues,'ByteOrder'));
                obj.ByteOrder=val;
            end
            if~coder.internal.const(visioncodegen.BinaryFileReader.propListManager(s,'PlayCount',false))
                val=coder.internal.const(visioncodegen.BinaryFileReader.getFieldFromMxStruct(propValues,'PlayCount'));
                obj.PlayCount=val;
            end
            if~coder.internal.const(visioncodegen.BinaryFileReader.propListManager(s,'InterlacedVideo',false))
                val=coder.internal.const(visioncodegen.BinaryFileReader.getFieldFromMxStruct(propValues,'InterlacedVideo'));
                obj.InterlacedVideo=val;
            end
            if~coder.internal.const(visioncodegen.BinaryFileReader.propListManager(s,'SignedData',false))
                val=coder.internal.const(visioncodegen.BinaryFileReader.getFieldFromMxStruct(propValues,'SignedData'));
                obj.SignedData=val;
            end
            if~coder.internal.const(visioncodegen.BinaryFileReader.propListManager(s,'VideoComponentBits',false))
                val=coder.internal.const(visioncodegen.BinaryFileReader.getFieldFromMxStruct(propValues,'VideoComponentBits'));
                obj.VideoComponentBits=val;
            end
            if~coder.internal.const(visioncodegen.BinaryFileReader.propListManager(s,'VideoComponentSizes',false))
                val=coder.internal.const(visioncodegen.BinaryFileReader.getFieldFromMxStruct(propValues,'VideoComponentSizes'));
                obj.VideoComponentSizes=val;
            end
            if~coder.internal.const(visioncodegen.BinaryFileReader.propListManager(s,'VideoComponentOrder',false))
                val=coder.internal.const(visioncodegen.BinaryFileReader.getFieldFromMxStruct(propValues,'VideoComponentOrder'));
                obj.VideoComponentOrder=val;
            end
            if coder.internal.const(~coder.target('Rtw'))
                obj.NoTuningBeforeLockingCodeGenError=false;
            end
        end
        function set.Filename(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.Filename),'MATLAB:system:codeGenNontunableSetAfterConstructor','vision.BinaryFileReader');
            obj.Filename=val;
        end
        function set.VideoFormat(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.VideoFormat),'MATLAB:system:codeGenNontunableSetAfterConstructor','vision.BinaryFileReader');
            obj.VideoFormat=val;
        end
        function set.FourCharacterCode(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.FourCharacterCode),'MATLAB:system:codeGenNontunableSetAfterConstructor','vision.BinaryFileReader');
            obj.FourCharacterCode=val;
        end
        function set.BitstreamFormat(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.BitstreamFormat),'MATLAB:system:codeGenNontunableSetAfterConstructor','vision.BinaryFileReader');
            obj.BitstreamFormat=val;
        end
        function set.OutputSize(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.OutputSize),'MATLAB:system:codeGenNontunableSetAfterConstructor','vision.BinaryFileReader');
            obj.OutputSize=val;
        end
        function set.VideoComponentCount(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.VideoComponentCount),'MATLAB:system:codeGenNontunableSetAfterConstructor','vision.BinaryFileReader');
            obj.VideoComponentCount=val;
        end
        function set.LineOrder(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.LineOrder),'MATLAB:system:codeGenNontunableSetAfterConstructor','vision.BinaryFileReader');
            obj.LineOrder=val;
        end
        function set.ByteOrder(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.ByteOrder),'MATLAB:system:codeGenNontunableSetAfterConstructor','vision.BinaryFileReader');
            obj.ByteOrder=val;
        end
        function set.PlayCount(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.PlayCount),'MATLAB:system:codeGenNontunableSetAfterConstructor','vision.BinaryFileReader');
            obj.PlayCount=val;
        end
        function set.InterlacedVideo(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.InterlacedVideo),'MATLAB:system:codeGenNontunableSetAfterConstructor','vision.BinaryFileReader');
            obj.InterlacedVideo=val;
        end
        function set.SignedData(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.SignedData),'MATLAB:system:codeGenNontunableSetAfterConstructor','vision.BinaryFileReader');
            obj.SignedData=val;
        end
        function set.VideoComponentBits(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.VideoComponentBits),'MATLAB:system:codeGenNontunableSetAfterConstructor','vision.BinaryFileReader');
            obj.VideoComponentBits=val;
        end
        function set.VideoComponentSizes(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.VideoComponentSizes),'MATLAB:system:codeGenNontunableSetAfterConstructor','vision.BinaryFileReader');
            obj.VideoComponentSizes=val;
        end
        function set.VideoComponentOrder(obj,val)
            coder.inline('always');
            coder.internal.errorIf(coder.internal.is_defined(obj.VideoComponentOrder),'MATLAB:system:codeGenNontunableSetAfterConstructor','vision.BinaryFileReader');
            obj.VideoComponentOrder=val;
        end
        function sObj=getCSFun(obj)
            sObj=obj.cSFunObject;
        end
        function args=getConstructionArgs(obj)
            args=obj.ConstructorArgs;
        end
        function cloneProp(obj,prop,value)
            if coder.internal.const(~coder.target('Rtw'))
                oldFlag=obj.NoTuningBeforeLockingCodeGenError;
                obj.NoTuningBeforeLockingCodeGenError=true;
            end
            obj.(prop)=value;
            if coder.internal.const(~coder.target('Rtw'))
                obj.NoTuningBeforeLockingCodeGenError=oldFlag;
            end
        end
    end
    methods(Access=protected)
        function num=getNumInputsImpl(obj)
            num=getNumInputs(obj.cSFunObject);
        end
        function num=getNumOutputsImpl(obj)
            num=getNumOutputs(obj.cSFunObject);
        end
        function resetImpl(obj)
            reset(obj.cSFunObject);
        end
        function setupImpl(obj,varargin)
            setup(obj.cSFunObject,varargin{:});
            if coder.internal.const(~coder.target('Rtw'))
                obj.NoTuningBeforeLockingCodeGenError=true;
            end
        end
        function varargout=isInputDirectFeedthroughImpl(obj,varargin)
            [varargout{1:nargout}]=isInputDirectFeedthrough(obj.cSFunObject,varargin{:});
        end
        function releaseImpl(obj)
            release(obj.cSFunObject);
        end
        function varargout=outputImpl(obj,varargin)
            [varargout{1:nargout}]=output(obj.cSFunObject,varargin{:});
        end
        function updateImpl(obj,varargin)
            update(obj.cSFunObject,varargin{:});
        end
        function out=getDiscreteStateImpl(~)
            out.s=1;
            coder.internal.assert(false,'MATLAB:system:getDiscreteStateNotSupported');
        end
        function out=getContinuousStateImpl(~)
            out.s=1;
            coder.internal.assert(false,'MATLAB:system:getContinuousStateNotSupported');
        end
        function setDiscreteStateImpl(~,~)
            coder.internal.assert(false,'MATLAB:system:setDiscreteStateNotSupported');
        end
        function setContinuousStateImpl(~,~)
            coder.internal.assert(false,'MATLAB:system:setContinuousStateNotSupported');
        end
        function y=isDoneImpl(obj)
            y=isDone(obj.cSFunObject);
        end
    end
    methods(Static,Hidden)
        function s=propListManager(varargin)














            if nargin>0&&isstruct(varargin{1})
                s=varargin{1};
                fieldName=varargin{2};
                if varargin{3}
                    s.(fieldName)=true;
                else
                    s=isfield(s,fieldName);
                end
            else
                s=struct;
                if nargin>0
                    for ii=1:varargin{1}
                        s.(varargin{ii+1})=true;
                    end
                end
            end
        end
        function y=getFieldFromMxStruct(s,field)







            y=s.(field);
        end
        function result=matlabCodegenUserReadableName
            result='vision.BinaryFileReader';
        end
    end
end
