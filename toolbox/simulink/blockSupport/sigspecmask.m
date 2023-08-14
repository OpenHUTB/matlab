function S=sigspecmask(block,D,Ts,DataType,SignalType,varargin)






    S=[];
    S.status='';
    S.dispStr='';

    dispStr='';
    lenv=length(varargin);
    if lenv==0
        SamplingMode='auto';
        bname=getfullname(block);
        MSLDiagnostic('Simulink:blocks:obsoleteMask','Signal Specification block',bname).reportAsWarning;
    elseif lenv==1
        SamplingMode=varargin{1};
    else
        DAStudio.error('Simulink:blocks:tooManyInputArguments');
    end



    dstr='';
    DIsInherit=(length(D)==1)&(D(1)==-1);
    if(~DIsInherit)

        isOk=(ndims(D)==2);
        if(isOk)
            m=size(D,1);
            n=size(D,2);

            isOk=(m==1|n==1)&(m*n==1|m*n==2);
        end

        if(isOk)
            isOk=isequal(double(int32(D)),D)&isempty(find(D<=0));
        end

        if(~isOk)
            S.status=['Dimensions must be -1 (inherited) or it must be '...
            ,'a positive, non-zero, integer valued vector with '...
            ,'1 or 2 elements.'];

            dStr=sprintf('D:?');
        else
            if(m==1&n==1)
                dStr=sprintf('D:[%d]',D);
            else
                dStr=sprintf('D:[%d, %d]',D(1),D(2));
            end;
        end
        dispStr=dStr;
    end;


    tsStr='';
    TsIsInherit=(length(Ts)==1)&(Ts(1)==-1);
    if(~TsIsInherit)
        isOk=(ndims(Ts)==2);
        if(isOk)
            m=size(Ts,1);
            n=size(Ts,2);

            isOk=(m==1|n==1)&(m*n==1|m*n==2);
        end

        if(~isOk)
            S.status=['Sample time must be a vector with 1 or 2 elements.'];
            tsStr=sprintf('Ts:?');
        else
            if(m==1&n==1)
                tsStr=sprintf('Ts:[%f]',Ts);
            else
                tsStr=sprintf('Ts:[%f %f]',Ts(1),Ts(2));
            end;
        end

        if(strcmp(dispStr,''))
            dispStr=tsStr;
        else
            dispStr=sprintf('%s, %s',dispStr,tsStr);
        end
    end



    sigTypeStr='';
    if(~isequal(SignalType,'auto'))
        sigTypeStr=SignalType;
        if(strcmpi(SignalType,'complex'))
            sigTypeStr='C:1';
        else
            sigTypeStr='C:0';
        end

        if(strcmp(dispStr,''))
            dispStr=sigTypeStr;
        else
            dispStr=sprintf('%s, %s',dispStr,sigTypeStr);
        end
    end


    dtypeStr='';
    if(~isequal(DataType,'auto'))
        dtypeStr=DataType;
        if(strcmp(dispStr,''))
            dispStr=dtypeStr;
        else
            dispStr=sprintf('%s, T:%s',dispStr,dtypeStr);
        end
    end


    samplingmodeStr='';
    if(~isequal(SamplingMode,'auto'))
        samplingmodeStr=SamplingMode;
        if(strcmpi(SamplingMode,'Sample based'))
            samplingmodeStr='NF';
        else
            samplingmodeStr='F';
        end

        if(strcmp(dispStr,''))
            dispStr=samplingmodeStr;
        else
            dispStr=sprintf('%s, S:%s',dispStr,samplingmodeStr);
        end

    end



    if(strcmp(dispStr,''))
        S.dispStr='Inherit';
    else
        S.dispStr=dispStr;
    end





    udtStr=DataType;
    if strcmp(DataType,'auto')
        udtStr='Inherit: auto';
    end

    if strcmp(S.status,'')
        try



            set_param([block,'/In'],...
            'OutDataTypeStr',udtStr,...
            'SignalType',SignalType,...
            'SamplingMode',SamplingMode);
        catch

        end
    end


