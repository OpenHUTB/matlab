function output=combinestruct(array1,array2,keyfield)

























    if(isempty(array1))
        output=array2;
        return;
    end

    if((isempty(array2)||~isfield(array2,keyfield)))
        output=array1;
        return;
    end

    if(~isfield(array1,keyfield))
        DAStudio.error('RTW:utility:KeyFieldNotFound');
    end

    output=array1;
    for j=1:length(array2)
        currentRecord=array2(j);
        duplicate=0;
        array2_val=currentRecord.(keyfield);
        if~isempty(array2_val)
            if~isfield(currentRecord,'type')||...
                ~(strcmpi(currentRecord.type,'category')||...
                strcmpi(currentRecord.type,'pushbutton'))
                for k=1:length(array1)
                    array1_val=array1(k).(keyfield);
                    if(isequal(array1_val,array2_val))

                        recordFields=fieldnames(currentRecord);
                        for i=1:length(recordFields)
                            field=char(recordFields(i));
                            if~isempty(currentRecord.(field))
                                output(k).(field)=currentRecord.(field);
                            end
                        end
                        duplicate=1;
                        break;
                    end
                end
            else
                for k=1:length(array1)
                    array1_val=array1(k).(keyfield);
                    if(isequal(array1_val,array2_val))


                        duplicate=1;
                        break;
                    end
                end
            end
        end
        if~duplicate
            output=AddRecordToArray(output,currentRecord);
        end
    end















    function output=AddRecordToArray(array,record)

        if(isequal(fieldnames(array),fieldnames(record)))
            output=[array,record];
            return;
        else
            output=array;
            k=length(output);
            recordFields=fieldnames(record);
            for j=1:length(recordFields)
                field=char(recordFields(j));
                output(k+1).(field)=record.(field);
            end
        end


