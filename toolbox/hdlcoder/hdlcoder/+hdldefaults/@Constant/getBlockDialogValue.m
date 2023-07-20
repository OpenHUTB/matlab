function[cval,vectorParams1D,TunableParamStr,v,isConstBlock]=...
    getBlockDialogValue(this,slbh)



    v=[];
    TunableParamStr='';
    vectorParams1D=0;
    isSynthetic=(slbh<0);
    if isSynthetic
        blockType='';
    else
        blockType=get_param(slbh,'BlockType');
    end
    isConstBlock=~isSynthetic&&strcmpi(blockType,'Constant');

    isStringConstBlock=~isSynthetic&&strcmpi(blockType,'StringConstant');

    if isConstBlock
        rto=get_param(slbh,'RuntimeObject');
        constprm=0;
        for n=1:rto.NumRuntimePrms
            if strcmp(rto.RuntimePrm(n).Name,'Value')
                constprm=n;
                break;
            end
        end
        if constprm==0
            error(message('hdlcoder:validate:constantvaluenotfound'));
        end
        cval=rto.RuntimePrm(constprm).Data;
        if isempty(cval)
            cval=hdlslResolve('Value',slbh);
        end
        vectorParams1D=get_param(slbh,'VectorParams1D');

        const_value=get_param(slbh,'Value');
        [TunableParamStr,v]=hdlimplbase.EmlImplBase.getTunableParameter(slbh,const_value);
        if~isempty(v)
            hdlDriver=hdlcurrentdriver;
            check=struct('path',getfullname(slbh),...
            'type','block',...
            'message',v.Message,...
            'level','Error',...
            'MessageID',v.MessageID);
            hdlDriver.updateChecksCatalog(hdlDriver.ModelName,check);
        end

    elseif isStringConstBlock
        rto=get_param(slbh,'RuntimeObject');
        constprm=0;
        for n=1:rto.NumRuntimePrms
            if strcmp(rto.DialogPrm(n).Name,'String')
                constprm=n;
                break;
            end
        end
        if constprm==0
            error(message('hdlcoder:validate:constantvaluenotfound'));
        end
        cval=rto.DialogPrm(constprm).Data;
        if isempty(cval)
            cval=hdlslResolve('String',slbh);
        end
        cval=convertStringsToChars(cval);


        slType=rto.RuntimePrm(constprm).DataType;
        slTypeLen=str2double(slType(4:end));
        strLen=length(cval);
        if(slTypeLen>strLen)
            cval=[cval,char(zeros(1,(slTypeLen-strLen)))];
        end
        vectorParams1D='on';
        const_value=get_param(slbh,'String');
        [TunableParamStr,v]=hdlimplbase.EmlImplBase.getTunableParameter(slbh,const_value);
        if~isempty(v)
            hdlDriver=hdlcurrentdriver;
            check=struct('path',getfullname(slbh),...
            'type','block',...
            'message',v.Message,...
            'level','Error',...
            'MessageID',v.MessageID);
            hdlDriver.updateChecksCatalog(hdlDriver.ModelName,check);
        end
    elseif isSynthetic||strcmpi(blockType,'Ground')
        cval=0;
    else
        valstruct=get_param(slbh,'MaskWSVariables');
        if isempty(valstruct)
            valstruct=get_param(get(get_param(slbh,'Object'),'Parent'),'MaskWSVariables');
        end
        if isempty(valstruct)
            cval=this.hdlslResolve('value',slbh);
        else
            val_loc=strcmp('Value',{valstruct.Name});
            if any(val_loc)==true
                cval=valstruct(val_loc).Value;
            else
                val_loc=strcmp('enumConstDispStr',{valstruct.Name});
                if any(val_loc)==true
                    cval=valstruct(val_loc).Value;
                else
                    error(message('hdlcoder:validate:MatrixTunableParamUnsupported'));
                end
            end
        end
        if ischar(cval)

            cval=slResolve(cval,slbh);
        end
    end
end

