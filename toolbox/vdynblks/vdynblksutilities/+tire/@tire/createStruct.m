function[tireStruct,tiresStruct,tireSimpStruct]=createStruct(tire)






    m=size(tire,1);
    n=size(tire,2);
    propName=fieldnames(tire);

    f=size(fieldnames(tire),1);
    numBus=m*n;
    clear elems;
    elems(f)=Simulink.BusElement;
    for idx=1:f
        propValue=[tire.(propName{idx})];
        elems(idx).Name=(propName{idx});
        if ischar(propValue)
            elems(idx).DataType='double';
            elems(idx).Description=regexprep([propName{idx},' = ',propValue],' filesep ','replace');
        end
    end
    Tire_T=Simulink.Bus;
    Tire_T.HeaderFile='';
    Tire_T.Description='';
    Tire_T.DataScope='Auto';
    Tire_T.Alignment=-1;
    Tire_T.Elements=elems;
    clear elems;

    elems(numBus)=Simulink.BusElement;
    for busidx=1:numBus
        elems(busidx).Name=['tire',num2str(busidx)];
        elems(busidx).DataType='Bus: Tire62_T';
    end
    Tires_T=Simulink.Bus;
    Tires_T.HeaderFile='';
    Tires_T.Description='';
    Tires_T.DataScope='Auto';
    Tires_T.Alignment=-1;
    Tires_T.Elements=elems;
    clear elems;

    tireStruct(m,n)=struct;
    tiresStruct=struct;
    tireSimpStruct(m*n,1)=struct;
    iddx=1;
    for i=1:m
        for j=1:n
            for idx=1:f
                propValue=tire(i,j).(propName{idx});
                if isempty(propValue)||ischar(propValue)
                    tireStruct(i,j).(propName{idx})=double(0);
                    tiresStruct.(['tire',num2str(iddx)]).(propName{idx})=double(0);
                    tireSimpStruct(iddx).(propName{idx})=double(0);
                else
                    tireStruct(i,j).(propName{idx})=double(tire(i,j).(propName{idx}));
                    tiresStruct.(['tire',num2str(iddx)]).(propName{idx})=double(tire(i,j).(propName{idx}));
                    tireSimpStruct(iddx).(propName{idx})=double(tire(i,j).(propName{idx}));
                end










            end

            iddx=iddx+1;
        end
    end

end

