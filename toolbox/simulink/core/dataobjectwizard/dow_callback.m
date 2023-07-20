function[varargout]=dow_callback(action,varargin)

















    if isempty(varargin)
        dow=get(gcbf,'UserData');
        assert(dow.fig==gcbf);
    else
        dow=varargin{1};
        varargout{1}=dow;
    end

    switch action
    case{'analyze'}
        model=get(dow.modelNameEdit,'String');
        model=strrep(model,' ','');
        modelName=strtok(model,'.');
        if isempty(modelName)
            err_disp(modelName,'Error','Simulink:dow:SpecifyModelNameEditField');
            return;
        elseif exist(modelName,'file')~=4
            err_disp(modelName,'Error','Simulink:dow:SpecifiedModelDoesNotExistInMatlabPath');
            return;
        else
            dow=clear_table(dow);
            dow.tagField=[modelName,'DataObjectWizard'];
            dow.oldModelName=modelName;
            if isempty(find_system('type','block_diagram','name',modelName))
                open_system(modelName);
            end
            calledFromGUI=true;
            dataList_sl=ec_analyze_model(modelName,calledFromGUI);
            if get(dow.aliastypeChk,'Value')
                if((exist('ec_get_info_for_aliastype','file')==6)||...
                    (exist('ec_get_info_for_aliastype','file')==2))

                    if~isequal(dataList_sl,-1)
                        dataList_alias=ec_get_info_for_aliastype(modelName);
                    else
                        dataList_alias={};
                    end
                else

                    dataList_alias=get_user_type_info_for_aliastype;
                end
            else
                dataList_alias={};
            end

            if isequal(dataList_sl,-1)

                if isempty(dataList_alias)

                    return
                else
                    dataList_sl={};
                end
            end

            if~isempty(dataList_sl)||~isempty(dataList_alias)


                dataList=get_selected_data_list(dow,dataList_sl,dataList_alias);

                dow.dataList=dataList;
                dow=load_data(dow);
                set(dow.ApplyPackage,'Enable','off');
                set(dow.CheckAll,'Enable','on');
                set(dow.UncheckAll,'Enable','on');
                set(dow.Create,'Enable','on');
                headerText=DAStudio.message('Simulink:dow:UnresolvedObjectsDataTypesAnalyzedModel');
                set(dow.topText,'String',headerText);
            else
                err_disp(modelName,'Info','Simulink:dow:ValidSignalsOrPotentialObjects');
            end
        end
    case{'modeledit'}
        if isempty(get(dow.modelNameEdit,'String'))
            set(dow.Analyze,'Enable','off');
            set(dow.ApplyPackage,'Enable','off');
            set(dow.CheckAll,'Enable','off');
            set(dow.UncheckAll,'Enable','off');
            set(dow.Create,'Enable','off');
            dow=clear_table(dow);
            headerText=DAStudio.message('Simulink:dow:UI_FigureHeader');
            set(dow.topText,'String',headerText);
        else
            set(dow.Analyze,'Enable','on');
        end
    case{'checkall'}
        for i=1:length(dow.chk)
            set(dow.chk(i),'Value',1);
        end
        set(dow.Create,'Enable','on');
        set(dow.ApplyPackage,'Enable','on');

    case{'uncheckall'}
        for i=1:length(dow.chk)
            set(dow.chk(i),'Value',0);
        end
        set(dow.ApplyPackage,'Enable','off');

    case{'cancel'}
        if dow.addPath==1
            rmpath(dow.modelPath);
        end
        close(dow.fig);
        return;
    case{'create','apply'}

        hw=waitbar(0,DAStudio.message('Simulink:dow:CreatingDataObjectsAndDataTypes'));
        createdObjects='';
        objectCreated=false;
        signalObjectsCreated={};
        modelName=strrep(dow.tagField,'DataObjectWizard','');
        dvStage=modelName;
        aliasMisMatch={};
        for i=1:length(dow.chk)
            if get(dow.chk(i),'Value')==1
                newObjectType=get(dow.type(i),'String');
                fullClassName=get(dow.fullClassName(i),'String');

                createdObjects{end+1}=dow.dataList{i}.name;%#ok
                if strcmp(newObjectType,'Parameter')==1
                    create_object_param(modelName,char(fullClassName),dow.dataList{i});
                elseif strcmp(newObjectType,'Signal')==1
                    create_object_signal(modelName,char(fullClassName),dow.dataList{i});
                    signalObjectsCreated{end+1,1}=dow.dataList{i};%#ok
                elseif strcmp(newObjectType,'AliasType')==1
                    mismatch=create_object_aliastype(modelName,dow.dataList{i});
                    if~isempty(mismatch)
                        aliasMisMatch{end+1}=mismatch;%#ok
                    end
                else
                    dvStage=err_disp(dvStage,'Error',...
                    'Simulink:dow:ObjectTypeUnsupportedClassType',newObjectType);
                end
                objectCreated=1;


                if ishghandle(hw);waitbar((i/(length(dow.dataList)+1)),hw);end
            end
        end
        aliasMisMatch=unique(aliasMisMatch);
        if~isempty(aliasMisMatch)

            str=cellstr2str(aliasMisMatch);
            dvStage=err_disp(dvStage,'Warning',...
            'Simulink:dow:FollowingDataTypeInconsistentWithExistingObjects',...
            'Simulink.AliasType','Simulink.NumericType',str);%#ok<NASGU>
        end


        if objectCreated


            if~isempty(signalObjectsCreated)
                signalResControl=get_param(modelName,'SignalResolutionControl');
                assert(~isequal(signalResControl,'None'));
                explicitResolutionOnly=strcmp(signalResControl,'UseLocalSettings');
                if explicitResolutionOnly
                    l_set_must_resolve(modelName,signalObjectsCreated);
                end
            end


            if isequal(action,'create')
                dataList='';
                for i=1:length(dow.dataList)
                    dataList{i}=dow.dataList{i}.name;
                end
                leftData='';
                [~,idx]=setdiff(dataList,createdObjects);
                [~,idxx]=sort(idx);
                for i=1:length(idxx)
                    leftData{end+1}=dow.dataList{idx(idxx(i))};%#ok
                end
                dow.dataList=leftData;
                dow=load_data(dow);
                if isempty(leftData)==1
                    set(dow.ApplyPackage,'Enable','off');
                    set(dow.CheckAll,'Enable','off');
                    set(dow.UncheckAll,'Enable','off');
                    set(dow.Create,'Enable','off');
                    headerText=DAStudio.message('Simulink:dow:UI_FigureHeader');
                    set(dow.topText,'String',headerText);
                end
            end
        end


        if ishghandle(hw)
            waitbar(1,hw);
            close(hw);
        end

        clear dvStage;

    case{'check'}
        if isAnySelected(dow)
            set(dow.ApplyPackage,'Enable','on');
        else
            set(dow.ApplyPackage,'Enable','off');
        end

    case{'applypackage'}
        defaultString=get(dow.Package,'String');
        index=get(dow.Package,'Value');
        defaultClass=defaultString{index};
        modelName=regexprep(dow.tagField,'DataObjectWizard','');
        dvStage=modelName;
        for i=1:length(dow.class)
            if get(dow.chk(i),'Value')==1
                if(class_check(i,defaultClass,dow)==1)
                    if strcmp(get(dow.type(i),'String'),'AliasType')
                        set(dow.class(i),'String','');
                    else
                        set(dow.class(i),'String',defaultClass);
                    end
                    set(dow.class(i),'BackgroundColor',dow.defaultColor);
                    set(dow.chk(i),'BackgroundColor',dow.chkColor);
                    set(dow.nameTxt(i),'BackgroundColor',dow.defaultColor);
                    set(dow.type(i),'BackgroundColor',dow.defaultColor);
                else
                    txtStr=get(dow.nameTxt(i),'String');
                    dvStage=err_disp(dvStage,'Warning',...
                    'Simulink:dow:DoesNotSupportRequestedClassType',...
                    defaultClass,txtStr);
                    set(dow.chk(i),'BackgroundColor',dow.chkColor);
                    set(dow.nameTxt(i),'BackgroundColor',dow.defaultErrorColor);
                    set(dow.type(i),'BackgroundColor',dow.defaultErrorColor);
                    set(dow.class(i),'BackgroundColor',dow.defaultErrorColor);
                end
            end
        end

        clear dvStage;

    case{'applyClass'}
        parameterClass=varargin{2};
        signalClass=varargin{3};


        for i=1:length(dow.type)
            if get(dow.chk(i),'Value')==1
                if strcmp(get(dow.type(i),'String'),'AliasType')
                    set(dow.fullClassName(i),'String','AliasType');
                elseif strcmp(get(dow.type(i),'String'),'Signal')
                    set(dow.fullClassName(i),'String',signalClass);
                elseif strcmp(get(dow.type(i),'String'),'Parameter')
                    set(dow.fullClassName(i),'String',parameterClass);
                end
                set(dow.chk(i),'BackgroundColor',dow.chkColor);
                set(dow.nameTxt(i),'BackgroundColor',dow.defaultColor);
                set(dow.fullClassName(i),'BackgroundColor',dow.defaultColor);
            end
        end

    case{'changeClass'}
        dlgSrc=Simulink.data.ChangeDefaultClassDDG(dow);
        DAStudio.Dialog(dlgSrc,'','DLG_STANDALONE');

    case{'slider'}
        refPos=get(dow.TitleFrame1,'Position');
        numDataObjects=length(dow.chk);
        sliderStep=1/numDataObjects;
        sliderMove=1-get(dow.Slider,'Value');
        delta=floor(sliderMove/sliderStep);

        if delta==0
            delta=1;
        end

        if delta<=(numDataObjects-dow.viewItems)
            status='off';
            for i=1:(delta-1)
                set(dow.chk(i),'Visible',status);
                set(dow.nameTxt(i),'Visible',status);
                set(dow.type(i),'Visible',status);
                set(dow.class(i),'Visible',status);
                updateWidget(dow,i,'off')
            end
            if(delta+dow.viewItems-1)<=numDataObjects
                status='on';
                for i=delta:(delta+dow.viewItems-1)
                    rPos=[12...
                    ,refPos(2)-((i-delta+1)*dow.defaultBoxHeight-1)...
                    ,17...
                    ,dow.defaultBoxHeight-1];
                    set(dow.chk(i),'Visible',status);
                    set(dow.chk(i),'Position',rPos);

                    rPos=[30,rPos(2),165,rPos(4)];
                    set(dow.nameTxt(i),'Visible',status);
                    set(dow.nameTxt(i),'Position',rPos);

                    rPos=[294,rPos(2),112,rPos(4)];
                    set(dow.type(i),'Visible',status);
                    set(dow.type(i),'Position',rPos);

                    rPos=[404,rPos(2),90,rPos(4)];
                    set(dow.class(i),'Visible',status);
                    set(dow.class(i),'Position',rPos);

                    rPos=[300,rPos(2),200,rPos(4)];
                    set(dow.fullClassName(i),'Visible',status);
                    set(dow.fullClassName(i),'Position',rPos);

                    updateWidget(dow,i,status);
                end
                status='off';
                for i=(delta+dow.viewItems):numDataObjects
                    set(dow.chk(i),'Visible',status);
                    set(dow.nameTxt(i),'Visible',status);
                    set(dow.type(i),'Visible',status);
                    set(dow.class(i),'Visible',status);
                    updateWidget(dow,i,status);
                end
            end
        else
            status='off';
            for i=1:(numDataObjects-dow.viewItems)
                set(dow.chk(i),'Visible',status);
                set(dow.nameTxt(i),'Visible',status);
                set(dow.type(i),'Visible',status);
                set(dow.class(i),'Visible',status);
                updateWidget(dow,i,status);
            end
            status='on';
            for i=(numDataObjects-dow.viewItems+1):(numDataObjects)
                rPos=[12...
                ,refPos(2)-(i-(numDataObjects-dow.viewItems))*dow.defaultBoxHeight-1...
                ,17...
                ,dow.defaultBoxHeight-1];
                set(dow.chk(i),'Visible',status);
                set(dow.chk(i),'Position',rPos);

                rPos=[30,rPos(2),165,rPos(4)];
                set(dow.nameTxt(i),'Visible',status);
                set(dow.nameTxt(i),'Position',rPos);

                rPos=[294,rPos(2),112,rPos(4)];
                set(dow.type(i),'Visible',status);
                set(dow.type(i),'Position',rPos);

                rPos=[404,rPos(2),90,rPos(4)];
                set(dow.class(i),'Visible',status);
                set(dow.class(i),'Position',rPos);

                rPos=[300,rPos(2),200,rPos(4)];
                set(dow.fullClassName(i),'Visible',status);
                set(dow.fullClassName(i),'Position',rPos);

                updateWidget(dow,i,status);
            end
        end

    case{'help'}
        helpview([docroot,'/mapfiles/simulink.map'],'data_objs_wizard');

    case{'browse'}
        dlgTitle=DAStudio.message('Simulink:modelReference:browseMdlRefsName');
        [filename,pathname]=uigetfile('*.mdl; *.slx',dlgTitle);
        if isequal(filename,0)||isequal(pathname,0)
            return;
        else
            fullfilename=filename;
            filename=strtok(filename,'.');
            set(dow.modelNameEdit,'String',filename);
            set(dow.Analyze,'Enable','on');
            dow.modelPath=pathname;
            if exist(fullfilename,'file')~=4

                addpath(pathname);
                dow.addPath=1;
            end
        end
    case{'contextmenu'}
        ind=str2double(indx);
        set(dow.class(ind),'String',class);
        set(dow.class(ind),'BackgroundColor',dow.defaultColor);
        set(dow.chk(ind),'BackgroundColor',dow.chkColor);
        set(dow.nameTxt(ind),'BackgroundColor',dow.defaultColor);
        set(dow.nameTxt2(ind),'BackgroundColor',dow.defaultColor);
        set(dow.type(ind),'BackgroundColor',dow.defaultColor);
        set(dow.fullClassName(ind),'BackgroundColor',dow.defaultColor);

    case{'setscchk'}
    case{'setresolutionchk'}




        if get(dow.setResolutionChk,'Value')==1
            set(dow.setSCChk,'Value',1);
            set(dow.setSCChk,'Enable','off');
        else
            set(dow.setSCChk,'Enable','on');
        end
    otherwise
    end
    set(dow.fig,'UserData',dow);

    if~isempty(varargin)
        varargout{1}=dow;
    end


    function dow=load_data(dow)


        dataList=dow.dataList;
        dow=clear_table(dow);

        dh=50;

        refPos=get(dow.TitleFrame1,'Position');

        visible='on';
        enable='on';

        [paramList,paramIndex]=Simulink.data.findValidClasses('Parameter');
        fullParamClassName=paramList{paramIndex+1};
        [signalList,signalIndex]=Simulink.data.findValidClasses('Signal');
        fullSignalClassName=signalList{signalIndex+1};

        for i=1:length(dataList)
            if i>dow.viewItems
                visible='off';
                enable='on';
            end


            pos=[12,refPos(2)-(i*dow.defaultBoxHeight-1)...
            ,17,dow.defaultBoxHeight-1];
            dow.chk(i)=uicontrol('Parent',dow.fig,...
            'Style','CheckBox',...
            'BackGroundColor',dow.chkColor,...
            'Callback','dow_callback(''check'');',...
            'SelectionHighlight','off',...
            'Visible',visible,...
            'Units','pixels',...
            'Enable',enable,...
            'Position',pos);


            pos=[30,refPos(2)-(i*dow.defaultBoxHeight-1)...
            ,164,dow.defaultBoxHeight-1];
            dow.nameTxt(i)=uicontrol('Parent',dow.fig,...
            'Style','Text',...
            'HorizontalAlignment','Left',...
            'BackGroundColor',dow.defaultColor,...
            'String',dataList{i}.name,...
            'Visible',visible,...
            'Units','pixels',...
            'Enable',enable,...
            'Position',pos);


            if strcmp(dataList{i}.type,'Signal')
                typeString='Signal';
            elseif strcmp(dataList{i}.type,'Parameter')
                typeString='Parameter';
            elseif strcmp(dataList{i}.type,'AliasType')||strcmp(dataList{i}.type,'NumericType')
                typeString='AliasType';
            end

            if strcmp(typeString,'Parameter')
                fullClassName=fullParamClassName;
            elseif strcmp(typeString,'Signal')
                fullClassName=fullSignalClassName;
            else
                fullClassName=typeString;
            end


            typeVisibility='off';
            pos=[294,refPos(2)-(i*dow.defaultBoxHeight-1)...
            ,112,dow.defaultBoxHeight-1];
            dow.type(i)=uicontrol('Parent',dow.fig,...
            'Style','Text',...
            'ButtonDownFcn','',...
            'HorizontalAlignment','center',...
            'BackGroundColor',dow.defaultColor,...
            'String',typeString,...
            'Visible',typeVisibility,...
            'Units','pixels',...
            'Enable',enable,...
            'Position',pos,...
            'Value',1);


            pkgVisibility='off';
            pos=[404,refPos(2)-(i*dow.defaultBoxHeight-1)...
            ,90,dow.defaultBoxHeight-1];
            if strcmp(typeString,'AliasType')
                classString='';
            else
                classString=dow.objectList(1).class;
            end
            dow.class(i)=uicontrol('Parent',dow.fig,...
            'Style','Text',...
            'ButtonDownFcn','',...
            'HorizontalAlignment','center',...
            'BackGroundColor',dow.defaultColor,...
            'String',classString,...
            'Visible',pkgVisibility,...
            'Units','pixels',...
            'Enable',enable,...
            'Position',pos,...
            'Value',1);


            fullNamePos=[300,refPos(2)-(i*dow.defaultBoxHeight-1)...
            ,200,dow.defaultBoxHeight-1];
            dow.fullClassName(i)=uicontrol('Parent',dow.fig,...
            'Style','Text',...
            'ButtonDownFcn','',...
            'HorizontalAlignment','center',...
            'BackGroundColor',dow.defaultColor,...
            'String',fullClassName,...
            'Visible',visible,...
            'Units','pixels',...
            'Enable',enable,...
            'Position',fullNamePos,...
            'Value',1);

        end

        if length(dataList)>=dow.viewItems+1
            dow.minStepSize=0.06;
            dow.maxStepSize=1.2*dow.minStepSize;



            dow.Slider=uicontrol('Parent',dow.fig,...
            'Style','Slider',...
            'BackGroundColor',dow.defaultColor,...
            'Callback','dow_callback(''slider'');',...
            'Visible','on',...
            'Units','pixels',...
            'Enable','on',...
            'SliderStep',[dow.minStepSize,dow.maxStepSize],...
            'Position',[546-15,126+dh,15,323],...
            'Value',1.0);
        end


        function create_object_param(modelName,className,dataInfo)



            assert(existsInGlobalScope(modelName,dataInfo.name)==1);

            var=evalinGlobalScope(modelName,dataInfo.name);

            tmpObj=feval(className);

            try
                tmpObj.Value=var;
            catch e %#ok

                assert(false,'Invalid numeric variables should have been removed during analysis');
                return;
            end


            assigninGlobalScope(modelName,dataInfo.name,tmpObj);


            function create_object_signal(modelName,className,dataInfo)



                if existsInGlobalScope(modelName,dataInfo.name)
                    return;
                end

                tmpObj=feval(className);
                tmpObj.DataType=l_get_data_type_string(modelName,dataInfo.datatype);
                tmpObj.Dimensions=dataInfo.dimensions;


                assigninGlobalScope(modelName,dataInfo.name,tmpObj);


                function out=class_check(index,className,dow)


                    out=0;
                    typeSelected=get(dow.type(index),'String');
                    if strcmp(typeSelected,'AliasType')
                        out=1;
                        return;
                    end
                    for i=1:length(dow.objectList)
                        if(strcmp(dow.objectList(i).class,className)==1)
                            types=dow.objectList(i).type;
                            for ix=1:length(types)
                                if strcmp(types{ix},typeSelected)
                                    out=1;
                                    return
                                end
                            end
                        end
                    end


                    function dvStage=err_disp(context,msgType,msgID,varargin)









                        if isequal(context,'')


                            dvStage=err_disp('Diagnostics',msgType,msgID,varargin{:});
                        else

                            title=DAStudio.message('Simulink:dow:UI_FigureTitle');
                            msg=DAStudio.message(msgID,varargin{:});



                            if ischar(context)
                                dvStage=sldiagviewer.createStage(title,'ModelName',context);
                            else
                                assert(isa(context,'Simulink.output.Stage'));
                                dvStage=context;
                            end

                            if isequal(msgType,'Error')
                                sldiagviewer.reportError(msg,'MessageId',msgID);
                            else
                                fcnName=['sldiagviewer.report',msgType];
                                feval(fcnName,msg,'MessageId',msgID);
                                sldiagviewer.reportError('');
                            end
                        end


                        function dataList=get_selected_data_list(dow,dataList_sl,dataList_alias)



                            dataList={};
                            for i=1:length(dataList_sl)
                                if isSelectedSRC(dataList_sl{i}.datasource,dataList_sl{i}.type,dow)
                                    dataList{end+1}=dataList_sl{i};%#ok
                                end
                            end

                            if~isempty(dataList_alias)&&get(dow.aliastypeChk,'Value')
                                dataList=[dataList,dataList_alias];
                            end


                            function isSelected=isSelectedSRC(dataSource,type,dow)


                                isSelected=true;
                                switch lower(dataSource)
                                case 'internal'
                                    if~get(dow.blockoChk,'Value')
                                        isSelected=false;
                                    end
                                case 'rootinput'
                                    if~get(dow.rootiChk,'Value')
                                        isSelected=false;
                                    end
                                case 'rootoutput'
                                    if~get(dow.rootoChk,'Value')
                                        isSelected=false;
                                    end
                                case 'state'
                                    if~get(dow.stateChk,'Value')
                                        isSelected=false;
                                    end
                                case 'datastore'
                                    if~get(dow.datastoreChk,'Value')
                                        isSelected=false;
                                    end
                                otherwise
                                    if strcmp(type,'Parameter')
                                        if~get(dow.paramChk,'Value')
                                            isSelected=false;
                                        end
                                    elseif strcmp(type,'AliasType')
                                        if~get(dow.aliastypeChk,'Value')
                                            isSelected=false;
                                        end
                                    else

                                        isSelected=true;
                                    end
                                end


                                function dow=clear_table(dow)


                                    if isempty(dow.nameTxt)==0
                                        delete(dow.chk);
                                        delete(dow.nameTxt);
                                        delete(dow.type);
                                        delete(dow.class);
                                        dow.chk=[];
                                        dow.nameTxt=[];
                                        dow.type=[];
                                        dow.class=[];
                                        delete(dow.fullClassName);
                                        dow.fullClassName=[];

                                        if isfield(dow,'Slider')&&ishandle(dow.Slider)
                                            delete(dow.Slider);
                                            dow.Slider=[];
                                        end
                                        set(dow.fig,'UserData',dow);
                                    end


                                    function l_set_must_resolve(modelName,signalObjectsCreated)

                                        for idx=1:length(signalObjectsCreated)
                                            signalInfo=signalObjectsCreated{idx};
                                            signalName=signalInfo.name;

                                            switch signalInfo.datasource
                                            case{'RootInput','RootOutput','Internal'}
                                                setOnPort=true;


                                                srcBlk=signalInfo.sourceblock;
                                                actualSrcBlk=srcBlk;
                                                try
                                                    srcObj=get_param(srcBlk,'Object');
                                                catch

                                                    srcObj=[];
                                                end
                                                if(~isempty(srcObj)&&...
                                                    strcmp(srcObj.Type,'block')&&...
                                                    strcmp(srcObj.BlockType,'SubSystem')&&...
                                                    strcmp(srcObj.SFBlockType,'Chart'))

                                                    rt=sfroot;
                                                    m=rt.find('-isa','Simulink.BlockDiagram','-and','Name',modelName);
                                                    chart=m.find('-isa','Stateflow.Chart','-and','Path',srcBlk);
                                                    data=chart.find('-isa','Stateflow.Data','-and','Scope','Output',...
                                                    '-and','Name',signalName,'-and','Path',srcObj.getFullName);
                                                    if~isempty(data)


                                                        assert(data.Props.ResolveToSignalObject==false);
                                                        data.Props.ResolveToSignalObject=true;
                                                        setOnPort=false;
                                                    end
                                                end


                                                if setOnPort



                                                    ports=find_system(modelName,'Findall','on','LookUnderMasks','on',...
                                                    'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
                                                    'Type','port','Name',signalName);
                                                    assert(~isempty(ports));

                                                    parents=get_param(ports,'Parent');
                                                    sourcePort=ports(strcmp(parents,actualSrcBlk));
                                                    if isempty(sourcePort)


                                                        for portIdx=1:length(ports)
                                                            assert(strcmp(get_param(ports(portIdx),'MustResolveToSignalObject'),'off'));
                                                            set_param(ports(portIdx),'MustResolveToSignalObject','on');
                                                        end
                                                    else






                                                        assert(isscalar(sourcePort));

                                                        assert(strcmp(get_param(sourcePort,'MustResolveToSignalObject'),'off'));
                                                        set_param(sourcePort,'MustResolveToSignalObject','on');
                                                    end
                                                end

                                            case{'State','DataStore'}
                                                blk=signalInfo.sourceblock;
                                                assert(strcmp(get_param(blk,'StateMustResolveToSignalObject'),'off'));
                                                set_param(blk,'StateMustResolveToSignalObject','on');

                                            case 'Stateflow'
                                                rt=sfroot;
                                                m=rt.find('-isa','Simulink.BlockDiagram','-and','Name',modelName);
                                                chart=m.find('-isa','Stateflow.Chart','-and','Path',signalInfo.sourceblock);
                                                data=chart.find('-isa','Stateflow.Data','-and','Scope','Local','-and','Name',signalName);
                                                assert(data.Props.ResolveToSignalObject==false);
                                                data.Props.ResolveToSignalObject=true;

                                            otherwise
                                                assert(false,'Unexpected data source');
                                            end

                                        end


                                        function updateWidget(dow,i,status)
                                            set(dow.type(i),'Visible','off');
                                            set(dow.class(i),'Visible','off');
                                            set(dow.fullClassName(i),'Visible',status);



                                            function isTrue=isAnySelected(dow)
                                                isTrue=0;
                                                for i=1:length(dow.chk)
                                                    if get(dow.chk(i),'Value')==1
                                                        isTrue=1;
                                                        break;
                                                    end
                                                end


                                                function dataTypeStr=l_get_data_type_string(modelName,dataTypeStr)

                                                    builtinDataTypes=Simulink.DataTypePrmWidget.getBuiltinListForDataObjects('AliasType');


                                                    if ismember(dataTypeStr,builtinDataTypes)
                                                        return;
                                                    end


                                                    if Simulink.data.isSupportedEnumClass(dataTypeStr)
                                                        dataTypeStr=['Enum: ',dataTypeStr];
                                                        return;
                                                    end

                                                    if existsInGlobalScope(modelName,dataTypeStr)

                                                        dtObj=evalinGlobalScope(modelName,dataTypeStr);
                                                        if isa(dtObj,'Simulink.Bus')
                                                            dataTypeStr=['Bus: ',dataTypeStr];
                                                        end
                                                        return;
                                                    end


                                                    assert(strcmp(dataTypeStr(1:4),'sfix')||...
                                                    strcmp(dataTypeStr(1:4),'ufix'));
                                                    dataTypeStr=['fixdt(''',dataTypeStr,''')'];


