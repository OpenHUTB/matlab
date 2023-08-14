function this=initDataTypeRow(this,type,row,controller,customStruct)








    this.Row=row;
    this.Controller=controller;
    this.Block=controller.block;





    baseEntries={getString(message('dspshared:FixptDialog:BinaryPointScaling')),getString(message('dspshared:FixptDialog:SlopeAndBiasScaling'))};


    if(isfield(type,'blockHasAccum'))
        accumExists=(type.blockHasAccum~=0);
    else
        accumExists=0;
    end

    if isfield(type,'blockHasProdOutput')
        prodOutExists=(type.blockHasProdOutput~=0);
    elseif isfield(type,'blockHasProdOut')
        prodOutExists=(type.blockHasProdOut~=0);
    else
        prodOutExists=0;
    end

    if(isfield(type,'firstInput'))
        notFirstInput=(type.firstInput==0);
    else
        notFirstInput=1;
    end

    if notFirstInput
        sameAsInputStr=getString(message('dspshared:FixptDialog:SameAsInput'));
    else
        sameAsInputStr=getString(message('dspshared:FixptDialog:SameAsFirstInput'));
    end

    switch(type.name)
    case 'custom'
        this.Name=customStruct.Name;
        this.Prefix=customStruct.Prefix;
        entries=customStruct.Entries;

    case 'state'
        this.Name=getString(message('dspshared:FixptDialog:statePrompt'));
        this.Prefix='memory';
        entries=cat(2,{sameAsInputStr},baseEntries);

    case 'prodOutput'
        this.Name=getString(message('dspshared:FixptDialog:productPrompt'));
        this.Prefix='prodOutput';
        entries=cat(2,{sameAsInputStr},baseEntries);

    case 'accum'
        this.Name=getString(message('dspshared:FixptDialog:accumulatorPrompt'));
        this.Prefix='accum';
        if prodOutExists
            entries=cat(2,{getString(message('dspshared:FixptDialog:SameAsProductOutput')),sameAsInputStr},baseEntries);
        else
            entries=cat(2,{sameAsInputStr},baseEntries);
        end

    case 'output'
        this.Name=getString(message('dspshared:FixptDialog:outputPrompt'));
        this.Prefix='output';
        if(accumExists&&prodOutExists)
            entries=cat(2,{getString(message('dspshared:FixptDialog:SameAsAccumulator')),getString(message('dspshared:FixptDialog:SameAsProductOutput')),sameAsInputStr},baseEntries);
        elseif accumExists
            entries=cat(2,{getString(message('dspshared:FixptDialog:SameAsAccumulator')),sameAsInputStr},baseEntries);
        elseif prodOutExists
            entries=cat(2,{getString(message('dspshared:FixptDialog:SameAsProductOutput')),sameAsInputStr},baseEntries);
        else
            entries=cat(2,{sameAsInputStr},baseEntries);
        end
    end

    if isfield(type,'internalRule')
        if(type.internalRule~=0)
            entries=cat(2,{getString(message('dspshared:FixptDialog:InheritViaInternalRule'))},entries);
        end
    end


    if(isfield(type,'blockSupportsUnsigned'))
        this.SupportsUnsigned=type.blockSupportsUnsigned;
    elseif(isfield(customStruct,'blockSupportsUnsigned'))
        this.SupportsUnsigned=customStruct.blockSupportsUnsigned;
    else
        this.SupportsUnsigned=0;
    end

    this.Entries=entries;

    this.loadFromBlock;
