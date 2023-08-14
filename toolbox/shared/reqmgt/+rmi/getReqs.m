function result=getReqs(varargin)



    persistent stmInstalled

    if isempty(stmInstalled)

        stmInstalled=~isempty(which('stm.view'));
    end

    obj=varargin{1};


    if rmide.isDataEntry(obj)
        result=rmide.getReqs(obj);
        return;
    end


    if ischar(obj)&&any(obj=='|')&&(rmisl.isSidString(obj)||rmiml.canLink(obj))
        result=rmiml.getReqs(obj);
        return;
    end

    if stmInstalled&&rmitm.isTest(obj)
        result=rmitm.getReqs(obj);
        return;
    end


    if rmifa.isFaultInfoObj(obj)
        result=rmifa.getReqs(obj);
        return;
    end


    if rmism.isSafetyManagerObj(obj)
        result=rmism.getReqs(obj);
        return;
    end


    [isSysComp,subtype]=sysarch.isSysArchObject(obj);

    if isSysComp
        if strcmp(subtype,'autosar')
            obj=obj.SimulinkHandle;
        else

            result=[];
            return;
        end
    end




    try
        [modelH,objH,isSf,isSigBuilder]=rmisl.resolveObj(obj);
    catch Mex
        if strcmp(Mex.identifier,'Slvnv:reqmgt:rmi:InvalidObject')




            if ischar(obj)&&isUnderVariantSubsystem(obj)


                Mex=[];
            end
        end
        if~isempty(Mex)

            ws=warning('off','backtrace');
            warning(Mex.identifier,'%s',Mex.message);
            if strcmp(ws.state,'on')
                warning('on','backtrace');
            end
        end
        result=[];
        return;
    end


    if rmisl.isComponentHarness(modelH)
        theObj=rmisl.getObject(objH,isSf);
        if Simulink.harness.internal.sidmap.isObjectOwnedByCUT(theObj)
            try
                cutObj=rmisl.harnessToModelRemap(theObj);
            catch ME
                if strcmp(ME.identifier,'Simulink:utility:invalidSID')






                    result=[];
                    return;
                else
                    rethrow(ME);
                end
            end
            result=rmi.getReqs(cutObj,varargin{2:end});
            return;
        end
    end

    if nargin>1&&islogical(varargin{2})

        if varargin{2}
            if~isSf&&objH~=modelH&&isSlFromLib(objH,false)
                refPath=get_param(objH,'ReferenceBlock');
                if isempty(refPath)
                    refPath=get_param(objH,'AncestorBlock');
                end
                if~isempty(refPath)
                    libName=strtok(refPath,'/');
                    if rmiut.isBuiltinNoRmi(libName)

                        result=[];
                        return;
                    end
                    if libraryAvailable(libName)
                        refH=get_param(refPath,'Handle');
                        result=rmi.getReqs(refH,varargin{3:end});
                    else
                        warning(message('Slvnv:getReqs:LibQueryFailed',refPath));
                        result=[];
                    end
                    return;
                else
                    error(message('Slvnv:getReqs:RefBlockUnknown',num2str(objH)));
                end
            elseif isSf
                if~isa(obj,'Stateflow.Object')
                    sfRoot=Stateflow.Root;
                    obj=sfRoot.idToHandle(objH);
                end
                if isa(obj,'Stateflow.AtomicSubchart')&&obj.isLink
                    refPath=obj.Subchart.Path;
                    if~isempty(refPath)
                        libName=strtok(refPath,'/');
                        if rmiut.isBuiltinNoRmi(libName)

                            result=[];
                            return;
                        end
                        if libraryAvailable(libName)
                            result=rmi.getReqs(refPath,varargin{3:end});
                        else
                            warning(message('Slvnv:getReqs:LibQueryFailed',refPath));
                            result=[];
                        end
                        return;
                    else
                        error(message('Slvnv:getReqs:RefBlockUnknown',num2str(objH)));
                    end
                else
                    error(message('Slvnv:getReqs:InvalidLibSwitch'));
                end
            else
                error(message('Slvnv:getReqs:InvalidLibSwitch'));
            end
        elseif~isSf&&objH~=modelH&&isSlFromLib(objH,true)




            result=[];
            return;
        else



            varargin(2)=[];
        end
    elseif~isSf&&objH~=modelH&&isSlFromLib(objH,true)


        result=[];
        return;
    end

    if rmidata.isExternal(modelH)
        result=rmidata.getReqs(objH,varargin{2:end});
    else


        result=rmisl.getEmbeddedReqs(objH,isSf,isSigBuilder,varargin{2:end});
    end



    if~isSf&&rmi.settings_mgr('get','reportSettings','toolsReqReport')
        if rmipref('ReportFollowLibraryLinks')
            if modelH~=objH&&~isempty(get_param(modelH,'DataDictionary'))
                try
                    [ddReqs,ddNames,ddSources]=rmide.getVarReqsForObj(objH);
                    if~isempty(ddReqs)
                        for i=1:length(ddReqs)
                            ddPrefix=['[',ddSources{i},':',ddNames{i},'] '];
                            ddReqs(i).description=[ddPrefix,ddReqs(i).description];
                        end
                        result=[result;ddReqs];
                    end
                catch ex %#ok<NASGU>

                end
            end
        end
    end
end

function yesno=libraryAvailable(libName)
    if any(strcmp(find_system('SearchDepth',0),libName))
        yesno=true;
    else
        try
            load_system(libName);
            yesno=true;
        catch ex %#ok<NASGU>
            yesno=false;
        end
    end
end

function result=isSlFromLib(objH,implicitOnly)

    if any(strcmp(get_param(objH,'Type'),{'annotation','port'}))
        result=false;
    else
        linkStatus=get_param(objH,'StaticLinkStatus');
        if implicitOnly
            result=strcmp(linkStatus,'implicit');
        else
            result=~strcmp(linkStatus,'none');
        end
    end
end

function tf=isUnderVariantSubsystem(obj)


    tf=false;
    while count(obj,'/')>1




        parent=regexprep(obj,'/[^/]*$','');
        try
            variantOnOff=get_param(parent,'Variant');
        catch
            variantOnOff=false;
        end
        if strcmp(variantOnOff,'on')
            tf=true;
            return;
        else
            obj=parent;
        end
    end
end