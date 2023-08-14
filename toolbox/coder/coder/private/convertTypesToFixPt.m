




















function newItys=convertTypesToFixPt(origItys,newTypesContainer,fimathStr)
    newItys={};
    if ischar(fimathStr)
        fimathObj=eval(fimathStr);
    else
        fimathObj=fimathStr;
    end

    if isa(newTypesContainer,'struct')
        assert(length(origItys)==length(fieldnames(newTypesContainer)));
    else
        assert(length(origItys)==length(newTypesContainer));
    end

    for ii=1:length(origItys)
        oITy=origItys{ii};
        iTyName=oITy.Name;
        iTyClass=oITy.ClassName;
        if strcmpi(iTyClass,'logical')||strcmpi(iTyClass,'embedded.fi')
            nITy=oITy;
        else


            if isa(newTypesContainer,'struct')
                numType=newTypesContainer.(iTyName);
            else
                numType=newTypesContainer{ii};
            end

            if isa(oITy,'coder.StructType')
                assert(isa(numType,'struct'),'expecting a stucture with the similar strucutre to the origItys is expected, whose values have the numerictype');
            end

            if isa(oITy,'coder.Constant')
                nITy=oITy;
            elseif isa(oITy,'coder.EnumType')
                nITy=oITy;
            elseif isa(numType,'struct')

                if isa(newTypesContainer,'struct')
                    fldNames=fieldnames(newTypesContainer.(iTyName));
                    fldNumericType=newTypesContainer.(iTyName);
                else
                    fldNames=fieldnames(numType);
                    fldNumericType=numType;
                end

                nITy=oITy;
                nInitVal=[];
                if numel(fldNames)==0
                    iTyFieldsStruct=struct();
                else
                    for count=1:numel(fldNames)
                        fieldName=fldNames{count};
                        hasInitVal=~isempty(oITy.InitialValue)&&~isempty(oITy.InitialValue.(field));

                        tmpTyp=oITy.Fields.(fieldName);
                        if hasInitVal
                            tmpTyp.InitialValue=oITy.InitialValue.(field);
                        end
                        if isa(oITy.Fields.(fieldName),'coder.StructType')
                            tempStruct=convertTypesToFixPt({tmpTyp},struct(fieldName,fldNumericType.(fieldName)),fimathStr);
                        else
                            tempStruct=convertTypesToFixPt({tmpTyp},{fldNumericType.(fieldName)},fimathStr);
                        end

                        if length(tempStruct)>=1&&hasInitVal
                            nInitVal.(field)=tempStruct{1}.InitialValue;
                        end

                        iTyFieldsStruct.(fieldName)=tempStruct{:};
                    end
                end
                nITy.Fields=iTyFieldsStruct;
                if~isempty(nInitVal)
                    nITy.InitialValue=nInitVal;
                end
            else
                if~isempty(numType)
                    nITy=coder.newtype('embedded.fi',numType,oITy.SizeVector,oITy.VariableDims,'complex',oITy.Complex,'fimath',fimathObj);
                    nITy.Name=iTyName;
                    if~isempty(oITy.InitialValue)
                        nITy.InitialValue=fi(oITy.InitialValue,numType,fimathObj);
                    end
                else
                    nITy=oITy;
                end
            end
        end

        newItys{ii}=nITy;%#ok<AGROW>
    end
end
