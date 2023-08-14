function this=fifactory(varargin)






































































    this=copy(varargin{1});
    varargin=varargin(2:end);


    if nargin==1
        return
    end




    wordlengthset=false;
    scalingset=false;


    if isstruct(varargin{1})
        error(message('fixed:fi:unsupportedStructFirstInput'));
    elseif isEitherNumericType(varargin{1})
        error(message('fixed:fi:unsupportedNumericTypeFirstInput'));
    end



    for k=1:nargin-1
        vKthInput=varargin{k};
        classKthInput=class(vKthInput);
        if~isnumeric(vKthInput)&&~islogical(vKthInput)&&~ischar(vKthInput)...
            &&~isfimath(vKthInput)&&~isEitherNumericType(vKthInput)&&...
            ~isquantizer(vKthInput)
            errMsg=message('fixed:fi:invalidConstructorInput',classKthInput);
            error(errMsg);
        end
    end


    fimathislocal=false;%#ok


    nnumeric=0;
    for k=1:nargin-1
        if~isnumeric(varargin{k})&&~islogical(varargin{k})
            break
        end
        nnumeric=nnumeric+1;
    end




    nfirstchararg=realmax;
    for k=1:nargin-1
        if ischar(varargin{k})
            nfirstchararg=k;
            break
        end
    end
    fimathSpecifiedByString=0;



    autoscale=true;


    isCopyConstructor=nargin>1&&isfi(varargin{1});
    isVar1FloatBoolFi=false;

    if isCopyConstructor

        this=varargin{1};
        this.fimathislocal=isfimathlocal(varargin{1});
        isVar1FloatBoolFi=isfloat(this)||isboolean(this);
    else
        resetlogging(this);
    end






    if~isCopyConstructor&&nargin==2&&nnumeric==1
        switch class(varargin{1})
        case 'single'
            this.numerictype=numerictype('single');
            autoscale=false;
        case 'logical'
            this.numerictype=numerictype('Boolean');
            autoscale=false;
        end
    elseif isCopyConstructor&&isVar1FloatBoolFi&&nargin>2&&nnumeric>1
        this=embedded.fi();
        if~feature('FimathLessFis')||isfimathlocal(varargin{1})
            this.fimath=fimath(varargin{1});
        end
        varargin{1}=double(varargin{1});
        resetlogging(this);
        isCopyConstructor=false;
    end


    if~isCopyConstructor&&nnumeric>0
        if isinteger(varargin{1})

            this.numerictype=numerictype(class(varargin{1}));
            autoscale=false;
            wordlengthset=true;
        end
    end


    if nnumeric>2&&nnumeric<6
        for idx=3:nnumeric
            if isa(varargin{idx},'half')

                varargin{idx}=double(varargin{idx});
            end
        end
    end












    switch nnumeric
    case 0

    case 1





        if nargin>2
            if isquantizer(varargin{2})
                this=setFiFromQuantizer(this,varargin{2});
                autoscale=false;

                fimathislocal=true;%#ok
            elseif isEitherNumericType(varargin{2})
                if isa(varargin{2},'Simulink.NumericType')
                    T=numerictype(varargin{2});
                else
                    T=varargin{2};
                end
                if(strcmp(T.DataTypeMode,'Half')==1)
                    error(message('fixed:fi:unsupportedDataType','Half'));
                end
                warnstate=warning('off','fixed:numerictype:invalidModeSetting');
                this.numerictype=T;
                warning(warnstate);
                wordlengthset=true;
                [autoscale,scalingset]=adjust_autoscale_scalingset(varargin{1},T,autoscale,scalingset);
                if nargin>3&&isfimath(varargin{3})
                    this.fimath=varargin{3};
                    fimathislocal=true;%#ok
                end
            elseif isfimath(varargin{2})
                this.fimath=varargin{2};
                fimathislocal=true;%#ok
                if nargin>3&&isnumerictype(varargin{3})
                    T=varargin{3};
                    if(strcmp(T.DataTypeMode,'Half')==1)
                        error(message('fixed:fi:unsupportedDataType','Half'));
                    end
                    warnstate=warning('off','fixed:numerictype:invalidModeSetting');
                    this.numerictype=T;
                    warning(warnstate);
                    wordlengthset=true;
                    [autoscale,scalingset]=adjust_autoscale_scalingset(varargin{1},T,autoscale,scalingset);
                end
            end
        end
    case 2

        this.Scaling='BinaryPoint';
        this.SignednessBool=varargin{2};
        autoscale=true&&autoscale;
    case 3

        this.Scaling='BinaryPoint';
        this.SignednessBool=varargin{2};
        this.WordLength=varargin{3};
        wordlengthset=true;
        autoscale=true;
    case 4

        this.Scaling='BinaryPoint';
        this.SignednessBool=varargin{2};
        this.WordLength=varargin{3};
        this.FractionLength=varargin{4};
        autoscale=false;
    case 5

        this.Scaling='SlopeBias';
        this.SignednessBool=varargin{2};
        this.WordLength=varargin{3};
        this.Slope=varargin{4};
        this.Bias=varargin{5};
        autoscale=false;
    case 6

        this.Scaling='SlopeBias';
        this.SignednessBool=varargin{2};
        this.WordLength=varargin{3};
        this.SlopeAdjustmentFactor=varargin{4};
        this.FixedExponent=varargin{5};
        this.Bias=varargin{6};
        autoscale=false;
    otherwise
        error(message('fixed:fi:invalidConstructorNumericInputs'));
    end


    this=setFimathAfterNumericInputs(this,nargin-1,nnumeric,...
    varargin{:});





    ntProps=lower({'DataType',...
    'DataTypeMode',...
    'Scaling',...
    'Signed',...
    'Signedness',...
    'SignednessBool',...
    'WordLength',...
    'FractionLength',...
    'BinaryPoint',...
    'FixedExponent',...
    'Slope',...
    'SlopeAdjustmentFactor',...
'Bias'
    });


    setloopargs=varargin(nfirstchararg:end);
    nsetloopargs=length(setloopargs)-fimathSpecifiedByString;
    if fix(nsetloopargs/2)~=nsetloopargs/2
        error(message('fixed:fi:invalidConstructorPVPairs'));
    end



    if isCopyConstructor&&isVar1FloatBoolFi&&nnumeric==1
        for k=1:2:nsetloopargs
            ntmatch=min(strmatch(lower(setloopargs{k}),ntProps));%#ok<MATCH2>
            if ntmatch


                if isequal(ntmatch,1)||isequal(ntmatch,2)

                    strDouble=strDataTypeMatch(setloopargs{k+1},'double');
                    strSingle=strDataTypeMatch(setloopargs{k+1},'single');
                    strBoolean=strDataTypeMatch(setloopargs{k+1},'boolean');

                    if~strDouble&&~strSingle&&~strBoolean
                        varargin{1}=double(varargin{1});
                        this=embedded.fi();
                        resetlogging(this);
                        isCopyConstructor=false;
                        break;
                    end
                else
                    varargin{1}=double(varargin{1});
                    this=embedded.fi();
                    resetlogging(this);
                    isCopyConstructor=false;
                    break;
                end
            end
        end
    end



    warnstate=warning('off','fixed:numerictype:invalidModeSetting');
    try


        this.datasetbypvpair=false;
        DataPVPairs={};
        for k=1:2:nsetloopargs
            this.(setloopargs{k})=setloopargs{k+1};

            switch LastPropertySet(this)
            case 0

                T=setloopargs{k+1};
                wordlengthset=true;
                if~strcmpi(T.Scaling,'Unspecified')
                    autoscale=false;
                end
            case 4

                if~wordlengthset
                    this.WordLength=16;
                    wordlengthset=true;
                    autoscale=true;
                end
            case 5

                wordlengthset=true;
                if~scalingset
                    autoscale=true;
                end
            case{6,7,8,9}


                autoscale=false;
                scalingset=true;
            case{25,26,27,28,29,30,31,32,33,51}


                this.datasetbypvpair=true;
                DataPVPairs{end+1}=setloopargs{k};%#ok<AGROW>
                DataPVPairs{end+1}=setloopargs{k+1};%#ok<AGROW>
            end
        end
        warning(warnstate);
    catch me

        warning(warnstate);
        rethrow(me);
    end



    fimathislocal=isfimathlocal(this);



    if isscaledtype(this)&&isCopyConstructor&&autoscale&&~wordlengthset
        autoscale=false;
    end







    p=fipref;
    doDataTypeOverride=~isequal(p.DataTypeOverride,'ForceOff')&&...
    ~isequal(this.DataType,'boolean')&&...
    ~isequal(this.numerictype.DataTypeOverride,'Off');
    if doDataTypeOverride
        switch p.DataTypeOverride
        case{'TrueDoubles','TrueSingles'}
            if(isequal(p.DataTypeOverrideAppliesTo,'AllNumericTypes'))||...
                (isequal(p.DataTypeOverrideAppliesTo,'Fixed-point')&&isfixed(this))||...
                (isequal(p.DataTypeOverrideAppliesTo,'Floating-point')&&isfloat(this))
                dtoStr=p.DataTypeOverride;
                this.DataType=lower(dtoStr(5:end-1));
            end
        case 'ScaledDoubles'
            if isequal(p.DataTypeOverrideAppliesTo,'AllNumericTypes')
                if strcmpi(this.DataType,'fixed')
                    this.DataType='ScaledDouble';
                elseif strcmpi(this.DataType,'single')
                    this.DataType='double';
                end
            elseif isequal(p.DataTypeOverrideAppliesTo,'Floating-point')&&isfloat(this)
                this.DataType='double';
            elseif isequal(p.DataTypeOverrideAppliesTo,'Fixed-point')&&strcmpi(this.DataType,'fixed')
                this.DataType='ScaledDouble';
            end
        end
    end


    this.DataTypeOverride='Inherit';



    if autoscale&&isscaledtype(this)&&nnumeric>0
        this=setbestfractionlength(this,varargin{1});
        this.isautoscaled=true;
    else
        this.isautoscaled=false;
    end


    if isCopyConstructor&&~isequal(numerictype(this),numerictype(varargin{1}))
        resetlogging(this);
    end


    if isCopyConstructor&&~datasetbypvpair(this)&&nargin>2

        if~fimathislocal
            this.fimath=[];
        end






        this.copydata(varargin{1});
    elseif nnumeric>0&&~isCopyConstructor&&~datasetbypvpair(this)
        if issparse(varargin{1})
            error(message('fixed:fi:unsupportedSparseInput','fi constructor'));
        end

        if(isa(varargin{1},'int64')||isa(varargin{1},'uint64'))
            maxVal=max(max(abs(real(varargin{1}(:))),abs(imag(varargin{1}(:)))));
            if maxVal>2^52
                if isa(varargin{1},'int64')
                    tmpNT=numerictype(1,64,0);
                else
                    tmpNT=numerictype(0,64,0);
                end
                tmp=embedded.fi([],tmpNT,false);
                tmp.int=varargin{1};
                outFimath=this.fimath;
                this=quantize(tmp,this.numerictype,...
                this.RoundingMethod,this.OverflowAction);
                if fimathislocal
                    this.fimath=outFimath;
                end

            else
                if fimathislocal
                    this.data=varargin{1};
                else
                    autoscale=isautoscaled(this);
                    this=embedded.fi(varargin{1},this.numerictype,false);
                    this.isautoscaled=autoscale;
                end
            end
        else
            if fimathislocal
                this.data=varargin{1};
            else
                autoscale=isautoscaled(this);
                this=embedded.fi(varargin{1},this.numerictype,false);
                this.isautoscaled=autoscale;
            end
        end
    elseif datasetbypvpair(this)



        warnstate=warning('off','fixed:numerictype:invalidModeSetting');
        for k=1:2:length(DataPVPairs)
            this.(DataPVPairs{k})=DataPVPairs{k+1};
        end
        warning(warnstate);
    end

    validate_datatype(this);

end


function validate_datatype(this)
    if isscaledtype(this)&&issigned(this)&&this.WordLength<2
        error(message('fixed:numerictype:invalidMinWordLengthCodegen'));

    end
end


function this=setFiFromQuantizer(this,q)
    switch lower(q.mode)
    case{'fixed','ufixed'}
        this.DataType='fixed';
        this.Signed=strcmpi(q.mode,'fixed');
        this.WordLength=q.WordLength;
        this.FractionLength=q.FractionLength;
        this.Scaling='BinaryPoint';
    case{'double','single'}
        this.DataType=q.mode;
    case 'float'
        error(message('fixed:fi:unsupportedDataType','float'));
    end
    this.OverflowMode=q.OverflowMode;
    this.RoundMode=q.RoundMode;
end

function this=setbestfractionlength(this,data)






    if any(isnan(data(:)))
        error(message('fixed:fi:unsupportedNanInput'));
    end
    if any(isinf(data(:)))
        error(message('fixed:fi:unsupportedInfInput'));
    end

    T=numerictype(this);
    if isscaledtype(T)
        if strcmpi(T.Scaling,'Unspecified')
            T.Scaling='BinaryPoint';
        end
        if isempty(data)
            if isempty(T.SignednessBool),T.SignednessBool=1;end
            T.FractionLength=T.WordLength-T.SignednessBool;
            this.numerictype=T;
        else

            vals=double(data);
            if isreal(vals)
                vals=vals(:);
            else
                vals=[real(vals(:));imag(vals(:))];
            end

            if isslopebiasscaled(T)
                vals=(vals-T.Bias)/(T.SlopeAdjustmentFactor);
            end



            A=max(vals(abs(vals)==max(abs(vals))));
            T.SetBestFractionLength(A);

            if A<0



                B=max(vals);
                if B>0
                    T2=copy(T);
                    T2.SetBestFractionLength(B);
                    if T.FractionLength>T2.FractionLength

                        T=T2;
                    end
                end
            end
            this.numerictype=T;
        end
        resetlogging(this);
    end
end

function strval=strDataTypeMatch(strvalin,strData)


    strvalin=lower(strvalin);
    strval=strmatch(strvalin,strData);%#ok<MATCH2>
    strval=~isempty(strval)&&strval;

end


function[this,fimathislocal]=setFimathAfterNumericInputs(this,ninputs,nnumeric,varargin)


    fimathislocal=false;
    if ninputs>nnumeric&&isfimath(varargin{nnumeric+1})
        this.fimath=varargin{nnumeric+1};
        fimathislocal=true;
    end

end


function res=isEitherNumericType(dt)

    res=isnumerictype(dt)||isa(dt,'Simulink.NumericType');

end

function[autoscale,scalingset]=adjust_autoscale_scalingset(data,T,autoscale,scalingset)



    if strcmpi(T.Scaling,'Unspecified')&&isinteger(data)
        autoscale=true;
        scalingset=false;
    elseif~strcmpi(T.Scaling,'Unspecified')
        autoscale=false;
        scalingset=true;
    end
end






