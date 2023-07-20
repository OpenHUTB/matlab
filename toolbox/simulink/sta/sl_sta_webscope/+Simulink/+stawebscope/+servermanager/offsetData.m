function editedData=offsetData(offset,inputData,item)







    editedData=cell(size(inputData));

    [rootID,sigID]=Simulink.stawebscope.servermanager.util.getRootAndSigID(item);


    repoUtil=starepository.RepositoryUtility();
    metaData_sig=repoUtil.getMetaDataStructure(sigID);
    metaData_parent=repoUtil.getMetaDataStructure(rootID);

    if metaData_sig.TreeOrder~=metaData_parent.TreeOrder
        columnLocation=metaData_sig.TreeOrder-metaData_parent.TreeOrder+1;
    else
        columnLocation=2;
    end

    for id=1:length(editedData)

        if ischar(inputData{id}{1})
            offsetTime=datacreation.internal.resolveMinMaxStr2Num(inputData{id}{1},item.DataType)+offset.offset_x;
        else
            offsetTime=inputData{id}{1}+offset.offset_x;
        end


        if isfield(offset,'lowerLimitX')&&...
            isfield(offset,'higherLimitX')
            offsetTime=max(offsetTime,offset.lowerLimitX);
            offsetTime=min(offsetTime,offset.higherLimitX);
        end
        offsetData=cell(1,length(inputData{id})-1);
        for kid=2:length(inputData{1})


            offsetData{kid-1}=inputData{id}{kid};
            if kid==columnLocation
                if strcmp(item.Type,'FunctionCall')

                    if ischar(offsetData{kid-1})

                        offsetData{kid-1}=double(uint32(datacreation.internal.resolveMinMaxStr2Num(offsetData{kid-1},item.DataType)+offset.offset_y));
                    else

                        offsetData{kid-1}=double(uint32(offsetData{kid-1}+offset.offset_y));
                    end


                elseif isstruct(offsetData{kid-1})

                    if ischar(offsetData{kid-1}.value)

                        offsetData{kid-1}.value=datacreation.internal.resolveMinMaxStr2Num(offsetData{kid-1}.value,item.DataType)+offset.offset_y;
                    else

                        offsetData{kid-1}.value=offsetData{kid-1}.value+offset.offset_y;
                    end

                elseif isfield(item,'isEnum')&&item.isEnum
                    castFcn=str2func(metaData_sig.DataType);
                    offsetValue=castFcn(offsetData{kid-1})+offset.offset_y;
                    enums=enumeration(metaData_sig.DataType);
                    closestEnumValue=castFcn(enums(1));
                    minVal=realmax;
                    for e=1:length(enums)

                        if abs(castFcn(enums(e))-offsetValue)<minVal
                            closestEnumValue=castFcn(enums(e));
                            minVal=abs(closestEnumValue-offsetValue);
                        end
                    end
                    offsetData{kid-1}=char(closestEnumValue);
                elseif isfield(item,'isString')&&item.isString

                    offsetData{kid-1}=offsetData{kid-1};
                elseif ischar(offsetData{kid-1})&&...
                    any(contains(offsetData{kid-1},{'inf','nan'},'IgnoreCase',true))

                    offsetData{kid-1}=offsetData{kid-1};
                elseif contains(metaData_sig.DataType,'int64')
                    offsetData{kid-1}=num2str(datacreation.internal.resolveMinMaxStr2Num(offsetData{kid-1},item.DataType)+offset.offset_y);
                elseif any(strcmp(metaData_sig.DataType,{'logical','boolean'}))

                    if ischar(offsetData{kid-1})

                        diff_1=abs(double(datacreation.internal.resolveMinMaxStr2Num(offsetData{kid-1},item.DataType))+offset.offset_y-1);
                        diff_0=abs(double(datacreation.internal.resolveMinMaxStr2Num(offsetData{kid-1},item.DataType))+offset.offset_y);
                    else
                        diff_1=abs(offsetData{kid-1}+offset.offset_y-1);
                        diff_0=abs(offsetData{kid-1}+offset.offset_y);
                    end
                    if diff_0<diff_1

                        offsetData{kid-1}=false;
                    else

                        offsetData{kid-1}=true;
                    end

                else
                    if ischar(offsetData{kid-1})
                        offsetData{kid-1}=datacreation.internal.resolveMinMaxStr2Num(offsetData{kid-1},item.DataType)+offset.offset_y;
                    else
                        offsetData{kid-1}=offsetData{kid-1}+offset.offset_y;
                    end
                end

            end
        end
        editedData{id}=[offsetTime,offsetData];
    end

end
