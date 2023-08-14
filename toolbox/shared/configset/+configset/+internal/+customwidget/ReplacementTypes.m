function out=ReplacementTypes(cs,name,direction,widgetVals)




    slNames={'double','single',...
    'int32','int16','int8',...
    'uint32','uint16','uint8',...
    'boolean','int','uint',...
    'char','uint64','int64'};

    cgNames={'real_T','real32_T',...
    'int32_T','int16_T','int8_T',...
    'uint32_T','uint16_T','uint8_T',...
    'boolean_T','int_T','uint_T',...
    'char_T','uint64_T','int64_T'};

    n=length(slNames);

    if direction==0
        val=cs.getProp(name);
        if~isstruct(val)


            val=configset.ert.setReplacementTypes([],[]);
        end
        a=cell(3,n+3);

        for i=1:n
            a{1,i}=val.(slNames{i});
            a{2,i}=slNames{i};
            a{3,i}=cgNames{i};
        end

        i=i+1;
        a{1,i}=message('RTW:configSet:ERTTargetReplacementTitle3Name').getString;
        a{2,i}=[message('RTW:configSet:ERTTargetReplacementTitle1Name').getString,'   '];
        a{3,i}=[message('RTW:configSet:ERTTargetReplacementTitle2Name').getString,'  '];
        i=i+1;
        a{1,i}=message('RTW:configSet:ERTTargetReplacementTitle4Name').getString;
        a{2,i}=message('RTW:configSet:ERTTargetReplacementTitle4Name').getString;
        a{3,i}=message('RTW:configSet:ERTTargetReplacementTitle4Name').getString;

        i=i+1;
        a{1,i}='';
        a{2,i}='';
        a{3,i}='';
        out=reshape(a,1,3*(n+3));

    elseif direction==1
        out=[];
        for i=1:length(slNames)
            out.(slNames{i})=widgetVals{(i-1)*3+1};
        end
    end

