function initValues=constructTSInitValStatements(initValStruct)


    indx=1;
    addFcnCallComment=true;

    len=length(initValStruct);
    initValues=cell(len+4,1);

    for j=1:len
        lhs=initValStruct(j).name;
        comment='';
        if strncmp(initValStruct(j).class,'Enum: ',6)
            enumType=initValStruct(j).class(7:end);
            idx=Simulink.IntEnumType.getIndexOfDefaultValue(enumType);
            c=meta.class.fromName(enumType);
            enumDefault=c.EnumerationMemberList(idx).Name;
            rhs=[enumType,'.',enumDefault];
            if~initValStruct(j).scalar
                rhs=sprintf('repmat(%s, %s)',rhs,initValStruct(j).size);
            end
        elseif strncmp(initValStruct(j).class,'fcnCall',7)
            lhs='';
            if isfield(initValStruct(j),'rate')&&initValStruct(j).rate>1

                rhs=sprintf('if t == 0 || every(%d, tick)\n\tsend(%s)\nend',...
                initValStruct(j).rate,...
                initValStruct(j).name);
            else
                rhs=strcat('send(',initValStruct(j).name,')');
            end
        elseif strncmp(initValStruct(j).class,'Bus: ',5)
            rhs=sprintf('%s(1)',lhs);
            if~initValStruct(j).scalar
                rhs=sprintf('repmat(%s, %s)',rhs,initValStruct(j).size);
                comment=' % bus array';
            end
        elseif strncmp(initValStruct(j).class,'fixdt',5)||strcmp(initValStruct(j).class,'embedded.fi')
            lhs=[lhs,'(:)'];%#ok
            rhs='0';
            comment=' % fixed-point';
        elseif initValStruct(j).scalar
            if strcmp(initValStruct(j).class,'logical')||strcmp(initValStruct(j).class,'boolean')
                rhs='false';
            elseif strcmp(initValStruct(j).class,'double')
                rhs='0';
            elseif ismember(initValStruct(j).class,Stateflow.MALUtils.getMALDataTypesThatCanBeCasted())


                rhs=sprintf('%s(0)',initValStruct(j).class);
            else
                rhs=sprintf('zeros(''like'', %s)',lhs);
            end
        else
            if strcmp(initValStruct(j).class,'logical')||strcmp(initValStruct(j).class,'boolean')
                rhs=sprintf('false(%s)',initValStruct(j).size);
            elseif strcmp(initValStruct(j).class,'double')
                rhs=sprintf('zeros(%s)',initValStruct(j).size);
            elseif ismember(initValStruct(j).class,Stateflow.MALUtils.getMALDataTypesThatCanBeCasted())


                rhs=sprintf('%s(zeros(%s))',initValStruct(j).class,initValStruct(j).size);
            else
                rhs=sprintf('zeros(%s, ''like'', %s)',initValStruct(j).size,lhs);
            end
        end
        if~isempty(lhs)
            initValues{indx}=sprintf('%s = %s;%s',lhs,rhs,comment);
        else
            if addFcnCallComment&&strcmp(initValStruct(j).modelEventType,'DontCare')

                initValues{indx}='';
                initValues{indx+1}='%% Schedule function-call outputs.';
                initValues{indx+2}='%% Modify this code to change function-call order.';
                initValues{indx+3}='';
                indx=indx+4;

                addFcnCallComment=false;
            end
            initValues{indx}=sprintf('%s',rhs);
        end
        indx=indx+1;
    end



    if addFcnCallComment
        initValues=initValues(1:end-4);
    end
end
