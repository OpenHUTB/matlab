classdef mxInfoToCoderType<handle




    properties(SetAccess=private,GetAccess=public)
MxInfos
MxArrays
    end

    properties(SetAccess=private,GetAccess=private)




VisitedTypes
    end

    properties
        mode{mustBeMember(mode,{'Coder','SimulinkCompatible'})}='Coder'
        upperBound=NaN
    end

    methods
        function obj=mxInfoToCoderType(inferenceReport)
            obj.MxInfos=inferenceReport.MxInfos;
            obj.MxArrays=inferenceReport.MxArrays;
            obj.VisitedTypes=cell(size(obj.MxInfos));
        end

        function setConversionMode(obj,mode,varargin)
            narginchk(2,3);
            obj.mode=mode;
            if mode=="SimulinkCompatible"
                upperBound_=varargin{1};
                obj.upperBound=upperBound_;
            end
        end

        function t=createCoderTypeObj(obj,mxInfoId)

            if isa(obj.VisitedTypes{mxInfoId},'coder.Type')
                t=obj.VisitedTypes{mxInfoId};
                return;



            elseif~isempty(obj.VisitedTypes{mxInfoId})
                t=[];
                return;
            end

            obj.VisitedTypes{mxInfoId}=NaN;
            mxInfoObj=obj.MxInfos{mxInfoId};

            baseException=MException('mxInfoToCoderType:unsupportedType',...
            'The mxInfoObj does not have a corresponding coder.Type object');
            errorCause=obj.isUnsupportedType(mxInfoObj);
            if~isempty(errorCause)
                baseException=baseException.addCause(errorCause);
                throw(baseException);
            end
            try
                switch class(mxInfoObj)
                case 'eml.MxNumericInfo'
                    t=obj.processMxNumericInfo(mxInfoObj);
                case 'eml.MxInfo'
                    t=obj.processMxInfo(mxInfoObj);
                case 'eml.MxFiInfo'
                    t=obj.processMxFiInfo(mxInfoObj);
                case 'eml.MxSparseClassInfo'
                    t=obj.processSparseType(mxInfoObj);
                case 'eml.MxClassInfo'
                    t=obj.processMxClassInfo(mxInfoObj);
                case 'eml.MxEnumInfo'
                    t=obj.processEnumType(mxInfoObj);
                case 'eml.MxStructInfo'
                    t=obj.processMxStructInfo(mxInfoObj);
                case 'eml.MxCellInfo'
                    t=obj.processMxCellInfo(mxInfoObj);
                otherwise
                    error('mxInfoToCoderType:unexpectedMxInfo',...
                    'Unexpected eml.MxInfo object: The class of input is %s',class(mxInfoObj));
                end
            catch ME
                expectedErrorID={'Coder:common:TypeSpecHandleClassNotSupported',...
                'Coder:builtins:ClassdefNotAnEnumeration'};
                if ismember(ME.identifier,expectedErrorID)
                    baseException=baseException.addCause(ME);
                    throw(baseException);
                else
                    rethrow(ME);
                end
            end

            obj.VisitedTypes{mxInfoId}=t;
        end

        function t=processMxNumericInfo(obj,mxInfoObj)


            [sz,variable_dims]=obj.returnSzVarDim(mxInfoObj);
            if obj.mode=="SimulinkCompatible"
                [sz,variable_dims]=obj.reconcileForSimulinkCompatiable(sz,variable_dims,obj.upperBound);
            end
            complexity=mxInfoObj.Complex;
            t=coder.newtype(mxInfoObj.Class,sz,variable_dims,'complex',complexity);
        end

        function t=processMxInfo(obj,mxInfoObj)

            [sz,variable_dims]=obj.returnSzVarDim(mxInfoObj);
            t=coder.newtype(mxInfoObj.Class,sz,variable_dims);
        end

        function t=processMxFiInfo(obj,mxInfoObj)
            fimathObj=obj.MxArrays{mxInfoObj.FiMathID};
            numericTypeObj=obj.MxArrays{mxInfoObj.NumericTypeID};
            [sz,variable_dims]=obj.returnSzVarDim(mxInfoObj);
            t=coder.newtype('embedded.fi',numericTypeObj,sz,variable_dims,'fimath',fimathObj,'complex',mxInfoObj.Complex);
        end

        function t=processSparseType(obj,mxInfoObj)
            className=extractAfter(mxInfoObj.Class,'sparse ');
            [sz,variable_dims]=obj.returnSzVarDim(mxInfoObj);
            inputArgs={className,sz,variable_dims,'sparse',true};
            if className=="double"
                inputArgs=[inputArgs,{'complex',mxInfoObj.Complex}];
            end
            t=coder.newtype(inputArgs{:});
        end

        function t=processStringType(obj,mxInfoObj)
            className=mxInfoObj.Class;
            assert(className=="string",'processStringType:notMxInfoForString',...
            'The class name is %s, instead of "string"',className);
            t=coder.newtype('string');
            mxInfoIdxForValue=mxInfoObj.ClassProperties.MxInfoID;
            mxInfoForValue=obj.MxInfos{mxInfoIdxForValue};
            t.Properties.Value=obj.processMxInfo(mxInfoForValue);
        end

        function t=processEnumType(obj,mxInfoObj)
            [sz,variable_dims]=obj.returnSzVarDim(mxInfoObj);
            t=coder.newtype(mxInfoObj.Class,sz,variable_dims);
        end

        function t=processMxStructInfo(obj,mxInfoObj)

            s=struct;
            for i=1:numel(mxInfoObj.StructFields)
                [fieldType,fieldName]=obj.processMxFieldInfo(mxInfoObj.StructFields(i));
                s.(fieldName)=fieldType;
            end
            [sz,variable_dims]=obj.returnSzVarDim(mxInfoObj);
            t=coder.newtype('struct',s,sz,variable_dims);
        end

        function t=processMxCellInfo(obj,mxInfoObj)
            coderTypeObjs=getCoderTypeObjsFromMxInfoIds(mxInfoObj.CellElements);
            [sz,variable_dims]=obj.returnSzVarDim(mxInfoObj);
            if mxInfoObj.Homogeneous
                t=makeHomogeneous(coder.newtype('cell',coderTypeObjs,sz,variable_dims));
            else
                t=makeHeterogeneous(coder.newtype('cell',coderTypeObjs,sz));
            end

            function coderTypeObjs=getCoderTypeObjsFromMxInfoIds(mxInfoIdsForCellObj)
                coderTypeObjs=cell(size(mxInfoIdsForCellObj));
                for i=1:numel(mxInfoIdsForCellObj)
                    coderTypeObjs{i}=obj.createCoderTypeObj(mxInfoIdsForCellObj(i));
                end
            end
        end

        function t=processMxClassInfo(obj,mxInfoObj)

            className=getActualClassName(mxInfoObj);
            mc=meta.class.fromName(className);
            assert(~isempty(mc),'mxInfoToCoderType:processMxClassInfo:classNotOnPath',...
            'The class %s is not on path',className);
            [sz,variable_dims]=obj.returnSzVarDim(mxInfoObj);
            t=coder.newtype(className,sz,variable_dims);
            if isa(t,'coder.type.Base')
                t=t.getCoderType();
            end





            s=struct;
            for i=1:numel(mxInfoObj.ClassProperties)
                [propType,propName]=obj.processMxPropertyInfo(mxInfoObj.ClassProperties(i));
                s.(propName)=propType;
            end
            if~isempty(mxInfoObj.ClassProperties)
                t.Properties=s;
            end
        end

        function[t,propName]=processMxPropertyInfo(obj,mxInfoObj)
            if mxInfoObj.MxValueID
                try
                    constantValue=obj.MxArrays{mxInfoObj.MxValueID};
                    t=coder.newtype('constant',constantValue);
                catch ME

                    if ME.identifier=="Coder:common:TypeSpecNullValueWithPath"
                        errorCause=MException('mxInfoToCoderType:unableToRecoverNontunableProp',...
                        'The mxArray object being referenced by mxInfo object for mcos with non-tunable property is unrecoverable.');
                        ME=ME.addCause(errorCause);
                    end
                    rethrow(ME);
                end
            else
                t=obj.createCoderTypeObj(mxInfoObj.MxInfoID);
            end
            propName=mxInfoObj.PropertyName;
        end

        function[t,fieldName]=processMxFieldInfo(obj,mxInfoObj)
            fieldName=mxInfoObj.FieldName;
            t=obj.createCoderTypeObj(mxInfoObj.MxInfoID);
        end

        function[sz,variable_dims]=returnSzVarDim(obj,mxInfoObj)
            sz=obj.returnCoderTypeSize(mxInfoObj.Size);
            variable_dims=obj.returnCoderTypeVariableDims(mxInfoObj.SizeDynamic);
        end
    end

    methods(Static)
        function[sz,variable_dims]=reconcileForSimulinkCompatiable(sz,variable_dims,upperBound)
            sz(sz==inf)=upperBound;
            idx=sz==0;
            sz(idx)=2;
            variable_dims(idx)=true;

            idx=(sz==1&variable_dims==1);
            sz(idx)=2;
        end

        function out=returnCoderTypeSize(szInMxInfo)
            out=double(szInMxInfo);
            out(out==-1)=inf;
        end

        function out=returnCoderTypeVariableDims(sizeDynamicInMxInfo)
            if isempty(sizeDynamicInMxInfo)
                out=[];
            else
                out=sizeDynamicInMxInfo;
            end
        end

        function errorCause=isUnsupportedType(mxInfoObj)
            errorCause=[];

...
...
...
...
...
...
...
...


            unsupportedTypes={'eml.MxFimathInfo',...
            'eml.MxNumericTypeInfo',...
            'eml.MxSEACompInfo'};
            isUnsupportedType=cellfun(@(t)isa(mxInfoObj,t),unsupportedTypes);
            if any(isUnsupportedType)
                errorCause=MException('mxInfoToCoderType:noCoderTypeForFimathNumericTypeSysObj',...
                'The mxInfo object has class %s',unsupportedTypes{isUnsupportedType});
                return;
            end
            isMxArray=isOfClass(mxInfoObj,'eml.MxInfo')&&mxInfoObj.Class=="mxArray";
            if isMxArray
                errorCause=MException('mxInfoToCoderType:noCoderTypeForMxArray',...
                'The mxInfo object is of class mxArray');
                return;
            end

            isFunctionHandle=isOfClass(mxInfoObj,'eml.MxInfo')&&mxInfoObj.Class=="function_handle";
            if isFunctionHandle
                errorCause=MException('mxInfoToCoderType:noCoderTypeForFunctionHandle',...
                'The mxInfo object is the type of a function handle.');
                return;
            end

            isCoderOpaque=isOfClass(mxInfoObj,'eml.MxInfo')&&mxInfoObj.Class=="coder.opaque";
            if isCoderOpaque
                errorCause=MException('mxInfoToCoderType:noCoderTypeForCoderOpaque',...
                'The mxInfo object is the type of an expression from coder.opaque.');
            end

            isMcosArray=isOfClass(mxInfoObj,'eml.MxClassInfo')&&~coder.internal.classSupportsCoderResize(mxInfoObj.Class)&&~all(mxInfoObj.Size==1);
            if isMcosArray
                errorCause=MException('mxInfoToCoderType:noCoderTypeForObjectArray',...
                'The mxInfo object is a non-scalar object array.');
                return;
            end

            isVararginCellType=isOfClass(mxInfoObj,'eml.MxInfo')&&mxInfoObj.Class=="cell";
            if isVararginCellType
                errorCause=MException('mxInfoToCoderType:noCoderTypeForVararginoutCellType',...
                'The mxInfo object is a type for varargin/varargout.');
                return;
            end

            isIndexInt=isOfClass(mxInfoObj,'eml.MxNumericInfo')&&mxInfoObj.Class=="coder.internal.indexInt";
            if isIndexInt
                errorCause=MException('mxInfoToCoderType:noCoderTypeForIndexInt',...
                'The mxInfo object is a type for coder.internal.indexInt');
                return;
            end
        end
    end
end

function className=getActualClassName(mxInfo)



    if~isempty(mxInfo.ClassProperties)
        className=mxInfo.ClassProperties(1).ClassDefinedIn;
    else
        className=mxInfo.Class;
    end
end

function tf=isOfClass(obj,className)

    tf=strcmp(class(obj),className);
end
