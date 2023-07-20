classdef StructHelper
    methods(Static)


        function res=hasFieldVal(structV,fullFieldN)
            res=false;
            fieldNs=strsplit(fullFieldN,'.');

            fldCount=length(fieldNs);
            if 0==fldCount
                return;
            end


            for ii=1:fldCount
                fld=fieldNs{ii};
                if isfield(structV,fld)
                    structV=structV.(fld);
                else
                    res=false;
                    return;
                end
            end
            res=true;
        end



        function out=getFieldVal(structV,fullFieldN)
            out=[];
            fieldNs=strsplit(fullFieldN,'.');

            fldCount=length(fieldNs);
            if 0==fldCount
                return;
            end


            for ii=1:fldCount
                fld=fieldNs{ii};
                if isfield(structV,fld)
                    structV=structV.(fld);
                else
                    out=[];
                    return;
                end
            end
            out=structV;
        end



        function[inStruct,isModified]=setFieldVal(inStruct,fullFieldN,fieldV)%#ok<INUSD>
            isModified=false;
            fieldNs=strsplit(fullFieldN,'.');
            isValidName=all(cellfun(@isvarname,fieldNs,'UniformOutput',true));
            if~isValidName
                return;
            end

            eval(['inStruct.',fullFieldN,' = fieldV;']);
            isModified=true;
        end
    end
end