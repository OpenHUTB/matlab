classdef SpecMiner < handle

    properties (Access=private)
        input
        jsonDependencies
        typedDependencies
        predicateTree
        ltlFormula

        useStanfordNlp
    end

    methods
       % Constructor
       function self = SpecMiner(varargin)
           if Simulink.specminer.internal.specminerFeature() == 0
               DAStudio.error('sltest:specminer:FeatureNotOn');
           end
           
           self.useStanfordNlp = false; % defalut to use local NLP toolbox
           switch nargin
               case 1
                   self.input = varargin{1};
               otherwise
                   self.input = '';
           end
       end       
       
       % Setters
       function SetUseStanfordNlp(self, tf)
           self.useStanfordNlp = tf;
       end
       function SetInput(self, userInput)
           self.input = userInput;
       end
       
       %Getters
       function retValue = GetJsonDependencies(self)
           self.DependencyParser();           
           retValue = self.jsonDependencies;
       end
       
       function retValue = GetTypedDependencies(self)
           self.DependencyParser()
           self.typedDependencies = Simulink.specminer.internal.parseJsonDependencies(self.jsonDependencies);
           retValue = self.typedDependencies;
       end
       
       % Misc utilities
       function clear(self)
           self.input = '';
           self.jsonDependencies = '';
           self.typedDependencies = '';
           self.predicateTree = '';
           self.ltlFormula = '';
       end
       
       
       % Actions
       function DependencyParser(self)
           if self.useStanfordNlp
               % call external python script to get information from
               % Stanford coreNLP service
               self.jsonDependencies = Simulink.specminer.internal.callpython('./nlpParser.py', self.input);    
           else
               % use local matlab NLP toolbox
               td = tokenizedDocument(self.input);
               tdd = addDependencyDetails(td);
               tddd = addPartOfSpeechDetails(tdd);
               details = tokenDetails(tddd);
               self.jsonDependencies = convertToJson(details, self.input);
               
           end
       end
       
       function JsonDependencyParser(self)
           self.typedDependencies = Simulink.specminer.internal.parseJsonDependencies(self.jsonDependencies);
       end
       
       function formula = SynthesizeTemporalAssessment(self)
           if isempty(self.input)
               formula = '';
               return;
           end
           
           % Run dependency parser
           self.DependencyParser();
           if isempty(self.jsonDependencies)
               formula = '';
               return;
           end
           
           self.typedDependencies = Simulink.specminer.internal.parseJsonDependencies(self.jsonDependencies);
           
           self.ltlFormula = Simulink.specminer.internal.convertToLTLFormula(self.typedDependencies);
           
           formula = self.ltlFormula;
       end
    end
end

function jsonStr = convertToJson(depDetails, inputStr)

    % mappings need to be confirmed:
    %   auxiliary-verb->VBZ (or VBD, VBG, VBN, VBP?)
    %   proper-noun -> NNP? NNPS?

    % PUNCT needs to be itself
    POS_MAP = containers.Map(...
        {'subord-conjunction', 'determiner', 'noun', 'auxiliary-verb', 'proper-noun', 'punctuation', 'adposition', 'numeral', ...
        }, ...
        {'IN', 'DT', 'NN', 'VBZ','NNP', 'PUNCT', 'IN', 'CD', ...
        });

    sz = size(depDetails);
    dependenciesStruct = {};
    tokens = {};
    rowCount = sz(1);
    curpos = 0;

    for i=1:rowCount
        row = depDetails(i, :);

        % 1. Token
        % each row corresponds to one token.
        % re-constuct tokens

        token.index = i;
        token.word = row.Token;
        token.originalText = row.Token; 
        % need the position of tokens in the inputStr
        % Not sure this is the best approach
        
        % we are basically assuming the tokens are in order here !!!!!
        pos = strfind(inputStr, row.Token);
        
        if length(pos) == 1
            token.characterOffsetBegin = pos - 1; % 0 based
            token.characterOffsetEnd = token.characterOffsetBegin + strlength(row.Token);
            curpos = token.characterOffsetEnd;
        else
            for j=1:length(pos)
                if pos(j) >= curpos
                    token.characterOffsetBegin = pos(j) - 1; % 0 based
                    token.characterOffsetEnd = token.characterOffsetBegin + strlength(row.Token);
                    curpos = token.characterOffsetEnd;
                    break;
                end
            end
        end
        token.pos='';
        partOS = char(cellstr(row.PartOfSpeech));
        if isKey(POS_MAP, partOS)
            if strcmp(partOS, 'punctuation')
                % Special. Punctuation is the text itself.
                token.pos = row.Token;
            else
                token.pos = POS_MAP(partOS);
            end
        else
            disp(['Not mapped yet: ' row.PartOfSpeech]);
        end

        tokens{end+1} = token; %#ok<AGROW> 

        % 2. basicDependencies. 
        % each entry in basicDependencies is a connection between governor
        % and dependent. 

        depStruct.dependentGloss = row.Token;
        depStr = char(cellstr(row.Dependency));

        depStruct.dep = depStr;
        % temp patch
        if strcmp(row.Token, 'seconds') && strcmp(depStr, 'obl')
            % overwrite
            depStruct.dep = 'nmod';
        end
        depStruct.governor = row.Head;
        if row.Head > 0
            glossRow = depDetails(row.Head, :);     % 1-based
            depStruct.governorGloss = glossRow.Token;
        else
            depStruct.governorGloss = 'ROOT';
        end
        depStruct.dependent = i;                % 1-based

        dependenciesStruct{end+1} = depStruct; %#ok<AGROW> 
    end
    tmp.index = 0;
    tmp.basicDependencies = dependenciesStruct;
    % enhanced and enhancedPlusPlus are very similar to basic
    tmp.enhancedDependencies = dependenciesStruct;
    tmp.enhancedPlusPlusDependencies = dependenciesStruct;
    tmp.tokens = tokens;
    jsonStr = jsonencode(tmp);

%     fid = fopen('/home/yongjiaf/Desktop/localResult.json', 'wt');
%     fprintf(fid, jsonStr);
%     fclose(fid);
end

