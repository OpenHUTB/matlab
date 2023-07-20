function[ResultDescription,ResultDetails]=maCheck(varargin)






    persistent resultsTable timeStamp;

    if ischar(varargin{1})
        switch varargin{1}

        case 'fixAll'
            if~isempty(timeStamp)&&strcmp(timeStamp,varargin{2})
                doFixAll(resultsTable);
            else
                errordlg(...
                getString(message('Slvnv:reqmgt:mdlAdvCheck:StaleMaReport')),...
                getString(message('Slvnv:reqmgt:mdlAdvCheck:DoorsFixAll')),'modal');
            end
            return;

        otherwise

            system=varargin{1};
        end
    else

        system=get_param(varargin{1},'Name');
    end
    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
    [resultsTable,errors,missingReqs]=doCheck(system,mdladvObj);
    timeStamp=sprintf('%s',now);

    [mlCheck,errors]=rmisl.checkMFunctions(system,'doors',errors);

    ResultDescription={};
    ResultDetails={};

    if isempty(resultsTable)&&isempty(mlCheck)
        ResultDescription{1}=pass_string();
        mdladvObj.setCheckResultStatus(true);
    elseif~isempty(resultsTable)
        [ResultDescription,ResultDetails]=getFormatedResults(resultsTable,errors,missingReqs,timeStamp);
        mdladvObj.setCheckResultStatus(false);
        if~isempty(mlCheck)
            [ResultDescription,ResultDetails]=rmiml.maAppendResults(mlCheck,ResultDescription,ResultDetails,'doors');
        end
        ResultDetails{end+1}=[];
    else
        [ResultDescription,ResultDetails]=rmiml.maAppendResults(mlCheck,{},{},'doors');
        mdladvObj.setCheckResultStatus(false);
    end

    if length(ResultDescription)>length(ResultDetails)
        ResultDetails{end+1}=[];
    end
end


function[resultsTable,all_errors,missing_docs]=doCheck(system,mdladvObj)

    resultsTable=cell(0,4);
    all_errors='';
    missing_docs='';


    filterSettings=rmi.settings_mgr('get','filterSettings');
    if filterSettings.enabled&&filterSettings.filterConsistency
        filters=filterSettings;
    else
        filters=[];
    end

    linkType=rmi.linktype_mgr('resolveByRegName','linktype_rmi_doors');

    hBlocks=rmisl.blockTable(system,'get',true);
    for i=1:length(hBlocks)
        [reqs,flags]=rmi.reqsWithFilterFlags(hBlocks(i),filters);
        for j=1:length(reqs)
            if~flags(j)
                continue;
            end
            if reqs(j).linked
                [isDoors,modId,objId]=isDoorsTarget(reqs(j));
                if~isDoors
                    continue;
                end

                try

                    if~reqmgt('findProc','doors.exe')
                        error(message('Slvnv:reqmgt:linktype_rmi_doors:IsValidDocFcn'));
                    end

                    [status,doorsInfo]=linkType.BacklinkCheckFcn(system,hBlocks(i),modId,objId);
                    if~status&&~rmi.isMAExcludedBlock(mdladvObj,hBlocks(i))
                        resultsTable(end+1,:)={hBlocks(i),modId,objId,doorsInfo};%#ok<AGROW>
                    end

                catch Mex
                    if rmi.isMAExcludedBlock(mdladvObj,hBlocks(i))
                        continue;
                    end





                    [this_error,missing_doc]=rmiut.errorToHtml(hBlocks(i),reqs(j),Mex,'id');
                    if isempty(this_error)
                        missing_doc=0;
                        this_error=['ERROR: ''',Mex.message,''' at ',Mex.stack(1).name,':',num2str(Mex.stack(1).line)];
                        doorsNavCmd=['rmi.navigate(''linktype_rmi_doors'',''',reqs(j).doc,''',''',reqs(j).id,''');'];
                        doorsNavLink=makeLink(doorsNavCmd,[reqs(j).id,' in ',strtok(reqs(j).doc)]);
                        failedToCheckMsg=getString(message('Slvnv:reqmgt:mdlAdvCheck:FailedToCheck'));
                        resultsTable(end+1,:)={hBlocks(i),reqs(j).doc,reqs(j).id,...
                        ['<font color="red">',failedToCheckMsg,' ',doorsNavLink,' </font>']};%#ok<AGROW>
                    end

                    if missing_doc
                        if~contains(missing_docs,this_error)
                            missing_docs=[missing_docs,'<li>',this_error,'</li>'];%#ok<AGROW>
                        end
                    else
                        if~contains(all_errors,this_error)
                            all_errors=[all_errors,'<li>',this_error,'</li>'];%#ok<AGROW>
                        end
                    end
                end
            end
        end
    end
end

function[isProxy,modId,objId]=isDoorsTarget(req)
    isProxy=false;
    modId='';
    objId=req.id;
    if strcmp(req.reqsys,'linktype_rmi_doors')
        isProxy=true;
        modId=strtok(req.doc);
    elseif strcmp(req.reqsys,'linktype_rmi_slreq')
        [isProxy,grpName,domain,customId]=slreq.internal.resolveProxyToExtReq(req);
        if isProxy&&strcmp(domain,'linktype_rmi_doors')
            modId=strtok(grpName);
            objId=customId;
        end
    end
end

function hyperlink=makeLink(matlabCmd,label)
    hyperlink=['<a href="matlab:',matlabCmd,'">',label,'</a>'];
end

function[ResultDescription,ResultDetails]=getFormatedResults(resultsTable,errors,~,timestampStr)
    ResultDescription=resultsTable(:,end);
    ResultDetails=resultsTable(:,1);
    if rmisf.isStateflowLoaded()

        rt=Stateflow.Root;
        for i=1:length(ResultDetails)
            item=ResultDetails{i};
            if floor(item)==item
                ResultDetails{i}={rt.idToHandle(item)};
            end
        end
    end



    if isempty(errors)
        all_errors='';
    else
        all_errors=['<p /><font color=''#cc5500''><b>'...
        ,DAStudio.message('Slvnv:consistency:EncounteredErrors'),'</b><ul>'...
        ,errors,'</ul></font><hr />'];
    end
    firstLine=getString(message('Slvnv:reqmgt:mdlAdvCheck:FollowingObjectsHaveNoLink'));
    fixAllBold=['<b>',getString(message('Slvnv:reqmgt:mdlAdvCheck:FixAll')),'</b>'];
    secondLine=getString(message('Slvnv:reqmgt:mdlAdvCheck:ClickFixAll',fixAllBold));
    firstColHeader=getString(message('Slvnv:reqmgt:mdlAdvCheck:SrcObjInDoors'));
    secondColHeader=getString(message('Slvnv:reqmgt:mdlAdvCheck:TargetObjInSimulink'));
    tableStart=[...
    '<p><font size="+1">',firstLine,'<br/>'...
    ,secondLine,'</font></p>',newline...
    ,'<table cellpadding="5">',newline...
    ,'<tr><td><b>',firstColHeader,'</b><hr/></td><td><b>',secondColHeader,'</b><hr/></td></tr><tr><td>'];
    ResultDescription{1}=[all_errors,newline,tableStart,ResultDescription{1}];

    for i=1:length(ResultDescription)
        ResultDescription{i}=[ResultDescription{i},'</td><td>'];
        if i>1
            ResultDescription{i}=['</td></tr><tr><td>',ResultDescription{i}];
        end
    end

    fixAllCmd=['rmidoors.maCheck(''fixAll'',''',timestampStr,''');'];
    fixAllHyperlink=makeLink(fixAllCmd,'Fix All');
    ResultDescription{end+1}=['</td></tr>'...
    ,'<tr><td>&nbsp;</td><td>&nbsp;</td></tr>'...
    ,'<tr><td></td><td align="right">',fixAllHyperlink,'</td></tr>'...
    ,'</table>'];
end

function html_string=pass_string()
    html_string=['<p /><font color="#008000">',DAStudio.message('Simulink:tools:MAPassedMsg'),'</font>'];
end

function doFixAll(resultsTable)
    linkType=rmi.linktype_mgr('resolveByRegName','linktype_rmi_doors');
    for i=1:size(resultsTable,1)
        try
            docId=resultsTable{i,2};
            itemId=resultsTable{i,3};
            mwObj=resultsTable{i,1};
            linkType.BacklinkInsertFcn(docId,itemId,mwObj);
        catch Ex
            msgString=getString(message('Slvnv:reqmgt:mdlAdvCheck:FailedToInsertLink',strtok(resultsTable{i,2})));
            errordlg({msgString,Ex.message},...
            getString(message('Slvnv:reqmgt:mdlAdvCheck:DoorsFixAll')));
            break;
        end
    end
end
