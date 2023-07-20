classdef ExternalParameterWriter<slrealtime.internal.cal.ParameterWriterBase








    properties(Hidden,Access=public)
        BuildInfo RTW.BuildInfo=RTW.BuildInfo.empty;
    end

    properties(SetAccess=immutable,GetAccess=private)


        Parameters=[];




        CoderTypesFileNames cell={};


        StructTypeName='';
        StructPtr='';
        StructName='';

        StructVariableObject=[];
    end

    properties(SetAccess=immutable,GetAccess=public)
        HasPageSwitchingExternalParameters=false;
    end

    methods(Access=public)
        function obj=ExternalParameterWriter(cDesc)








            if slfeature('SLRTPageSwitchingStorageClassForDataObjects')
                [obj.Parameters,obj.CoderTypesFileNames]=obj.initializeGlobalParameterDefs(cDesc);
                obj.HasPageSwitchingExternalParameters=~isempty(obj.Parameters);
                if obj.HasPageSwitchingExternalParameters
                    [obj.StructPtr,obj.StructTypeName,obj.StructName,obj.StructVariableObject]=obj.initializeRTEVariableSymbols(cDesc);
                    assert(~isempty(obj.StructPtr),'Page switching struct type not identified');
                    assert(~isempty(obj.StructTypeName),'Page switching variable name not identified');
                    assert(~isempty(obj.StructName),'Page switching pointer variable name not identified');
                    assert(~isempty(obj.StructVariableObject),'Page switching pointer variable object not found');
                end
            end

        end

        function includes=getParameterTypeIncludes(obj)





            if isempty(obj.Parameters)
                includes={};
            else
                includes=[obj.CoderTypesFileNames,...
                {obj.Parameters.dtHdr}];
                includes(strcmp(includes,''))=[];
                includes=unique(includes,'stable');
            end
        end

        function writeStructureTypeDefinition(obj,writer)





            if~obj.HasPageSwitchingExternalParameters
                return;
            end

            paramStruct=obj.Parameters;
            writer.wLine('struct %s {',obj.StructTypeName);
            writer.incIndent;
            for kParam=1:numel(paramStruct)
                locDims=strip(paramStruct(kParam).dims);
                if strcmp(locDims,'[1]')
                    locDims='';
                end
                writer.wLine('%s %s%s;',...
                strip(paramStruct(kParam).dt),...
                strip(paramStruct(kParam).name),...
                locDims);
            end
            writer.decIndent;
            writer.wLine('};');
        end

        function writeStructureVariableDeclaration(obj,writer)





            if~obj.HasPageSwitchingExternalParameters
                return;
            end

            writer.wLine('extern %s %s;',...
            obj.StructTypeName,...
            obj.StructName);
        end


        function writeStructureVariableInitialization(obj,writer)






            if~obj.HasPageSwitchingExternalParameters
                return;
            end

            writer.wLine('%s %s = {',...
            obj.StructTypeName,...
            obj.StructName);
            writer.incIndent;

            paramStruct=obj.Parameters;
            nParams=numel(paramStruct);
            for kParam=1:nParams
                if kParam==nParams
                    comma='';
                else
                    comma=',';
                end
                writer.wLine('%s%s ',paramStruct(kParam).init,comma);
            end
            writer.wLine('};');
            writer.decIndent;
        end

        function writeStructurePointerDeclaration(obj,writer)




            if~obj.HasPageSwitchingExternalParameters
                return;
            end

            writer.wLine('extern %s *%s;',...
            obj.StructTypeName,...
            obj.StructPtr);
        end

        function writeStructurePointerInitialization(obj,writer)





            if~obj.HasPageSwitchingExternalParameters
                return;
            end

            writer.wLine('%s *%s = &%s;',...
            obj.StructTypeName,...
            obj.StructPtr,...
            obj.StructName);
            writer.wNewLine;
        end

        function writeAccessFunctionPrototypes(obj,writer)




            if~obj.HasPageSwitchingExternalParameters
                return;
            end

            paramStruct=obj.Parameters;
            for kParam=1:numel(paramStruct)
                writer.wLine('%s;',obj.getAccessFunctionPrototype(paramStruct(kParam)));
            end
        end

        function writeAccessFunctionImplementations(obj,writer)




            if~obj.HasPageSwitchingExternalParameters
                return;
            end

            paramStruct=obj.Parameters;
            nParams=numel(paramStruct);
            for kParam=1:nParams
                writer.wBlockStart('%s',...
                obj.getAccessFunctionPrototype(paramStruct(kParam)));

                locDims=strip(paramStruct(kParam).dims);
                isScalar=strcmp(locDims,'[1]');





                if isScalar
                    addrOfOp='&';
                else
                    addrOfOp='';
                end

                writer.wLine('return %s%s->%s;',...
                addrOfOp,...
                obj.StructPtr,...
                strip(paramStruct(kParam).name));
                writer.wBlockEnd
                writer.wNewLine;
            end
        end

        function updateCodeDescriptor(obj,cDesc)








            if~obj.HasPageSwitchingExternalParameters
                return;
            end


            paramStruct=obj.Parameters;
            fcnToNameMap=containers.Map({paramStruct.fcn},{paramStruct.name});

            mf0Model=cDesc.getMF0Model;
            params=cDesc.getDataInterfaces('Parameters');
            cDesc.beginTransaction();
            for kParam=1:numel(params)
                p=params(kParam);
                obj.updateDataInterfaceImplementation(mf0Model,fcnToNameMap,p);
            end
            cDesc.commitTransaction();
        end

        function segment=getSegment(obj,cDesc)





            if~obj.HasPageSwitchingExternalParameters
                segment=slrealtime.internal.cal.PageSwitchingSegment.empty;
                return;
            end

            modelHeader=sprintf('%s.h',cDesc.getFullComponentInterface.HeaderFile);
            modelName=cDesc.ModelName;
            segment=slrealtime.internal.cal.PageSwitchingSegment;
            segment.Index=0;
            segment.Type=obj.StructTypeName;
            segment.Instance=obj.StructName;
            segment.Pointer=obj.StructPtr;
            segment.Header=slrealtime.internal.cal.ParameterServiceGenerator.getInterfaceFile(modelName);
            segment.ModelName='';
            segment.ModelHeader=modelHeader;
        end
    end


    methods(Access=private)
        function updateDataInterfaceImplementation(obj,m,fcnToNameMap,dataInterface)







            if dataInterface.isLookupTableDataInterface||dataInterface.isBreakpointDataInterface
                dupDis=coder.descriptor.LookupTableDataInterface.getParametersToUpdate(m,dataInterface);
                for kDup=1:numel(dupDis)
                    obj.updateDataInterfaceImplementationInner(m,fcnToNameMap,dupDis(kDup));
                end
            else
                obj.updateDataInterfaceImplementationInner(m,fcnToNameMap,dataInterface);
            end
        end

        function updateDataInterfaceImplementationInner(obj,m,fcnToNameMap,dataInterface)

            if isa(dataInterface.Implementation,'coder.descriptor.CustomExpression')
                getFcn=dataInterface.Implementation.ReadExpression;
                if fcnToNameMap.isKey(getFcn)
                    identifier=fcnToNameMap(getFcn);
                    type=dataInterface.Implementation.Type;
                    codeType=dataInterface.Implementation.CodeType;
                    newImpl=coder.descriptor.StructExpression(m);
                    newImpl.ElementIdentifier=identifier;
                    newImpl.Type=type;
                    newImpl.CodeType=codeType;
                    newImpl.BaseRegion=obj.StructVariableObject;
                    dataInterface.Implementation=newImpl;
                end
            end
            if dataInterface.isLookupTableDataInterface

                for kBp=1:dataInterface.Breakpoints.Size
                    obj.updateDataInterfaceImplementationInner(m,fcnToNameMap,dataInterface.Breakpoints.at(kBp));
                end
            end
        end
    end

    methods(Static,Access=private)
        function[parameters,coderTypesFileNames]=initializeGlobalParameterDefs(cDesc)



            buildFolder=cDesc.BuildDir;
            modelName=cDesc.ModelName;
            globalParametersDefFile=fullfile(buildFolder,sprintf('%scal.mat',modelName));
            if isfile(globalParametersDefFile)
                tmp=load(globalParametersDefFile);
                parameters=tmp.Parameters;



                coderTypesFileNames=strcat('"',tmp.CoderTypesFileNames,'"');
            else
                parameters=[];
                coderTypesFileNames={};
            end
        end

        function[structPtr,structTypeName,structName,structVariableObject]=initializeRTEVariableSymbols(cDesc)



            internalData=cDesc.getFullComponentInterface.InternalData.toArray;
            pointerVariable=findobj(internalData,'GraphicalName','SLRT_PAGESWITCHING_RTE_PTR');
            assert(numel(pointerVariable)==1,'Could not find unique descriptor of page switching pointer');
            structPtr=pointerVariable.Implementation.Identifier;
            structTypeName=pointerVariable.Implementation.TargetVariable.Type.Name;
            structName=pointerVariable.Implementation.TargetVariable.Identifier;
            structVariableObject=pointerVariable.Implementation.TargetVariable;
        end

        function ret=getAccessFunctionPrototype(pStruct)




            ret=sprintf('%s* %s(%s)',...
            strip(pStruct.dt),...
            strip(pStruct.fcn),...
            'void');
        end
    end
end






