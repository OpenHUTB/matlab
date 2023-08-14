function rmiobjnavigate(modelPath,varargin)




































    modelPath=convertStringsToChars(modelPath);
    if nargin>1
        [varargin{:}]=convertStringsToChars(varargin{:});
    end

    if isDD(modelPath)

        if sl.interface.dict.api.isInterfaceDictionary(modelPath)
            dictPath=rmide.getFilePath(modelPath);
            if isempty(varargin{1})

                sl.interface.dictionaryApp.StudioApp.open(dictPath);
            else
                myConnection=rmide.connection(dictPath);
                ddEntryKey=varargin{1};
                entryPath=rmide.getEntryPath(myConnection,ddEntryKey);
                assert(startsWith(entryPath,'Design.'),'Expected Design Data entry');
                entryName=strrep(entryPath,'Design.','');
                sl.interface.dictionaryApp.utils.showEntryByName(entryName,dictPath);
            end
            return;
        end









        rmide.navigate(modelPath,varargin{:});
        return;
    end
    function yesno=isDD(myPath)
        yesno=contains(myPath,'.sldd');
    end

    if~isempty(varargin)&&sysarch.isZCElement(varargin{1})



        try
            open_system(modelPath);
            [~,mdlName]=fileparts(modelPath);
            sysarch.navigate(varargin{1},mdlName);

        catch ex
            errTitle=getString(message('Slvnv:rmiml:NavigationError'));
            errMsg=getString(message('Slvnv:rmiref:WordUtil:UnableToLocate',varargin{1},modelPath));
            errordlg({errMsg,ex.message},errTitle);
        end
        return;
    end


    if modelPath(1)=='!'
        modelPath=modelPath(2:end);
        clear_actions=false;
    else
        clear_actions=true;
    end

    isComponentHarness=rmisl.isHarnessIdString(modelPath);
    if isComponentHarness

        modelName=rmisl.harnessIdToEditorName(modelPath);
        mPath='';

    else
        [mPath,modelName]=fileparts(modelPath);
    end


    try
        modelH=get_param(modelName,'Handle');
        if~strcmp(get_param(modelH,'Open'),'on')



            open_system(modelH);
        end
    catch Mex %#ok<NASGU>,
        try
            open_system(modelPath);
            modelH=get_param(modelName,'Handle');
        catch Mex %#ok<NASGU>,
            if isComponentHarness


                inform(getString(message('Slvnv:reqmgt:rmiobjnavigate:ErrorNoHarness')),...
                getString(message('Slvnv:reqmgt:rmiobjnavigate:UnresolvedItem')),1);
            else
                inform(getString(message('Slvnv:reqmgt:rmiobjnavigate:ErrorNoModel',modelPath)),...
                getString(message('Slvnv:reqmgt:rmiobjnavigate:UnresolvedItem')),1);
            end
            return;
        end
    end


    if~isempty(mPath)
        actPath=get_param(modelH,'FileName');
        pathMathches=false;
        if~isempty(actPath)
            [aPath]=fileparts(actPath);
            pathMathches=rmiut.cmp_paths(mPath,aPath);
        else
            aPath='';
        end
        if~pathMathches
            inform(getString(message('Slvnv:reqmgt:rmiobjnavigate:ModelPathDoesNotMatch',aPath,mPath)),...
            getString(message('Slvnv:reqmgt:rmiobjnavigate:RequirementPathInconsistency')),2);
        end
    end



    if strcmp(get_param(modelH,'ReqHilite'),'on')
        set_param(modelH,'ReqHilite','off');
    elseif clear_actions
        action_highlight('clear');
    end


    show_window();


    argCount=length(varargin);
    i=1;
    while i<=argCount
        thisArg=varargin{i};
        if isempty(thisArg)

            open_system(modelName);
            if ispc
                show_window([modelName,'\s+-\s+Simulink$']);
            end
            i=i+1;
        elseif thisArg(1)=='!'
            rmiobjnavigate(thisArg,varargin{i+1:end});
            break;
        elseif strcmp(thisArg,'_suppress_browser')
            if ispc
                reqmgt('winClose','(?:localhost|127\.0\.0\.1):\d+\/matlab\/feval/rmiobjnavigate');
            end
            break;
        else

            if i==argCount
                locate_object_in_model(modelH,thisArg,0);
                break;
            else
                nextArg=varargin{i+1};
                if isa(nextArg,'double')
                    locate_object_in_model(modelH,thisArg,nextArg);
                    i=i+2;
                else
                    locate_object_in_model(modelH,thisArg,0);
                    i=i+1;
                end
            end
        end
    end
end


function locate_object_in_model(modelH,objId,grpIdx)

    if isnumeric(objId)

        locate_object(modelH,objId,objId,grpIdx);




    elseif strncmp(objId,'GID',3)

        objH=gidToHandle(modelH,objId);
        if~isempty(objH)
            locate_object(modelH,objId,objH,grpIdx);
        end

    elseif objId(1)==':'






        if Simulink.internal.isArchitectureModel(modelH)
            adapter=slreq.adapters.AdapterManager.getInstance.getAdapterByDomain('linktype_rmi_simulink');
            modelName=get_param(modelH,'Name');
            adapter.select(modelName,objId);
            return;
        end




        try
            if rmisl.isHarnessIdString(objId)


                [harnessName,~,objId]=rmisl.resolveHarnessObjRef(modelH,objId,true);
                modelH=get_param(harnessName,'Handle');
            end
            objH=rmisl.sidToHandle(modelH,objId);
        catch Mex
            modelName=get_param(modelH,'Name');
            inform(getString(message('Slvnv:reqmgt:rmiobjnavigate:CouldNotLocateId',objId,modelName,[': ',Mex.message])),...
            getString(message('Slvnv:reqmgt:rmiobjnavigate:UnresolvedItem')),1);
            objH=[];
        end
        if~isempty(objH)
            locate_object(modelH,objId,objH,grpIdx);
        end

    else
        inform(getString(message('Slvnv:reqmgt:rmiobjnavigate:ObjIdNotSupported',objId)),...
        getString(message('Slvnv:reqmgt:rmiobjnavigate:UnsupportedObject')),2);
    end
end

function objH=gidToHandle(modelH,objGuid)

    objH=rmisl.guidlookup(modelH,objGuid);
    if isempty(objH)
        modelName=get_param(modelH,'Name');
        inform(getString(message('Slvnv:reqmgt:rmiobjnavigate:CouldNotLocateId',objGuid,modelName,'')),...
        getString(message('Slvnv:reqmgt:rmiobjnavigate:UnresolvedItem')),1);
    end
end

function locate_object(modelH,objId,objH,grpIdx)










    modelName=get_param(modelH,'Name');
    if floor(objH)==objH
        isSf=true;
        if~sf('ishandle',objH)
            inform(getString(message('Slvnv:reqmgt:rmiobjnavigate:CouldNotResolveObj',objId,modelName)),...
            getString(message('Slvnv:reqmgt:rmiobjnavigate:NavigationFailed')),1);
            return
        end
    else
        isSf=false;
        if~ishandle(objH)
            inform(getString(message('Slvnv:reqmgt:rmiobjnavigate:CouldNotResolveObj',objId,modelName)),...
            getString(message('Slvnv:reqmgt:rmiobjnavigate:NavigationFailed')),1);
            return
        end
    end

    if~strcmp(get_param(modelH,'isHarness'),'on')


        [modelH,objH]=remapToHarnessIfOpen(modelH,objH,isSf);
    end

    if strcmp(get_param(modelH,'LibraryType'),'BlockLibrary')
        modelName=['Library: ',modelName];
    end

    if~isSf
        if objH==modelH
            if ispc()
                show_window([modelName,'\s+-\s+Simulink$']);
            end
        else
            parent=get_param(objH,'Parent');
            if~isempty(parent)
                open_system(parent,'force');
                action_highlight('reqHere',objH);


                highlightInSfIfSlInSf(objH,parent);

                if ispc()



                    parentH=get_param(parent,'Handle');
                    parentName=cr2space(get_param(parentH,'Name'));
                    if parentH==modelH
                        show_window([modelName,'\s+-\s+Simulink$']);
                    else
                        grandParentH=get_param(get_param(parentH,'Parent'),'Handle');
                        grandParentName=cr2space(get_param(grandParentH,'Name'));
                        if grandParentH==modelH
                            show_window([grandParentName,'/',parentName,'\s+-\s+Simulink$']);
                        else





                            ggParentH=get_param(get_param(grandParentH,'Parent'),'Handle');
                            if ggParentH==modelH
                                show_window([modelName,'/',grandParentName,'/',parentName,'\s+-\s+Simulink$']);
                            else
                                show_window([modelName,'/.../',grandParentName,'/',parentName,'\s+-\s+Simulink$']);
                            end
                        end
                    end
                end
            end


            if grpIdx>0&&rmisl.is_signal_builder_block(objH)
                rmisl.navigateToSigbuilder(objH,grpIdx);
            end
        end
    else

        sf('Open',objH);
        highlightInSF(objH);

    end
end

function highlightInSF(sfId)
    updated_charts=action_highlight_sf('req',sfId);
    if~isempty(updated_charts)

        chartBlocks=sf('Private','chart2block',updated_charts);
        for block=chartBlocks
            action_highlight('reqInside',block);
        end
    end
end

function findInSfAndHighlight(slH)
    root=sfroot;
    slInSf=root.find('-isa','Stateflow.SimulinkBasedState',...
    '-or','-isa','Stateflow.SLFunction');
    for i=1:length(slInSf)
        slInfo=Stateflow.SLINSF.ActionSubsysMan(slInSf(i).Id);
        if slInfo.subsysH==slH
            highlightInSF(slInSf(i).Id);
            return;
        end
    end
end

function highlightInSfIfSlInSf(slH,parent)
    pObj=get_param(parent,'Object');
    try
        PType=pObj.SFBlockType;
        if strcmp(PType,'Chart')
            findInSfAndHighlight(slH);
        elseif contains(pObj.SID,'::')


            findInSfAndHighlight(pObj.Handle);

            nestedSid=pObj.SID;
            colidx=strfind(nestedSid,'::');
            mdlName=get_param(bdroot(slH),'Name');
            ppObj=Simulink.ID.getHandle([mdlName,':',nestedSid(1:colidx(1)-1)]);
            if~isa(ppObj,'Stateflow.Object')
                if~strcmp(get_param(ppObj,'HiliteAncestors'),'reqHere')
                    set_param(ppObj,'HiliteAncestors','reqInside');
                end
            end
        else

        end
    catch ex %#ok<NASGU>


    end
end

function[modelH,objH]=remapToHarnessIfOpen(modelH,objH,isSf)
    if isSf
        sfrt=sfroot;
        object=sfrt.idToHandle(objH);
    else
        object=get_param(objH,'Object');
    end
    harnessObjSid=Simulink.harness.internal.sidmap.getOwnerObjectSIDInHarness(object);
    if~isempty(harnessObjSid)
        objH=Simulink.ID.getHandle(harnessObjSid);
        if isSf
            modelH=get_param(strtok(objH.Path,'/'),'Handle');
            objH=objH.Id;
        else
            modelH=bdroot(objH);
        end
    end
end

function inform(msg,title,severity)
    switch(severity)
    case 1
        errordlg(msg,title);
    case 2
        warndlg(msg,title);
    end
    if ispc()
        show_window(title);
    end
end

function out=cr2space(in)
    out=in;
    out(out==newline)=char(32);
end

function show_window(winTitle)

    persistent lastFocused;
    if isempty(lastFocused)
        lastFocused='__none__';
    end

    if nargin==0
        lastFocused='__none__';
    else
        if~strcmp(winTitle,lastFocused)
            reqmgt('winFocus',winTitle);
            lastFocused=winTitle;
        end
    end
end


