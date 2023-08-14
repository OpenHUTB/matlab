function assignPVConstructor(this,mandatoryFlag,varargin)


    while iscell(varargin{1})

        if isempty(varargin{1})
            return
        end

        varargin=varargin{1};
    end

    if mod(length(varargin),2)~=0
        error('HDLReadStatistics:InvalidPVCount','Property-Value pair count do not match. Please note that every property must have a corresponding value.');
    end


    failFlag=mandatoryFlag;


    for ii=1:2:length(varargin)


        if isempty(varargin{ii})||isempty(varargin{ii+1})
            continue
        end


        if~isa(varargin{ii},'char')
            error('HDLReadStatistics:InvalidPVEntry',['Expected entry #',num2str(ii),' in the PV pair to be of type ''char''.']);
        end

        switch varargin{ii}
        case 'TargetDir'

            if~isa(varargin{ii+1},'char')
                error('HDLReadStatistics:InvalidPVEntry','The value for property ''TargetDir'' should be of type ''char''.');
            end
            this.targetDir=varargin{ii+1};

        case 'SynthTool'

            if~isa(varargin{ii+1},'char')
                error('HDLReadStatistics:InvalidPVEntry','The value for property ''SynthTool'' should be of type ''char''.');
            end
            this.synthTool=varargin{ii+1};
            failFlag=false;

        case 'ModelName'

            if~isa(varargin{ii+1},'char')
                error('HDLReadStatistics:InvalidPVEntry','The value for property ''ModelName'' should be of type ''char''.');
            end
            this.mdlName=varargin{ii+1};

        otherwise
            error('HDLReadStatistics:InvalidPVEntry',['Invalid property name: ',varargin{ii},'. Valid property names are: ''ModelName'', ''SynthTool'' and ''TargetDir''.']);
        end
    end

    if failFlag
        error('HDLReadStatistics:MissingSynthTool',['Please pass a value for the property: ''SynthTool'' in the following manner:',newline,newline,'>> parserObj(''',this.dutName,''', ''SynthTool'', ''<Synthesis-tool-name>'');',newline,newline,'The supported synthesis tools are - ''Xilinx Vivado'', ''Altera QUARTUS II'' and ''Libero''.']);
    end
end