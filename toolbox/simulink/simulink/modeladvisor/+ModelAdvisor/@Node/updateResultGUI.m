function varargout=updateResultGUI(thisNode,varargin)




    informer=thisNode.MAObj.ResultGUI;


    if(nargin>1)&&strcmpi(varargin{1},'get')
        varargout{1}=informer;
        return
    end


    if strcmp(thisNode.MAObj.Stage,'InitMAExplorer')
        return
    end



    if~(strcmp(thisNode.MAObj.TaskAdvisorRoot.ID,'SysRoot')||strcmp(thisNode.MAObj.TaskAdvisorRoot.ID,'CommandLineRun'))
        return
    end



    if~thisNode.MAObj.ShowInformer
        if~isempty(thisNode.MAObj.MAExplorer)||thisNode.MAObj.parallel
            thisNode.MAObj.ResultMap=containers.Map;
            if isa(thisNode,'ModelAdvisor.Task')
                if thisNode.MACIndex>0
                    checkobj=thisNode.Check;

                    if checkobj.SupportHighlighting
                        resultdata=checkobj.ProjectResultData;
                        for i=1:length(resultdata)
                            blkSID=resultdata{i};
                            thisNode.MAObj.ResultMap(blkSID)={checkobj.ID,checkobj.Title};
                        end
                    end
                end
            elseif isa(thisNode,'ModelAdvisor.Group')
                allTaskNodes=thisNode.getAllChildren;
                for j=1:length(allTaskNodes)
                    if isa(allTaskNodes{j},'ModelAdvisor.Task')
                        checkobj=allTaskNodes{j}.Check;
                        if isa(checkobj,'ModelAdvisor.Check')&&checkobj.SupportHighlighting
                            resultdata=checkobj.ProjectResultData;
                            for i=1:length(resultdata)
                                blkSID=resultdata{i};
                                if thisNode.MAObj.ResultMap.isKey(blkSID)
                                    thisNode.MAObj.ResultMap(blkSID)=[thisNode.MAObj.ResultMap(blkSID),checkobj.ID,checkobj.Title];
                                else
                                    thisNode.MAObj.ResultMap(blkSID)={checkobj.ID,checkobj.Title};
                                end
                            end
                        end
                    end
                end
            end
        end
        return;
    end




    modeladvisorprivate('modeladvisorutil2','ClearHighlitedResultObjs');

    if isempty(informer)||~isa(informer,'DAStudio.Informer')
        slprivate('remove_hilite',bdroot(thisNode.MAObj.System));
        informer=DAStudio.Informer;
        informer.mode='ClickMode';
        informer.title=[DAStudio.message('ModelAdvisor:engine:MAHighlighting'),' - ',thisNode.MAObj.SystemName];

        modelLocation=get_param(bdroot(thisNode.MAObj.System),'Location');
        informer.position=[modelLocation(1),modelLocation(4)+20,modelLocation(4)-modelLocation(2)-30,150];
        informer.preCloseFcn=['modeladvisorprivate(''modeladvisorutil2'',''CloseResultGUI'',''',thisNode.MAObj.SystemName,''')'];
        informer.defaultText=' ';
        informer.filePath={''};
        informer.alwaysOnTop=true;informer.alwaysOnTop=false;

        screenSize=get(0,'ScreenSize');
        height=screenSize(4);
        width=screenSize(3);
        if(informer.position(1)>width-100)
            informer.position=[width-100,informer.position(2),informer.position(3),informer.position(4)];
        end
        if(informer.position(2)>height-100)
            informer.position=[informer.position(1),height-100,informer.position(3),informer.position(4)];
        end

        thisNode.MAObj.ResultGUI=informer;
        thisNode.updateStates('refreshME');
        set_param(bdroot(thisNode.MAObj.System),'HiliteAncestors','fade');
        fade_sf_charts(bdroot(thisNode.MAObj.SystemName));

    else
        set_param(bdroot(thisNode.MAObj.System),'HiliteAncestors','fade');
    end

    thisNode.MAObj.ProjectResultMapData=containers.Map;
    thisNode.MAObj.ResultMap=containers.Map;

    resultdata={};%#ok<NASGU>

    if isa(thisNode,'ModelAdvisor.Task')
        CheckIDs={thisNode.MAC};
    else
        evalc('CheckIDs = Simulink.ModelAdvisor.getID;');
        CheckIDs=unique(CheckIDs);%#ok<NODEF>
    end


    editor=GLUE2.Util.findAllEditors(thisNode.MAObj.SystemName);
    fullMessage=['<a href="matlab: slCfgPrmDlg ',thisNode.MAObj.ModelName,' Open;">',DAStudio.message('ModelAdvisor:engine:CheckFailedOpenConfigParamDlg',thisNode.getDisplayLabel),'</a>'];
    if~isempty(editor)
        if isa(thisNode,'ModelAdvisor.Task')
            if ModelAdvisor.internal.isConfigSetCheck(thisNode.MAC)
                if(thisNode.State>=ModelAdvisor.CheckStatus.Warning)
                    editor.deliverInfoNotification('modeladvisor.highlight.openconfigset',fullMessage);
                else
                    editor.closeNotificationByMsgID('modeladvisor.highlight.openconfigset');
                end

            end
        else
            editor.closeNotificationByMsgID('modeladvisor.highlight.openconfigset');
        end
    end

    waitbarThreshold=50;
    hWait=-1;


    counterStructure=modeladvisorprivate('modeladvisorutil2','getNodeSummaryInfo',thisNode);
    if isempty(deblank(thisNode.getDisplayIcon))
        imagepath=fullfile(matlabroot,'toolbox','simulink','simulink','modeladvisor','private');
    else
        imagepath=fileparts(fullfile(matlabroot,thisNode.getDisplayIcon));
    end

    statusIcon=ModelAdvisor.Image;
    statusIcon.setImageSource(fullfile(matlabroot,thisNode.getDisplayIcon));
    passedIcon=ModelAdvisor.Image;
    passedIcon.setImageSource(fullfile(imagepath,'task_passed.png'));
    failedIcon=ModelAdvisor.Image;
    failedIcon.setImageSource(fullfile(imagepath,'task_failed.png'));
    warnIcon=ModelAdvisor.Image;
    warnIcon.setImageSource(fullfile(imagepath,'task_warning.png'));
    nrunIcon=ModelAdvisor.Image;
    nrunIcon.setImageSource(fullfile(imagepath,'icon_task.png'));
    informerIcon=ModelAdvisor.Image;
    informerIcon.setImageSource(fullfile(imagepath,'info_icon.png'));



    if isa(thisNode,'ModelAdvisor.Group')
        titleMsg=thisNode.getDisplayLabel;
        parentNode=thisNode.getParent;
        while~isempty(parentNode)&&~isempty(parentNode.getParent)
            titleMsg=[parentNode.getDisplayLabel,' > ',titleMsg];%#ok<AGROW>
            parentNode=parentNode.getParent;
        end
    else
        titleMsg=thisNode.getDisplayLabel;
    end
    if strcmp(thisNode.ID,'SysRoot')
        informer.defaultText=['&nbsp;<b><font color="black">',titleMsg,'</font></b>'];
    else
        informer.defaultText=[statusIcon.emitHTML,'&nbsp;<b><font color="black">',titleMsg,'</font></b>'];
    end

    linkObj=ModelAdvisor.Text(DAStudio.message('ModelAdvisor:engine:InformerOpenResults'));
    linkObj.setHyperlink(['matlab: modeladvisorprivate(''modeladvisorutil2'',''BringMAToForeground'',''',num2str(thisNode.Index),''');']);
    informer.defaultText=[informer.defaultText,'&nbsp;&nbsp;&nbsp;',linkObj.emitHTML];
    if isa(thisNode,'ModelAdvisor.Group')
        informer.defaultText=[informer.defaultText,'<p/>'];
        informer.defaultText=[informer.defaultText,passedIcon.emitHTML,'&nbsp;',DAStudio.message('Simulink:tools:MAPass'),': ',num2str(counterStructure.passCt),'&nbsp;&nbsp;&nbsp;'];
        informer.defaultText=[informer.defaultText,failedIcon.emitHTML,'&nbsp;',DAStudio.message('Simulink:tools:MAFail'),': ',num2str(counterStructure.failCt),'&nbsp;&nbsp;&nbsp;'];
        informer.defaultText=[informer.defaultText,warnIcon.emitHTML,'&nbsp;',DAStudio.message('Simulink:tools:MAWarning'),': ',num2str(counterStructure.warnCt),'&nbsp;&nbsp;&nbsp;'];
        informer.defaultText=[informer.defaultText,nrunIcon.emitHTML,'&nbsp;',DAStudio.message('Simulink:tools:MANotRunMsg'),': ',num2str(counterStructure.nrunCt),'&nbsp;&nbsp;&nbsp;'];
    else
        if isa(thisNode,'ModelAdvisor.Task')&&(thisNode.MACIndex>0)&&isempty(thisNode.Check.ProjectResultData)
            if counterStructure.nrunCt>0
                informer.defaultText=[informer.defaultText,'<p/>'];
                informer.defaultText=[informer.defaultText,informerIcon.emitHTML,' ',DAStudio.message('ModelAdvisor:engine:MAResultsUnavailable')];
            elseif(counterStructure.failCt>0)||(counterStructure.warnCt>0)
                informer.defaultText=[informer.defaultText,'<p/>'];
                informer.defaultText=[informer.defaultText,informerIcon.emitHTML,' ',DAStudio.message('ModelAdvisor:engine:MAHighlightingUnavailable')];
            end
        end
    end


    if thisNode.MAObj.ShowCheckResultsOnGUI
        if isa(thisNode,'ModelAdvisor.Task')
            if thisNode.MACIndex>0
                checkobj=thisNode.Check;
                resultdata=checkobj.ProjectResultData;
                resultdata=unique(resultdata);
                needWaitbar=length(resultdata)>waitbarThreshold;
                if needWaitbar
                    hWait=waitbar(0,DAStudio.message('ModelAdvisor:engine:HighlitingCheckResults'),'Name',DAStudio.message('Simulink:tools:MAPleaseWait'),'CreateCancelBtn','modeladvisorprivate(''modeladvisorutil2'',''CloseResultGUI'')');
                end
                for i=1:length(resultdata)


                    if loc_cancelRequested(thisNode.MAObj)
                        loc_cancelHighlighting(hWait);
                        return
                    end

                    blkSID=resultdata{i};
                    try
                        h=Simulink.ID.getHandle(blkSID);%#ok<NASGU>
                    catch %#ok<CTCH>
                        continue;
                    end
                    if needWaitbar
                        if strcmp(thisNode.MAObj.memenus.ShowInformerGUI.on,'off')
                            break
                        end
                        i_waitbar(i/length(resultdata),hWait,DAStudio.message('ModelAdvisor:engine:HighlitingCheckResults'));
                    end

                    overlayBlocks(thisNode.MAObj,informer,blkSID,'default',checkobj.ID,checkobj.Title,thisNode.Index);

                    thisNode.MAObj.ResultMap(blkSID)={checkobj.ID,checkobj.Title};
                end
            end
        elseif isa(thisNode,'ModelAdvisor.Group')
            allTaskNodes=thisNode.getAllChildren;


            allresultdata=0;
            listOfFailedChecks='';
            failedCheckCount=0;
            for j=1:length(allTaskNodes)
                if allTaskNodes{j}.MACIndex>0
                    checkobj=allTaskNodes{j}.Check;
                    resultdata=checkobj.ProjectResultData;
                    resultdata=unique(resultdata);
                    allresultdata=allresultdata+length(resultdata);
                    if isempty(resultdata)&&(allTaskNodes{j}.State>=ModelAdvisor.CheckStatus.Warning)
                        if~allTaskNodes{j}.Failed
                            linkObj=ModelAdvisor.Text(allTaskNodes{j}.DisplayName);
                            NodeIndexStr=num2str(allTaskNodes{j}.Index);
                            linkObj.setHyperlink(['matlab: modeladvisorprivate(''modeladvisorutil2'',''BringMAToForeground'',''',NodeIndexStr,''');']);
                            listOfFailedChecks=[listOfFailedChecks,'<li>',linkObj.emitHTML,'</li>'];%#ok<AGROW>
                            failedCheckCount=failedCheckCount+1;
                        end
                    end
                end
            end
            if~isempty(listOfFailedChecks)
                informer.defaultText=[informer.defaultText,'<br/><br/>',DAStudio.message('ModelAdvisor:engine:SystemViolatedXChecks',thisNode.MAObj.SystemName,num2str(failedCheckCount)),'<ul>',listOfFailedChecks,'</ul>'];
            end
            needWaitbar=allresultdata>waitbarThreshold;
            if needWaitbar
                hWait=waitbar(0,DAStudio.message('ModelAdvisor:engine:HighlitingCheckResults'),'Name',DAStudio.message('Simulink:tools:MAPleaseWait'),'CreateCancelBtn','modeladvisorprivate(''modeladvisorutil2'',''CancelHighlighting'')');
            end

            counter=0;
            visitedChecks=[];
            for j=1:length(allTaskNodes)

                if loc_cancelRequested(thisNode.MAObj)
                    loc_cancelHighlighting(hWait);
                    return
                end

                if ismember(allTaskNodes{j}.MACIndex,visitedChecks)
                    continue;
                else
                    visitedChecks(end+1)=allTaskNodes{j}.MACIndex;%#ok<AGROW>
                end

                if allTaskNodes{j}.MACIndex>0
                    checkobj=allTaskNodes{j}.Check;
                    resultdata=checkobj.ProjectResultData;
                    for i=1:length(resultdata)
                        blkSID=resultdata{i};
                        try
                            h=Simulink.ID.getHandle(blkSID);%#ok<NASGU>
                        catch %#ok<CTCH>
                            continue;
                        end
                        if needWaitbar
                            if slfeature('AdvisorWebUI')==0&&strcmp(thisNode.MAObj.memenus.ShowInformerGUI.on,'off')
                                break
                            end
                            counter=counter+1;
                            i_waitbar(counter/allresultdata,hWait,DAStudio.message('ModelAdvisor:engine:HighlitingCheckResults'));
                        end

                        NodeObj=allTaskNodes{j};
                        NodeIndex=NodeObj.Index;
                        if thisNode.MAObj.ResultMap.isKey(blkSID)
                            overlayBlocks(thisNode.MAObj,informer,blkSID,'default',checkobj.ID,checkobj.Title,NodeIndex);
                            thisNode.MAObj.ResultMap(blkSID)=[thisNode.MAObj.ResultMap(blkSID),checkobj.ID,checkobj.Title];
                        else
                            overlayBlocks(thisNode.MAObj,informer,blkSID,'default',checkobj.ID,checkobj.Title,NodeIndex);
                            thisNode.MAObj.ResultMap(blkSID)={checkobj.ID,checkobj.Title};
                        end
                    end
                end
            end
        end
    end



    if thisNode.MAObj.ShowExclusionsOnGUI
        [excludeBlks,excludeInfoList]=slcheck.getExcludedBlocksForHighlighting(thisNode.MAObj.SystemName,CheckIDs);
        needWaitbar=length(excludeBlks)>waitbarThreshold;
        if needWaitbar
            if~ishghandle(hWait)
                hWait=waitbar(0,DAStudio.message('ModelAdvisor:engine:HighlitingExclusions'),'Name',DAStudio.message('Simulink:tools:MAPleaseWait'),'CreateCancelBtn','modeladvisorprivate(''modeladvisorutil2'',''CancelHighlighting'')');
            end
            i_waitbar(0,hWait,DAStudio.message('ModelAdvisor:engine:HighlitingExclusions'));
        end

        for i=1:length(excludeBlks)
            if needWaitbar
                if strcmp(thisNode.MAObj.memenus.ShowInformerGUI.on,'off')
                    break
                end
                i_waitbar(i/length(excludeBlks),hWait,DAStudio.message('ModelAdvisor:engine:HighlitingExclusions'));
            end
            overlayBlocks(thisNode.MAObj,informer,excludeBlks{i},'exclude',excludeInfoList{i});


            if loc_cancelRequested(thisNode.MAObj)
                loc_cancelHighlighting(hWait);
                return
            end
        end
    end





    if ishghandle(hWait)
        delete(hWait);
    end


    function loc_cancelHighlighting(hWait)

        ma=Simulink.ModelAdvisor.getActiveModelAdvisorObj();
        ma.AtticData.HighlightingCanceled=false;

        modeladvisorprivate('modeladvisorutil2','CloseResultGUI');


        if ishghandle(hWait)
            delete(hWait);
        end


        function output=createDefaultMapStructure(SID)
            output.SID=SID;
            output.screencolor='';
            output.bgcolor='';
            output.subsys=0;
            output.exclusion=0;
            output.exclude_subsys=0;
            output.checkID={};
            output.checkTitle={};
            output.NodeIndex={};

            function message=updateOverlayMsg(currentValue,informer,temp)

                if~isempty(currentValue.checkID)
                    if isa(temp,'Stateflow.Object')
                        message=DAStudio.message('ModelAdvisor:engine:ViolatednMAChecks',temp.Path,num2str(length(currentValue.checkID)));
                    else
                        message=DAStudio.message('ModelAdvisor:engine:ViolatednMAChecks',getfullname(currentValue.SID),num2str(length(currentValue.checkID)));
                    end
                    checkList=ModelAdvisor.List;
                    for i=1:length(currentValue.checkID)


                        linkObj=ModelAdvisor.Text(currentValue.checkTitle{i});
                        if isfield(currentValue,'NodeIndex')
                            NodeIndexStr=num2str(currentValue.NodeIndex{i});
                        else
                            NodeIndexStr='';
                        end
                        linkObj.setHyperlink(['matlab: modeladvisorprivate(''modeladvisorutil2'',''BringMAToForeground'',''',NodeIndexStr,''');']);
                        checkList.addItem(linkObj.emitHTML);
                    end
                    message=[message,checkList.emitHTML];
                    if~isa(temp,'Stateflow.Object')
                        if~strcmp(get_param(temp,'HiliteAncestors'),'mahiliteHere')
                            set_param(temp,'HiliteAncestors','mahiliteHere');
                        end
                    elseif isa(temp,'Stateflow.Chart')||isa(temp,'Stateflow.State')||isa(temp,'Stateflow.Transition')
                        style=sf_style('req');
                        sf_set_style(temp.ID,style);
                    end
                elseif currentValue.subsys>0
                    message=DAStudio.message('ModelAdvisor:engine:ViolateMAChecksInside',informer.defaultText,getfullname(currentValue.SID));
                    set_param(temp,'HiliteAncestors','mahiliteInside');
                elseif currentValue.exclusion>0
                    informerIcon=ModelAdvisor.Image;
                    informerIcon.setImageSource(fullfile(matlabroot,'toolbox','simulink','simulink','modeladvisor','private','info_icon.png'));
                    message=DAStudio.message('ModelAdvisor:engine:MAExclusionsForBlock',informer.defaultText,informerIcon.emitHTML,['<b>',getfullname(currentValue.SID),'</b>']);
                    message=[message,currentValue.exclusionMsg];
                    set_param(temp,'HiliteAncestors','maexcludeHere');
                elseif currentValue.exclude_subsys>0
                    message=DAStudio.message('ModelAdvisor:engine:MAElementsInsideExcluded',informer.defaultText,getfullname(currentValue.SID));
                    set_param(temp,'HiliteAncestors','maexcludeInside');
                end





                function overlayBlocks(MAObj,informer,objectSID,mode,msg1,msg2,msg3)


                    if loc_cancelRequested(MAObj)
                        return
                    end

                    temp=Simulink.ID.getHandle(objectSID);
                    if~isa(temp,'Stateflow.Object')&&strcmp(get_param(temp,'Type'),'block_diagram')

                    else
                        switch mode
                        case 'default'
                            if MAObj.ProjectResultMapData.isKey(objectSID)
                                currentValue=MAObj.ProjectResultMapData(objectSID);
                                currentValue.checkID{end+1}=msg1;
                                currentValue.checkTitle{end+1}=msg2;
                                currentValue.NodeIndex{end+1}=msg3;
                            else
                                currentValue=createDefaultMapStructure(objectSID);
                                currentValue.checkID={msg1};
                                currentValue.checkTitle={msg2};
                                currentValue.NodeIndex={msg3};
                            end
                            informer.mapData(temp,updateOverlayMsg(currentValue,informer,temp));

                            if isa(temp,'Stateflow.Object')
                                if isa(temp,'Stateflow.Chart')||isa(temp,'Stateflow.EMChart')
                                    parentBlk=temp.Path;
                                elseif isa(temp,'Stateflow.Data')||isa(temp,'Stateflow.Event')
                                    parentBlk='';
                                else
                                    parentBlk=temp.Chart.Path;
                                end
                            else
                                parentBlk=get_param(temp,'Parent');
                            end
                            while~isempty(parentBlk)&&~strcmp(getfullname(parentBlk),bdroot(MAObj.SystemName))
                                overlayBlocks(MAObj,informer,Simulink.ID.getSID(parentBlk),'subsys','','');


                                if loc_cancelRequested(MAObj)
                                    return
                                end

                                parentBlk=get_param(parentBlk,'Parent');
                            end
                        case 'exclude'
                            if MAObj.ProjectResultMapData.isKey(objectSID)
                                currentValue=MAObj.ProjectResultMapData(objectSID);
                                currentValue.exclusion=currentValue.exclusion+1;
                            else
                                currentValue=createDefaultMapStructure(objectSID);
                                currentValue.exclusion=1;
                            end
                            currentValue.exclusionMsg=msg1;

                            informer.mapData(temp,updateOverlayMsg(currentValue,informer,temp));

                            parentBlk=get_param(temp,'Parent');
                            while~isempty(parentBlk)&&~strcmp(getfullname(parentBlk),bdroot(MAObj.SystemName))
                                overlayBlocks(MAObj,informer,Simulink.ID.getSID(parentBlk),'exclude_subsys','','');


                                if loc_cancelRequested(MAObj)
                                    return
                                end

                                parentBlk=get_param(parentBlk,'Parent');
                            end
                        case 'subsys'
                            if MAObj.ProjectResultMapData.isKey(objectSID)
                                currentValue=MAObj.ProjectResultMapData(objectSID);
                                currentValue.subsys=currentValue.subsys+1;
                            else
                                currentValue=createDefaultMapStructure(objectSID);
                                currentValue.subsys=1;
                            end
                            informer.mapData(temp,updateOverlayMsg(currentValue,informer,temp));
                        case 'exclude_subsys'
                            if MAObj.ProjectResultMapData.isKey(objectSID)
                                currentValue=MAObj.ProjectResultMapData(objectSID);
                                currentValue.exclude_subsys=currentValue.exclude_subsys+1;
                            else
                                currentValue=createDefaultMapStructure(objectSID);
                                currentValue.exclude_subsys=1;
                            end

                            informer.mapData(temp,updateOverlayMsg(currentValue,informer,temp));
                        end
                        MAObj.ProjectResultMapData(objectSID)=currentValue;


                    end

                    function fade_sf_charts(model)

                        modelObj=get_param(model,'Object');
                        sfFilter=sfisa('isaFilter');
                        sfObjs=find(modelObj,sfFilter);
                        sfHs=get(sfObjs,'Id');
                        if iscell(sfHs)
                            sfHs=cell2mat(sfHs);
                        end

                        fade_style=sf_style('fade');

                        for i=1:length(sfHs)
                            sf_set_style(sfHs(i),fade_style);
                        end


                        machine=find(sfroot,'-isa','Stateflow.Machine','-and','Name',model);%#ok<GTARG>
                        if~isempty(machine)
                            machineID=machine.id;
                            sf('Redraw',machineID);
                        end


                        function sf_set_style(obj,style)

                            sf('SetAltStyle',style,obj);

                            while(1)
                                obj=sf('get',obj,'transition.subLink.next');
                                if isempty(obj)||obj==0
                                    break;
                                end
                                sf('SetAltStyle',style,obj);
                            end


                            function style=sf_style(style_name,fgColor,bgColor,fontColor)


                                style=sf('find','all','style.name',style_name);


                                if isempty(style)


                                    if strcmp(style_name,'req')
                                        fgColor=[1.0,0.65,0];
                                        bgColor=[1,1,1];
                                        fontColor=[1.0,0.2,0];

                                    elseif strcmp(style_name,'fade')
                                        fgColor=0.7*[1,1,1];
                                        bgColor=[1,1,1];
                                        fontColor=0.7*[1,1,1];

                                    end


                                    style=sf('new','style');
                                    sf('set',style,...
                                    'style.name',style_name,...
                                    'style.blockEdgeColor',fgColor,...
                                    'style.wireColor',fgColor,...
                                    'style.fontColor',fontColor,...
                                    'style.bgColor',bgColor);
                                else
                                    style=style(1);

                                end

                                function out=sfisa(in)


                                    persistent sfIsaStruct;
                                    persistent sfObjTypes;
                                    persistent isaFilter;

                                    if isempty(sfIsaStruct)
                                        sfIsaStruct.chart=sf('get','default','chart.isa');
                                        sfIsaStruct.state=sf('get','default','state.isa');
                                        sfIsaStruct.junction=sf('get','default','junction.isa');
                                        sfIsaStruct.port=sf('get','default','port.isa');
                                        sfIsaStruct.transition=sf('get','default','transition.isa');
                                        sfIsaStruct.machine=sf('get','default','machine.isa');
                                        sfIsaStruct.target=sf('get','default','target.isa');
                                        sfIsaStruct.event=sf('get','default','event.isa');
                                        sfIsaStruct.data=sf('get','default','data.isa');
                                        sfIsaStruct.instance=sf('get','default','instance.isa');

                                        sfObjTypes={'Stateflow.Chart',...
                                        'Stateflow.State',...
                                        'Stateflow.Transition',...
                                        'Stateflow.Box',...
                                        'Stateflow.EMFunction',...
                                        'Stateflow.EMChart',...
                                        'Stateflow.TruthTable',...
                                        'Stateflow.TruthTableChart',...
                                        'Stateflow.Function',...
                                        'Stateflow.SLFunction',...
                                        'Stateflow.AtomicSubchart',...
                                        'Stateflow.AtomicBox',...
                                        };


                                        isaFilter=makeFilter(sfObjTypes);
                                    end

                                    if nargin==0
                                        out=sfIsaStruct;
                                    elseif strcmp(in,'supportedTypes')
                                        out=sfObjTypes;
                                    elseif strcmp(in,'isaFilter')
                                        out=isaFilter;
                                    end

                                    function filter=makeFilter(allTypes)
                                        totalTypes=length(allTypes);
                                        filter=cell(1,totalTypes*3-1);
                                        filter(1:3:totalTypes*3-2)={'-isa'};
                                        filter(2:3:totalTypes*3-1)=allTypes;
                                        filter(3:3:totalTypes*3-3)={'-or'};

                                        function i_waitbar(value,handle,message)
                                            if ishghandle(handle)
                                                waitbar(value,handle,message);
                                            end

                                            function status=loc_cancelRequested(maObj)
                                                if isfield(maObj.AtticData,'HighlightingCanceled')
                                                    status=maObj.AtticData.HighlightingCanceled;
                                                else
                                                    maObj.AtticData.HighlightingCanceled=false;
                                                    status=false;
                                                end


