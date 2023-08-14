function saveToMatFile(this,dataStruct)



    allStructs={...
    'original Simulink signal log',...
    'TLM input vectors',...
'TLM results as Simulink signal log'...
    };

    nostruct=false;

    switch(dataStruct)

    case allStructs{1}
        if(~isempty(this.OrigSllog))
            eval([this.OrigSllogName,'= this.OrigSllog.',this.OrigSllogName,';']);
            save(fullfile('vectors',[this.OrigSllogName,'.mat']),this.OrigSllogName);
        else
            nostruct=true;
        end

    case allStructs{2}
        if(~isempty(this.TlmInVec))
            eval([this.TlmInVecName,'= this.TlmInVec.',this.TlmInVecName,';']);
            save(fullfile('vectors',[this.TlmInVecName,'.mat']),this.TlmInVecName);
        else
            nostruct=true;
        end

    case allStructs{3}
        if(~isempty(this.TlmSllog))
            eval([this.TlmSllogName,'= this.TlmSllog.',this.TlmSllogName,';']);
            save(fullfile('vectors',[this.TlmSllogName,'.mat']),this.TlmSllogName);
        end

    otherwise
        error(message('TLMGenerator:TLMTestbench:BadDataStructNameSave',dataStruct));
    end

    if(nostruct)
        error(message('TLMGenerator:TLMTestbench:NoDataStruct',dataStruct));
    end
















end
