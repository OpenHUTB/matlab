function[psConfigFile,psDefaultCompiler]=prepareSnifferConfiguration(...
    tc,buildConfigName,customToolchainOpts,targetLang)




    buildCompiler=sprintf('%s Compiler',targetLang);
    buildTool=tc.getBuildTool(buildCompiler);

    [psDefaultCompiler,compilerBaseName,compilerExeName]=polyspace.internal.sniffer.toolchainUsesKnownCompiler(tc,targetLang);
    if psDefaultCompiler
        psConfigFile='';
        return
    end


    xmlNode=matlab.io.xml.dom.Document('compiler_configuration');
    compConfig=xmlNode.getDocumentElement;



    compConfig.appendChild(...
    loc_createXMLNodes(...
    xmlNode,...
    'compiler_names',...
    'name',...
    compilerExeName));

    directive='IncludeSearchPath';
    if~buildTool.Directives.isKey(directive)||...
        isempty(buildTool.getDirective(directive))
        DAStudio.error('CoderProfile:ExecutionTime:MissingDirectiveInBTI',directive);
    end
    includeSearchPath=buildTool.getDirective(directive);


    compConfig.appendChild(...
    loc_createXMLNodes(...
    xmlNode,...
    'include_options',...
    'opt',...
    includeSearchPath,...
    {'isPrefix','true'}));


    compConfig.appendChild(...
    xmlNode.createElement('system_include_options'));


    compConfig.appendChild(...
    xmlNode.createElement('preinclude_options'));


    directive='PreprocessorDefine';
    if~buildTool.Directives.isKey(directive)||...
        isempty(buildTool.getDirective(directive))
        DAStudio.error('CoderProfile:ExecutionTime:MissingDirectiveInBTI',directive);
    end
    preprocessorDefine=buildTool.getDirective(directive);


    compConfig.appendChild(...
    loc_createXMLNodes(...
    xmlNode,...
    'define_options',...
    'opt',...
    preprocessorDefine,...
    {'isPrefix','true'}));


    compConfig.appendChild(...
    xmlNode.createElement('undefine_options'));


    if tc.isAttribute('RequiresCommandFile')
        compConfig.appendChild(...
        loc_createXMLNodes(...
        xmlNode,...
        'options_file_options',...
        'opt',...
        '@'));
    else
        compConfig.appendChild(...
        xmlNode.createElement('options_file_options'));
    end

    if startsWith(tc.Name,'Intel Parallel Studio')&&...
        any(strcmp(tc.Name,coder.make.internal.getHostToolchains))
















        incStrategyElement=xmlNode.createElement('include_strategy');
        incStrategyElement.appendChild(...
        xmlNode.createTextNode('visual'));
        compConfig.appendChild(incStrategyElement);



        minusIsSlashElement=xmlNode.createElement('minus_is_slash');
        minusIsSlashElement.appendChild(...
        xmlNode.createTextNode('1'));
        compConfig.appendChild(minusIsSlashElement);
    end


    directive='PreprocessFile';
    if~buildTool.Directives.isKey(directive)||...
        isempty(buildTool.getDirective(directive))
        DAStudio.error('CoderProfile:ExecutionTime:MissingDirectiveInBTI',directive);
    end
    preprocessOpt=buildTool.getDirective(directive);

    directive='OutputFlag';
    if~buildTool.Directives.isKey(directive)||...
        isempty(buildTool.getDirective(directive))||...
        ~isempty(regexp(preprocessOpt,'\$\(OUTPUT_FILE\)','match'))
        preprocessOptsList=regexp(preprocessOpt,'\s+','split');
    else
        outputFlag=buildTool.getDirective(directive);
        preprocessOptsList={preprocessOpt,[outputFlag,'$(OUTPUT_FILE)']};
    end

    preprocessOptionsListNode=xmlNode.createElement('preprocess_options_list');
    for ii=1:numel(preprocessOptsList)
        optNode=xmlNode.createElement('opt');
        optNode.appendChild(xmlNode.createTextNode(preprocessOptsList{ii}));
        preprocessOptionsListNode.appendChild(optNode);
    end
    compConfig.appendChild(preprocessOptionsListNode);


    pdmElement=xmlNode.createElement('preprocess_dollar_macros');
    pdmElement.appendChild(...
    xmlNode.createTextNode('no'));
    compConfig.appendChild(pdmElement);


    compConfig.appendChild(...
    xmlNode.createElement('forbidden_macros_list'));


    directive='CompileFlag';
    if~buildTool.Directives.isKey(directive)||...
        isempty(buildTool.getDirective(directive))
        DAStudio.error('CoderProfile:ExecutionTime:MissingDirectiveInBTI',directive);
    end
    compileFlag=buildTool.getDirective(directive);

    compConfig.appendChild(...
    loc_createXMLNodes(...
    xmlNode,...
    'compile_options_list',...
    'opt',...
    compileFlag));




    if strcmpi(buildConfigName,'Specify')
        assert(~isempty(customToolchainOpts),'Empty customToolchainOpts');
        [~,idx]=ismember(buildCompiler,customToolchainOpts(1:2:end));
        compilerOpts=customToolchainOpts{idx*2};
    else
        buildConfig=tc.getBuildConfiguration(buildConfigName);
        compilerOpts=buildConfig.getOption(buildCompiler).getValue();
        if iscellstr(compilerOpts)
            compilerOpts=strjoin(compilerOpts,' ');
        end
    end


    hasAnsiOpts=false;
    while true
        tokens=regexp(compilerOpts,'^(.*)\$\((.*?)\)(.*)','tokens');
        if isempty(tokens)
            break
        end
        tokens=tokens{1};
        macro=tokens{2};


        if strcmp(macro,'MATLAB_ROOT')
            macroVal=matlabroot;
        elseif~isempty(regexp(macro,'^shell\s','once'))
            [~,macroVal]=system(regexprep(macro(7:end),'\n',' '));
        else
            if tc.Macros.isKey(macro)
                macroVal=tc.getMacro(macro);
            else
                macroVal=[];
            end
        end
        if isempty(macroVal)
            compilerOpts=[tokens{[1,3]}];
            if ismember(macro,{'C_STANDARD_OPTS','CPP_STANDARD_OPTS',...
                'MINGW_C_STANDARD_OPTS'})
                hasAnsiOpts=true;
            end
        else
            compilerOpts=[tokens{1},macroVal,tokens{3}];
        end
    end





    compilerOpts=regexp(strtrim(compilerOpts),'\s+','split');
    compilerOpts(strcmp(compilerOpts,compileFlag))=[];
    idx=find(strcmp(compilerOpts,preprocessorDefine));
    compilerOpts([idx,idx+1])=[];
    compilerOpts(strncmp(compilerOpts,preprocessorDefine,numel(preprocessorDefine)))=[];
    idx=find(strcmp(compilerOpts,includeSearchPath));
    compilerOpts([idx,idx+1])=[];
    compilerOpts(strncmp(compilerOpts,includeSearchPath,numel(includeSearchPath)))=[];

    if hasAnsiOpts



        compilerOpts=[compilerOpts,{'-ansi','-std=c99','-std=gnu99','-std=c++98','-Wno-long-long','-fwrapv'}];
    end



    semanticOptionsNode=xmlNode.createElement('semantic_options');
    ii=1;
    while ii<=numel(compilerOpts)
        optNode=xmlNode.createElement('opt');
        optNode.appendChild(xmlNode.createTextNode(compilerOpts{ii}));
        semanticOptionsNode.appendChild(optNode);
        ii=ii+1;



        if(ii<=numel(compilerOpts))&&...
            (~any(compilerOpts{ii}(1)=='-/')||~isempty(dir(compilerOpts{ii})))
            optNode.setAttribute('numArgs','1');
            ii=ii+1;
        end
    end
    compConfig.appendChild(semanticOptionsNode);


    dialectNode=xmlNode.createElement('dialect');
    dialectNode.appendChild(...
    xmlNode.createTextNode('default'));
    compConfig.appendChild(dialectNode);


    srcExtensions=buildTool.getFileExtension('Source');
    compConfig.appendChild(...
    loc_createXMLNodes(...
    xmlNode,...
    'src_extensions',...
    'ext',...
    srcExtensions(2:end)));


    objExtensions=buildTool.getFileExtension('Object');
    compConfig.appendChild(...
    loc_createXMLNodes(...
    xmlNode,...
    'obj_extensions',...
    'ext',...
    objExtensions(2:end)));


    compConfig.appendChild(...
    xmlNode.createElement('precompiled_header_extensions'));


    compConfig.appendChild(...
    xmlNode.createElement('precompiled_header_extensions'));


    compConfig.appendChild(...
    xmlNode.createElement('polyspace_c_extra_options_list'));


    compConfig.appendChild(...
    xmlNode.createElement('polyspace_cpp_extra_options_list'));




    polyspaceConfFile=regexprep([compilerBaseName,'.xml'],'\s','_');
    writer=matlab.io.xml.dom.DOMWriter;
    writer.Configuration.FormatPrettyPrint=true;
    writeToURI(writer,xmlNode,polyspaceConfFile);

    psConfigFile=polyspaceConfFile;

end

function parentNode=loc_createXMLNodes(...
    root,...
    parentElement,...
    childElement,...
    childContent,...
    childAttributes)

    parentNode=root.createElement(parentElement);
    childNode=root.createElement(childElement);
    if nargin>=5
        for ii=1:2:numel(childAttributes)
            childNode.setAttribute(childAttributes{ii},childAttributes{ii+1});
        end
    end
    childNode.appendChild(...
    root.createTextNode(childContent));
    parentNode.appendChild(childNode);
end
