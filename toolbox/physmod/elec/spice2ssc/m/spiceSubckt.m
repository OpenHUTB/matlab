classdef spiceSubckt<spiceBase























    properties(Constant)
        commandIndicator=".";
        continuationIndicator="+";
        startid=".subckt";
        endid=".ends";
    end

    properties(Access=public)
        fileText;
        rawText;
        internalNodes;
        optionalNodeString;
        text;
        publicParameterString;
        privateParameterStrings;
        functionStrings;
        elementStrings;
        modelStrings;
        publicParameters=struct();
        privateParameters=struct();
        publicParasiticParameters=struct();
        publicSmoothParameters=struct();
        functions=struct();
        elements;
        sensors=struct();
        paramNameValue;
        model;
    end

    properties(Access=private)
        sections;
    end

    methods
        function this=spiceSubckt(netlistStringArray,subcktName)

            if nargin<2

                this.name=string.empty;
                if nargin==1
                    pm_warning('physmod:ee:spice2ssc:Missing',getString(message('physmod:ee:library:comments:spice2ssc:spiceSubckt:warning_SubcircuitName')));
                end
            else

                this.name=subcktName;
                fullNetlist=spiceSubckt.cleanNetlistStringArray(netlistStringArray);
                this.loadSubckt(fullNetlist);
            end
        end

        function output=getSimscapeText(this,libName)



            output.components=this.name+" = ";
            if nargin>=2
                output.components=output.components+libName+".";
            else
                pm_warning('physmod:ee:spice2ssc:Missing',getString(message('physmod:ee:library:comments:spice2ssc:spiceSubckt:warning_LibraryName')));
            end
            output.components=output.components+this.model+"(";
            if isstruct(this.paramNameValue)
                f=fieldnames(this.paramNameValue);
            else
                f=[];
            end
            if~isempty(f)
                output.components=output.components+f(1)+"="...
                +string(this.paramNameValue.(f{1}));
                for ii=2:length(f)
                    output.components=output.components+","+f(ii)+"="...
                    +string(this.paramNameValue.(f{ii}));
                end
            end
            output.components=output.components+");";
            output.connections=this.getConnectionString;
        end

        function preparSimscapeFile(this,filepath)


            libName=spiceBase.extractLibraryName(filepath);

            this.sections=struct('variables',string.empty,...
            'components',string.empty,...
            'connections',string.empty,...
            'branches',string.empty,...
            'equations',string.empty);
            for ii=1:length(this.elements)
                temp=this.elements{ii}.getSimscapeText(libName);
                f=fieldnames(temp);
                for jj=1:length(f)
                    for kk=1:length(temp.(f{jj}))
                        this.sections.(f{jj})(end+1)=temp.(f{jj})(kk);
                    end
                end
                if ismethod(this.elements{ii},'preparSimscapeFile')
                    this.elements{ii}.preparSimscapeFile(filepath);
                end
            end





            for ii=1:length(this.sensors.names)
                this.sections.variables(end+1)=this.sensors.names(ii)...
                +" = {value={0,'1'},priority=priority.none};";
                this.sections.equations(end+1)=this.sensors.names(ii)...
                +" == "+this.sensors.signals(ii)+";";
            end


            this.addDiffEquations();
        end

        function writeSimscapeFile(this,filepath)


            if~exist(filepath,'dir')
                pm_error('physmod:ee:spice2ssc:DoesNotExist',getString(message('physmod:ee:library:comments:spice2ssc:spiceSubckt:error_Directory')));
            end


            libName=spiceBase.extractLibraryName(filepath);
            if isempty(libName)
                if any(cellfun(@(x)(isa(x,'spiceSubckt')),this.elements))||~isempty(this.functions.names)
                    pm_error('physmod:ee:spice2ssc:FileNotInLibrary',getString(message('physmod:ee:library:comments:spice2ssc:spiceSubckt:error_TargetDirectory')));
                end
            end

            if isempty(this.model)
                pm_error('physmod:ee:spice2ssc:Mismatch',"In order to write ssc file, subcircuit "+this.name,"one subcircuit","netlist");
            end
            if~isempty(this.functions.names)
                this.functions.path=string(filepath)+filesep+"+"+this.model+"_simscape_functions";
                this.writeSimscapeFunctionFiles;
            end


            fid=fopen(string(filepath)+filesep+this.model+".ssc",'w+');
            if fid==-1
                pm_error('physmod:ee:spice2ssc:CannotOpenFile',string(filepath)+filesep+this.model+".ssc");
            end

            try

                fprintf(fid,'component %s\n',this.model);
                fprintf(fid,'%% %s\n',this.model);


                fprintf(fid,['%% ',getString(message('physmod:ee:library:comments:spice2ssc:spiceSubckt:sprintf_ComponentAutomaticallyGeneratedFromASPICENetlistForSubc',upper(this.model)))]);

                this.writeHeaderVersion(fid);


                allUnsupported=this.getAllUnsupportedData;
                if~isempty(allUnsupported)
                    fprintf(fid,['%%\n%% ',getString(message('physmod:ee:library:comments:spice2ssc:spiceSubckt:sprintf_TheSubcircuit2sscFunctionDoesNotSupportTheseSPICEParameters')),'\n']);
                    for ii=1:length(allUnsupported)
                        fprintf(fid,'%%    %s\n',allUnsupported(ii));
                    end
                    fprintf(fid,['%% ',getString(message('physmod:ee:library:comments:spice2ssc:spiceSubckt:sprintf_IfPossibleYouHaveToManuallyImplementThemToAchieveCompleteFunctionality'))]);
                    fprintf(fid,[' ',getString(message('physmod:ee:library:comments:spice2ssc:spiceSubckt:sprintf_ReferToTheDocumentationPageOfTheBlocksRelevantToYourConversionInsideTheSimscapeElectricalAdditionalComponentsLibrary')),'\n']);
                end
                fprintf(fid,'\n');


                allConversionNotes=this.getAllConversionNotes;
                if~isempty(allConversionNotes)
                    fprintf(fid,['%%\n%% ',getString(message('physmod:ee:library:comments:spice2ssc:spiceSubckt:sprintf_ConversionNotes')),'\n']);
                    for ii=1:length(allConversionNotes)
                        fprintf(fid,'%%    %s\n',allConversionNotes(ii));
                    end
                end
                fprintf(fid,'\n');



                if~isempty(this.nodes(this.nodes~="*"))
                    fprintf(fid,'    nodes\n');
                    for ii=1:length(this.nodes)
                        if this.nodes(ii)~="*"
                            fprintf(fid,'        %s = foundation.electrical.electrical; %% %s\n',this.nodes(ii),this.nodes(ii));
                        end
                    end
                    fprintf(fid,'    end\n\n');
                end




                if~isempty(this.internalNodes(this.internalNodes~="*"))
                    fprintf(fid,'    nodes(Access=protected, ExternalAccess=none)\n');
                    for ii=1:length(this.internalNodes)
                        if this.internalNodes(ii)~="*"
                            fprintf(fid,'        %s = foundation.electrical.electrical;\n',this.internalNodes(ii));
                        end
                    end
                    fprintf(fid,'    end\n\n');
                end



                if~isempty(fieldnames(this.publicParameters))||...
                    ~isempty(fieldnames(this.publicParasiticParameters))||...
                    ~isempty(fieldnames(this.publicSmoothParameters))
                    fprintf(fid,'    annotations\n');
                    fprintf(fid,'        UILayout = [\n');
                    if~isempty(fieldnames(this.publicParameters))
                        fprintf(fid,"            UIGroup('"+getString(message('physmod:ee:library:comments:spice2ssc:spiceSubckt:tab_Main'))+"', ...\n                    ");
                        fields=fieldnames(this.publicParameters);
                        for ii=1:length(fields)
                            if ii~=length(fields)
                                fprintf(fid,'%s, ',fields{ii});
                            else
                                fprintf(fid,'%s',fields{ii});
                            end
                        end
                        fprintf(fid,')\n');
                    end
                    if~isempty(fieldnames(this.publicParasiticParameters))
                        fprintf(fid,"            UIGroup('"+getString(message('physmod:ee:library:comments:spice2ssc:spiceSubckt:tab_ParasiticElements'))+"', ...\n                    ");
                        fprintf(fid,'specifyParasiticValues, ');
                        fields=fieldnames(this.publicParasiticParameters);
                        for ii=1:length(fields)
                            if ii~=length(fields)
                                fprintf(fid,'%s, ',fields{ii});
                            else
                                fprintf(fid,'%s',fields{ii});
                            end
                        end
                        fprintf(fid,')\n');
                    end
                    if~isempty(fieldnames(this.publicSmoothParameters))
                        fprintf(fid,"            UIGroup('"+getString(message('physmod:ee:library:comments:spice2ssc:spiceSubckt:tab_SmoothingFunctions'))+"', ...\n                    ");
                        fprintf(fid,'specifySmoothValues, ');
                        fields=fieldnames(orderfields(this.publicSmoothParameters));
                        for ii=1:length(fields)
                            if ii~=length(fields)
                                fprintf(fid,'%s, ',fields{ii});
                            else
                                fprintf(fid,'%s',fields{ii});
                            end
                        end
                        fprintf(fid,')\n');
                    end
                    fprintf(fid,'                   ]\n');
                    fprintf(fid,'    end\n\n');
                end



                if~isempty(fieldnames(this.publicParameters))
                    fprintf(fid,'    parameters\n');
                    fields=fieldnames(this.publicParameters);
                    for ii=1:length(fields)
                        n=fields{ii};
                        v=this.publicParameters.(n);
                        if isnumeric(v)
                            fprintf(fid,'        %s = {%g, ''1''};\n',n,v);
                        else



                            fprintf(fid,'        %s = %s;\n',n,...
                            spiceSubckt.reformatStringWithContinuation(...
                            spiceSubckt.fnExpander(v,this.functions)));
                        end
                    end
                    fprintf(fid,'    end\n\n');
                end




                if~isempty(fieldnames(this.publicParasiticParameters))
                    fprintf(fid,'    parameters\n');
                    fprintf(fid,'        specifyParasiticValues = ee.enum.include.no;');
                    fprintf(fid,['    %% ',getString(message('physmod:ee:library:comments:spice2ssc:spiceSubckt:sprintf_SpecifyParasiticValues')),'\n']);
                    fprintf(fid,'    end\n\n');
                    fprintf(fid,'    parameters(ExternalAccess=none)\n');
                    fields=fieldnames(this.publicParasiticParameters);
                    for ii=1:length(fields)
                        n=fields{ii};
                        v=this.publicParasiticParameters.(n);
                        if strcmp(n,'capacitorSeriesResistance')
                            fprintf(fid,'        %s = {%g, ''Ohm''};',n,v);
                            fprintf(fid,['    %% ',getString(message('physmod:ee:library:comments:spice2ssc:spiceSubckt:sprintf_CapacitorParasiticSeriesResistance')),'\n']);
                        else
                            fprintf(fid,'        %s = {%g, ''1/Ohm''};',n,v);
                            fprintf(fid,['    %% ',getString(message('physmod:ee:library:comments:spice2ssc:spiceSubckt:sprintf_InductorParasiticParallelConductance')),'\n']);
                        end
                    end
                    fprintf(fid,'    end\n\n');

                    fprintf(fid,'    if specifyParasiticValues == ee.enum.include.yes\n');
                    fprintf(fid,'        annotations\n');
                    if length(fields)==1
                        fprintf(fid,'            [%s] : ExternalAccess=modify;\n',fields{1});
                    else
                        fprintf(fid,'            [%s, %s] : ExternalAccess=modify;\n',fields{1},fields{2});
                    end
                    fprintf(fid,'        end\n');
                    fprintf(fid,'    end\n\n');
                end




                if~isempty(fieldnames(this.publicSmoothParameters))
                    fprintf(fid,'    parameters\n');
                    fprintf(fid,'        specifySmoothValues = ee.enum.include.no;');
                    fprintf(fid,['    %% ',getString(message('physmod:ee:library:comments:spice2ssc:spiceSubckt:sprintf_SpecifyFunctionSmoothParameters')),'\n']);
                    fprintf(fid,'    end\n\n');
                    fprintf(fid,'    parameters(ExternalAccess=none)\n');
                    fields=fieldnames(orderfields(this.publicSmoothParameters));
                    for ii=1:length(fields)
                        n=fields{ii};
                        v=this.publicSmoothParameters.(n);
                        switch n
                        case 'crossZero'
                            if v==0
                                fprintf(fid,'        %s = ee.enum.include.no;',n);
                            else
                                fprintf(fid,'        %s = ee.enum.include.yes;',n);
                            end
                            fprintf(fid,['    %% ',getString(message('physmod:ee:library:comments:spice2ssc:spiceSubckt:sprintf_ZeroCrossingForAbsAndSign')),'\n']);
                        case 'dropPowerFlag'
                            if v==0
                                fprintf(fid,'        %s = ee.enum.function.powerFlag.origin;',n);
                            else
                                fprintf(fid,'        %s = ee.enum.function.powerFlag.hyp;',n);
                            end
                            fprintf(fid,['    %% ',getString(message('physmod:ee:library:comments:spice2ssc:spiceSubckt:sprintf_sqrtAndXYProtectionMethod')),'\n']);
                        case 'dropPowerHypEpsilon'
                            fprintf(fid,'        %s = {%g, ''1''};',n,v);
                            fprintf(fid,['    %% ',getString(message('physmod:ee:library:comments:spice2ssc:spiceSubckt:sprintf_EpsilonForProtectionHypFunctionInModifiedSqrtAndPower')),'\n']);
                        case 'dropTanFlag'
                            if v==0
                                fprintf(fid,'        %s = ee.enum.function.tanFlag.hyp;',n);
                            else
                                fprintf(fid,'        %s = ee.enum.function.tanFlag.linear;',n);
                            end
                            fprintf(fid,['    %% ',getString(message('physmod:ee:library:comments:spice2ssc:spiceSubckt:sprintf_tanProtectionMethod')),'\n']);
                        case 'dropTanHypEpsilon'
                            fprintf(fid,'        %s = {%g, ''1''};',n,v);
                            fprintf(fid,['    %% ',getString(message('physmod:ee:library:comments:spice2ssc:spiceSubckt:sprintf_EpsilonForProtectionHypFunctionInModifiedTan')),'\n']);
                        case 'dropTanX0'
                            fprintf(fid,'        %s = {%g, ''1''};',n,v);
                            fprintf(fid,['    %% ',getString(message('physmod:ee:library:comments:spice2ssc:spiceSubckt:sprintf_BoundaryValueOfLinearExtrapolationForTan')),'\n']);
                        case 'expXh'
                            fprintf(fid,'        %s = {%g, ''1''};',n,v);
                            fprintf(fid,['    %% ',getString(message('physmod:ee:library:comments:spice2ssc:spiceSubckt:sprintf_UpperBoundaryOfLinearExtrapolationForExp')),'\n']);
                        case 'expXl'
                            fprintf(fid,'        %s = {%g, ''1''};',n,v);
                            fprintf(fid,['    %% ',getString(message('physmod:ee:library:comments:spice2ssc:spiceSubckt:sprintf_LowerBoundaryOfLinearExtrapolationForExp')),'\n']);
                        case 'hyperbolicMaximumAbsolute'
                            fprintf(fid,'        %s = {%g, ''1''};',n,v);
                            fprintf(fid,['    %% ',getString(message('physmod:ee:library:comments:spice2ssc:spiceSubckt:sprintf_AbsoluteBoundaryValueOfLinearExtrapolationForSinhAndCosh')),'\n']);
                        case 'logX0'
                            fprintf(fid,'        %s = {%g, ''1''};',n,v);
                            fprintf(fid,['    %% ',getString(message('physmod:ee:library:comments:spice2ssc:spiceSubckt:sprintf_BoundaryValueOfLinearExtrapolationForLogAndLog10')),'\n']);
                        case 'smoothN'
                            fprintf(fid,'        %s = {%g, ''1''};',n,v);
                            fprintf(fid,['    %% ',getString(message('physmod:ee:library:comments:spice2ssc:spiceSubckt:sprintf_TheOrderOfTheSmoothingFunctionInLimitMaxAndMin')),'\n']);
                        case 'smoothEpsilon'
                            fprintf(fid,'        %s = {%g, ''1''};',n,v);
                            fprintf(fid,['    %% ',getString(message('physmod:ee:library:comments:spice2ssc:spiceSubckt:sprintf_EpsilonDeterminesTheStartOfTheTransitionAndTheAbsoluteErrorOfTheSmoothingFunctionInLimitMaxAndMin')),'\n']);
                        case 'aWarning'
                            if v==0
                                fprintf(fid,'        %s = ee.enum.include.no;',n);
                            else
                                fprintf(fid,'        %s = ee.enum.include.yes;',n);
                            end
                            fprintf(fid,['    %% ',getString(message('physmod:ee:library:comments:spice2ssc:spiceSubckt:sprintf_IncludeWarning')),'\n']);
                        otherwise
                        end
                    end
                    fprintf(fid,'    end\n\n');

                    fprintf(fid,'    if specifySmoothValues == ee.enum.include.yes\n');
                    fprintf(fid,'        annotations\n');
                    fprintf(fid,'            [');

                    for ii=1:length(fields)

                        if~strcmp(fields{ii},'dropPowerHypEpsilon')&&...
                            ~strcmp(fields{ii},'dropTanHypEpsilon')&&...
                            ~strcmp(fields{ii},'dropTanX0')
                            if ii==1
                                fprintf(fid,'%s',fields{ii});
                            else
                                fprintf(fid,', %s',fields{ii});
                            end
                        end
                    end
                    fprintf(fid,'] : ExternalAccess=modify;\n');
                    fprintf(fid,'        end\n');


                    if any(strcmp(fields,'dropTanFlag'))
                        fprintf(fid,'        if dropTanFlag == ee.enum.function.tanFlag.hyp\n');
                        fprintf(fid,'            annotations\n');
                        fprintf(fid,'                dropTanHypEpsilon : ExternalAccess=modify;\n');
                        fprintf(fid,'            end\n');
                        fprintf(fid,'        else\n');
                        fprintf(fid,'            annotations\n');
                        fprintf(fid,'                dropTanX0 : ExternalAccess=modify;\n');
                        fprintf(fid,'            end\n');
                        fprintf(fid,'        end\n');
                    end


                    if any(strcmp(fields,'dropPowerFlag'))
                        fprintf(fid,'        if dropPowerFlag == ee.enum.function.powerFlag.hyp\n');
                        fprintf(fid,'            annotations\n');
                        fprintf(fid,'                dropPowerHypEpsilon : ExternalAccess=modify;\n');
                        fprintf(fid,'            end\n');
                        fprintf(fid,'        end\n');
                    end
                    fprintf(fid,'    end\n\n');
                end



                if~isempty(fieldnames(this.privateParameters))
                    fprintf(fid,'    parameters(Access=private,ExternalAccess=none)\n');
                    fields=fieldnames(this.privateParameters);
                    for ii=1:length(fields)
                        n=fields{ii};
                        v=this.privateParameters.(n);
                        if isnumeric(v)
                            fprintf(fid,'        %s = {%g, ''1''};\n',n,v);
                        else



                            fprintf(fid,'        %s = %s;\n',n,spiceSubckt.reformatStringWithContinuation(...
                            spiceSubckt.fnExpander(v,this.functions)));
                        end
                    end
                    fprintf(fid,'    end\n\n');
                end

                for ii=1:length(this.elements)

                    if ismethod(this.elements{ii},'writeSimscapeFile')
                        this.elements{ii}.writeSimscapeFile(filepath);
                    end
                end



                f=fieldnames(this.sections);
                for ii=1:length(f)
                    if~isempty(this.sections.(f{ii}))
                        fprintf(fid,'    %s',f{ii});
                        switch f{ii}
                        case "components"
                            fprintf(fid,'(ExternalAccess=observe)\n');
                        otherwise
                            fprintf(fid,'\n');
                        end
                        for jj=1:length(this.sections.(f{ii}))



                            fprintf(fid,'        %s\n',spiceSubckt.reformatStringWithContinuation(...
                            spiceSubckt.fnExpander(this.sections.(f{ii})(jj),this.functions)));
                        end
                        fprintf(fid,'    end\n\n');
                    end
                end

                fprintf(fid,'end\n');
            catch exception
                fclose(fid);
                throw(exception);
            end
            fclose(fid);
        end

        function strArray=getAllUnsupportedData(this)
            thisHasUnsupported=~isempty(this.unsupportedStrings);
            elemHasUnsupported=cellfun(@(x)(~isempty(x.unsupportedStrings)),this.elements);
            strArray=string.empty();
            if thisHasUnsupported||any(elemHasUnsupported)
                strArray(end+1:end+length(this.unsupportedStrings))=this.unsupportedStrings;
                ndex=find(elemHasUnsupported);
                for ii=1:length(ndex)
                    strArray(end+1:end+length(this.elements{ndex(ii)}.unsupportedStrings))=this.elements{ndex(ii)}.unsupportedStrings;
                end
                strArray=unique(strArray);
            end
        end

        function strArray=getAllConversionNotes(this)
            thisHasUnsupported=~isempty(this.conversionNotes);
            elemHasUnsupported=cellfun(@(x)(~isempty(x.conversionNotes)),this.elements);
            strArray=string.empty();
            if thisHasUnsupported||any(elemHasUnsupported)
                strArray(end+1:end+length(this.conversionNotes))=this.conversionNotes;
                ndex=find(elemHasUnsupported);
                for ii=1:length(ndex)
                    strArray(end+1:end+length(this.elements{ndex(ii)}.conversionNotes))=this.elements{ndex(ii)}.conversionNotes;
                end
                strArray=unique(strArray);
            end
        end
    end

    methods(Access=protected)
        function loadSubckt(this,netlistArray)




            netlistArray=spiceSubckt.handleLibIncFiles(netlistArray,this.name);
            this.fileText=netlistArray;


            startSubckt_index=find(strncmpi(netlistArray,spiceSubckt.startid,...
            strlength(spiceSubckt.startid)));


            endSubckt_index=find(strncmpi(netlistArray,spiceSubckt.endid,...
            strlength(spiceSubckt.endid)));


            if length(startSubckt_index)~=length(endSubckt_index)
                pm_error('physmod:ee:spice2ssc:NotPaired',getString(message('physmod:ee:library:comments:spice2ssc:spiceSubckt:error_SUBCKTAndENDS')),getString(message('physmod:ee:library:comments:spice2ssc:spiceSubckt:error_Netlist')));
            end


            if any(startSubckt_index>endSubckt_index)
                pm_error('physmod:ee:spice2ssc:UnexpectedFormat',getString(message('physmod:ee:library:comments:spice2ssc:spiceSubckt:error_SubcircuitDelimiters')));
            end


            if any(startSubckt_index(2:end)<endSubckt_index(1:end-1))
                pm_error('physmod:ee:spice2ssc:UnexpectedFormat',getString(message('physmod:ee:library:comments:spice2ssc:spiceSubckt:error_SubcircuitDelimiters')));
            end


            matchFound=false;
            for ii=1:length(startSubckt_index)
                splt=strsplit(netlistArray(startSubckt_index(ii)));
                if strcmpi(splt(2),this.name)
                    matchFound=true;
                    break;
                end
            end
            if matchFound
                this.rawText=netlistArray(startSubckt_index(ii):endSubckt_index(ii));
                this.addGlobalData(netlistArray);
                this.normalizeNaming;
                this.translateStandardFunctions;
                this.extractSubcktDefinitionStrings;
                this.extractCommandStrings;
                this.privateParameterStrings=this.privateParameterStrings;
                this.modelStrings=this.eliminateDuplicates(this.modelStrings);
                this.functionStrings=this.eliminateDuplicates(this.functionStrings);
                this.getFunctionCalls;
                this.extractElementStrings;
                this.extractPublicParameters;
                this.extractPrivateParameters;
                this.getElements;
                this.getInternalNodes;
                this.cleanNaming;
                this.model=this.name;
            else
                this.rawText="Subcircuit definition for "+this.name+" was not found.";
            end
        end

        function writeSimscapeFunctionFiles(this)



            if~exist(this.functions.path,'dir')
                mkdir(this.functions.path);
            end
            for ii=1:length(this.functions.names)
                fid=fopen(this.functions.path+filesep+this.functions.names(ii)+".ssc",'w+');
                if fid==-1
                    pm_error('physmod:ee:spice2ssc:CannotOpenFile',this.functions.path+filesep+this.functions.names(ii)+".ssc");
                end

                fnDeclaration=sprintf('function result = %s(%s',this.functions.names(ii),this.functions.args{ii});
                for jj=1:length(this.functions.parameters{ii})
                    if strlength(this.functions.args{ii})==0&&jj==1
                        fnDeclaration=strcat(fnDeclaration,sprintf('%s',this.functions.parameters{ii}(jj)));
                    else
                        fnDeclaration=strcat(fnDeclaration,sprintf(',%s',this.functions.parameters{ii}(jj)));
                    end
                end
                fnDeclaration=strcat(fnDeclaration,sprintf(')'));



                fprintf(fid,'%s\n',fnDeclaration);
                fprintf(fid,'%% %s\n',fnDeclaration);
                fprintf(fid,['%% ',getString(message('physmod:ee:library:comments:spice2ssc:spiceSubckt:sprintf_FunctionAutomaticallyGeneratedFromASPICENetlistForSubci',upper(this.model))),'\n']);

                this.writeHeaderVersion(fid);


                fprintf(fid,'\ndefinitions\n');
                fprintf(fid,'    result = %s;\n',spiceSubckt.reformatStringWithContinuation(spiceSubckt.fnExpander(this.functions.body(ii),this.functions)));
                fprintf(fid,'end\n\nend\n');
                fclose(fid);
            end
        end

        function[componentNames,functionNames,parameterNames,subcktParameterNames]=getNames(this)





            rawCompNames=regexpi(this.rawText,"^[^.]\S*(?=\s|$)",'match');
            idx=cellfun(@(x)(~isempty(x)),rawCompNames);
            componentNames=unique(string(rawCompNames(idx)));


            rawFuncNames=regexpi(this.rawText,"(?<=\.func\s+)[^\s\(]*",'match');
            idx=cellfun(@(x)(~isempty(x)),rawFuncNames);
            functionNames=unique(string(rawFuncNames(idx)));


            rawParamNameValues=regexpi(this.rawText,"(?<=\.param\s+).*",'match');
            idx=cellfun(@(x)(~isempty(x)),rawParamNameValues);
            parameterNameValues=string(rawParamNameValues(idx));
            parameterNames=string.empty();
            for ii=1:length(parameterNameValues)
                [n,~]=unique(spiceBase.parseNameEqualsValue(parameterNameValues(ii)));
                parameterNames=[parameterNames,n];%#ok<AGROW>
            end
            parameterNames=unique(parameterNames);


            rawSubcktParamPlus=strtrim(regexpi(this.rawText,"(?<=\.subckt\s+.*params:).*",'match'));
            idx=cellfun(@(x)(~isempty(x)),rawSubcktParamPlus);
            subcktParamPlus=string(rawSubcktParamPlus(idx));
            subcktParamNameValues=regexprep(subcktParamPlus,"\s+\w+:.*","");
            subcktParameterNames=string.empty();
            for ii=1:length(subcktParamNameValues)
                [n,~]=unique(spiceBase.parseNameEqualsValue(subcktParamNameValues(ii)));
                subcktParameterNames=[subcktParameterNames,n];%#ok<AGROW>
            end
            subcktParameterNames=unique(subcktParameterNames);
        end

        function normalizeNaming(this)




            [componentNames,functionNames,parameterNames,subcktParameterNames]=this.getNames();


            if~isempty(intersect(componentNames,functionNames))...
                ||~isempty(intersect(componentNames,parameterNames))...
                ||~isempty(intersect(componentNames,subcktParameterNames))...
                ||~isempty(intersect(functionNames,parameterNames))...
                ||~isempty(intersect(functionNames,subcktParameterNames))...
                ||~isempty(intersect(parameterNames,subcktParameterNames))
                pm_error('physmod:ee:spice2ssc:UnsupportedFormat',getString(message('physmod:ee:library:comments:spice2ssc:spiceSubckt:error_DuplicateDefinition')),"Check that all component, function, and parameter names are unique in "+this.name);
            end




            namesList=componentNames(:);
            initialList=lower(cellfun(@(x)x(1),namesList,'UniformOutput',false));
            if any(strcmp('c',initialList))||any(strcmp('l',initialList))
                keywordList=unique(string([simscape.internal.reservedKeywords();ne_reserved();iskeyword;cellstr(this.subcircuit2sscReservedWords')]));
            else
                keywordList=unique(string([simscape.internal.reservedKeywords();ne_reserved();iskeyword]));
            end
            exclude=[keywordList(:);...
            functionNames(:);...
            parameterNames(:);...
            subcktParameterNames(:)];
            [newNames,modIndices]=this.getUniqueNames(namesList,exclude,"ss_");
            componentOld=namesList(modIndices);
            componentNew=upper(newNames(modIndices));
            escapedComponentOld=regexptranslate('escape',componentOld);


            exclude=[keywordList(:);...
            componentNew(:)];
            namesList=[this.name;functionNames(:);...
            parameterNames(:);...
            subcktParameterNames(:)];
            [newNames,modIndices]=this.getUniqueNames(namesList,exclude,"ss_");
            otherOld=namesList(modIndices);
            otherNew=newNames(modIndices);
            escapedOtherOld=regexptranslate('escape',otherOld);

            repOld=[componentOld(:);otherOld(:)];
            repNew=[componentNew(:);otherNew(:)];
            escapedOld=[escapedComponentOld(:);escapedOtherOld(:)];


            for ii=1:length(repOld)
                this.rawText=regexprep(this.rawText,"(?<=(^|\s|\+|\-|\*|/|~|\||&|=|\(|\)|\{|\}|\[|\])+)("+escapedOld(ii)+")(?=($|\s|\+|\-|\*|/|~|\||&|=|\(|\)|\{|\}|\[|\])+)",repNew(ii),'ignorecase');
            end
            idx=find(strcmpi(repOld,this.name));
            if~isempty(idx)
                this.name=repNew(idx);
                this.model=this.name;
            end
        end

        function addGlobalData(this,netlistArray)






            outsideSubckt=true;
            for ii=1:length(netlistArray)
                if outsideSubckt
                    if strncmpi(netlistArray(ii),'.subckt',7)
                        outsideSubckt=false;
                    else



                        if strncmpi(netlistArray(ii),'.',1)
                            this.rawText=[netlistArray(ii),this.rawText];
                        end
                    end
                else
                    if strncmpi(netlistArray(ii),'.ends',5)
                        outsideSubckt=true;
                    end
                end
            end
        end

        function cleanNaming(this)


            keywordList=unique(string([simscape.internal.reservedKeywords();ne_reserved();iskeyword]));
            nodeNames=[this.nodes(:);this.internalNodes(:)];
            nodeNames(nodeNames=="*")=[];
            exclude=[keywordList(:);...
            string(fieldnames(this.publicParameters));...
            string(fieldnames(this.privateParameters));...
            this.functions.names(:);...
            this.name;...
            cellfun(@(x)(x.('name')),this.elements)';...
            this.sensors.names(:)];
            [newNames,modIndices]=this.getUniqueNames(nodeNames,exclude);
            repOld=nodeNames(modIndices);
            escapedRepOld=regexptranslate('escape',repOld);
            repNew=newNames(modIndices);





            for ii=length(repOld):-1:1
                this.nodes(this.nodes==repOld(ii))=repNew(ii);
                this.internalNodes(this.internalNodes==repOld(ii))=repNew(ii);
                for jj=1:length(this.elements)
                    this.elements{jj}.connectingNodes(this.elements{jj}.connectingNodes==repOld(ii))=repNew(ii);
                    if isprop(this.elements{jj},'value')
                        if~isempty(this.elements{jj}.value)
                            this.elements{jj}.value=regexprep(this.elements{jj}.value,"(?<=\W+)"+escapedRepOld(ii)+"(?=\.v)",repNew(ii));
                        end
                    end
                end
                for jj=1:length(this.functions.body)


                    this.functions.body(jj)=regexprep(this.functions.body(jj),"(?<=\W+)"+escapedRepOld(ii)+"(?=\.v)",repNew(ii));
                end
                for jj=1:length(this.sensors.signals)

                    this.sensors.signals(jj)=regexprep(this.sensors.signals(jj),"(?<=\W+)"+escapedRepOld(ii)+"(?=\.v)",repNew(ii));
                end
            end
        end

        function getInternalNodes(this)


            this.internalNodes=string.empty;
            for ii=1:length(this.elements)
                for jj=1:length(this.elements{ii}.connectingNodes)

                    if~ismember(this.elements{ii}.connectingNodes(jj),this.nodes)...
                        &&~ismember(this.elements{ii}.connectingNodes(jj),this.internalNodes)
                        this.internalNodes(end+1)=this.elements{ii}.connectingNodes(jj);
                    end
                end
            end
            this.internalNodes(this.internalNodes=="0")="*";
        end

        function getElements(this)

            this.elements=cell(1,length(this.elementStrings));
            couplingFactors=spiceCouplingFactor.empty;
            for ii=1:length(this.elementStrings)
                id=lower(this.elementStrings{ii}(1));
                switch id
                case 'b'
                    this.elements{ii}=spiceBehavioral(this.elementStrings(ii));
                case 'c'
                    this.elements{ii}=spiceCapacitor(this.elementStrings(ii),this.modelStrings);
                case 'd'
                    this.elements{ii}=spiceDiode(this.elementStrings(ii),this.modelStrings);
                case 'e'
                    this.elements{ii}=spiceVCVS(this.elementStrings(ii));
                case 'f'
                    this.elements{ii}=spiceCCCS(this.elementStrings(ii));
                case 'g'
                    this.elements{ii}=spiceVCCS(this.elementStrings(ii));
                case 'h'
                    this.elements{ii}=spiceCCVS(this.elementStrings(ii));
                case 'i'
                    this.elements{ii}=spiceI(this.elementStrings(ii));
                case 'j'
                    this.elements{ii}=spiceJfet(this.elementStrings(ii),this.modelStrings);
                case 'k'
                    couplingFactors(end+1)=spiceCouplingFactor(this.elementStrings(ii));%#ok<AGROW>
                    for jj=1:length(couplingFactors(end).unsupportedStrings)
                        this.unsupportedStrings(end+1)=couplingFactors(end).unsupportedStrings(jj);
                    end
                case 'l'
                    this.elements{ii}=spiceInductor(this.elementStrings(ii),this.modelStrings);
                case 'm'
                    this.elements{ii}=spiceMosfet(this.elementStrings(ii),this.modelStrings);
                case 'q'
                    this.elements{ii}=spiceBjt(this.elementStrings(ii),this.modelStrings);
                case 'r'
                    this.elements{ii}=spiceResistor(this.elementStrings(ii),this.modelStrings);
                case 's'
                    this.elements{ii}=spiceVswitch(this.elementStrings(ii),this.modelStrings);
                case 'v'
                    this.elements{ii}=spiceV(this.elementStrings(ii));
                case 'w'
                    this.elements{ii}=spiceIswitch(this.elementStrings(ii),this.modelStrings);
                case 'x'
                    temp=strsplit(strtrim(regexprep(this.elementStrings(ii),spiceBase.commentIndicators(2)+".*","")));
                    pdex=find(strncmpi(temp,"PARAMS",6));
                    if isempty(pdex)
                        pdex=find(strncmpi(temp,"TEXT",4));
                    end
                    if isempty(pdex)
                        this.elements{ii}=spiceSubckt(this.fileText,temp(end));
                        this.elements{ii}.connectingNodes=temp(2:end-1);
                    else
                        this.elements{ii}=spiceSubckt(this.fileText,temp(pdex-1));
                        this.elements{ii}.connectingNodes=temp(2:pdex-2);
                        [n,v]=spiceSubckt.parseNameEqualsValue(strjoin(temp(pdex+1:end)));


                        this.elements{ii}.paramNameValue=struct(char(n(1)),v{1});
                        for jj=2:length(n)
                            this.elements{ii}.paramNameValue.(char(n(jj)))=v{jj};
                        end
                    end



                    if~isempty(this.elements{ii}.publicParasiticParameters)
                        fns=fieldnames(this.elements{ii}.publicParasiticParameters);
                        for jj=1:numel(fns)
                            this.elements{ii}.paramNameValue.(fns{jj})=fns{jj};
                        end
                    end


                    this.elements{ii}.name=temp(1);


                    this.elements{ii}.connectingNodes(this.elements{ii}.connectingNodes=="0")="*";


                    if~isempty(this.elements{ii}.publicParasiticParameters)
                        fns=fieldnames(this.elements{ii}.publicParasiticParameters);
                        for jj=1:numel(fns)
                            if~isfield(this.publicParasiticParameters,fns{jj})
                                this.publicParasiticParameters.(fns{jj})=this.elements{ii}.publicParasiticParameters.(fns{jj});
                            end
                        end
                    end


                    if~isempty(this.elements{ii}.publicSmoothParameters)
                        fns=fieldnames(this.elements{ii}.publicSmoothParameters);
                        for jj=1:numel(fns)
                            if~isfield(this.publicSmoothParameters,fns{jj})
                                this.publicSmoothParameters.(fns{jj})=this.elements{ii}.publicSmoothParameters.(fns{jj});
                            end
                        end
                    end
                case 'z'
                    this.elements{ii}=spiceIgbt(this.elementStrings(ii),this.modelStrings);
                otherwise
                    this.unsupportedStrings(end+1)=this.name+": "+this.elementStrings(ii);
                end
            end
            this.elements(cellfun(@isempty,this.elements))=[];
            elementsClassname=cellfun(@class,this.elements,'UniformOutput',false);

            if any(strcmp('spiceCapacitor',elementsClassname))
                this.publicParasiticParameters.capacitorSeriesResistance=0;
            end

            if any(strcmp('spiceInductor',elementsClassname))
                this.publicParasiticParameters.inductorParallelConductance=0;
            end

            for ii=1:length(couplingFactors)
                couplingFactors(ii).addCouplingToInductors(this.elements);
            end


            for ii=1:length(this.elements)
                if isa(this.elements{ii},'spiceInductor')
                    if this.elements{ii}.isCoupled
                        for jj=1:length(this.elements)
                            if isprop(this.elements{jj},'value')
                                if~isempty(this.elements{jj}.value)
                                    this.elements{jj}.value=regexprep(this.elements{jj}.value,"value\("+this.elements{ii}.name+"\.i,'A'\)","value("+this.elements{ii}.name+",'A')");
                                end
                            end
                        end
                        for jj=1:length(this.functions.body)
                            this.functions.body(jj)=regexprep(this.functions.body(jj),"value\("+this.elements{ii}.name+"\.i,'A'\)","value("+this.elements{ii}.name+",'A')");
                        end
                        for jj=1:length(this.sensors.signals)
                            this.sensors.signals(jj)=regexprep(this.sensors.signals(jj),"value\("+this.elements{ii}.name+"\.i,'A'\)","value("+this.elements{ii}.name+",'A')");
                        end


                        parasiticName='parallelConductance'+this.elements{ii}.name;
                        this.elements{ii}.addParasitics(parasiticName);
                    end
                end
            end
        end

        function translateStandardFunctions(this)




            this.rawText=regexprep(this.rawText,"!=","~=");


            this.rawText=regexprep(this.rawText,"(?<=\W)arctan\s*(","atan(");


            this.rawText=regexprep(this.rawText,"(?<=\W)ddt\s*(","der(");


            for ii=1:length(this.rawText)


                tempdex=regexp(this.rawText(ii),'((?<=\W)abs\s*\()|(^abs\s*\()','start');
                for jj=length(tempdex):-1:1
                    oldStr=this.rawText{ii};



                    parIndices=spiceSubckt.findEnclosure(oldStr,'(',')');
                    pindex=find(parIndices(:,1)>tempdex(jj),1);


                    oldFormat=oldStr(parIndices(pindex,1):parIndices(pindex,2));


                    argument=oldFormat(2:end-1);


                    newFormat="simscape.function.abs("+string(argument)+...
                    ", crossZero)";


                    this.rawText(ii)=replaceBetween(oldStr,tempdex(jj),parIndices(pindex,2),newFormat);
                end


                if~isempty(tempdex)&&~isfield(this.publicSmoothParameters,'crossZero')
                    this.publicSmoothParameters.crossZero=0;
                end



                tempdex=regexp(this.rawText(ii),'((?<=\W)sgn\s*\()|(^sgn\s*\()','start');
                for jj=length(tempdex):-1:1
                    oldStr=this.rawText{ii};



                    parIndices=spiceSubckt.findEnclosure(oldStr,'(',')');
                    pindex=find(parIndices(:,1)>tempdex(jj),1);


                    oldFormat=oldStr(parIndices(pindex,1):parIndices(pindex,2));


                    argument=oldFormat(2:end-1);


                    newFormat="simscape.function.sign("+string(argument)+...
                    ", crossZero)";


                    this.rawText(ii)=replaceBetween(oldStr,tempdex(jj),parIndices(pindex,2),newFormat);
                end


                if~isempty(tempdex)&&~isfield(this.publicSmoothParameters,'crossZero')
                    this.publicSmoothParameters.crossZero=0;
                end



                tempdex=regexp(this.rawText(ii),'((?<=\W)exp\s*\()|(^exp\s*\()','start');
                for jj=length(tempdex):-1:1
                    exprGroups=spiceSubckt.findEnclosure(this.rawText{ii},'{','}');



                    if isempty(exprGroups)
                        powerInCurly=[];
                    else
                        powerInCurly=find((exprGroups(:,1)<tempdex(jj)).*(exprGroups(:,2)>tempdex(jj)),1);
                    end


                    if isempty(powerInCurly)
                        id=lower(this.rawText{ii}(1));
                        if strcmpi(id,'v')||strcmpi(id,'i')
                            continue
                        end
                    end
                    oldStr=this.rawText{ii};


                    parIndices=spiceSubckt.findEnclosure(oldStr,'(',')');
                    pindex=find(parIndices(:,1)>tempdex(jj),1);


                    oldFormat=oldStr(parIndices(pindex,1):parIndices(pindex,2));


                    argument=oldFormat(2:end-1);


                    newFormat="simscape.function.expm("+string(argument)+...
                    ", expXl, expXh, aWarning)";


                    this.rawText(ii)=replaceBetween(oldStr,tempdex(jj),parIndices(pindex,2),newFormat);


                    if~isfield(this.publicSmoothParameters,'expXl')
                        this.publicSmoothParameters.expXl=-Inf;
                        this.publicSmoothParameters.expXh=Inf;
                    end

                    if~isfield(this.publicSmoothParameters,'aWarning')
                        this.publicSmoothParameters.aWarning=0;
                    end
                end



                tempdex=regexp(this.rawText(ii),'((?<=\W)sinh\s*\()|(^sinh\s*\()','start');
                for jj=length(tempdex):-1:1
                    oldStr=this.rawText{ii};



                    parIndices=spiceSubckt.findEnclosure(oldStr,'(',')');
                    pindex=find(parIndices(:,1)>tempdex(jj),1);


                    oldFormat=oldStr(parIndices(pindex,1):parIndices(pindex,2));


                    argument=oldFormat(2:end-1);


                    newFormat="simscape.function.sinhm("+string(argument)+...
                    ", hyperbolicMaximumAbsolute, aWarning)";


                    this.rawText(ii)=replaceBetween(oldStr,tempdex(jj),parIndices(pindex,2),newFormat);
                end


                if~isempty(tempdex)&&~isfield(this.publicSmoothParameters,'hyperbolicMaximumAbsolute')
                    this.publicSmoothParameters.hyperbolicMaximumAbsolute=Inf;
                end

                if~isempty(tempdex)&&~isfield(this.publicSmoothParameters,'aWarning')
                    this.publicSmoothParameters.aWarning=0;
                end



                tempdex=regexp(this.rawText(ii),'((?<=\W)cosh\s*\()|(^cosh\s*\()','start');
                for jj=length(tempdex):-1:1
                    oldStr=this.rawText{ii};



                    parIndices=spiceSubckt.findEnclosure(oldStr,'(',')');
                    pindex=find(parIndices(:,1)>tempdex(jj),1);


                    oldFormat=oldStr(parIndices(pindex,1):parIndices(pindex,2));


                    argument=oldFormat(2:end-1);


                    newFormat="simscape.function.coshm("+string(argument)+...
                    ", hyperbolicMaximumAbsolute, aWarning)";


                    this.rawText(ii)=replaceBetween(oldStr,tempdex(jj),parIndices(pindex,2),newFormat);
                end


                if~isempty(tempdex)&&~isfield(this.publicSmoothParameters,'hyperbolicMaximumAbsolute')
                    this.publicSmoothParameters.hyperbolicMaximumAbsolute=Inf;
                end

                if~isempty(tempdex)&&~isfield(this.publicSmoothParameters,'aWarning')
                    this.publicSmoothParameters.aWarning=0;
                end



                tempdex=regexp(this.rawText(ii),'((?<=\W)ln\s*\()|(^ln\s*\()|((?<=\W)log\s*\()|(^log\s*\()','start');
                for jj=length(tempdex):-1:1
                    oldStr=this.rawText{ii};



                    parIndices=spiceSubckt.findEnclosure(oldStr,'(',')');
                    pindex=find(parIndices(:,1)>tempdex(jj),1);


                    oldFormat=oldStr(parIndices(pindex,1):parIndices(pindex,2));


                    argument=oldFormat(2:end-1);


                    newFormat="simscape.function.logm("+string(argument)+...
                    ", logX0, aWarning)";


                    this.rawText(ii)=replaceBetween(oldStr,tempdex(jj),parIndices(pindex,2),newFormat);
                end


                if~isempty(tempdex)&&~isfield(this.publicSmoothParameters,'logX0')
                    this.publicSmoothParameters.logX0=0;
                end

                if~isempty(tempdex)&&~isfield(this.publicSmoothParameters,'aWarning')
                    this.publicSmoothParameters.aWarning=0;
                end



                tempdex=regexp(this.rawText(ii),'((?<=\W)log10\s*\()|(^log10\s*\()','start');
                for jj=length(tempdex):-1:1
                    oldStr=this.rawText{ii};



                    parIndices=spiceSubckt.findEnclosure(oldStr,'(',')');
                    pindex=find(parIndices(:,1)>tempdex(jj),1);


                    oldFormat=oldStr(parIndices(pindex,1):parIndices(pindex,2));


                    argument=oldFormat(2:end-1);


                    newFormat="simscape.function.log10m("+string(argument)+...
                    ", logX0, aWarning)";


                    this.rawText(ii)=replaceBetween(oldStr,tempdex(jj),parIndices(pindex,2),newFormat);
                end


                if~isempty(tempdex)&&~isfield(this.publicSmoothParameters,'logX0')
                    this.publicSmoothParameters.logX0=0;
                end

                if~isempty(tempdex)&&~isfield(this.publicSmoothParameters,'aWarning')
                    this.publicSmoothParameters.aWarning=0;
                end



                tempdex=regexp(this.rawText(ii),'((?<=\W)tan\s*\()|(^tan\s*\()','start');
                for jj=length(tempdex):-1:1
                    oldStr=this.rawText{ii};



                    parIndices=spiceSubckt.findEnclosure(oldStr,'(',')');
                    pindex=find(parIndices(:,1)>tempdex(jj),1);


                    oldFormat=oldStr(parIndices(pindex,1):parIndices(pindex,2));


                    argument=oldFormat(2:end-1);


                    newFormat="simscape.function.tanm("+string(argument)+...
                    ", dropTanFlag, dropTanHypEpsilon, dropTanX0, aWarning)";


                    this.rawText(ii)=replaceBetween(oldStr,tempdex(jj),parIndices(pindex,2),newFormat);
                end


                if~isempty(tempdex)&&~isfield(this.publicSmoothParameters,'dropTanFlag')
                    this.publicSmoothParameters.dropTanFlag=0;
                    this.publicSmoothParameters.dropTanX0=pi/2-1e-2;
                    this.publicSmoothParameters.dropTanHypEpsilon=0;
                end

                if~isempty(tempdex)&&~isfield(this.publicSmoothParameters,'aWarning')
                    this.publicSmoothParameters.aWarning=0;
                end



                tempdex=regexp(this.rawText(ii),'((?<=\W)arcsin\s*\()|(^arcsin\s*\()|((?<=\W)asin\s*\()|(^asin\s*\()','start');
                for jj=length(tempdex):-1:1
                    oldStr=this.rawText{ii};



                    parIndices=spiceSubckt.findEnclosure(oldStr,'(',')');
                    pindex=find(parIndices(:,1)>tempdex(jj),1);


                    oldFormat=oldStr(parIndices(pindex,1):parIndices(pindex,2));


                    argument=oldFormat(2:end-1);


                    newFormat="simscape.function.asinm("+string(argument)+...
                    ", aWarning)";


                    this.rawText(ii)=replaceBetween(oldStr,tempdex(jj),parIndices(pindex,2),newFormat);
                end


                if~isempty(tempdex)&&~isfield(this.publicSmoothParameters,'aWarning')
                    this.publicSmoothParameters.aWarning=0;
                end



                tempdex=regexp(this.rawText(ii),'((?<=\W)arccos\s*\()|(^arccos\s*\()|((?<=\W)acos\s*\()|(^acos\s*\()','start');
                for jj=length(tempdex):-1:1
                    oldStr=this.rawText{ii};



                    parIndices=spiceSubckt.findEnclosure(oldStr,'(',')');
                    pindex=find(parIndices(:,1)>tempdex(jj),1);


                    oldFormat=oldStr(parIndices(pindex,1):parIndices(pindex,2));


                    argument=oldFormat(2:end-1);


                    newFormat="simscape.function.acosm("+string(argument)+...
                    ", aWarning)";


                    this.rawText(ii)=replaceBetween(oldStr,tempdex(jj),parIndices(pindex,2),newFormat);
                end


                if~isempty(tempdex)&&~isfield(this.publicSmoothParameters,'aWarning')
                    this.publicSmoothParameters.aWarning=0;
                end



                tempdex=regexp(this.rawText(ii),'((?<=\W)sqrt\s*\()|(^sqrt\s*\()','start');
                for jj=length(tempdex):-1:1
                    oldStr=this.rawText{ii};



                    parIndices=spiceSubckt.findEnclosure(oldStr,'(',')');
                    pindex=find(parIndices(:,1)>tempdex(jj),1);


                    oldFormat=oldStr(parIndices(pindex,1):parIndices(pindex,2));


                    argument=oldFormat(2:end-1);


                    newFormat="simscape.function.sqrtm("+string(argument)+...
                    ", dropPowerFlag, dropPowerHypEpsilon, aWarning)";


                    this.rawText(ii)=replaceBetween(oldStr,tempdex(jj),parIndices(pindex,2),newFormat);
                end


                if~isempty(tempdex)&&~isfield(this.publicSmoothParameters,'dropPowerFlag')
                    this.publicSmoothParameters.dropPowerFlag=1;
                end

                if~isempty(tempdex)&&~isfield(this.publicSmoothParameters,'dropPowerHypEpsilon')
                    this.publicSmoothParameters.dropPowerHypEpsilon=0;
                end

                if~isempty(tempdex)&&~isfield(this.publicSmoothParameters,'aWarning')
                    this.publicSmoothParameters.aWarning=0;
                end




                this.rawText{ii}=regexprep(this.rawText{ii},'(?i)((\.?\d++(e[+-]?\d++)?)+\w?|(\w+))(?=\s*\*{2})','\($0\)');

                this.rawText{ii}=regexprep(this.rawText{ii},'(?i)(?<=\*{2}\s*)[+-]?((\.?\d++(e[+-]?\d++)?)+\w?|(\w+(?!(\w*\()|(\w*\.))))','\($0\)');
                tempdex=regexp(this.rawText(ii),'*{2}','start');
                for jj=1:length(tempdex)

                    tempdex=regexp(this.rawText(ii),'*{2}','start');
                    exprGroups=spiceSubckt.findEnclosure(this.rawText{ii},'{','}');

                    if isempty(exprGroups)
                        powerInCurly=[];
                    else
                        powerInCurly=find((exprGroups(:,1)<tempdex(1)).*(exprGroups(:,2)>tempdex(1)),1);
                    end
                    if isempty(powerInCurly)


                        this.rawText(ii)=replaceBetween(this.rawText(ii),tempdex(1),tempdex(1)+1,'^');
                    else
                        oldStr=this.rawText{ii};


                        parIndices=spiceSubckt.findEnclosure(oldStr,'(',')');
                        [~,I]=sort(parIndices(:,2));

                        parIndicesClose=parIndices(I,:);

                        pindexX=find(parIndicesClose(:,2)<tempdex(1),1,'last');

                        pindexY=find(parIndices(:,1)>tempdex(1),1);



                        strAfterPower=oldStr(tempdex(1)+2:parIndices(pindexY,1)-1);

                        exponent=oldStr(parIndices(pindexY,1)+1:parIndices(pindexY,2)-1);

                        if~all(isspace(strAfterPower))&&~isempty(strAfterPower)

                            exponent=string(strAfterPower(~isspace(strAfterPower)))+"("+string(exponent)+")";
                        end

                        powerEnd=parIndices(pindexY,2);


                        strBeforePower=oldStr(1:parIndicesClose(pindexX,1));

                        [firstF,lastF]=regexp(strBeforePower,"((\w+\s*)|(simscape.\w+\s*)|(simscape.function.\w+\s*))(?=\()");

                        base=oldStr(parIndicesClose(pindexX,1)+1:parIndicesClose(pindexX,2)-1);

                        powerStart=parIndicesClose(pindexX,1);

                        if~isempty(lastF)
                            strBetweenLastFAndPower=strBeforePower(lastF(end)+1:end-1);
                            if all(isspace(strBetweenLastFAndPower))&&isempty(strBetweenLastFAndPower)
                                powerStart=firstF(end);

                                base=string(strBeforePower(powerStart:end))+string(base)+")";
                            end
                        end



                        newPwrStatement="simscape.function.powerRational("+string(base)+", "...
                        +string(exponent)+", dropPowerFlag, dropPowerHypEpsilon, aWarning)";


                        this.rawText(ii)=replaceBetween(oldStr,powerStart,powerEnd,newPwrStatement);


                        if~isfield(this.publicSmoothParameters,'dropPowerFlag')
                            this.publicSmoothParameters.dropPowerFlag=1;
                            this.publicSmoothParameters.dropPowerHypEpsilon=0;
                        end

                        if~isfield(this.publicSmoothParameters,'aWarning')
                            this.publicSmoothParameters.aWarning=0;
                        end
                    end
                end



                tempdex=regexp(this.rawText(ii),'((?<=\W)pwr\s*\()|(^pwr\s*\()','start');
                for jj=length(tempdex):-1:1
                    oldStr=this.rawText{ii};


                    parIndices=spiceSubckt.findEnclosure(oldStr,'(',')');
                    pindex=find(parIndices(:,1)>tempdex(jj),1);


                    oldPwrStatement=oldStr(parIndices(pindex,1):parIndices(pindex,2));




                    commadex=strfind(oldPwrStatement,',');
                    for kk=(pindex+1):size(parIndices,1)
                        commadex(parIndices(pindex,1)+commadex-1>=parIndices(kk,1)...
                        &parIndices(pindex,1)+commadex-1<=parIndices(kk,2))=[];
                    end
                    if length(commadex)~=1
                        pm_error('physmod:ee:spice2ssc:UnsupportedFormat',getString(message('physmod:ee:library:comments:spice2ssc:spiceSubckt:error_PwrstatementFormat')),getString(message('physmod:ee:library:comments:spice2ssc:spiceSubckt:error_CheckThatAllPwrstatementsFollowTheAcceptedSyntaxPwrxY')));
                    end


                    base=oldPwrStatement(2:commadex(1)-1);
                    exponent=oldPwrStatement(commadex(1)+1:end-1);



                    newPwrStatement="simscape.function.powerRational(simscape.function.abs("+string(base)+", crossZero), "...
                    +string(exponent)+", 1, 0, aWarning)";


                    this.rawText(ii)=replaceBetween(oldStr,tempdex(jj),parIndices(pindex,2),newPwrStatement);
                end


                if~isempty(tempdex)&&~isfield(this.publicSmoothParameters,'aWarning')
                    this.publicSmoothParameters.aWarning=0;
                end


                if~isempty(tempdex)&&~isfield(this.publicSmoothParameters,'crossZero')
                    this.publicSmoothParameters.crossZero=0;
                end



                tempdex=regexp(this.rawText(ii),'((?<=\W)pwrs\s*\()|(^pwrs\s*\()','start');
                for jj=length(tempdex):-1:1
                    oldStr=this.rawText{ii};


                    parIndices=spiceSubckt.findEnclosure(oldStr,'(',')');
                    pindex=find(parIndices(:,1)>tempdex(jj),1);


                    oldPwrsStatement=oldStr(parIndices(pindex,1):parIndices(pindex,2));




                    commadex=strfind(oldPwrsStatement,',');
                    for kk=(pindex+1):size(parIndices,1)
                        commadex(parIndices(pindex,1)+commadex-1>=parIndices(kk,1)...
                        &parIndices(pindex,1)+commadex-1<=parIndices(kk,2))=[];
                    end
                    if length(commadex)~=1
                        pm_error('physmod:ee:spice2ssc:UnsupportedFormat',getString(message('physmod:ee:library:comments:spice2ssc:spiceSubckt:error_PwrsstatementFormat')),getString(message('physmod:ee:library:comments:spice2ssc:spiceSubckt:error_CheckThatAllPwrsstatementsFollowTheAcceptedSyntaxPwrsxY')));
                    end


                    base=oldPwrsStatement(2:commadex(1)-1);
                    exponent=oldPwrsStatement(commadex(1)+1:end-1);


                    newPwrsStatement="simscape.function.powerRational("+string(base)+", "...
                    +string(exponent)+", 0, 0, aWarning)";


                    this.rawText(ii)=replaceBetween(oldStr,tempdex(jj),parIndices(pindex,2),newPwrsStatement);
                end


                if~isempty(tempdex)&&~isfield(this.publicSmoothParameters,'aWarning')
                    this.publicSmoothParameters.aWarning=0;
                end



                tempdex=regexp(this.rawText(ii),'((?<=\W)uramp\s*\()|(^uramp\s*\()','start');
                for jj=length(tempdex):-1:1
                    oldStr=this.rawText{ii};



                    parIndices=spiceSubckt.findEnclosure(oldStr,'(',')');
                    pindex=find(parIndices(:,1)>tempdex(jj),1);


                    oldFormat=oldStr(parIndices(pindex,1):parIndices(pindex,2));


                    argument=oldFormat(2:end-1);


                    newFormat="simscape.function.limit("...
                    +string(argument)+", 0, inf, 1)";


                    this.rawText(ii)=replaceBetween(oldStr,tempdex(jj),parIndices(pindex,2),newFormat);
                end



                tempdex=regexp(this.rawText(ii),'((?<=\W)stp\s*\()|(^stp\s*\()','start');
                for jj=length(tempdex):-1:1
                    oldStr=this.rawText{ii};



                    parIndices=spiceSubckt.findEnclosure(oldStr,'(',')');
                    pindex=find(parIndices(:,1)>tempdex(jj),1);


                    oldFormat=oldStr(parIndices(pindex,1):parIndices(pindex,2));


                    argument=oldFormat(2:end-1);


                    newFormat="(if "+string(argument)+...
                    " > 0, 1 else 0 end)";


                    this.rawText(ii)=replaceBetween(oldStr,tempdex(jj),parIndices(pindex,2),newFormat);
                end



                tempdex=regexp(this.rawText(ii),'((?<=\W)u\s*\()|(^u\s*\()','start');
                for jj=length(tempdex):-1:1
                    oldStr=this.rawText{ii};



                    parIndices=spiceSubckt.findEnclosure(oldStr,'(',')');
                    pindex=find(parIndices(:,1)>tempdex(jj),1);


                    oldFormat=oldStr(parIndices(pindex,1):parIndices(pindex,2));


                    argument=oldFormat(2:end-1);


                    newFormat="(if "+string(argument)+...
                    " > 0, 1 else 0 end)";


                    this.rawText(ii)=replaceBetween(oldStr,tempdex(jj),parIndices(pindex,2),newFormat);
                end


                tempdex=regexp(this.rawText(ii),'((?<=\W)if\s*\()|(^if\s*\()','start');
                for jj=length(tempdex):-1:1
                    oldStr=this.rawText{ii};


                    parIndices=spiceSubckt.findEnclosure(oldStr,'(',')');
                    pindex=find(parIndices(:,1)>tempdex(jj),1);


                    oldIfStatement=oldStr(parIndices(pindex,1):parIndices(pindex,2));




                    commadex=strfind(oldIfStatement,',');
                    for kk=(pindex+1):size(parIndices,1)
                        commadex(parIndices(pindex,1)+commadex-1>=parIndices(kk,1)...
                        &parIndices(pindex,1)+commadex-1<=parIndices(kk,2))=[];
                    end
                    if length(commadex)~=2
                        pm_error('physmod:ee:spice2ssc:UnsupportedFormat',getString(message('physmod:ee:library:comments:spice2ssc:spiceSubckt:error_IfstatementFormat')),getString(message('physmod:ee:library:comments:spice2ssc:spiceSubckt:error_CheckThatAllIfstatementsFollowTheAcceptedSyntaxIfaBC')));
                    end


                    cond=oldIfStatement(2:commadex(1));
                    ifpart=oldIfStatement(commadex(1)+1:commadex(2)-1);
                    elsepart=oldIfStatement(commadex(2)+1:end-1);


                    newIfStatement=" "+string(cond)+" "...
                    +string(ifpart)+" else "+string(elsepart)...
                    +" end";


                    this.rawText(ii)=replaceBetween(oldStr,tempdex(jj),parIndices(pindex,2),"(if"+newIfStatement+")");
                end



                tempdex=regexp(this.rawText(ii),'(?<=[^a-zA-Z_0-9.])limit(|^limit(');
                for jj=length(tempdex):-1:1
                    oldStr=this.rawText{ii};


                    parIndices=spiceSubckt.findEnclosure(oldStr,'(',')');
                    pindex=find(parIndices(:,1)>tempdex(jj),1);


                    oldLimStatement=oldStr(parIndices(pindex,1):parIndices(pindex,2));




                    commadex=strfind(oldLimStatement,',');
                    for kk=(pindex+1):size(parIndices,1)
                        commadex(parIndices(pindex,1)+commadex-1>=parIndices(kk,1)...
                        &parIndices(pindex,1)+commadex-1<=parIndices(kk,2))=[];
                    end
                    if length(commadex)~=2
                        pm_error('physmod:ee:spice2ssc:UnsupportedFormat',getString(message('physmod:ee:library:comments:spice2ssc:spiceSubckt:error_LimitstatementFormat')),getString(message('physmod:ee:library:comments:spice2ssc:spiceSubckt:error_CheckThatAllLimitstatementsFollowTheAcceptedSyntaxLimitaB')));
                    end


                    firstpart=oldLimStatement(2:commadex(1)-1);
                    secondpart=oldLimStatement(commadex(1)+1:commadex(2)-1);
                    thirdpart=oldLimStatement(commadex(2)+1:end-1);


                    newLimStatement="simscape.function.limitm("...
                    +string(firstpart)+", "...
                    +string(secondpart)+", "...
                    +string(thirdpart)+", smoothN, smoothEpsilon)";


                    this.rawText(ii)=replaceBetween(oldStr,tempdex(jj),parIndices(pindex,2),newLimStatement);
                end


                if~isempty(tempdex)&&~isfield(this.publicSmoothParameters,'smoothN')
                    this.publicSmoothParameters.smoothN=1;
                    this.publicSmoothParameters.smoothEpsilon=0;
                end



                tempdex=regexp(this.rawText(ii),'((?<=\W)max\s*\()|(^max\s*\()','start');
                for jj=length(tempdex):-1:1
                    oldStr=this.rawText{ii};


                    parIndices=spiceSubckt.findEnclosure(oldStr,'(',')');
                    pindex=find(parIndices(:,1)>tempdex(jj),1);


                    oldMaxStatement=oldStr(parIndices(pindex,1):parIndices(pindex,2));




                    commadex=strfind(oldMaxStatement,',');
                    for kk=(pindex+1):size(parIndices,1)
                        commadex(parIndices(pindex,1)+commadex-1>=parIndices(kk,1)...
                        &parIndices(pindex,1)+commadex-1<=parIndices(kk,2))=[];
                    end
                    if length(commadex)~=1
                        pm_error('physmod:ee:spice2ssc:UnsupportedFormat',getString(message('physmod:ee:library:comments:spice2ssc:spiceSubckt:error_MaxstatementFormat')),getString(message('physmod:ee:library:comments:spice2ssc:spiceSubckt:error_CheckThatAllMaxstatementsFollowTheAcceptedSyntaxMaxXY')));
                    end


                    firstpart=oldMaxStatement(2:commadex(1)-1);
                    secondpart=oldMaxStatement(commadex(1)+1:end-1);


                    newMaxStatement="simscape.function.maxm("...
                    +string(firstpart)+", "...
                    +string(secondpart)+", smoothN, smoothEpsilon)";


                    this.rawText(ii)=replaceBetween(oldStr,tempdex(jj),parIndices(pindex,2),newMaxStatement);
                end


                if~isempty(tempdex)&&~isfield(this.publicSmoothParameters,'smoothN')
                    this.publicSmoothParameters.smoothN=1;
                    this.publicSmoothParameters.smoothEpsilon=0;
                end



                tempdex=regexp(this.rawText(ii),'((?<=\W)min\s*\()|(^min\s*\()','start');
                for jj=length(tempdex):-1:1
                    oldStr=this.rawText{ii};


                    parIndices=spiceSubckt.findEnclosure(oldStr,'(',')');
                    pindex=find(parIndices(:,1)>tempdex(jj),1);


                    oldMinStatement=oldStr(parIndices(pindex,1):parIndices(pindex,2));




                    commadex=strfind(oldMinStatement,',');
                    for kk=(pindex+1):size(parIndices,1)
                        commadex(parIndices(pindex,1)+commadex-1>=parIndices(kk,1)...
                        &parIndices(pindex,1)+commadex-1<=parIndices(kk,2))=[];
                    end
                    if length(commadex)~=1
                        pm_error('physmod:ee:spice2ssc:UnsupportedFormat',getString(message('physmod:ee:library:comments:spice2ssc:spiceSubckt:error_MinstatementFormat')),getString(message('physmod:ee:library:comments:spice2ssc:spiceSubckt:error_CheckThatAllMinstatementsFollowTheAcceptedSyntaxMinXY')));
                    end


                    firstpart=oldMinStatement(2:commadex(1)-1);
                    secondpart=oldMinStatement(commadex(1)+1:end-1);


                    newMinStatement="simscape.function.minm("...
                    +string(firstpart)+", "...
                    +string(secondpart)+", smoothN, smoothEpsilon)";


                    this.rawText(ii)=replaceBetween(oldStr,tempdex(jj),parIndices(pindex,2),newMinStatement);
                end


                if~isempty(tempdex)&&~isfield(this.publicSmoothParameters,'smoothN')
                    this.publicSmoothParameters.smoothN=1;
                    this.publicSmoothParameters.smoothEpsilon=0;
                end



                tempdex=regexp(this.rawText(ii),'(?<=[^a-zA-Z_0-9.])table(|^table(');
                for jj=length(tempdex):-1:1
                    oldStr=this.rawText{ii};


                    parIndices=spiceSubckt.findEnclosure(oldStr,'(',')');
                    pindex=find(parIndices(:,1)>tempdex(jj),1);


                    oldTableStatement=oldStr(parIndices(pindex,1):parIndices(pindex,2));




                    commadex=strfind(oldTableStatement,',');
                    for kk=(pindex+1):size(parIndices,1)
                        commadex(parIndices(pindex,1)+commadex-1>=parIndices(kk,1)...
                        &parIndices(pindex,1)+commadex-1<=parIndices(kk,2))=[];
                    end
                    if rem(length(commadex),2)
                        pm_error('physmod:ee:spice2ssc:UnsupportedFormat',getString(message('physmod:ee:library:comments:spice2ssc:spiceSubckt:error_TablestatementFormat')),getString(message('physmod:ee:library:comments:spice2ssc:spiceSubckt:error_CheckThatAllTablestatementsFollowTheAcceptedSyntaxTablexXnYn')));
                    end


                    firstpart=oldTableStatement(2:commadex(1)-1);
                    sep=commadex;
                    sep(length(commadex)+1)=length(oldTableStatement);
                    input=strings(1,floor(length(sep)/2));
                    output=strings(1,floor(length(sep)/2));
                    for i=1:floor(length(sep)/2)
                        input(i)=oldTableStatement(sep(2*i-1)+1:sep(2*i)-1);
                        output(i)=oldTableStatement(sep(2*i)+1:sep(2*i+1)-1);
                    end


                    newTableStatement="simscape.tablelookup(["...
                    +strjoin(input,",")+"],["...
                    +strjoin(output,",")+"],"...
                    +string(firstpart)+...
                    ",interpolation=linear,extrapolation=nearest)";


                    this.rawText(ii)=replaceBetween(oldStr,tempdex(jj),parIndices(pindex,2),newTableStatement);
                end


                tempdex=regexp(this.rawText(ii),'(?<=\W)i(|^i(');
                for jj=length(tempdex):-1:1
                    oldStr=this.rawText{ii};



                    parIndices=spiceSubckt.findEnclosure(oldStr,'(',')');
                    pindex=find(parIndices(:,1)>tempdex(jj),1);


                    oldFormat=oldStr(parIndices(pindex,1):parIndices(pindex,2));


                    argument=oldFormat(2:end-1);


                    if strncmpi(argument,'b',1)...
                        ||strncmpi(argument,'e',1)...
                        ||strncmpi(argument,'f',1)...
                        ||strncmpi(argument,'g',1)...
                        ||strncmpi(argument,'h',1)
                        newFormat="value("+upper(argument)+",'A')";
                    else
                        newFormat="value("+upper(argument)+".i,'A')";
                    end


                    this.rawText(ii)=replaceBetween(oldStr,tempdex(jj),parIndices(pindex,2),newFormat);
                end


                tempdex=regexp(this.rawText(ii),'(?<=\W)v(|^v(');
                for jj=length(tempdex):-1:1
                    oldStr=this.rawText{ii};



                    parIndices=spiceSubckt.findEnclosure(oldStr,'(',')');
                    pindex=find(parIndices(:,1)>tempdex(jj),1);


                    oldFormat=oldStr(parIndices(pindex,1):parIndices(pindex,2));




                    commadex=strfind(oldFormat,',');
                    for kk=(pindex+1):size(parIndices,1)
                        commadex(parIndices(pindex,1)+commadex-1>=parIndices(kk,1)...
                        &parIndices(pindex,1)+commadex-1<=parIndices(kk,2))=[];
                    end



                    if~isempty(commadex)
                        firstpart=strtrim(oldFormat(2:commadex(1)-1));
                        secondpart=strtrim(oldFormat(commadex(1)+1:end-1));

                        if~strcmpi(firstpart,'0')&&~strcmpi(secondpart,'0')
                            newFormat="value("+firstpart+".v-"...
                            +secondpart+".v,'V')";
                        elseif~strcmpi(firstpart,'0')&&strcmpi(secondpart,'0')
                            newFormat="value("+firstpart+".v,'V')";
                        elseif strcmpi(firstpart,'0')&&~strcmpi(secondpart,'0')
                            newFormat="value(-"...
                            +secondpart+".v,'V')";
                        else
                            newFormat="(0)";
                        end
                    else

                        argument=strtrim(oldFormat(2:end-1));


                        if~strcmpi(argument,'0')
                            newFormat="value("+argument+".v,'V')";
                        else
                            newFormat="(0)";
                        end
                    end


                    this.rawText(ii)=replaceBetween(oldStr,tempdex(jj),parIndices(pindex,2),newFormat);
                end


                this.rawText(ii)=regexprep(this.rawText(ii),'(?<=\W|^)time(?=\W|$)','value(time,''s'')');
            end
        end

        function extractPrivateParameters(this)

            names=string.empty;
            values=cell.empty;


            if~isempty(this.privateParameterStrings)
                for ii=1:length(this.privateParameterStrings)
                    [local_names,local_values]=spiceSubckt.parseNameEqualsValue(this.privateParameterStrings(ii));
                    names=[names,local_names];%#ok<AGROW>
                    values=[values,local_values];%#ok<AGROW>
                end


                this.privateParameters=struct(char(names(1)),values{1});
                for ii=2:length(names)

                    this.privateParameters.(char(names(ii)))=spiceBase.parseSpiceUnits(values{ii});
                end
            end
        end

        function extractPublicParameters(this)



            if~isempty(this.publicParameterString)
                [names,values]=spiceSubckt.parseNameEqualsValue(this.publicParameterString);


                this.publicParameters=struct(char(names(1)),values{1});
                for ii=2:length(names)

                    this.publicParameters.(char(names(ii)))=spiceBase.parseSpiceUnits(values{ii});
                end
            end


            if any(~cellfun(@isempty,regexp(this.rawText,"(?<=\W+)temp(?=\W+)",'once')))
                this.publicParameters.temp=27;
            end
        end

        function extractCommandStrings(this)









            cmd_indices=find(strncmpi(this.rawText,...
            spiceSubckt.commandIndicator,...
            strlength(spiceSubckt.commandIndicator)));


            subckt_indices=find(strncmpi(this.rawText,".subckt",7));
            func_indices=find(strncmpi(this.rawText,".func",5));
            privPar_indices=find(strncmpi(this.rawText,".param",6));
            model_indices=find(strncmpi(this.rawText,".model",6));
            ends_indices=find(strncmpi(this.rawText,".ends",5));
            supported_indices=[subckt_indices,func_indices,privPar_indices,model_indices,ends_indices];




            unsupported_indices=setdiff(cmd_indices,supported_indices);



            this.privateParameterStrings=regexprep(this.rawText(privPar_indices),"(?i)^(\.param\s*)","");
            this.functionStrings=regexprep(this.rawText(func_indices),"(?i)^(\.func\s*)","");
            this.modelStrings=regexprep(this.rawText(model_indices),"(?i)^(\.model\s*)","");


            for ii=1:length(unsupported_indices)
                this.unsupportedStrings(end+1)=this.name+": "+this.rawText(unsupported_indices(ii));
            end
        end

        function extractElementStrings(this)


            elem_indices=~strncmpi(this.rawText,...
            spiceSubckt.commandIndicator,...
            strlength(spiceSubckt.commandIndicator));
            this.elementStrings=this.rawText(elem_indices);
        end

        function extractSubcktDefinitionStrings(this)


            subckt_idx=find(strncmpi(this.rawText,'.subckt',7),1);
            defnParts=strsplit(this.rawText(subckt_idx));
            params_index=find(strcmpi(defnParts,"params:"));
            opt_index=find(strcmpi(defnParts,"optional:"));
            text_index=find(strcmpi(defnParts,"text:"));



            node_end=min([params_index,opt_index,text_index])-1;
            if isempty(node_end)
                node_end=length(defnParts);
            end



            this.nodes=defnParts(3:node_end);
            if any(this.nodes=="0")
                pm_error('physmod:ee:spice2ssc:IllegalConnection',getString(message('physmod:ee:library:comments:spice2ssc:spiceSubckt:error_PublicNodes')),getString(message('physmod:ee:library:comments:spice2ssc:spiceSubckt:error_Ground')));
            end


            if~isempty(opt_index)
                if params_index<opt_index
                    pp=[];
                else
                    pp=params_index;
                end
                if text_index<opt_index
                    tt=[];
                else
                    tt=text_index;
                end
                opt_end=min([pp,tt])-1;
                if isempty(opt_end)
                    opt_end=length(defnParts);
                elseif opt_end<=opt_index
                    opt_end=length(defnParts);
                end
                this.optionalNodeString=strjoin(defnParts(opt_index+1:opt_end));
                this.unsupportedStrings(end+1)=this.name+": OPTIONAL: "+this.optionalNodeString;
            end


            if~isempty(text_index)
                if params_index<text_index
                    pp=[];
                else
                    pp=params_index;
                end
                if opt_index<text_index
                    oo=[];
                else
                    oo=opt_index;
                end
                text_end=min([pp,oo])-1;
                if isempty(text_end)
                    text_end=length(defnParts);
                elseif text_end<=text_index
                    text_end=length(defnParts);
                end
                this.text=strjoin(defnParts(text_index+1:text_end));
                this.unsupportedStrings(end+1)=this.name+": TEXT: "+this.text;
            end


            if~isempty(params_index)
                if opt_index<params_index
                    oo=[];
                else
                    oo=opt_index;
                end
                if text_index<params_index
                    tt=[];
                else
                    tt=text_index;
                end
                params_end=min([oo,tt])-1;
                if isempty(params_end)
                    params_end=length(defnParts);
                elseif params_end<=params_index
                    params_end=length(defnParts);
                end
                this.publicParameterString=strjoin(defnParts(params_index+1:params_end));
            end
        end

        function getFunctionCalls(this)







            c=regexpi(this.rawText,'((?<!^\.model.*)\w+\()|((?<=^\.model.*=.*)\w+\()');

            b=regexpi(this.rawText,'(?<=\<simscape\.)\w+\(');

            a=regexpi(this.rawText,'(?<=\<simscape\.function\.)\w+\(');



            fdex=find(cellfun(@(x)~isempty(x),c));



            fns=string.empty;
            args=string.empty;



            for ii=1:length(fdex)
                s=this.rawText(fdex(ii));
                p=spiceSubckt.findEnclosure(s,'(',')');
                if~isempty(a{fdex(ii)})

                    compare=ismember(c{fdex(ii)},a{fdex(ii)});
                    c{fdex(ii)}=c{fdex(ii)}-length('simscape.function.')*compare;
                end
                if~isempty(b{fdex(ii)})

                    compare=ismember(c{fdex(ii)},b{fdex(ii)});
                    c{fdex(ii)}=c{fdex(ii)}-length('simscape.')*compare;
                end
                loc_indices=c{fdex(ii)};








                isFuncDefn=strncmpi(s,".func",5);
                if isFuncDefn
                    startIndex=2;
                else
                    startIndex=1;
                end




                for jj=startIndex:length(loc_indices)


                    pindex=find(p(:,1)>loc_indices(jj),1);


                    fn=s{:}(loc_indices(jj):p(pindex,1)-1);


                    arg=s{:}(p(pindex,1)+1:p(pindex,2)-1);



                    if~any(strcmpi(fn,this.supportedMATLABFunctions))
                        fns(end+1)=string(fn);%#ok<AGROW>
                        args(end+1)=string(arg);%#ok<AGROW>
                    end
                end
            end




            [this.functions.names,~,ic]=unique(fns);
            this.functions.calledWith=cell.empty;
            this.functions.body=string.empty;
            this.functions.args=cell.empty;
            this.functions.parameters=cell.empty;
            this.functions.nestedFunctions=cell.empty;
            this.functions.path=string.empty;
            this.sensors.names=string.empty;
            this.sensors.signals=string.empty;


            for ii=1:length(this.functions.names)

                this.functions.calledWith{ii}=args(ic==ii);

                switch this.functions.names(ii)
                case{"i","v"}
                    this.functions.body(ii)=this.functions.names(ii);
                    this.functions.args{ii}="-";
                otherwise


                    temp=regexpi(this.functionStrings,"^"+this.functions.names(ii)+"(");
                    if iscell(temp)
                        fdex=find(cellfun(@(x)~isempty(x),temp));
                    else
                        fdex=temp;
                    end
                    if length(fdex)~=1
                        pm_error('physmod:ee:spice2ssc:DoesNotExist',"Function "+this.functions.names(ii));
                    end






                    exprGroups=spiceSubckt.findEnclosure(this.functionStrings(fdex),'{','}');
                    if size(exprGroups,1)<1
                        pm_error('physmod:ee:spice2ssc:NotEnclosed',getString(message('physmod:ee:library:comments:spice2ssc:spiceSubckt:error_Functions')),'{}');
                    end
                    [~,this.functions.body(ii),paren]=spiceBase.stripEnclosedArguments(this.functionStrings(fdex));
                    this.functions.body(ii)=spiceSubckt.parseSpiceUnits(this.functions.body(ii));


                    idxList=regexp(this.functions.body(ii),"(?<=\W)der\s*(|^der\s*(",'once');
                    if~isempty(idxList)
                        pm_error('physmod:ee:spice2ssc:DiffTermInFunc');
                    end



                    if isempty(paren)
                        pm_error('physmod:ee:spice2ssc:UnexpectedFormat',this.functionStrings(fdex));
                    end
                    this.functions.args{ii}=paren(1);







                    removeInterpolationExtrapolation=regexprep(this.functions.body(ii),',interpolation=linear,extrapolation=nearest)',')');
                    simscapeFunction=regexp(removeInterpolationExtrapolation,'((\<simscape\.\w+)|(\<simscape\.function\.\w+))(?=\()','match');
                    removeSimscapeFunction=regexprep(removeInterpolationExtrapolation,'((\<simscape\.\w+)|(\<simscape\.function\.\w+))(?=\()','');
                    candidates=regexp(removeSimscapeFunction,...
                    "(?<=^|[^a-zA-Z0-9.'""])[a-zA-Z]\w*(?=$|[^\w.'""])",'match');
                    allNestedFunctions=regexpi(removeSimscapeFunction,"\w+(?=\()",'match');
                    if~isempty(simscapeFunction)
                        candidates(end+1:end+length(simscapeFunction))=simscapeFunction;
                        allNestedFunctions(end+1:end+length(simscapeFunction))=simscapeFunction;
                    end
                    this.functions.parameters{ii}=setdiff(unique(candidates),strsplit(this.functions.args{ii},{' ',','}));


                    functionArguments=setdiff(candidates,allNestedFunctions);
                    checkArgumentsName=intersect(functionArguments,this.supportedMATLABFunctions);
                    if~isempty(checkArgumentsName)
                        pm_error('physmod:ee:spice2ssc:UnexpectedFormat',checkArgumentsName);
                    end
                    this.functions.nestedFunctions{ii}=setdiff(allNestedFunctions,this.supportedMATLABFunctions);
                end
            end










            keywordList=unique(string([simscape.internal.reservedKeywords();ne_reserved();iskeyword]));
            sensedSignals=regexpi(this.functions.body,"(?<=^|\W|\s)(value\([^,\s]+?,'\w{1}'\))(?=$|\W|\s)",'match');
            idx=find(cellfun(@(x)(~isempty(x)),sensedSignals));
            if~isempty(idx)
                for ii=idx
                    this.sensors.signals=[this.sensors.signals,sensedSignals{ii}];
                end
                this.sensors.signals=unique(this.sensors.signals);
                [componentNames,functionNames,parameterNames,subcktParameterNames]=this.getNames();
                allArgs=cellfun(@(x)strsplit(x,','),this.functions.args,'UniformOutput',false);
                fargs=string.empty;
                fparams=string.empty;
                for ii=1:length(this.functions.names)
                    fargs=[fargs,allArgs{ii}];%#ok<AGROW>
                    if~isempty(this.functions.parameters{ii})
                        fparams=[fparams,this.functions.parameters{ii}];%#ok<AGROW>
                    end
                end
                fargs=unique(fargs);
                fparams=unique(fparams);
                fargs(fargs=="")=[];
                fparams(fparams=="")=[];
                exclude=[keywordList;...
                componentNames(:);...
                functionNames(:);...
                parameterNames(:);...
                subcktParameterNames(:);...
                fargs(:);...
                fparams(:)];
                extraParams=string(1:length(this.sensors.signals));
                this.sensors.names=this.getUniqueNames(extraParams,exclude,"sensor_");



                for ii=1:length(this.functions.names)
                    for jj=1:length(this.sensors.signals)
                        if contains(this.functions.body(ii),this.sensors.signals(jj))
                            this.functions.body(ii)=strrep(this.functions.body(ii),this.sensors.signals(jj),this.sensors.names(jj));
                            this.functions.parameters{ii}(end+1)=this.sensors.names(jj);
                        end
                    end
                end
            end



            for ii=1:length(this.functions.names)
                this.functions.parameters{ii}=setdiff(this.functions.parameters{ii},...
                [keywordList',this.functions.names,this.supportedMATLABFunctions]);
            end


            for ii=1:length(this.functions.names)
                this.functions.parameters{ii}=spiceSubckt.addNestedFunctionParameters(this.functions.names(ii),this.functions,1);
            end
        end

        function addDiffEquations(this)


            varDerList=strings;
            varDerOrigList=strings;
            paramName=[string(fieldnames(this.privateParameters));...
            string(fieldnames(this.publicParameters));...
            string(this.nodes)';...
            string(this.name);...
            ];
            varNameList=string(paramName);
            len=length(this.sections.equations);
            oldEqu=true;
            for ii=1:len
                thisEquation=this.sections.equations(ii);
                [thisEquation,equationsOut,variablesOut,varDerList,varDerOrigList,varNameList]...
                =this.addDiffHelper(thisEquation,varDerList,varDerOrigList,varNameList,oldEqu);
                this.sections.equations(ii)=thisEquation;
                this.sections.equations=[this.sections.equations,equationsOut];
                this.sections.variables=[this.sections.variables,variablesOut];
            end
        end

        function[equationModi,equationsOut,variablesOut,varDerListOut,varDerOrigListOut,varNameListOut]=...
            addDiffHelper(this,equation,varDerList,varDerOrigList,varNameList,oldEqu)

            equationsOut=strings;
            variablesOut=strings;
            [thisVarInDerList,thisVarInDerOrigList,thisVarDerList,thisVarDerOrigList,~]=spiceSubckt.getVarInDer(equation);

            nDer=length(thisVarDerList);
            for ii=1:nDer

                if nDer>1||spiceSubckt.derInConditional(equation)


                    varDer=thisVarDerList{ii};
                    varDerOrig=thisVarDerOrigList{ii};

                    this.conversionNotes(end+1)=strjoin([this.name+": "+...
                    getString(message('physmod:ee:library:comments:spice2ssc:spiceSubckt:sprintf_DifferentialEquationWithinIfElseStatement'))]);
                else


                    varDer=thisVarInDerList{1};
                    varDerOrig=thisVarInDerOrigList{1};
                end

                if~any(strcmp(varDerList,varDer))
                    varDerList(end+1)=varDer;
                    varName=spiceSubckt.makeVarDerName(varDer);
                    varNameList(end+1)=varName;
                    varNameList=matlab.lang.makeUniqueStrings(varNameList,length(varNameList));
                    varName=varNameList(end);


                    equation=strrep(equation,varDerOrig,varName);
                    if oldEqu
                        exp=sprintf("der\\s*\\(\\s*%s\\s*\\)",varName);
                        equation=regexprep(equation,exp,"value(der("+varName+"),'1/s')");
                    end

                    newVariable=varName+" = {value={0,'1'},priority=priority.none};";
                    if contains(varDer,"der(")
                        newEquation=varName+" == value("+varDer+",'1/s');";
                    else
                        newEquation=varName+" == "+varDer+";";
                    end

                    oldEqu=false;
                    [newEquation,x_equationsOut,x_variablesOut,varDerList,varDerOrigList,varNameList]=...
                    this.addDiffHelper(newEquation,varDerList,varDerOrigList,varNameList,oldEqu);
                    equationsOut=[equationsOut,newEquation,x_equationsOut];
                    variablesOut=[variablesOut,newVariable,x_variablesOut];
                else
                    varName=varNameList(strcmp(varDerList,varDer));
                    equation=strrep(equation,varDerOrig,varName);
                end
            end
            equationModi=equation;
            varDerListOut=varDerList;
            varDerOrigListOut=varDerOrigList;
            varNameListOut=varNameList;
            equationsOut(strcmp(equationsOut,""))=[];
            variablesOut(strcmp(variablesOut,""))=[];
        end
    end

    methods(Static,Access=protected)
        function result=addNestedFunctionParameters(name,data,recursionLevel)






            if~exist('recursionLevel','var')
                recursionLevel=1;
            end
            if recursionLevel>100
                pm_error('physmod:ee:spice2ssc:UnsupportedFormat',getString(message('physmod:ee:library:comments:spice2ssc:spiceSubckt:error_DeeplyNestedFunction')),getString(message('physmod:ee:library:comments:spice2ssc:spiceSubckt:error_CheckNestedFunctionsForCircularReferencesOrExcessiveNesti')));
            end

            base_idx=find(name==data.names,1);



            result=data.parameters{base_idx};
            for ii=1:length(data.nestedFunctions{base_idx})
                idx=find(data.nestedFunctions{base_idx}(ii)==data.names,1);
                if recursionLevel==1
                    try
                        result=unique([result...
                        ,spiceSubckt.addNestedFunctionParameters(...
                        data.names(idx),data,recursionLevel+1)]);
                    catch ME
                        throwAsCaller(ME);
                    end
                else
                    result=unique([result...
                    ,spiceSubckt.addNestedFunctionParameters(...
                    data.names(idx),data,recursionLevel+1)]);
                end
            end
        end

        function result=isGlobalOrInSubcircuit(array,name)




            result=false(size(array));
            relevant=true;
            for ii=1:length(array)
                if relevant
                    if strncmpi(array(ii),'.subckt',7)
                        splt=strsplit(array(ii));
                        if strcmpi(splt(2),name)
                            result(ii)=true;
                            relevant=true;
                        else
                            relevant=false;
                        end
                    else
                        result(ii)=true;
                    end
                else
                    if strncmpi(array(ii),'.ends',5)
                        relevant=true;
                    end
                end
            end
        end

        function newArray=handleLibIncFiles(oldArray,sname,recursionLevel)



            if~exist('recursionLevel','var')
                recursionLevel=1;
            end
            if recursionLevel>100
                pm_error('physmod:ee:spice2ssc:UnsupportedFormat',getString(message('physmod:ee:library:comments:spice2ssc:spiceSubckt:error_DeeplyNestedINCCommands')),getString(message('physmod:ee:library:comments:spice2ssc:spiceSubckt:error_CheckIncludeFilesForCircularReferencesOrExcessiveNesting')));
            end
            newArray=oldArray;


            idx=find((strncmpi(newArray,".inc",4)|strncmpi(newArray,".lib",4))...
            &spiceSubckt.isGlobalOrInSubcircuit(oldArray,sname),1);

            if isempty(idx)
                return;
            else
                entry=newArray{idx}(6:end);
                [entry,brace,~,~]=spiceBase.stripEnclosedArguments(entry);
                if isempty(brace)
                    fname=regexprep(entry,spiceBase.commentIndicators(2)+".*","");
                else
                    fname=brace;
                end
                fname=strtrim(fname);
                newText=spiceNetlist2String(fname);
                newText=spiceSubckt.cleanNetlistStringArray(newText);
                if strncmpi(newArray(idx),".lib",4)
                    newArray(idx)=[];
                    newArray=[newText,newArray];
                else
                    newArray=[newArray(1:idx-1),newText,newArray(idx+1:end)];
                end

                if recursionLevel==1
                    try
                        newArray=spiceSubckt.handleLibIncFiles(newArray,sname,recursionLevel+1);
                    catch ME
                        throwAsCaller(ME);
                    end
                else
                    newArray=spiceSubckt.handleLibIncFiles(newArray,sname,recursionLevel+1);
                end
            end
        end

        function newStrArray=eliminateDuplicates(oldStrArray)

            splitStr=cellfun(@(x)strsplit(x,{' ','(',')','='}),oldStrArray,'UniformOutput',false);
            names=cellfun(@(x)x(1),splitStr);
            [~,idx]=unique(names,'last');
            newStrArray=oldStrArray(idx);
        end

        function writeHeaderVersion(fid)
            mver=ver('matlab');
            ever=ver('sps');
            if isempty(mver)
                fprintf(fid,['\n%%   ',getString(message('physmod:ee:library:comments:spice2ssc:spiceSubckt:sprintf_MATLABVersionUnknown')),'\n']);
            else
                fprintf(fid,['\n%%   ',getString(message('physmod:ee:library:comments:spice2ssc:spiceSubckt:sprintf_Version',mver.Name,mver.Version)),'\n']);
            end
            if isempty(ever)
                fprintf(fid,['%%   ',getString(message('physmod:ee:library:comments:spice2ssc:spiceSubckt:sprintf_Spice2sscVersionUnknown')),'\n']);
            else
                fprintf(fid,['%%   ',getString(message('physmod:ee:library:comments:spice2ssc:spiceSubckt:sprintf_Version',ever.Name,ever.Version)),'\n']);
            end
            fprintf(fid,['%%   ',getString(message('physmod:ee:library:comments:spice2ssc:spiceSubckt:sprintf_SimscapeCodeGeneratedOn',datestr(now))),'\n']);
        end

        function[varInDerList,varInDerOrigList,varDerList,varDerOrigList,idxDerList]=getVarInDer(str)


            varInDerList={};
            varInDerOrigList={};
            varDerList={};
            varDerOrigList={};
            idxDerList={};
            idxList=regexp(str,"(?<=\W)der\s*(|^der\s*(");
            pos=0;
            for ii=1:length(idxList)
                newStr=extractAfter(str,max(idxList(ii),pos)-1);
                parIndices=spiceSubckt.findEnclosure(newStr,'(',')',false);
                if isempty(parIndices)||any(isnan(parIndices(1,:)))
                    continue
                end
                idxDer=[idxList(ii),idxList(ii)+parIndices(1,2)-1];
                varDer=extractBetween(str,idxDer(1),idxDer(2));
                idxDerList{end+1}=idxDer;
                varDerList{end+1}=strrep(varDer,' ','');
                varDerOrigList{end+1}=varDer;
                pos=idxDer(2);

                parIndices=spiceSubckt.findEnclosure(varDer,'(',')');
                varInDer=extractBetween(varDer,parIndices(1,1)+1,parIndices(1,2)-1);
                varInDerList{end+1}=strrep(varInDer,' ','');
                varInDerOrigList{end+1}=varInDer;
            end
        end

        function tf=derInConditional(equation)
            if isempty(regexp(equation,'\W\s*if\s.*\selse\s.*end\s*\W','once'))
                tf=false;
            else
                conditional_statement=regexp(equation,'\W\s*if\s.*\selse\s.*end\s*\W','match');
                tf=~isempty(regexp(conditional_statement,'\Wder|w','once'));
            end

        end

        function varName=makeVarDerName(str)

            idxList=regexp(str,"(?<=\W)der\s*(|^der\s*(",'once');
            if isempty(idxList)
                varName="term";
            else
                varName="ddt_term";
            end
        end

    end

    methods(Static,Access=public)
        function newStrArray=cleanNetlistStringArray(oldStrArray)






            newStrArray=strtrim(oldStrArray);


            newStrArray=regexprep(newStrArray,'\s+',' ');


            for ii=1:length(spiceSubckt.commentIndicators)
                l=strlength(spiceSubckt.commentIndicators(ii));
                newStrArray=newStrArray(~strncmpi(newStrArray,...
                spiceSubckt.commentIndicators(ii),l));
            end


            contIndices=find(strncmpi(newStrArray,...
            spiceSubckt.continuationIndicator,...
            strlength(spiceSubckt.continuationIndicator)));
            if~isempty(contIndices)
                if contIndices(1)==1
                    pm_error('physmod:ee:spice2ssc:UnexpectedFormat',getString(message('physmod:ee:library:comments:spice2ssc:spiceSubckt:error_LineContinuation')));
                end
                repexp="^\"+spiceSubckt.continuationIndicator+"(\s)*";
                for ii=length(contIndices):-1:1
                    if strcmpi(newStrArray(contIndices(ii)-1),"")
                        pm_error('physmod:ee:spice2ssc:UnexpectedFormat',getString(message('physmod:ee:library:comments:spice2ssc:spiceSubckt:error_LineContinuation')));
                    end
                    newStrArray(contIndices(ii)-1)=newStrArray(contIndices(ii)-1)+...
                    regexprep(newStrArray(contIndices(ii)),repexp," ");
                end
                newStrArray(contIndices)=[];
            end


            newStrArray(strcmpi(newStrArray,""))=[];



            idx=find(~strncmpi(newStrArray,".lib",4)...
            &~strncmpi(newStrArray,".inc",4));
            newStrArray(idx)=lower(newStrArray(idx));
            newStrArray=regexprep(newStrArray,"^(\w+)","${upper($1)}");


            qdx=strfind(newStrArray,"'");
            if iscell(qdx)
                num_quotes=cellfun(@length,qdx);
            else
                num_quotes=length(qdx);
            end
            idx=find(num_quotes>0);
            edex=find(mod(num_quotes,2)~=0,1);
            if~isempty(edex)
                pm_error('physmod:ee:spice2ssc:Mismatch',getString(message('physmod:ee:library:comments:spice2ssc:spiceSubckt:error_NumberOfOpeningQuotes')),getString(message('physmod:ee:library:comments:spice2ssc:spiceSubckt:error_NumberOfClosingQuotes')),newStrArray(edex));
            end
            for ii=idx
                newStrArray{ii}(qdx{ii}(1:2:end))='{';
                newStrArray{ii}(qdx{ii}(2:2:end))='}';
            end
            qdx=strfind(newStrArray,'"');
            if iscell(qdx)
                num_quotes=cellfun(@length,qdx);
            else
                num_quotes=length(qdx);
            end
            idx=find(num_quotes>0);
            edex=find(mod(num_quotes,2)~=0,1);
            if~isempty(edex)
                pm_error('physmod:ee:spice2ssc:Mismatch',getString(message('physmod:ee:library:comments:spice2ssc:spiceSubckt:error_NumberOfOpeningQuotes')),getString(message('physmod:ee:library:comments:spice2ssc:spiceSubckt:error_NumberOfClosingQuotes')),newStrArray(edex));
            end
            for ii=idx
                newStrArray{ii}(qdx{ii}(1:2:end))='{';
                newStrArray{ii}(qdx{ii}(2:2:end))='}';
            end
        end
    end
end