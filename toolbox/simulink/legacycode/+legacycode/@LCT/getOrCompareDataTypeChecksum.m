function out=getOrCompareDataTypeChecksum(workspace,dataTypeName,expectedChk)





    if nargin<3
        expectedChk=[];
    end

    out=[];


    name2Chk=containers.Map('KeyType','char','ValueType','Any');




    if ischar(workspace)||isStringScalar(workspace)
        modelName=bdroot(workspace);
        dataAccessor=Simulink.data.DataAccessor.createForExternalData(modelName);
    else
        assert(isa(workspace,'Simulink.data.DataAccessor'),...
        'Expected Simulink.data.DataAccessor object');
        dataAccessor=workspace;
    end


    chk=computeChecksum(dataAccessor,dataTypeName,name2Chk);
    if~isempty(chk)
        if isempty(expectedChk)

            out=uint32(chk);
        else

            out=numel(chk)==numel(expectedChk)&&all(chk==double(expectedChk));
        end
    end


    function chk=computeChecksum(dataAccessor,dataTypeName,name2Chk)

        persistent builtinTypeNames;
        if isempty(builtinTypeNames)
            builtinTypeNames={...
            'boolean','uint8','int8','uint16','int16','uint32','int32','uint64','int64','single','double'...
            };
        end


        if name2Chk.isKey(dataTypeName)
            chk=name2Chk(dataTypeName);
            return
        end




        dataTypeName=regexprep(dataTypeName,'^\s+|(?:Enum|Bus)\s*:\s*|\s+$','','ignorecase');


        if contains(dataTypeName,builtinTypeNames)
            chk=CGXE.Utils.md5([],dataTypeName);
            name2Chk(dataTypeName)=chk;%#ok<NASGU>
            return
        end

        [~,slObj]=legacycode.lct.util.getNamedObject(dataTypeName,dataAccessor);

        if isa(slObj,'Simulink.Bus')||isa(slObj,'Simulink.StructType')

            dtInfo.fieldNames=cell(1,numel(slObj.Elements));
            dtInfo.fieldTypes=cell(1,numel(slObj.Elements));
            dtInfo.fieldWidths=zeros(1,numel(slObj.Elements));
            dtInfo.fieldCplx=zeros(1,numel(slObj.Elements));

            for ii=1:numel(slObj.Elements)
                thisElement=slObj.Elements(ii);
                dtInfo.fieldNames{ii}=thisElement.Name;
                dtInfo.fieldTypes{ii}=computeChecksum(dataAccessor,thisElement.DataType,name2Chk);


                lDimensions=legacycode.lct.util.evalIfNumStr(thisElement.Dimensions);
                if isempty(lDimensions)
                    error(message('Simulink:tools:LCTErrorBusElementBadDim',dtInfo.fieldNames{ii},dataTypeName));
                end
                dtInfo.fieldWidths(ii)=prod(lDimensions);
                dtInfo.fieldCplx(ii)=double(strcmp(thisElement.Complexity,'complex'));
            end
            dtInfo.Class=class(slObj);
            chk=CGXE.Utils.md5([],dtInfo);

        elseif isa(slObj,'meta.class')

            [enumVals,enumNames]=enumeration(dataTypeName);
            dtInfo.val=double(enumVals);
            dtInfo.Names=enumNames;
            dtInfo.lastIdx=Simulink.IntEnumType.getIndexOfDefaultValue(dataTypeName);
            dtInfo.addPrefix=Simulink.data.getEnumTypeInfo(dataTypeName,'AddClassNameToEnumNames');
            dtInfo.Class=class(slObj);
            chk=CGXE.Utils.md5([],dtInfo);


            clear enumVals;

        elseif isa(slObj,'Simulink.NumericType')

            dtInfo.wordlength=max(2^nextpow2(slObj.WordLength),8);
            dtInfo.sign=slObj.Signedness;
            chk=CGXE.Utils.md5([],dtInfo);

        elseif isa(slObj,'Simulink.AliasType')

            chk=computeChecksum(dataAccessor,slObj.BaseType,name2Chk);

        elseif isempty(slObj)


            chk=CGXE.Utils.md5([],strrep(dataTypeName,' ',''));
        else

            chk=CGXE.Utils.md5([],slObj);
        end


        name2Chk(dataTypeName)=chk;%#ok
