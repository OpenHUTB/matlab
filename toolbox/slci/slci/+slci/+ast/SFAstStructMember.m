



classdef SFAstStructMember<slci.ast.SFAst
    properties(Access=private)
        fMember='';
    end

    methods(Access=protected)



        function out=IsExecutable(aObj)%#ok
            out=false;
        end

    end

    methods


        function ComputeDataType(aObj)
            assert(~aObj.fComputedDataType);
            children=aObj.getChildren();
            baseDataType=children{1}.getDataType();
            sfBlkSID=aObj.ParentBlock.getSID();
            if strcmpi(baseDataType,'string')
                aObj.fDataType='';
            elseif strcmpi(baseDataType,'struct')
                field_value=aObj.getValue();
                if~isempty(field_value)
                    elementType=class(field_value);
                    aObj.fDataType=parseDataType(elementType);
                else
                    aObj.fDataType='';
                end
            else



                try
                    busObject=slResolve(baseDataType,sfBlkSID);

                    assert(isa(busObject,'Simulink.Bus'));

                    aObj.fDataType=aObj.getBusElementDataType(busObject);

                catch
                    aObj.fDataType='';
                end
            end

        end


        function out=getValue(aObj)

            children=aObj.getChildren();
            assert(numel(children)==2,...
            'Number of children of SFAstStructMember is 2');
            root=children{1};
            assert(isa(root,'slci.ast.SFAstStructMember')...
            ||isa(root,'slci.ast.SFAstQualifiedId'),...
            'Invalid root of SFAstStructMember');

            root_value=root.getValue();
            if~isempty(root_value)
                assert(isstruct(root_value));


                field=aObj.getMember();
                assert(isfield(root_value,field));

                out=root_value.(field);
            else
                out=[];
            end
        end


        function ComputeDataDim(aObj)
            assert(~aObj.fComputedDataDim);
            children=aObj.getChildren();

            baseDataType=children{1}.getDataType();
            sfBlkSID=aObj.ParentBlock.getSID();
            if strcmpi(baseDataType,'string')
                aObj.fDataDim=1;
            elseif strcmpi(baseDataType,'struct')
                field_value=aObj.getValue();
                if~isempty(field_value)
                    aObj.fDataDim=numel(field_value);
                else
                    aObj.fDataDim=1;
                end
            else



                busObject=slResolve(baseDataType,sfBlkSID);
                elementDim=1;
                assert(isa(busObject,'Simulink.Bus'));
                field=aObj.getMember();
                busHasField=false;
                for i=1:numel(busObject.Elements)
                    if strcmp(busObject.Elements(i).Name,field)
                        busHasField=true;
                        elementDim=busObject.Elements(i).Dimensions;
                        break;
                    end
                end
                assert(busHasField==true);
                aObj.fDataDim=elementDim;
            end
        end


        function elementType=getBusElementDataType(aObj,busObject)
            assert(isa(busObject,'Simulink.Bus'));
            field=aObj.getMember();
            elementType='';
            for i=1:numel(busObject.Elements)
                if strcmp(busObject.Elements(i).Name,field)

                    elementType=busObject.Elements(i).DataType;


                    elementType=parseDataType(elementType);
                    break;
                end
            end
            assert(~isempty(elementType));
        end


        function aObj=SFAstStructMember(aAstObj,aParent)
            aObj=aObj@slci.ast.SFAst(aAstObj,aParent);
            children=aObj.getChildren();




            if isa(children{2},'slci.ast.SFAstIdentifier')
                aObj.fMember=children{2}.fName;
            else
                aObj.fMember='';
            end
        end



        function out=getMember(aObj)
            out=aObj.fMember;
        end
    end

end



function parsedType=parseDataType(dataType)

    if strncmp(dataType,'Bus:',4)
        parsedType=strtrim(dataType(5:end));
    elseif strncmp(dataType,'Enum:',5)
        parsedType=strtrim(dataType(6:end));
    else
        parsedType=dataType;
    end
end
