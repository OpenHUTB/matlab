function[noports,any_real,all_real,any_double,all_double,any_single,all_single,any_half,all_half]=checkForDoublePorts(~,ports)









    if~isempty(ports)
        noports=false;
        any_real=false;
        all_real=true;
        any_double=false;
        all_double=true;
        any_single=false;
        all_single=true;
        any_half=false;
        all_half=true;

        for ii=1:length(ports)
            sig=ports(ii).Signal;
            sigType=sig.Type;

            if sigType.isArrayType
                sigType=sigType.BaseType;
            end

            if sigType.isComplexType
                sigType=sigType.getLeafType;
            end

            if sigType.isFloatType
                any_real=true;
                if sigType.isDoubleType
                    any_double=true;
                else
                    if sigType.isSingleType
                        any_single=true;
                    elseif sigType.isHalfType
                        any_half=true;
                    else
                        assert(any_half,'Real but not double, single and half!');
                    end
                end

            elseif sigType.isRecordType&&ports(ii).getBustoVectorFlag
                [t_any_real,t_all_real,t_any_double,t_all_double,t_any_single,t_all_single,t_any_half,t_all_half]=checkRecordType(sigType);
                any_real=any_real||t_any_real;
                all_real=all_real&&t_all_real;
                any_double=any_double||t_any_double;
                all_double=all_double&&t_all_double;
                any_single=any_single||t_any_single;
                all_single=all_single&&t_all_single;
                any_half=any_half||t_any_half;
                all_half=all_half&&t_all_half;
            else
                all_real=false;
                all_double=false;
                all_single=false;
                all_half=false;
            end
        end
    else
        noports=true;
        any_real=false;
        all_real=false;
        any_double=false;
        all_double=false;
        any_single=false;
        all_single=false;
        any_half=false;
        all_half=false;
    end



    function[any_real,all_real,any_double,all_double,any_single,all_single,any_half,all_half]=checkRecordType(recType)

        any_real=false;
        all_real=true;
        any_double=false;
        all_double=true;
        any_single=false;
        all_single=true;
        any_half=false;
        all_half=true;

        typeList=recType.MemberTypesFlattened;
        for ii=1:length(typeList)
            type=typeList(ii);

            if type.isArrayType
                type=type.BaseType;
            end

            if type.isComplexType
                type=type.getLeafType;
            end

            if type.isFloatType
                any_real=true;
                if type.isDoubleType
                    any_double=true;
                else
                    if type.isSingleType
                        any_single=true;
                    elseif type.isHalfType
                        any_half=true;
                    else
                        assert(any_half,'Real but not double, single and half!');
                    end
                end
            elseif type.isRecordType
                [t_any_real,t_all_real,t_any_double,t_all_double,t_any_single,t_all_single,t_any_half,t_all_half]=checkRecordType(recType);
                any_real=any_real||t_any_real;
                all_real=all_real&&t_all_real;
                any_double=any_double||t_any_double;
                all_double=all_double&&t_all_double;
                any_single=any_single||t_any_single;
                all_single=all_single&&t_all_single;
                any_half=any_half||t_any_half;
                all_half=all_half&&t_all_half;
            else
                all_real=false;
                all_double=false;
                all_single=false;
                all_half=false;
            end
        end


