function[outputArg]=list(blockHandle,itemType,varargin)
    blockHandle=Simulink.SFunctionBuilder.internal.verifyBlockHandle(blockHandle);
    applicationData=Simulink.SFunctionBuilder.internal.getApplicationData(blockHandle);
    p=inputParser;
    p.addParameter('Format','Structure');
    p.parse(varargin{:});
    switch(itemType)
    case{'Input','Output'}
        if strcmp(itemType,'Input')
            ports=applicationData.SfunWizardData.InputPorts;
        else
            ports=applicationData.SfunWizardData.OutputPorts;
        end
        ports=renamePortInfo(ports);
        if portNumber(ports)==0
            outputArg=DAStudio.message('Simulink:SFunctionBuilder:NoPorts');
        else
            if strcmp(p.Results.Format,'Structure')
                outputArg=ports;
                outputArg.Dimensions=outputArg.Dimension;
                outputArg=rmfield(outputArg,'Dimension');
                outputArg=orderfields(outputArg,{'Name','DataType','Dimensions','Complexity'});
            elseif strcmp(p.Results.Format,'Table')
                Name=ports.Name(:);
                DataType=ports.DataType(:);
                Dimensions=ports.Dimension(:);
                Complexity=ports.Complexity(:);
                outputArg=table(Name,DataType,Dimensions,Complexity);
            end
        end
    case 'Parameter'
        parameters=applicationData.SfunWizardData.Parameters;
        parameters=renameParameterInfo(parameters);
        if portNumber(parameters)==0
            outputArg=DAStudio.message('Simulink:SFunctionBuilder:NoParameters');
        else
            if strcmp(p.Results.Format,'Structure')
                outputArg=parameters;
            elseif strcmp(p.Results.Format,'Table')
                Name=parameters.Name(:);
                DataType=parameters.DataType(:);
                Value=parameters.Value(:);
                Complexity=parameters.Complexity(:);
                outputArg=table(Name,DataType,Value,Complexity);
            end
        end

    case 'LibraryItem'
        libraryFiles=applicationData.SfunWizardData.LibraryFilesTable;
        SrcPaths=libraryFiles.SrcPaths;
        LibPaths=libraryFiles.LibPaths;
        IncPaths=libraryFiles.IncPaths;
        EnvPaths=libraryFiles.EnvPaths;
        Entries=libraryFiles.Entries;

        nSrcPaths=numel(SrcPaths);
        nLibPaths=numel(LibPaths);
        nIncPaths=numel(IncPaths);
        nEnvPaths=numel(EnvPaths);
        nEntries=numel(Entries);

        if nSrcPaths+nLibPaths+nIncPaths+nEnvPaths+nEntries==0
            outputArg=DAStudio.message('Simulink:SFunctionBuilder:NoLibraryItems');
        else
            if strcmp(p.Results.Format,'Structure')
                outputArg=libraryFiles;

                outputArg.SRC_PATH=outputArg.SrcPaths;
                outputArg=rmfield(outputArg,'SrcPaths');
                outputArg.LIB_PATH=outputArg.LibPaths;
                outputArg=rmfield(outputArg,'LibPaths');
                outputArg.INC_PATH=outputArg.IncPaths;
                outputArg=rmfield(outputArg,'IncPaths');
                outputArg.ENV_PATH=outputArg.EnvPaths;
                outputArg=rmfield(outputArg,'EnvPaths');
                outputArg.ENTRY=outputArg.Entries;
                outputArg=rmfield(outputArg,'Entries');
            elseif strcmp(p.Results.Format,'Table')
                Tag=[repmat({'SRC_PATH'},1,nSrcPaths),repmat({'LIB_PATH'},1,nLibPaths),...
                repmat({'INC_PATH'},1,nIncPaths),repmat({'ENV_PATH'},1,nEnvPaths),...
                repmat({'ENTRY'},1,nEntries)]';
                Value=[libraryFiles.SrcPaths(:)',libraryFiles.LibPaths(:)',libraryFiles.IncPaths(:)',libraryFiles.EnvPaths(:)',libraryFiles.Entries(:)']';
                outputArg=table(Tag,Value);
            end
        end
    case 'States'
        if strcmp(p.Results.Format,'Structure')
            outputArg.NumberOfDiscreteStates=applicationData.SfunWizardData.NumberOfDiscreteStates;
            outputArg.DiscreteStatesIC=applicationData.SfunWizardData.DiscreteStatesIC;
            outputArg.NumberOfContinuousStates=applicationData.SfunWizardData.NumberOfContinuousStates;
            outputArg.ContinuousStatesIC=applicationData.SfunWizardData.ContinuousStatesIC;
        elseif strcmp(p.Results.Format,'Table')
            States={'Discrete States';'Continuous States'};
            NumberofStates={applicationData.SfunWizardData.NumberOfDiscreteStates;applicationData.SfunWizardData.NumberOfContinuousStates};
            InitialConditions={applicationData.SfunWizardData.DiscreteStatesIC;applicationData.SfunWizardData.ContinuousStatesIC};
            outputArg=table(States,NumberofStates,InitialConditions);
        end
    otherwise
        errorStruct.message=DAStudio.message('Simulink:SFunctionBuilder:InvalidField',itemType);
        errorStruct.identifier='Simulink:SFunctionBuilder:InvalidField';
        error(errorStruct);
    end
end


function n=portNumber(ports)
    if isempty(ports.Name)||isempty(ports.Name{1})
        n=0;
    else
        n=length(ports.Name);
    end
end


function ports=renamePortInfo(oP)
    ports.Name=oP.Name;
    for i=1:length(oP.Name)

        if(strcmp(oP.Bus{i},'on'))
            ports.DataType{i}=['Bus:',oP.Busname{i}];
        elseif(strcmp(oP.DataType{i},'cfixpt')||strcmp(oP.DataType{i},'fixpt'))
            if strcmp(oP.FixPointScalingType{i},'0')
                ports.DataType{i}=['fixdt(',oP.IsSigned{i},',',oP.WordLength{i},',',oP.FractionLength{i},')'];
            else
                ports.DataType{i}=['fixdt(',oP.IsSigned{i},',',oP.WordLength{i},',',oP.Slope{i},',',oP.Bias{i},')'];
            end
        else
            if(strcmp(oP.DataType{i},'real32_T')||...
                strcmp(oP.DataType{i},'creal32_T'))
                ports.DataType{i}=...
                strrep(oP.DataType{i},'real32_T','single');
                ports.DataType{i}=...
                strrep(ports.DataType{i},'c','');
            else
                ports.DataType{i}=...
                strrep(oP.DataType{i},'real_T','double');
                ports.DataType{i}=...
                strrep(ports.DataType{i},'_T','');
                ports.DataType{i}=...
                strrep(ports.DataType{i},'c','');
            end
        end

        if isequal(numel(str2num(oP.Dimensions{i})),1)&&...
            strcmp(oP.Dims{i},'1-D')
            dimVec=str2num(oP.Dimensions{i});
            ports.Dimension{i}=sprintf('[%d,1]',dimVec(1));
        else
            ports.Dimension{i}=oP.Dimensions{i};
        end
    end
    ports.Complexity=strrep(oP.Complexity,'COMPLEX_YES','complex');
    ports.Complexity=strrep(ports.Complexity,'COMPLEX_NO','real');
end


function param=renameParameterInfo(param)

    for i=1:length(param.Name)
        if(strcmp(param.DataType{i},'real32_T')||...
            strcmp(param.DataType{i},'creal32_T'))
            param.DataType{i}=...
            strrep(param.DataType{i},'real32_T','single');
            param.DataType{i}=...
            strrep(param.DataType{i},'c','');
        else
            param.DataType{i}=...
            strrep(param.DataType{i},'real_T','double');
            param.DataType{i}=...
            strrep(param.DataType{i},'_T','');
            param.DataType{i}=...
            strrep(param.DataType{i},'c','');
        end
    end
    param.Complexity=strrep(param.Complexity,'COMPLEX_YES','complex');
    param.Complexity=strrep(param.Complexity,'COMPLEX_NO','real');
end



