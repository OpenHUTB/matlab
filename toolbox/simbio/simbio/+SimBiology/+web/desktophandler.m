function out=desktophandler(action,varargin)











    out={action};

    switch(action)
    case 'openModelAnalyzer'
        openModelAnalyzer;
    case 'openModelBuilder'
        openModelBuilder;
    case 'getModelAnalyzer'
        out=getModelAnalyzer;
    case 'getModelBuilder'
        out=getModelBuilder;
    case 'initModelAnalyzer'
        out=initModelAnalyzer(varargin{1});
    case 'initModelBuilder'
        out=initModelBuilder(varargin{1});
    case 'showInTable'
        showInTable(varargin{1});
    case 'showInDiagram'
        showInDiagram(varargin{1});
    case 'openFileDialog'
        out=openFileDialog(varargin{1});
    case 'saveFileDialog'
        out=saveFileDialog(varargin{1});
    case 'getModelAnalyzerPreferenceFileName'
        out=getModelAnalyzerPreferenceFileName;
    case 'getModelBuilderPreferenceFileName'
        out=getModelBuilderPreferenceFileName;
    case 'cleanupOnModelAnalyzerClose'
        cleanupOnModelAnalyzerClose(varargin{1});
    case 'saveModelAnalyzerPreferences'
        saveModelAnalyzerPreferences(varargin{1});
    case 'cleanupOnModelBuilderClose'
        cleanupOnModelBuilderClose(varargin{1});
    case 'saveModelBuilderPreferences'
        saveModelBuilderPreferences(varargin{1});
    case 'postEventToModelAnalyzer'
        out=postEventToModelAnalyzer(varargin{1});
    case 'postEventToModelBuilder'
        out=postEventToModelBuilder(varargin{1});
    case 'doc'
        showDoc;
    case 'examples'
        showExamples;
    case 'community'
        showCommunityPage;
    case 'showContactPage'
        showContactPage;
    case 'launchDemo'
        launchDemo(varargin{1});
    case 'aboutWindow'
        out=getAboutWindowInfo(action);
    case 'getprojectfiles'
        out=getProjectFiles(action);
    case 'tempfile'
        out={action,SimBiology.web.internal.desktopTempname()};
    case 'getfullpath'
        out=getfullpath(varargin{:});
    case 'copyToClipBoard'
        copyToClipBoard(varargin{1});
    case 'packageApp'
        packageApp(varargin{1});
    case 'launchApp'
        launchApp;
    case 'addStaticContentOnPath'
        out=addStaticContentOnPath(varargin{1});
    case 'runProgramMATLABCalls'
        out=runProgramMATLABCalls(action,varargin);
    case 'getMatFileVariableName'
        out=getMatFileVariableName(varargin{1});
    case 'closeAllExportWebWindows'
        closeAllExportWebWindows;
    end

end

function openModelAnalyzer

    simBiologyModelAnalyzer;

end

function openModelBuilder

    simBiologyModelBuilder;

end

function out=getModelAnalyzer

    out.title='SimBiology Model Analyzer';
    out.webWindow=getWebWindowByTitle(out.title);

end

function out=getModelBuilder

    out.title='SimBiology Model Builder';
    out.webWindow=getWebWindowByTitle(out.title);

end

function out=initModelAnalyzer(input)


    r=sbioroot;
    r.SendJSEvents=true;


    out.matfileName=[SimBiology.web.internal.desktopTempdir,filesep,'externaldata.mat'];
    out.args=input;
    out.licenses=getLicenses;


    mb=getModelBuilder;
    out.modelBuilderOpen=~isempty(mb.webWindow);


    prefName=getModelAnalyzerPreferenceFileName;
    if exist(prefName,'file')
        preferences=load(prefName);
        preferences=preferences.preferences;
        out.Preferences=preferences.preferences;

        if isfield(preferences,'desktopState')
            out.DesktopState=preferences.desktopState;
        else
            out.DesktopState=[];
        end
    else
        out.Preferences=[];
        out.DesktopState=[];
    end


    if isfield(input,'name')
        projectName=convertfilename(input.name);
        value.ProjectName=projectName;
        value.appType='AnalysisApp';
        out.Project=SimBiology.web.projecthandler('loadproject',value);
    else
        out.Project='';
    end

    if isfield(input,'model')
        sessionIDs=eval(input.model);
        initDiagramSyntax=SimBiology.web.diagram.inithandler('doesDiagramSyntaxNeedToBeInitialized',struct('appType','AnalysisApp'));


        evt.type='initApp';
        evt.models=sessionIDs;
        evt=updateEventBeforePostToApp(evt,initDiagramSyntax);
        out.Model=evt.mInfo;

        for i=1:length(sessionIDs)
            mobj=SimBiology.web.modelhandler('getModelFromSessionID',sessionIDs(i));
            SimBiology.web.modelhandler('turnOnEvents',mobj);
        end
    else
        out.Model='';
    end

end

function out=initModelBuilder(input)


    r=sbioroot;
    r.SendJSEvents=true;


    out.matfileName=[SimBiology.web.internal.desktopTempdir,filesep,'externaldata.mat'];
    out.args=input;
    out.licenses=getLicenses;
    out.Preferences=[];


    ma=getModelAnalyzer;
    out.modelAnalyzerOpen=~isempty(ma.webWindow);


    prefName=getModelBuilderPreferenceFileName;
    if exist(prefName,'file')
        preferences=load(prefName);
        preferences=preferences.preferences;
        out.Preferences=preferences.preferences;
    end

    if isfield(input,'name')
        projectName=convertfilename(input.name);
        value.ProjectName=projectName;
        value.appType='ModelingApp';
        out.Project=SimBiology.web.projecthandler('loadproject',value);
    else
        out.Project='';
    end

    if isfield(input,'model')
        sessionIDs=eval(input.model);

        evt.type='initApp';
        evt.models=sessionIDs;
        evt=updateEventBeforePostToApp(evt,true);
        out.Model=evt.mInfo;

        for i=1:length(sessionIDs)
            mobj=SimBiology.web.modelhandler('getModelFromSessionID',sessionIDs(i));
            SimBiology.web.modelhandler('turnOnEvents',mobj);
        end
    else
        out.Model='';
    end


    root=sbioroot;
    bakls=root.BuiltinLibrary.KineticLaws;
    akls=root.UserDefinedLibrary.KineticLaws;
    aklInfo=struct('name','','expression','','parameters',{},'species',{},'builtin',true);
    aklInfo=repmat(aklInfo,1,length(akls)+length(bakls));
    count=length(bakls)+1;

    for i=1:length(bakls)
        aklInfo(i).name=bakls(i).Name;
        aklInfo(i).expression=bakls(i).Expression;
        aklInfo(i).parameters=bakls(i).ParameterVariables;
        aklInfo(i).species=bakls(i).SpeciesVariables;
        aklInfo(i).builtin=true;
    end

    for i=1:length(akls)
        aklInfo(count).name=akls(i).Name;
        aklInfo(count).expression=akls(i).Expression;
        aklInfo(count).parameters=akls(i).ParameterVariables;
        aklInfo(count).species=akls(i).SpeciesVariables;
        aklInfo(count).builtin=false;
        count=count+1;
    end

    out.AbstractKineticLaws=aklInfo;


    bunits=root.BuiltinLibrary.Units;
    units=root.UserDefinedLibrary.Units;
    unitsInfo=struct('name','','composition','','multiplier',1,'builtin',true);
    unitsInfo=repmat(unitsInfo,1,length(units)+length(bunits));
    count=length(bunits)+1;

    for i=1:length(bunits)
        unitsInfo(i).name=bunits(i).Name;
        unitsInfo(i).composition=bunits(i).Composition;
        unitsInfo(i).multiplier=bunits(i).Multiplier;
        unitsInfo(i).builtin=true;
    end

    for i=1:length(units)
        unitsInfo(count).name=units(i).Name;
        unitsInfo(count).composition=units(i).Composition;
        unitsInfo(count).multiplier=units(i).Multiplier;
        unitsInfo(count).builtin=false;
        count=count+1;
    end

    out.Units=unitsInfo;


    bprefixes=root.BuiltinLibrary.UnitPrefixes;
    prefixes=root.UserDefinedLibrary.UnitPrefixes;
    prefixInfo=struct('name','','exponent','','builtin',true);
    prefixInfo=repmat(prefixInfo,1,length(prefixes)+length(bprefixes));
    count=length(bprefixes)+1;

    for i=1:length(bprefixes)
        prefixInfo(i).name=bprefixes(i).Name;
        prefixInfo(i).exponent=bprefixes(i).Exponent;
        prefixInfo(i).builtin=true;
    end

    for i=1:length(prefixes)
        prefixInfo(count).name=prefixes(i).Name;
        prefixInfo(count).exponent=prefixes(i).Exponent;
        prefixInfo(count).builtin=false;
        count=count+1;
    end

    out.UnitPrefixes=prefixInfo;

    customBlockLibrary=[];
    if isfield(out.Preferences,'customBlockLibrary')
        customBlockLibrary=out.Preferences.customBlockLibrary;
    end


    if isempty(customBlockLibrary)
        try
            simbioPrefDir=fullfile(prefdir,'SimBiology','blocklibrary','*.sbblib');
            customLibraries=dir(simbioPrefDir);


            customBlockLibrary=[];
            if~isempty(customLibraries)
                customBlockLibrary=SimBiology.web.diagram.palettehandler('importOldCustomPalettes',customLibraries);
            end

            out.Preferences.customBlockLibrary=customBlockLibrary;

            preferences=struct('preferences',out.Preferences);
            save(getModelBuilderPreferenceFileName,'preferences');
        catch
        end
    end

end

function showInTable

    openModelBuilder;

end

function showInDiagram

    openModelBuilder;

end

function out=openFileDialog(input)

    [filename,pathname]=uigetfile(createFileSpec(input),'Open SimBiology file',input.filePath);

    out.id=input.id;
    if filename==0
        out.filename='';
    else
        out.filename=[pathname,filename];
    end

end

function out=saveFileDialog(input)

    if isempty(input.fileName)
        input.fileName='project.sbproj';
    end



    name=input.fileName;
    filepath=fileparts(name);
    if isempty(filepath)
        name=fullfile(input.filePath,name);
    end

    [filename,pathname]=uiputfile(createFileSpec(input),'Save SimBiology file',name);

    out.id=input.id;
    if filename==0
        out.filename='';
    else
        out.filename=[pathname,filename];
    end

end

function out=getModelAnalyzerPreferenceFileName

    out=fullfile(prefdir,'SimBiology','simBiologyModelAnalyzer.mat');

end

function out=getModelBuilderPreferenceFileName

    out=fullfile(prefdir,'SimBiology','simBiologyModelBuilder.mat');

end

function cleanupOnModelAnalyzerClose(input)

    preferences=struct('preferences',input.preferences,'desktopState',input.desktopState);
    saveModelAnalyzerPreferences(preferences);

    models=input.sessionIDs;
    for i=1:length(models)
        model=SimBiology.web.modelhandler('getModelFromSessionID',models(i));
        SimBiology.web.modelhandler('turnOffEvents',model);
    end

end

function saveModelAnalyzerPreferences(preferences)

    prefFileName=getModelAnalyzerPreferenceFileName;
    simbioPrefdir=fileparts(prefFileName);

    if~exist(simbioPrefdir,'dir')
        mkdir(simbioPrefdir);
    end

    try
        save(prefFileName,'preferences');
    catch
        warning('SimBiology:Preferences','A problem occurred while saving the preferences. The preferences were not saved.');
    end


    mb=getModelBuilder;
    if isempty(mb.webWindow)
        r=sbioroot;
        r.SendJSEvents=false;
    end

end

function cleanupOnModelBuilderClose(input)

    saveModelBuilderPreferences(input);

    models=input.sessionIDs;
    for i=1:length(models)
        model=SimBiology.web.modelhandler('getModelFromSessionID',models(i));
        SimBiology.web.modelhandler('turnOffEvents',model);
    end

end

function saveModelBuilderPreferences(input)

    prefFileName=getModelBuilderPreferenceFileName;
    simbioPrefdir=fileparts(prefFileName);

    if~exist(simbioPrefdir,'dir')
        mkdir(simbioPrefdir);
    end

    try
        preferences=struct('preferences',input.preferences);
        save(prefFileName,'preferences');




        if input.modelsLoaded&&isfield(preferences.preferences,'customBlockLibrary')
            simbioBlockLibrariesDir=fullfile(prefdir,'SimBiology','blocklibrary');


            if exist(simbioBlockLibrariesDir,'dir')
                rmdir(simbioBlockLibrariesDir,'s');
            end
        end
    catch
        warning('SimBiology:Preferences','A problem occurred while saving the preferences. The preferences were not saved.');
    end


    mb=getModelAnalyzer;
    if isempty(mb.webWindow)
        r=sbioroot;
        r.SendJSEvents=false;
    end

end

function out=postEventToModelAnalyzer(evt)

    evt=updateEventBeforePostToApp(evt,true);
    message.publish('/SimBiology/builderToAnalyzer',evt);

    out.type=evt.type;

end

function out=postEventToModelBuilder(evt)

    evt=updateEventBeforePostToApp(evt,true);
    message.publish('/SimBiology/analyzerToBuilder',evt);


    if any(strcmp(evt.type,{'showModel','showModelComponent','showModelPage'}))
        mb=getModelBuilder;
        if~isempty(mb.webWindow)
            mb.webWindow.bringToFront;
        end
    end

    out.type=evt.type;

end

function evt=updateEventBeforePostToApp(evt,initDiagramSyntax)

    if strcmp(evt.type,'syncApp')||strcmp(evt.type,'initApp')
        models=evt.models;
        mInfo=struct('name','','obj','','diagramView','','diagramInfo',...
        '','imageFileName','','modelFileName','','info','');
        mInfo=repmat(mInfo,1,length(models));

        for i=1:length(models)
            m=SimBiology.web.modelhandler('getModelFromSessionID',models(i));
            mInfo(i).name=m.Name;
            mInfo(i).obj=m.SessionID;
            mInfo(i).info=SimBiology.web.modelhandler('getModelInfoFromModel',m);







            if~m.hasDiagramSyntax&&initDiagramSyntax
                args=struct('model',m,'viewFile','','projectVersion','');
                SimBiology.web.diagramhandler('initDiagramSyntax',args);
            end
        end

        evt.mInfo=mInfo;
    end

end

function showDoc

    doc simbio

end

function showExamples

    demo('matlab','SimBiology')

end

function showCommunityPage

    webpage='https://www.mathworks.com/matlabcentral/simbiology';


    web(webpage,'-browser','-display');

end

function showContactPage

    webpage='https://www.mathworks.com/products/simbiology/';


    web(webpage,'-browser','-display');

end

function launchDemo(input)

    switch(input.demo)
    case 1
        helpview(strcat(docroot,'\simbio\simbio.map'),'fitting_analyzer_example')
    case 2
        helpview(strcat(docroot,'\simbio\simbio.map'),'scandoses_analyzer_example')
    case 3
        helpview(strcat(docroot,'\simbio\simbio.map'),'sensitivity_analyzer_example')
    end

end

function out=getAboutWindowInfo(action)

    info=ver('simbio');
    out={action,info.Version};

end

function out=getProjectFiles(action)

    h=dir(fullfile(matlabroot,'toolbox','simbio','simbiodemos'));
    names={};
    for i=1:length(h)
        next=h(i).name;
        [~,~,ext]=fileparts(next);
        if strcmpi(ext,'.sbproj')
            names{end+1}=next;%#ok<*AGROW>
        end
    end

    out={action,names};

end

function copyToClipBoard(str)


    if iscell(str)
        str=str{1};
    end


    clipboard('copy',str);

end

function out=getfullpath(name)


    out.id='';
    out.msg='';
    out.fullfilename='';


    [~,~,ext]=fileparts(name);
    if isempty(ext)
        name=[name,'.sbproj'];
    elseif~strcmp(ext,'.sbproj')
        out.id='SimBiology:SIMBIOLOGY_INVALID_FILENAME';
        out.msg='Invalid FILENAME. SIMBIOLOGY supports files with a .sbproj extension.';
        return;
    end


    out.fullfilename=which(name);
    if isempty(out.fullfilename)
        if exist(name,'file')
            out.fullfilename=name;
        else
            filename=strrep(name,'\','\\');
            out.id='SimBiology:SIMBIOLOGY_INVALID_FILENAME';
            out.msg=['Invalid FILENAME. The specified file: ',filename,' could not be found.'];
        end
    end

end

function packageApp(input)

    folder=sbiogate('sbiotempdir');
    name='project.sbproj';
    input.ProjectName=fullfile(folder,name);
    SimBiology.web.projecthandler('saveproject',input);

end

function launchApp

    webpage=['https://',getAppDomain,'/artifacts/'];
    web(webpage,'-browser','-display');

end

function domain=getAppDomain

    domain=getenv('DOMAIN');
    if isempty(domain)
        domain='simbio.volturnus.mwcloudtest.com';
    end

end

function out=addStaticContentOnPath(inputs)

    route=inputs.route;
    pathName=inputs.pathName;
    out=connector.addStaticContentOnPath(route,pathName);

end

function out=runProgramMATLABCalls(action,inputs)

    results=struct;

    for i=1:numel(inputs)
        results(i).programName=inputs{i}.programName;
        steps=inputs{i}.steps;

        stepResults=struct;
        for z=1:numel(steps)
            stepResults(z).stepIndex=steps(z).stepIndex;
            stepResults(z).sections=struct;

            sections=steps(z).sections;
            for j=1:numel(sections)
                stepResults(z).sections(j).sectionIndex=sections(j).sectionIndex;


                handlerInputs=sections(j).args;
                args={sprintf('SimBiology.web.%s',handlerInputs.handler),handlerInputs.action,handlerInputs.args};


                try
                    stepResults(z).sections(j).results=feval(args{:});
                catch
                    stepResults(z).sections(j).results={};
                end
            end
        end
        results(i).steps=stepResults;
    end

    out={action,results};

end

function out=convertfilename(name)

    count=1;
    out='';

    while(count<=length(name))
        if strcmp(name(count),'%')
            code=name(count+1:count+2);
            code=hex2dec(code);
            code=char(code);
            out=[out,code];
            count=count+3;
        else
            out=[out,name(count)];
            count=count+1;
        end
    end

    if~isempty(out)&&strcmp(out(end),'#')
        out=out(1:end-1);
    end



end

function results=getLicenses()

    resultTemplate=struct('name','','installed',false);
    results=repmat(resultTemplate,6,1);


    results(1).name='SimBiology';
    results(1).installed=license('test','SimBiology')==1;
    results(2).name='Distributed';
    results(2).installed=SimBiology.internal.checkForToolbox('parallel');
    results(3).name='Optimization';
    results(3).installed=SimBiology.internal.checkForToolbox('optim');
    results(4).name='Statistics and Machine Learning';
    results(4).installed=SimBiology.internal.checkForToolbox('stats');
    results(5).name='Global Optimization';
    results(5).installed=SimBiology.internal.checkForToolbox('globaloptim');
    results(6).name='Compiler';
    results(6).installed=SimBiology.internal.checkForToolbox('compiler');

end

function webWindow=getWebWindowByTitle(title)

    webWindow=[];
    webWindowList=[];


    if connector.isRunning
        webWindowManager=matlab.internal.webwindowmanager.instance;
        webWindowList=webWindowManager.windowList;
    end


    for i=1:length(webWindowList)
        nextTitle=webWindowList(i).Title;
        nextURL=webWindowList(i).CurrentURL;


        if strncmp(title,nextTitle,length(title))&&~contains(nextURL,'export=1')
            webWindow=webWindowList(i);
            break;
        end
    end

end

function closeAllExportWebWindows

    webWindowList=[];


    if connector.isRunning
        webWindowManager=matlab.internal.webwindowmanager.instance;
        webWindowList=webWindowManager.windowList;
    end


    for i=1:length(webWindowList)
        nextURL=webWindowList(i).CurrentURL;
        if contains(nextURL,'export=1')
            close(webWindowList(i));
        end
    end

end

function out=createFileSpec(input)

    filters=input.fileFilters;
    if~iscell(filters)
        filters={filters};
    end

    fileExtensions='';
    fileDescription='';
    for i=1:length(filters)
        fileExtensions=[fileExtensions,'*.',filters{i},';'];
        fileDescription=[fileDescription,'*.',filters{i},','];
    end

    fileExtensions=fileExtensions(1:end-1);
    fileDescription=[input.fileFilterName,' (',fileDescription(1:end-1),')'];

    out={fileExtensions,fileDescription;'*.*','All Files (*.*)'};

end

function out=getMatFileVariableName(matfileName)

    if exist(matfileName,'file')
        names=SimBiology.internal.getVariableNamesInMatFile(matfileName);
        count=2;
        matfileVariableName='data1';
        derivedVariableName='derived1';

        while any(strcmp(matfileVariableName,names))
            matfileVariableName=['data',num2str(count)];
            derivedVariableName=['derived',num2str(count)];
            count=count+1;
        end
    else
        matfileVariableName='data1';
        derivedVariableName='derived1';
    end

    out=struct;
    out.matfileVariableName=matfileVariableName;
    out.derivedVariableName=derivedVariableName;
end
