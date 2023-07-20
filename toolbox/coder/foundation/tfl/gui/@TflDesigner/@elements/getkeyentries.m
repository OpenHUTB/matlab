function names=getkeyentries(this)




    if isa(this.object,'RTW.TflCOperationEntry')&&...
        ~(strcmpi(this.EntryType,'RTW.TflBlasEntryGenerator')||...
        strcmpi(this.EntryType,'RTW.TflCBlasEntryGenerator'))
        names{1}='Addition';
        names{end+1}='Minus';
        names{end+1}='Multiply';
        names{end+1}='Element-wise Matrix Multiply';
        names{end+1}='Divide';
        if~any(strcmp(this.EntryType,{'RTW.TflCOperationEntryGenerator',...
            'RTW.TflCOperationEntryGenerator_NetSlope'}))
            names{end+1}='Left Matrix Divide';
            names{end+1}='Right Matrix Divide';
            names{end+1}='Matrix Inverse';
        end
        names{end+1}='Cast';
        names{end+1}='Shift Left';
        names{end+1}='Shift Right Arithmetic';
        names{end+1}='Shift Right Logical';
        names{end+1}='Transpose';
        names{end+1}='Complex Conjugate';
        names{end+1}='Complex Conjugate Transpose (Hermitian)';
        names{end+1}='Hermitian Multiplication';
        names{end+1}='Transpose Multiplication';
        names{end+1}='Multiply Divide';
        if~any(strcmp(this.EntryType,{'RTW.TflCOperationEntryGenerator',...
            'RTW.TflCOperationEntryGenerator_NetSlope'}))
            names{end+1}='Multiply Shift Right Arithmetic';
        end
        names{end+1}='Greater Than';
        names{end+1}='Greater Than Or Equal';
        names{end+1}='Less Than';
        names{end+1}='Less Than Or Equal';
        names{end+1}='Equal';
        names{end+1}='Not Equal';

    elseif strcmpi(this.EntryType,'RTW.TflBlasEntryGenerator')||...
        strcmpi(this.EntryType,'RTW.TflCBlasEntryGenerator')
        names{1}='Multiply';
        names{end+1}='Hermitian Multiplication';
        names{end+1}='Transpose Multiplication';

    elseif isa(this.object,'RTW.TflCSemaphoreEntry')
        names{1}='Semaphore Init';
        names{end+1}='Semaphore Wait';
        names{end+1}='Semaphore Post';
        names{end+1}='Semaphore Destroy';
        names{end+1}='Mutex Init';
        names{end+1}='Mutex Lock';
        names{end+1}='Mutex Unlock';
        names{end+1}='Mutex Destroy';

    elseif isa(this.object,'RTW.TflCFunctionEntry')
        names{1}='abs';
        names{end+1}='acos';
        names{end+1}='acosd';
        names{end+1}='acosh';
        names{end+1}='acot';
        names{end+1}='acotd';
        names{end+1}='acoth';
        names{end+1}='acsc';
        names{end+1}='acscd';
        names{end+1}='acsch';
        names{end+1}='asec';
        names{end+1}='asecd';
        names{end+1}='asech';
        names{end+1}='asin';
        names{end+1}='asind';
        names{end+1}='asinh';
        names{end+1}='atan';
        names{end+1}='atand';
        names{end+1}='atan2';
        names{end+1}='atan2d';
        names{end+1}='atanh';
        names{end+1}='ceil';
        names{end+1}='circularIndex';
        names{end+1}='code_profile_read_timer';
        names{end+1}='cos';
        names{end+1}='cosd';
        names{end+1}='cosh';
        names{end+1}='cot';
        names{end+1}='cotd';
        names{end+1}='coth';
        names{end+1}='csc';
        names{end+1}='cscd';
        names{end+1}='csch';
        names{end+1}='exactrSqrt';
        names{end+1}='exp';
        names{end+1}='fix';
        names{end+1}='floor';
        names{end+1}='fmod';
        names{end+1}='frexp';
        names{end+1}='hypot';
        names{end+1}='ldexp';
        names{end+1}='ln';
        names{end+1}='log';
        names{end+1}='log2';
        names{end+1}='log10';
        names{end+1}='max';
        names{end+1}='memcpy';
        names{end+1}='memset';
        names{end+1}='memcmp';
        names{end+1}='min';
        names{end+1}='mod';
        names{end+1}='pow';
        names{end+1}='rem';
        names{end+1}='reciprocal';
        names{end+1}='round';
        names{end+1}='rSqrt';
        names{end+1}='saturate';
        names{end+1}='sec';
        names{end+1}='secd';
        names{end+1}='sech';
        names{end+1}='sign';
        names{end+1}='signPow';
        names{end+1}='sin';
        names{end+1}='sind';
        names{end+1}='sincos';
        names{end+1}='sinh';
        names{end+1}='sqrt';
        names{end+1}='tan';
        names{end+1}='tand';
        names{end+1}='tanh';
        names{end+1}='Custom';

    elseif isa(this.object,'RTW.TflCustomization')
        names{1}='abs';
        names{end+1}='acos';
        names{end+1}='acosh';
        names{end+1}='asin';
        names{end+1}='asinh';
        names{end+1}='atan';
        names{end+1}='atan2';
        names{end+1}='atanh';
        names{end+1}='ceil';
        names{end+1}='cos';
        names{end+1}='cosh';
        names{end+1}='copysign';
        names{end+1}='exp';
        names{end+1}='fix';
        names{end+1}='floor';
        names{end+1}='fmod';
        names{end+1}='frexp';
        names{end+1}='getInf';
        names{end+1}='getMinusInf';
        names{end+1}='getNaN';
        names{end+1}='hypot';
        names{end+1}='isFinite';
        names{end+1}='ldexp';
        names{end+1}='log';
        names{end+1}='log10';
        names{end+1}='max';
        names{end+1}='min';
        names{end+1}='mod';
        names{end+1}='nrand';
        names{end+1}='pow';
        names{end+1}='rtIsInf';
        names{end+1}='rtIsNaN';
        names{end+1}='rem';
        names{end+1}='round';
        names{end+1}='rSqrt';
        names{end+1}='saturate';
        names{end+1}='sign';
        names{end+1}='sincos';
        names{end+1}='sin';
        names{end+1}='sinh';
        names{end+1}='signSqrt';
        names{end+1}='sqrt';
        names{end+1}='tan';
        names{end+1}='tanh';
        names{end+1}='urand';
        names{end+1}='Custom';

    else
        names={''};
    end




