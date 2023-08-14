function createConceptualArgs(this)






    dttype='double';
    if isa(this.object,'RTW.TflCOperationEntryGenerator')||...
        isa(this.object,'RTW.TflCOperationEntryGenerator_NetSlope')
        dttype='fixdt(1,16,1,0)';
    end

    switch this.object.Key
    case 'saturate'
        loc_createargs(this,3,'double','double','double','double');

    case 'memcpy'
        loc_createargs(this,3,'void*','void*','size_t','void*');

    case 'memcmp'
        loc_createargs(this,3,'void*','void*','size_t','integer');

    case 'memset'
        loc_createargs(this,3,'void*','integer','size_t','void*');

    case 'frexp'
        loc_createargs(this,2,'single','integer*','','single');

    case{'RTW_OP_ADD','RTW_OP_MINUS','RTW_OP_MUL',...
        'RTW_OP_DIV','RTW_OP_SL','RTW_OP_SRA',...
        'RTW_OP_SRL','RTW_OP_HMMUL','RTW_OP_TRMUL',...
        'RTW_OP_ELEM_MUL','RTW_OP_LDIV','RTW_OP_RDIV',...
        'RTW_OP_GREATER_THAN','RTW_OP_LESS_THAN',...
        'RTW_OP_GREATER_THAN_OR_EQUAL','RTW_OP_LESS_THAN_OR_EQUAL',...
        'RTW_OP_EQUAL','RTW_OP_NOT_EQUAL'}
        loc_createargs(this,2,dttype,dttype,'',dttype);

    case{'RTW_OP_MULDIV','RTW_OP_MUL_SRA'}
        loc_createargs(this,3,dttype,dttype,dttype,dttype);

    case 'circularIndex'
        loc_createargs(this,3,'int32','int32','int32','int32');

    case{'atan2','fmod','hypot','ldexp',...
        'max','min','mod','pow','rem',...
        'signPow','atan2d'}
        loc_createargs(this,2,'double','double','','double');

    case{'RTW_OP_CAST','RTW_OP_TRANS','RTW_OP_HERMITIAN',...
        'RTW_OP_CONJUGATE','RTW_OP_INV'}
        loc_createargs(this,1,dttype,'','',dttype);

    case{'abs','acos','acosh','asin','asinh','atan',...
        'atanh','ceil','cos','cosh','exp','exactrSqrt',...
        'fix','floor','ln','log','log10','round',...
        'rSqrt','sign','sin','sincos','sinh','signsqrt',...
        'sqrt','tan','tanh','isinf','isnan','reciprocal'...
        ,'isfinite','copysign','acosd','asind','acot','acotd',...
        'acsc','acscd','asec','asecd','cot','coth','csc',...
        'csch','sec','sech','atand','asech','acsch','acoth',...
        'cosd','secd','sind','cscd','tand','cotd','log2',}
        loc_createargs(this,1,'double','','','double');

    case{'RTW_SEM_WAIT','RTW_SEM_POST','RTW_SEM_DESTROY',...
        'RTW_MUTEX_INIT','RTW_MUTEX_LOCK','RTW_MUTEX_UNLOCK',...
        'RTW_MUTEX_DESTROY'}
        loc_createargs(this,1,'void','','','void');

    case 'RTW_SEM_INIT'
        loc_createargs(this,1,'integer','','','void');

    case{'urand','nrand','getinf','getnan','getminusinf'}
        loc_createargs(this,0);

    case{'code_profile_read_timer'}
        loc_createargs(this,0,'','','','uint16');

    otherwise
        this.object.ConceptualArgs=[];
    end



    function loc_createargs(this,numin,in1type,in2type,in3type,outtype)%#ok

        if isa(this.object,'RTW.TflBlasEntryGenerator')||...
            isa(this.object,'RTW.TflCBlasEntryGenerator')

            if~isempty(this.object.ConceptualArgs)
                this.object.ConceptualArgs=[];
            end
            hEnt=this.object;
            dims=[2,2;2,2];

            hEnt.createAndAddConceptualArg('RTW.TflArgMatrix',...
            'Name','y1',...
            'IOType','RTW_IO_OUTPUT',...
            'BaseType',outtype,...
            'DimRange',dims);

            if~isempty(in1type)
                hEnt.createAndAddConceptualArg('RTW.TflArgMatrix',...
                'Name','u1',...
                'BaseType',in1type,...
                'DimRange',dims);
            end

            if~isempty(in2type)
                hEnt.createAndAddConceptualArg('RTW.TflArgMatrix',...
                'Name','u2',...
                'BaseType',in2type,...
                'DimRange',dims);
            end

            if~isempty(in3type)
                hEnt.createAndAddConceptualArg('RTW.TflArgMatrix',...
                'Name','u2',...
                'BaseType',in3type,...
                'DimRange',dims);
            end


            this.argtype=1;
        else

            if~isempty(this.object.ConceptualArgs)
                this.object.ConceptualArgs=[];
            end

            this.object.ConceptualArgs=createArgument(this,'y1',outtype);
            this.object.ConceptualArgs.IOType='RTW_IO_OUTPUT';

            if strcmpi(this.object.Key,'sincos')
                this.object.ConceptualArgs(2)=createArgument(this,'y2',outtype);
                this.object.ConceptualArgs(2).IOType='RTW_IO_OUTPUT';
            end


            if~isempty(in1type)
                name='u1';
                this.object.ConceptualArgs(end+1)=createArgument(this,name,in1type);
                this.object.ConceptualArgs(end).IOType='RTW_IO_INPUT';
            end

            if~isempty(in2type)
                name='u2';
                this.object.ConceptualArgs(end+1)=createArgument(this,name,in2type);
                this.object.ConceptualArgs(end).IOType='RTW_IO_INPUT';
            end

            if~isempty(in3type)
                name='u3';
                this.object.ConceptualArgs(end+1)=createArgument(this,name,in3type);
                this.object.ConceptualArgs(end).IOType='RTW_IO_INPUT';
            end
        end


        function arg=createArgument(this,name,type)

            arg=this.parentnode.object.getTflArgFromString(name,type);
            if isa(this.object,'RTW.TflCOperationEntryGenerator')||...
                isa(this.object,'RTW.TflCOperationEntryGenerator_NetSlope')
                arg.CheckSlope=false;
                arg.CheckBias=false;
            end






