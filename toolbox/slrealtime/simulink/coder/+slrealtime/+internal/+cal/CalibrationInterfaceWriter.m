classdef CalibrationInterfaceWriter<slrealtime.internal.cal.ParameterWriterBase




    properties(Constant)
        SegmentVectorTypeName='SegmentVector';
        SegmentVectorInstanceName='segmentInfo';
        SegmentVectorGetterName='getSegmentVector';

        NameSpace='slrealtime';
        NumPages=2;
        CalibrationTypesHeaderFile='SegmentInfo.hpp';
    end


    methods
        function writeSegmentInfoAccessFunctionDeclaration(obj,writer,segments)
            if numel(segments)==0

                return;
            end
            namespaceScopeGuard=obj.writeNamespace(writer,obj.NameSpace);
            writer.wLine('%s &%s(void);',obj.SegmentVectorTypeName,obj.SegmentVectorGetterName);
            namespaceScopeGuard.delete;
        end

        function writeSegmentVector(obj,writer,segments)

            if numel(segments)==0

                return;
            end

            obj.writeSegmentDeclarations(writer,segments);
            namespaceScopeGuard=obj.writeNamespace(writer,obj.NameSpace);


            writer.wComment('Description of SEGMENTS');
            writer.wLine('%s %s {',...
            obj.SegmentVectorTypeName,...
            obj.SegmentVectorInstanceName)
            writer.incIndent;
            for kSeg=1:numel(segments)
                isFinal=kSeg==numel(segments);
                obj.writeSegmentInfo(writer,segments(kSeg),isFinal);
            end
            writer.decIndent;
            writer.wLine('};');
            writer.wNewLine;


            writer.wLine('%s &%s(void) {',...
            obj.SegmentVectorTypeName,...
            obj.SegmentVectorGetterName);
            writer.incIndent;
            writer.wLine('return %s;',obj.SegmentVectorInstanceName);
            writer.decIndent;
            writer.wLine('}');

            namespaceScopeGuard.delete;
        end

        function writeSegmentDeclarations(~,writer,segments)

            for kSeg=numel(segments):-1:1
                writer.wLine('extern %s %s;',segments(kSeg).Type,segments(kSeg).Instance);
            end
        end

        function includes=getIncludesForSourceFile(~,segments)





            modelHeaders=unique({segments(end:-1:1).ModelHeader},'stable');


            calibrationHeaders=unique({segments(end:-1:1).Header},'stable');

            includes=unique([modelHeaders,calibrationHeaders],'stable');
        end
    end

    methods(Access=private)
        function writeSegmentInfo(obj,writer,segment,isFinal)
            if isFinal
                comma='';
            else
                comma=',';
            end
            writer.wLine('{ (void*)&%s, (void**)&%s, sizeof(%s), %d}%s',...
            segment.Instance,...
            segment.Pointer,...
            segment.Type,...
            obj.NumPages,...
            comma);
        end
    end
end
