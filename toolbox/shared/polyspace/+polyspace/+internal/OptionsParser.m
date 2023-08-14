classdef(Hidden=true)OptionsParser<handle










    properties(SetAccess=private,GetAccess=public)
        Results=struct();
        ExtraArguments={};
    end

    properties(Access=private)
        OptionsDefinitions;
        OptionsSynonyms;
    end

    properties(Access=public)
        FunctionName='';
        AllowExtraArguments=false;
    end

    methods(Access=public)



        function this=OptionsParser()
            this.OptionsDefinitions=containers.Map('KeyType','char','ValueType','any');
            this.OptionsSynonyms=containers.Map('KeyType','char','ValueType','char');
        end




        function addSwitch(this,optName,fieldName,dependentOptions,defaultValue,value)
            if nargin<4
                dependentOptions={};
            end
            if nargin<5
                defaultValue=false;
            end
            if nargin<6
                value=true;
            end
            this.OptionsDefinitions(optName)=struct('isSwitch',true,...
            'fieldName',fieldName,...
            'isMulti',false,...
            'defaultValue',defaultValue,...
            'value',value,...
            'dependentOptions',{dependentOptions});
        end




        function addOptional(this,optName,fieldName,defaultValue,dependentOptions)
            if nargin<5
                dependentOptions={};
            end
            this.OptionsDefinitions(optName)=struct('isSwitch',false,...
            'fieldName',fieldName,...
            'isMulti',false,...
            'defaultValue',defaultValue,...
            'dependentOptions',{dependentOptions});
        end




        function addMultiOptional(this,optName,fieldName,dependentOptions)
            if nargin<4
                dependentOptions={};
            end
            this.OptionsDefinitions(optName)=struct('isSwitch',false,...
            'fieldName',fieldName,...
            'isMulti',true,...
            'dependentOptions',{dependentOptions});
        end




        function addRequired(this,optName,fieldName)
            this.OptionsDefinitions(optName)=struct('isSwitch',false,...
            'fieldName',fieldName,...
            'isMulti',false,...
            'dependentOptions',{{}});
        end




        function setIncompatibleOptions(this,varargin)
            for iArg=1:nargin-1
                optName=varargin{iArg};
                if~this.OptionsDefinitions.isKey(optName)
                    error(message('polyspace:pscore:unknownOption',optName));
                end
                optDef=this.OptionsDefinitions(optName);
                incompatibleOptions=varargin;
                incompatibleOptions(iArg)=[];
                if isfield(optDef,'incompatibleOptions')
                    optDef.incompatibleOptions=[optDef.incompatibleOptions,incompatibleOptions];
                else
                    optDef.incompatibleOptions=incompatibleOptions;
                end
                this.OptionsDefinitions(optName)=optDef;
            end
        end




        function setOptionSynonym(this,optName,otherOptName)
            this.OptionsSynonyms(otherOptName)=optName;
        end




        function parse(this,varargin)
            this.Results=struct();
            this.ExtraArguments={};

            alreadyParsedOptions={};

            iArg=1;
            while iArg<nargin
                optName=varargin{iArg};
                validateattributes(optName,{'char'},{'row'},this.FunctionName,optName,iArg);
                if this.OptionsSynonyms.isKey(optName)
                    effOptName=this.OptionsSynonyms(optName);
                else
                    effOptName=optName;
                end
                if this.OptionsDefinitions.isKey(effOptName)
                    iArg=iArg+1;
                    optDef=this.OptionsDefinitions(effOptName);


                    if isfield(optDef,'incompatibleOptions')
                        idx=ismember(optDef.incompatibleOptions,alreadyParsedOptions);
                        if any(idx)
                            otherOptName=alreadyParsedOptions{find(idx,1,'first')};
                            error(message('polyspace:pscore:incompatibleOptions',optName,otherOptName));
                        end
                    end

                    if optDef.isSwitch

                        this.Results.(optDef.fieldName)=optDef.value;
                    else

                        if(iArg>=nargin)
                            error(message('polyspace:pscore:missingArgumentForOption',optName));
                        end
                        val=varargin{iArg};
                        validateattributes(val,{'char'},{'row'},this.FunctionName,optName,iArg);
                        iArg=iArg+1;
                        if isempty(val)||strncmp(val,'-',1)
                            error(message('polyspace:pscore:missingArgumentForOption',optName));
                        end


                        if isfield(this.Results,optDef.fieldName)&&~optDef.isMulti
                            error(message('polyspace:pscore:optionMustBeUsedOnce',optName));
                        end

                        if optDef.isMulti
                            if isfield(this.Results,optDef.fieldName)
                                this.Results.(optDef.fieldName)=[this.Results.(optDef.fieldName),{val}];
                            else
                                this.Results.(optDef.fieldName)={val};
                            end
                        else
                            this.Results.(optDef.fieldName)=val;
                        end
                    end
                    alreadyParsedOptions{end+1}=effOptName;%#ok<AGROW>
                elseif strncmp(optName,'-',1)

                    error(message('polyspace:pscore:unknownOption',optName));
                elseif~this.AllowExtraArguments
                    error(message('polyspace:pscore:unexpectedArgument',optName));
                else

                    this.ExtraArguments=varargin(iArg:end);
                    break
                end
            end




            allOptNames=this.OptionsDefinitions.keys();
            depsSatisfied=false(1,numel(allOptNames));
            for ii=1:numel(allOptNames)
                optDef=this.OptionsDefinitions(allOptNames{ii});

                if isfield(optDef,'incompatibleOptions')
                    idx=ismember(optDef.incompatibleOptions,alreadyParsedOptions);
                    if any(idx)
                        continue
                    end
                end

                if isempty(optDef.dependentOptions)
                    depsSatisfied(ii)=true;
                else
                    depsSatisfied(ii)=false;
                    for jj=1:numel(optDef.dependentOptions)
                        depOptDef=this.OptionsDefinitions(optDef.dependentOptions{jj});
                        if isfield(this.Results,depOptDef.fieldName)
                            depsSatisfied(ii)=true;
                            break
                        end
                    end
                end
            end


            for ii=1:numel(allOptNames)
                optDef=this.OptionsDefinitions(allOptNames{ii});

                if~isfield(this.Results,optDef.fieldName)

                    if~isfield(optDef,'defaultValue')&&~optDef.isMulti

                        error(message('polyspace:pscore:missingRequiredOption',allOptNames{ii}));
                    elseif depsSatisfied(ii)

                        if isfield(optDef,'defaultValue')
                            this.Results.(optDef.fieldName)=optDef.defaultValue;
                        else
                            this.Results.(optDef.fieldName)={};
                        end
                    end
                elseif ismember(allOptNames{ii},alreadyParsedOptions)

                    if~depsSatisfied(ii)&&~isempty(optDef.dependentOptions)
                        if numel(optDef.dependentOptions)==1
                            error(message('polyspace:pscore:missingDependentOption',allOptNames{ii},optDef.dependentOptions{1}));
                        else
                            error(message('polyspace:pscore:missingDependentOptionFromList',allOptNames{ii},...
                            ['''',strjoin(optDef.dependentOptions,''', '''),'''']));
                        end
                    end
                end
            end
        end
    end
end
