


classdef XMLComparisonBuilder<xmlcomp.internal.ComparisonBuilder

    methods(Access=public)

        function obj=addFile(obj,xmlFile)
            fullpath=comparisons.internal.resolvePath(xmlFile);

            obj.addSource(fullpath);

            if numel(obj.Sources)==2&&~obj.canCompareAsXml(obj.Sources{1},obj.Sources{2})
                xmlcomp.internal.error('engine:CompareOnlyXML');
            end
        end

    end


    methods(Access=private)

        function canCompare=canCompareAsXml(~,file1,file2)

            import com.mathworks.comparisons.main.ComparisonTool;
            import com.mathworks.comparisons.register.datatype.CDataTypeXML;
            import com.mathworks.comparisons.source.impl.LocalFileSource;

            canCompare=false;


            source1=LocalFileSource(java.io.File(file1),file1);
            source2=LocalFileSource(java.io.File(file2),file2);


            compatibleTypes=ComparisonTool.getInstance....
            getCompatibleComparisonTypes(source1,source2,[]);


            for ii=0:compatibleTypes.size()-1
                type=compatibleTypes.get(ii);
                if type.getDataType.equals(CDataTypeXML.getInstance())
                    canCompare=true;
                    return
                end
            end

        end

    end

end

