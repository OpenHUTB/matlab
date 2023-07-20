classdef DataTypeHelper





    methods(Static)


        function dataTypeCellStr=getDataTypeStrings()
            dataTypeCellStr={
            'double',...
            'single',...
            'int8',...
            'uint8',...
            'int16',...
            'uint16',...
            'int32',...
            'uint32',...
            'int64',...
            'uint64',...
            'boolean',...
            'string',...
'half'
            };
        end


        function outEnumDataType=parseDataTypeStringForEnumeration(dataTypeString)





            enumPattern='Enum[\s]*:';
            regexpResult=regexp(dataTypeString,enumPattern,'split');
            idxEnumStr=1;
            if length(regexpResult)>1
                idxEnumStr=2;
            end

            outEnumDataType=strtrim(regexpResult{idxEnumStr});
        end


        function[enumObject,errStr]=getEnumerationDefinitionByName(...
            nameOfEnumClass,varargin)
            errStr='';
            enumObject=struct;

            UNIQUE_VALS=true;

            if~isempty(varargin)
                UNIQUE_VALS=varargin{1};
            end

            try


                [enumMembers,names]=enumeration(datacreation.internal.DataTypeHelper.parseDataTypeStringForEnumeration(nameOfEnumClass));

                if isempty(enumMembers)
                    errStr=message('datacreation:datacreation:enumDefinitionMissing',nameOfEnumClass).getString;
                end
            catch ME
                errStr=ME.message;
                return;
            end

            try
                if UNIQUE_VALS

                    [uVal,uIdx,uIdxUVal]=unique(int32(enumMembers)');
                    enumMembers=enumMembers(sort(uIdx));
                    names=names(sort(uIdx));
                else
                    [uVal,uIdx]=sort(int32(enumMembers)');
                    enumMembers=enumMembers(uIdx);
                    names=names(uIdx);
                end
            catch ME_CONVERT_TO_INT32
                errStr=ME_CONVERT_TO_INT32.message;
                return;
            end

            for k=1:length(enumMembers)
                enumObject.(names{k})=double(enumMembers(k));
            end
        end
    end
end
