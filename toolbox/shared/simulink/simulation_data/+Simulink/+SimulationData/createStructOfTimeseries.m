function ret=createStructOfTimeseries(arg1,data,dims)





























    if nargin>0
        arg1=convertStringsToChars(arg1);
    end

    if isa(arg1,'Simulink.TsArray')


        if nargin>1
            DAStudio.error('Simulink:SimInput:InvalidCreateStructTsArrayArg');
        end

    elseif ischar(arg1)
        isOk=false;
        if nargin==2
            if iscell(data)

                isOk=true;
                dims=[1,1];
            elseif isstruct(data)

                isOk=true;
                dims=size(data);
            end
        elseif nargin==3&&iscell(data)
            if~iscell(dims)&&isnumeric(dims)
                dims=double(dims);
            end
            if isValidNonZeroDimension(dims)

                if length(dims)==1
                    dims=[1,dims];
                end
                isOk=true;
            end
        else
            isOk=false;
        end

        if(~isOk)
            DAStudio.error('Simulink:SimInput:InvalidCreateStructBusObjArg');
        end
    else
        DAStudio.error('Simulink:SimInput:InvalidCreateStructArg');
    end


    if isa(arg1,'Simulink.TsArray')
        ret=locCreateFromTsArray(arg1);


    else

        try
            hierStruct=Simulink.Bus.createMATLABStruct(arg1,[],dims);
            flatElTypes=evalin('base',[arg1,'.getLeafBusElements']);
        catch me
            DAStudio.error('Simulink:SimInput:InvalidCreateStructBusObj');
        end


        if iscell(data)&&length(flatElTypes)*prod(dims)~=length(data)
            DAStudio.error('Simulink:SimInput:InvalidCreateStructDataNumData');
        end




        if(iscell(data))
            [ret,~]=locFillInLeaves(hierStruct,flatElTypes,...
            data,1,1);
        else
            [ret,~]=structDirectReplace(hierStruct,flatElTypes,...
            data,1,1);
        end
    end

end




function ret=locCreateFromTsArray(tsArray)






    if isa(tsArray,'Simulink.Timeseries')
        ret=convertToMATLABTimeseries(tsArray);
        return;
    end


    fields=tsArray.who;
    ret=struct();
    for idx=1:length(fields)

        if~isvarname(fields{idx})
            DAStudio.error('Simulink:SimInput:InvalidCreateBusSignalName',...
            fields{idx});
        end


        subEl=eval(['tsArray.',fields{idx}]);
        ret=setfield(ret,fields{idx},locCreateFromTsArray(subEl));%#ok
    end

end


function[ret,curIdx,curTypeIdx]=locFillInLeaves(input,flatElTypes,data,curIdx,curTypeIdx)



























    fields=fieldnames(input);
    numElements=numel(input);
    ret=input;
    for eIdx=1:numElements
        for idx=1:length(fields)

            curField=getfield(input(eIdx),fields{idx});%#ok
            if isstruct(curField)

                [retStruct,curIdx,curTypeIdx]=...
                locFillInLeaves(curField,flatElTypes,...
                data,curIdx,curTypeIdx);
                ret(eIdx).(fields{idx})=retStruct;
            else



                if(isempty(data{curIdx}))
                    ret(eIdx).(fields{idx})=[];
                else

                    locValidateData(curField,flatElTypes(curTypeIdx),...
                    data{curIdx},curIdx);


                    if isa(data{curIdx},'timeseries')
                        ret(eIdx).(fields{idx})=data{curIdx};
                    else
                        ret(eIdx).(fields{idx})=...
                        convertToMATLABTimeseries(data{curIdx});
                    end
                end

                curIdx=curIdx+1;
                if curTypeIdx==length(flatElTypes)
                    curTypeIdx=1;
                else
                    curTypeIdx=curTypeIdx+1;
                end
            end
        end
    end
end


function[ret,curIdx,curTypeIdx]=structDirectReplace(input,flatElTypes,other,curIdx,curTypeIdx)
























    fields=fieldnames(input);
    otherFields=fieldnames(other);

    numElements=numel(input);

    if numElements~=numel(other)||numel(fields)~=numel(otherFields)
        DAStudio.error('Simulink:SimInput:InvalidCreateStructFromStruct');
    end

    ret=input;
    for eIdx=1:numElements
        for idx=1:length(fields)

            curField=input(eIdx).(fields{idx});
            curOtherField=other(eIdx).(otherFields{idx});

            if isstruct(curField)
                if~isstruct(curOtherField)
                    DAStudio.error('Simulink:SimInput:InvalidCreateStructFromStruct');
                end

                [retStruct,curIdx,curTypeIdx]=...
                structDirectReplace(curField,flatElTypes,...
                curOtherField,curIdx,curTypeIdx);
                ret(eIdx).(fields{idx})=retStruct;
            else
                if isstruct(curOtherField)
                    DAStudio.error('Simulink:SimInput:InvalidCreateStructFromStruct');
                end

                if isempty(curOtherField)
                    ret(eIdx).(fields{idx})=[];
                else


                    locValidateData(curField,flatElTypes(curTypeIdx),...
                    curOtherField,curIdx);
                    ret(eIdx).(fields{idx})=curOtherField;
                end

                curIdx=curIdx+1;
                if curTypeIdx==length(flatElTypes)
                    curTypeIdx=1;
                else
                    curTypeIdx=curTypeIdx+1;
                end
            end
        end
    end
end


function locValidateData(dataSample,elType,dataTs,idx)







    if~isa(dataTs,'timeseries')&&~isa(dataTs,'Simulink.Timeseries')
        DAStudio.error('Simulink:SimInput:InvalidCreateStructDataElement');
    end


    locCompareDataType(dataSample,dataTs.Data,idx);


    if~isreal(dataTs.Data)&&isreal(dataSample)
        DAStudio.error('Simulink:SimInput:InvalidCreateStructDataComplexity',...
        idx);
    end


    actualDims=Simulink.SimulationData.TimeseriesUtil.getSampleDimensions(dataTs);
    expectedDims=elType.Dimensions;
    if~isequal(actualDims,expectedDims)


        actDimsStr=['[',num2str(actualDims),']'];
        expDimsStr=['[',num2str(expectedDims),']'];

        DAStudio.error('Simulink:SimInput:InvalidCreateStructDataDims',...
        idx,actDimsStr,expDimsStr);
    end
end



function locCompareDataType(dataSample,dataTs,idx)



    earlyBailOut=true;


    if((isnumeric(dataSample)||islogical(dataSample))&&~isenum(dataSample))&&...
        ((isnumeric(dataTs)||islogical(dataTs))&&~isenum(dataTs))
        earlyBailOut=false;
    end


    if(earlyBailOut||(slfeature('PreserveBuiltin64Bit')==0))

        if~strcmp(class(dataSample),class(dataTs))
            DAStudio.error('Simulink:SimInput:InvalidCreateStructDataType',...
            idx,...
            class(dataTs),...
            class(dataSample));
        end


        if isfi(dataSample)
            if~isequivalent(dataSample.numerictype,dataTs.numerictype)
                DAStudio.error('Simulink:SimInput:InvalidCreateStructFiMismatch',...
                idx);
            end
        end
    else
        if isfi(dataSample)
            dataSampleDT=dataSample.numerictype;
        else
            dataSampleDT=numerictype(class(dataSample));
        end

        if isfi(dataTs)
            dataTsDT=dataTs.numerictype;
        else
            dataTsDT=numerictype(class(dataTs));
        end

        if(~isequivalent(dataSampleDT,dataTsDT))
            DAStudio.error('Simulink:SimInput:InvalidCreateStructDataType',...
            idx,...
            dataTsDT.tostringInternalSlName,...
            dataSampleDT.tostringInternalSlName);
        end
    end


end

function result=isValidNonZeroDimension(dims)




    result=false;
    if~iscell(dims)&&...
        isnumeric(dims)&&...
        isrow(dims)&&...
        isempty(find(dims<=0,1))&&...
        isreal(dims)&&...
        isempty(find(mod(double(dims),1)~=0,1))
        result=true;
    end

end
