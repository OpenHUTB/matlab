classdef ParameterServiceGenerator<slrealtime.internal.cal.ParameterWriterBase







    properties(Hidden,Access=public)
        BuildInfo RTW.BuildInfo=RTW.BuildInfo.empty;
    end

    properties(Access=private)

        CalibrationInterfaceWriter=[];
        ExternalParameterWriter=[];



        Segments=[];
        Initialized=false;
    end

    methods(Access=public)
        function generateRTEInterface(obj,modelName,cDesc)





            obj.initialize(cDesc);
            if isempty(obj.Segments)

                return;
            end

            buildFolder=cDesc.BuildDir;
            interfaceFileName=obj.getInterfaceFile(modelName);
            interfaceFileFullPath=fullfile(buildFolder,interfaceFileName);
            writer=obj.getWriter(interfaceFileFullPath);


            guardObj=obj.writeHeaderGuard(writer,interfaceFileName);




            requiredIncludes={'"rtwtypes.h"',...
            '"SegmentInfo.hpp"'};


            if slfeature('SLRTPageSwitchingStorageClassForDataObjects')
                externalParameterIncludes=obj.ExternalParameterWriter.getParameterTypeIncludes();
                requiredIncludes=unique([requiredIncludes,externalParameterIncludes],'stable');
            end


            obj.writeIncludes(writer,requiredIncludes);


            obj.ExternalParameterWriter.writeStructureTypeDefinition(writer);


            obj.ExternalParameterWriter.writeStructureVariableDeclaration(writer);


            obj.ExternalParameterWriter.writeStructurePointerDeclaration(writer);


            writer.wNewLine;


            obj.ExternalParameterWriter.writeAccessFunctionPrototypes(writer);


            writer.wNewLine;


            obj.CalibrationInterfaceWriter.writeSegmentInfoAccessFunctionDeclaration(writer,obj.Segments);


            guardObj.delete;
        end

        function generateRTEImplementation(obj,modelName,cDesc)


            buildFolder=cDesc.BuildDir;
            sourceFileName=obj.getImplementationFile(modelName);
            sourceFileFullPath=fullfile(buildFolder,sourceFileName);
            obj.initialize(cDesc);
            if isempty(obj.Segments)


                if isfile(sourceFileFullPath)
                    delete(sourceFileFullPath);
                end
                return;
            end

            writer=obj.getWriter(sourceFileFullPath);


            calibrationInterfaceIncludes=...
            strcat('"',obj.CalibrationInterfaceWriter.getIncludesForSourceFile(obj.Segments),'"');

            requiredIncludes=unique(...
            [sprintf('"%s"',obj.getInterfaceFile(modelName)),...
            calibrationInterfaceIncludes],...
            'stable');
            obj.writeIncludes(writer,requiredIncludes);


            obj.ExternalParameterWriter.writeStructureVariableInitialization(writer);


            obj.ExternalParameterWriter.writeStructurePointerInitialization(writer);


            obj.ExternalParameterWriter.writeAccessFunctionImplementations(writer);


            obj.CalibrationInterfaceWriter.writeSegmentVector(writer,obj.Segments);

            if~isempty(obj.BuildInfo)


                obj.BuildInfo.addSourceFiles(sourceFileName,buildFolder);
            end

            obj.ExternalParameterWriter.updateCodeDescriptor(cDesc);
        end

        function initialize(obj,cDesc)
            if~obj.Initialized


                obj.CalibrationInterfaceWriter=slrealtime.internal.cal.CalibrationInterfaceWriter;
                obj.ExternalParameterWriter=slrealtime.internal.cal.ExternalParameterWriter(cDesc);
                obj.Segments=slrealtime.internal.cal.getPageSwitchingSegments(cDesc,'ExternalParameterWriter',obj.ExternalParameterWriter);
                obj.Initialized=true;
            end
        end
    end

    methods(Static,Access=public)
        function ret=hasPageSwitchingSupport(cDesc)




            buildFolder=cDesc.BuildDir;
            modelName=cDesc.ModelName;
            calSourceFile=slrealtime.internal.cal.ParameterServiceGenerator.getImplementationFile(modelName);
            ret=isfile(fullfile(buildFolder,calSourceFile));
        end

        function ret=getInterfaceFile(modelName)

            ret=sprintf('rte_%s_parameters.h',modelName);
        end

        function ret=getImplementationFile(modelName)

            ret=sprintf('rte_%s_parameters.cpp',modelName);
        end
    end
end
