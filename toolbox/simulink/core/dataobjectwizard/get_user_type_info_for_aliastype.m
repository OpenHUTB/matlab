function[dataList,dataNameList]=get_user_type_info_for_aliastype





    dataList={};
    dataNameList={};

    try


        hcustom=cusattic('AtticData','slDataObjectCustomizations');
        if isempty(hcustom)
            return
        end

        userTypes=sldowprivate('cusattic','AtticData','userTypes');


        ctr=0;

        for i=1:length(userTypes)
            ctr=ctr+1;
            dataList{ctr}.name=userTypes{i}.userName;
            dataList{ctr}.BaseType=userTypes{i}.tmwName;
            if isa(userTypes{i}.tmwName,'Simulink.AliasType')
                dataList{ctr}.type='AliasType';
            elseif isa(userTypes{i}.tmwName,'Simulink.NumericType')
                dataList{ctr}.type='NumericType';
            elseif~isempty(strfind(userTypes{i}.tmwName,'fixdt'))
                dataList{ctr}.type='NumericType';
            else
                dataList{ctr}.type='AliasType';
                dataList{ctr}.BaseType=convert_type_to_sl_type(userTypes{i}.tmwName);
            end
            dataList{ctr}.HeaderFile=userTypes{i}.userTypeDepend;
            dataList{ctr}.isAlias=userTypes{i}.isAlias;
            dataList{ctr}.Description='';
            dataNameList{ctr}=dataList{ctr}.name;
        end
    catch merr

        warning(merr.identifier,merr.message);
    end


    function slType=convert_type_to_sl_type(type)

        slType=type;

        switch(type)
        case 'boolean_T'
            slType='boolean';
        case{'uint8_T'}
            slType='uint8';
        case{'int8_T'}
            slType='int8';
        case{'uint16_T'}
            slType='uint16';
        case{'int16_T'}
            slType='int16';
        case{'uint32_T'}
            slType='uint32';
        case{'int32_T'}
            slType='int32';
        case 'real32_T'
            slType='single';
        case 'real_T'
            slType='double';
        otherwise
        end
