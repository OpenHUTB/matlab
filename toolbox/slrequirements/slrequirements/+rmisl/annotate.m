function annH=annotate(varargin)

    annH=[];

    if builtin('_license_checkout','Simulink_Requirements','quiet')
        error(message('Slvnv:reqmgt:licenseCheckoutFailed'));
    end

    obj=varargin{1};

    if isa(obj,'Simulink.Annotation')


        mode=checkMode(varargin{:});
        if isempty(mode)
            return;
        else

            ensureRmiContent(obj,mode);
        end
    elseif ischar(obj)&&~isempty(regexp(obj,'Requirements Annotations$','once'))

        if strcmp(bdroot(obj),'reqmanage')

        else

            substitute(gcbh);
        end
    else



        if nargin<2
            annH=createNew(true,obj,'');
        else
            annH=createNew(true,varargin{:});
        end
    end

end

function result=checkMode(an,opt)
    if~isempty(strfind(an.Parent,'Requirements Annotations'))

        result=[];
        return;
    end
    if isempty(opt)

        mode=an.UserData;
        if strcmp(mode,'RmiLinks')
            an.ClickFcn='rmisl.annotate(getCallbackAnnotation, false);';
        elseif strcmp(mode,'RmiDetails')
            an.ClickFcn='rmisl.annotate(getCallbackAnnotation, true);';
        else
            error('rmisl.annotate(): unsupported UserData "%s"',mode);
        end
        an.Text=getString(message('Slvnv:rmi:informer:ClickToDisplayLinks'));
        result=[];
    else
        result=opt;
    end
end

function annH=createNew(mode,obj,thirdArg,edgePos)

    try
        if ischar(obj)
            obj=strrep(obj,newline,' ');
        end
        [isSf,objH]=rmi.resolveobj(obj);

        if isSf
            htmlStr=makeHtmlStr(objH,true,thirdArg);
            sfChart=sfGetDestination(objH);
            annObj=Stateflow.Annotation(sfChart);
            annObj.text=getString(message('Slvnv:rmi:informer:Processing'));
            annObj.Tag='RmiDetails';
            if nargin<4
                edgePos=sfFindBottomLeftEdge(sfChart);
            end
            annH=annObj.Id;

        else
            htmlStr=makeHtmlStr(objH,false,thirdArg);
            sysPath=slGetDestination(objH);
            destinationPath=[sysPath,'/__RMI_ANNOTATION__'];
            add_block('built-in/Note',destinationPath);
            annH=get_param(destinationPath,'Handle');
            set_param(annH,'ZOrder',intmax);
            annObj=get_param(annH,'Object');
            if nargin<4
                edgePos=slFindBottomLeftEdge(sysPath);
            end
            if mode
                annObj.UserData='RmiDetails';
            else
                annObj.UserData='RmiLinks';
            end
        end

        setupRmiAnnotation(annObj,isSf,htmlStr,edgePos);

    catch Mex
        wrongArgumentWarning(Mex.message);
        return;
    end
end

function destinationChart=sfGetDestination(objId)
    sfRoot=Stateflow.Root;
    sfisa=rmisf.sfisa();
    if sf('get',objId,'.isa')==sfisa.chart
        destinationChart=sfRoot.idToHandle(objId);
    else
        parentChartId=sf('get',objId,'.chart');
        destinationChart=sfRoot.idToHandle(parentChartId);
    end
end

function destinationPath=slGetDestination(objH)


    objPath=getfullname(objH);
    if strcmp(objPath,gcs)
        destinationPath=objPath;
    else
        destinationPath=get_param(objPath,'Parent');
    end
end

function htmlStr=makeHtmlStr(objId,isSf,thirdArg)
    if isa(thirdArg,'double')

        htmlStr=reqsToHtml(objId,isSf,thirdArg);
    elseif isempty(thirdArg)

        htmlStr=reqsToHtml(objId,isSf);
    else

        htmlStr=thirdArg;
    end
end

function wrongArgumentWarning(message)
    disp(message);
    error(message('Slvnv:rmi:informer:WrongObject'));
end

function setupRmiAnnotation(annObj,isSf,reqHtml,cornerPos)
    reqHtml=wrapHtml(reqHtml);
    annObj.setContent(reqHtml);
    relativePos=[15,15,300,200];
    annObj.InternalMargins=[10,10,10,10];
    if isSf
        annObj.Interpretation='RICH';
        annObj.DropShadow=1;
        annObj.Position=[cornerPos,0,0]+relativePos;
    else
        annObj.Interpreter='RICH';
        annObj.HorizontalAlignment='left';
        annObj.DropShadow='on';
        annObj.Position=[cornerPos,cornerPos]+relativePos;
    end
end

function pos=sfFindBottomLeftEdge(sfChart)
    pos=[0,0];
    sfObjs=sfChart.getChildren();
    for i=1:length(sfObjs)
        try
            onePos=sfObjs(i).Position;
        catch ME %#ok<NASGU>
            continue;
        end
        if onePos(1)<pos(1)
            pos(1)=onePos(1);
        end
        if onePos(2)+onePos(4)>pos(2)
            pos(2)=onePos(2)+onePos(4);
        end
    end
end

function pos=slFindBottomLeftEdge(sysPath)
    sysObj=get_param(sysPath,'Object');
    if isa(sysObj,'Simulink.Subsystem')
        sysPos=sysObj.Position;
        pos=sysPos(1,4);
    else
        pos=[1,1];
    end
    blocks=sysObj.Blocks;
    for i=1:length(blocks)
        oneBlk=strrep(blocks{i},'/','//');
        oneObj=get_param([sysPath,'/',oneBlk],'Object');
        onePos=oneObj.Position;
        if onePos(1)<pos(1)
            pos(1)=onePos(1);
        end
        if onePos(4)>pos(2)
            pos(2)=onePos(4);
        end
    end
end

function html=reqsToHtml(objH,isSf,linkNum)
    reqs=rmi.getReqs(objH);
    if nargin==3&&linkNum(end)<=length(reqs)
        reqs=reqs(linkNum);
    end
    if~isempty(reqs)
        if ispc&&any(strcmp({reqs.reqsys},'other'))


            rmiut.msOfficeApps('cache');
            restoreOfficeApps=true;
        else
            restoreOfficeApps=false;
        end
        [~,html]=rmi.Informer.makeContents(objH,reqs,isSf);
        if restoreOfficeApps
            rmiut.msOfficeApps('restore');
        end
    else
        html=['<html><h2>',getString(message('Slvnv:rmi:informer:NoLinks')),'</h2></html>'];
    end


    html=cleanupForCanvas(html);
end

function html=cleanupForCanvas(html)
    disp(html);
    html=regexprep(html,'^<hr>','');
    html=regexprep(html,'\[<a href="[^"]+">Embed</a>\]','');
end

function html=wrapHtml(html)

    html=regexprep(html,'</?body>','');
    if~strncmpi(strtrim(html),'<html>',length('<html>'))
        html=['<html>',newline,html,newline,'</html>'];
    end
end

function ensureRmiContent(an,mode)
    sysPath=an.Parent;

    if mode
        htmlStr=reqsToHtml(sysPath,false);
    else
        htmlStr=linksToHtml(sysPath);
    end
    htmlStr=wrapHtml(htmlStr);
    an.Interpreter='RICH';
    an.InternalMargins=[10,10,10,10];
    an.HorizontalAlignment='left';
    an.setContent(htmlStr);
    if~contains(htmlStr,getString(message('Slvnv:rmi:informer:NoLinks')))
        an.ClickFcn='';
    end
    if mode
        an.UserData='RmiDetails';
    else
        an.UserData='RmiLinks';
    end
end

function htmlStr=linksToHtml(source)
    reqs=rmi.getReqs(source);
    if isempty(reqs)
        htmlStr=['<html><h2>',getString(message('Slvnv:rmi:informer:NoLinks')),'</h2></html>'];
    else
        htmlStr=['<html><h3>',getString(message('Slvnv:rmi:informer:TraceabilityLinks')),'</h3><ol>'];
        for i=1:length(reqs)
            cmd=['matlab:rmi.navigateToReq(''',source,''',',num2str(i),');'];
            hyperlink=['<li><a href="',cmd,'">',reqs(i).description,'</a></li>'];
            htmlStr=[htmlStr,newline,hyperlink];%#ok<AGROW>
        end
        htmlStr=[htmlStr,newline,'</ol></html>'];
    end
end

function substitute(th,varargin)
    persistent tempHandle;
    if isa(th,'timer')
        stop(th);
        delete(th);
        if ishandle(tempHandle)
            parent=get_param(tempHandle,'Parent');
            position=get_param(tempHandle,'Position');
            set_param(tempHandle,'Name',getString(message('Slvnv:rmi:informer:Processing')));
            questStr=getString(message('Slvnv:rmi:informer:NavOrDetailsQuest'));
            questTitle=getString(message('Slvnv:rmi:informer:NavOrDetailsTitle',get_param(parent,'Name')));
            ansShortcuts=getString(message('Slvnv:rmi:informer:NavOrDetailsAnsShortcuts'));
            ansDetailed=getString(message('Slvnv:rmi:informer:NavOrDetailsAnsDetailed'));
            reply=questdlg(questStr,questTitle,ansShortcuts,ansDetailed,ansShortcuts);
            switch reply
            case ansDetailed
                createNew(true,parent,'',position(1:2));
            case ansShortcuts
                htmlStr=linksToHtml(parent);
                createNew(false,parent,htmlStr,position(1:2));
            otherwise

            end
            delete_block(tempHandle);
            tempHandle=[];
        end
    elseif ishandle(th)
        tempHandle=th;
        t=timer('TimerFcn',@substitute,'StartDelay',0.3);
        start(t);
    end
end


