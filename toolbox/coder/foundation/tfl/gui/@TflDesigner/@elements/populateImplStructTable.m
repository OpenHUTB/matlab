function structtable=populateImplStructTable(h,structtable)







    tblData=cell(2,2);
    [nrows,~]=size(tblData);





    if isempty(h.iargstructfields)
        implarg=hGetActiveImplArg(h);
        emStructType=[];
        if~isempty(implarg)&&h.isDataTypeStruct(implarg.toString(true))
            implargtype=implarg.Type;


            if implargtype.isStructure
                emStructType=implargtype;
            else
                if implargtype.isPointer&&implargtype.BaseType.isStructure
                    emStructType=implargtype.BaseType;
                end
            end
        end

        for rowIdx=1:nrows
            h.iargstructfields{rowIdx,1}='';
            h.iargstructfields{rowIdx,2}='double';

            if~isempty(emStructType)
                currElement=emStructType.Elements(rowIdx);
                try
                    tempArg=RTW.TflArgNumeric;
                    tempArg.Type=currElement.Type;
                    elemTypeStr=tempArg.toString;
                catch
                    errorMsg=DAStudio.message('CoderFoundation:tfl:UnsupportedDataType',...
                    currElement.Type.tostring);
                    ME=MException('tfl:UnsupportedDataType',errorMsg);
                    throw(ME);
                end


                h.iargstructfields{rowIdx,1}=currElement.Identifier;
                h.iargstructfields{rowIdx,2}=elemTypeStr;
            end
        end
    end

    for rowIdx=1:nrows
        fieldname.Type='edit';
        fieldname.Value=h.iargstructfields{rowIdx,1};

        fieldtype.Type='combobox';
        fieldtype.Entries=h.getentries('Tfldesigner_ImplStructDatatype');
        fieldtype.Editable=false;

        idx=find(ismember(fieldtype.Entries,h.iargstructfields{rowIdx,2}));
        if isempty(idx)
            idx=1;
        end
        fieldtype.Value=idx-1;

        tblData{rowIdx,1}=fieldname;
        tblData{rowIdx,2}=fieldtype;
    end

    structtable.Data=tblData;


    function implarg=hGetActiveImplArg(this)


        index=this.activeimplarg;
        implarg=[];

        if index==0&&~isempty(this.object.Implementation.Return)
            implarg=this.object.Implementation.Return;
        else

            if index~=0&&~isempty(this.object.Implementation.Arguments)
                implarg=this.object.Implementation.Arguments(index);
            end
        end