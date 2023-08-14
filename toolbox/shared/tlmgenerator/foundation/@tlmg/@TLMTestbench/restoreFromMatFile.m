function restoreFromMatFile(this,dataStruct)



    allStructs={...
    'original Simulink signal log',...
    'TLM input vectors',...
    'TLM output vectors',...
'TLM results as Simulink signal log'...
    };

    try
        switch(dataStruct)

        case allStructs{1}
            load(fullfile('vectors',[this.OrigSllogName,'.mat']));
            this.OrigSllog.(this.OrigSllogName)=eval(this.OrigSllogName);

        case allStructs{2}
            load(fullfile('vectors',[this.TlmInVecName,'.mat']));
            this.TlmInVec.(this.TlmInVecName)=eval(this.TlmInVecName);

        case allStructs{3}
            load(fullfile('vectors',[this.TlmOutVecName,'.mat']));
            this.TlmOutVec.(this.TlmOutVecName)=eval(this.TlmOutVecName);

        case allStructs{4}
            load(fullfile('vectors',[this.TlmSllogName,'.mat']));
            this.TlmSllog.(this.TlmSllogName)=eval(this.TlmSllogName);

        otherwise
            error(message('TLMGenerator:TLMTestbench:BadDataStructNameRestore',dataStruct));
        end
    catch ME
        l_me=MException('TLMGenerator:TLMTestbench:RestoreError',getString(message('TLMGenerator:TLMTestbench:RestoreError',dataStruct)));
        ME=addCause(ME,l_me);
        throw(ME);
    end

end
