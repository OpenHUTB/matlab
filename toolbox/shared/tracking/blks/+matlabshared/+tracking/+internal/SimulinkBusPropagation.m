classdef(Hidden)SimulinkBusPropagation<handle
%#codegen

    properties(Access=private)
        pCurrentBusIdx=0
        pBlockName=char.empty(1,0)
        pBusInitialized={''}
        pBusRecursion=cell(0,1)
pDaClean
    end

    properties(Abstract,Constant,Access=protected)

pBusPrefix
    end


    properties(Constant,Access=private)
        pKeywordList=iskeyword()
    end

    methods
        function obj=SimulinkBusPropagation


            coder.allowpcode('plain');
        end
    end

    methods(Access=protected)












        function busIdx=getBusPrefixIndex(obj,indBusPrefix)
            if nargin<2
                indBusPrefix=1;
            end

            busIdx=1;
            if iscell(obj.pBusPrefix)
                if ischar(indBusPrefix)
                    busIdx=str2double(...
                    strrep(strrep(indBusPrefix,'BusName',''),'Source',''));
                else
                    busIdx=indBusPrefix;
                end
            end

            if isempty(busIdx)
                busIdx=1;
            end
        end

        function busName=getBusName(obj,busName,busIdx)
            if isempty(busName)
                if nargin<3
                    busIdx=1;
                end

                if iscell(obj.pBusPrefix)
                    busName=obj.pBusPrefix{busIdx};
                else
                    busName=obj.pBusPrefix;
                end
            end
        end

        function busSource=getBusSource(obj,varargin)
            busIdx=getBusPrefixIndex(obj,varargin{:});
            propBusName='BusName';
            if busIdx>1
                propBusName=[propBusName,num2str(busIdx)];
            end
            propBusNameSource=[propBusName,'Source'];
            busSource=obj.(propBusNameSource);
        end

        function validateBusName(obj,val,propBusName)
            if coder.target('MATLAB')
                isActive=~isInactiveBusProperty(obj,propBusName);
            else
                busNameSourceProp=[propBusName,'Source'];
                isActive=strcmpi(obj.(busNameSourceProp),'Property');
            end
            if isActive
                validateattributes(val,{'char','string'},{'nonempty','row'},class(obj),propBusName);
                cond=~isvarnamecg(val);
                if cond
                    coder.internal.errorIf(cond,'shared_tracking:SimulinkBusUtilities:busMustBeValidVariableName',propBusName,gcb);
                end
            end
        end

        function flag=isInactiveBusProperty(obj,prop)
            flag=false;
            if~isSourceBlock(obj)&&startsWith(prop,'BusName')
                flag=true;
            elseif startsWith(prop,'BusName')&&~contains(prop,'Source')
                if strcmp(getBusSource(obj,prop),'Auto')
                    flag=true;
                end
            end
        end
    end

    methods(Static,Access=protected)
        function groups=getBusPropertyGroups
            busList={'BusNameSource','BusName'};
            busSection=matlabshared.tracking.internal.getDisplaySection('shared_tracking',...
            'SimulinkBusUtilities','PortSettings',busList);
            groups=busSection;
        end
    end

    methods(Abstract)
        isActive=isInactiveProperty(obj,prop)
        flag=isLocked(obj)
    end

    methods(Abstract,Access=protected)









        [out,argsToBus]=defaultOutput(obj,varargin)



















        outStruct=sendToBus(obj,defaultOut,varargin)
    end

    methods(Access=protected)
        function flag=isSourceBlock(obj)
            flag=obj.getExecPlatformIndex();
        end

        function flag=isBusPropagated(obj)
            flag=obj.getExecPlatformIndex();
        end

        function s=saveBuses(obj,s)
            if isLocked(obj)
                s.pBlockName=obj.pBlockName;
                s.pBusInitialized=obj.pBusInitialized;
            end
        end

        function loadBuses(obj,s,wasLocked)
            if wasLocked
                if isfield(s,'pBlockName')
                    obj.pBlockName=s.pBlockName;
                end
                if isfield(s,'pBusInitialized')
                    obj.pBusInitialized=s.pBusInitialized;
                end
            end
        end

        function releaseBuses(obj)
            obj.pBusInitialized={''};
        end

        function busIdx=getPortBusIndex(obj,resolvedBlkName,portNum)
            try %#ok<EMTC>
                portHandle=get_param(resolvedBlkName,'PortHandles');
                numInput=numel(portHandle.Outport);





                if isequal(numInput,1)&&...
                    isequal(portNum,1)
                    busIdx=portNum;
                    return;
                end

                isBusPort=false(numInput,1);
                activeBusIdxs=zeros(numInput,1);


                busName=get_param(resolvedBlkName,'BusName');
                set_param(resolvedBlkName,'BusName',busName);
                for i=1:numInput
                    sig=get_param(portHandle.Outport(i),'SignalHierarchy');
                    if~isempty(sig)
                        if~isempty(sig.BusObject)
                            isBusPort(i)=true;
                        end
                    end
                end
            catch
            end

            if any(isBusPort)


                activeBusIdxs(isBusPort)=obj.getActiveBusIndices;

                busIdx=activeBusIdxs(portNum);
            else


                busIdx=portNum;
            end
        end

        function busIdx=getActiveBusIndices(obj)

            if ischar(obj.pBusPrefix)
                busIdx=1;
            else
                numBus=numel(obj.pBusPrefix);
                busIdx=1:numBus;
                for m=1:numBus

                    propBusNameSource='BusName';
                    if m>1
                        propBusNameSource=cat(2,propBusNameSource,num2str(m));
                    end
                    propBusNameSource=cat(2,propBusNameSource,'Source');
                    if isInactiveProperty(obj,propBusNameSource)
                        busIdx(m)=NaN;
                    end
                end
                busIdx=busIdx(~isnan(busIdx));
            end
        end

        function varargout=getBusDataTypes(obj)


            thisBlk=gcb;
            obj.pBlockName=thisBlk;


            busIdx=getActiveBusIndices(obj);
            numBus=numel(busIdx);
            varargout=cell(1,numBus);
            for m=1:numBus
                obj.pCurrentBusIdx=busIdx(m);
                try %#ok<EMTC>
                    dt=openBus(obj);
                catch ME
                    obj.pBusRecursion=cell(0,1);
                    rethrow(ME);
                end
                obj.pBusInitialized{m}=dt;
                obj.pBusRecursion=cell(0,1);

                if isempty(dt)
                    dt=[];
                end
                varargout{m}=dt;
            end
        end

        function busName=propagatedInputBus(obj,idx)





            busName='';

            obj.pBusRecursion{end+1,1}=sprintf('%s:%i',obj.pBlockName,idx);
            [connBlk,connPort,isConnDefined]=getSourceBlockFromPortConnectivity(obj.pBlockName,idx);


            if~isConnDefined
                return
            end

            [srcBlk,srcPort]=getConnectedSource(obj,connBlk,connPort);


            if isInfiniteBusRecursion(obj)
                str=strsplit(obj.pBusRecursion{end-1},':');
                msg=message('shared_tracking:SimulinkBusUtilities:busCannotBePropagated',str{1},str2double(str{2}));
                MSLException(msg).throw();
            end


            if isempty(srcBlk)
                msg=message('shared_tracking:SimulinkBusUtilities:busCannotBePropagated',obj.pBlockName,idx);
                MSLException(msg).throw();
            end


            [busName,isBus]=getPortBusName(obj,srcBlk,srcPort);
            if~isBus
                msg=message('shared_tracking:SimulinkBusUtilities:portNotConnectedToABus',obj.pBlockName,idx);
                MSLException(msg).throw();
            elseif isempty(busName)
                msg=message('shared_tracking:SimulinkBusUtilities:busCannotBePropagated',obj.pBlockName,idx);
                MSLException(msg).throw();
            end
        end

        function busName=openBus(obj,blkName,busNameIn)
























            if nargin<2
                sysobj=obj;
                blkName=obj.pBlockName;
            else
                sysobj=obj.blockConstructor(blkName);
                sysobj.pBusRecursion=obj.pBusRecursion;
                sysobj.pCurrentBusIdx=obj.pCurrentBusIdx;
            end

            rootModel=bdroot(blkName);
            rootModel=get_param(rootModel,'Handle');
            obj.pDaClean=onCleanup(@()matlabshared.tracking.internal.getSBUDataAccessor(rootModel,'clear'));


            busIdx=sysobj.pCurrentBusIdx;


            busNameProvided=nargin>2;
            if~busNameProvided
                busName=sysobj.blockBusName(blkName,busIdx);
            else
                busName=busNameIn;
            end


            initializedBuses=sysobj.pBusInitialized;
            if numel(initializedBuses)>=busIdx&&strcmp(initializedBuses{busIdx},busName)
                busName=initializedBuses{busIdx};
                if sysobj.existBus(busName)
                    return
                end
                sysobj.pBusInitialized{busIdx}='';
            end


            if~isvarname(busName)
                msg=message('shared_tracking:SimulinkBusUtilities:busMustBeValidVariableName',busName,sysobj.pBlockName);
                error(msg);
            end

            needsCreation=~sysobj.existBus(busName);
            busNameSource=sysobj.blockBusNameSource(blkName,busIdx);
            needsCheck=strcmp(busNameSource,'Property')&&~needsCreation;
            isMultiBus=~(ischar(sysobj.pBusPrefix)||numel(sysobj.pBusPrefix)==1);
            if needsCreation||needsCheck
                if~isMultiBus
                    [out,argsToBus]=defaultOutput(sysobj);
                else
                    [out,argsToBus]=defaultOutput(sysobj,busIdx);
                end


                if isempty(out)
                    busName='';
                    return
                end

                if~isMultiBus
                    outStruct=sendToBus(sysobj,out,argsToBus{:});
                else
                    outStruct=sendToBus(sysobj,out,busIdx,argsToBus{:});
                end
            end

            if needsCreation
                busName=localOpenBus(sysobj,busName,outStruct,true,busIdx);
            elseif needsCheck

                flag=isBusEquivalentToStruct(busName,outStruct);
                if~flag
                    msg=message('shared_tracking:SimulinkBusUtilities:busIncompatibleExists',busName,blkName);
                    error(msg);
                end
            end
        end
    end

    methods(Access=private)
        function[busNameOut,eqFound]=localOpenBus(obj,baseBusName,st,isToplevel,busIdx)








            if nargin<4
                isToplevel=true;
            end

            if nargin<5
                busIdx=1;
            end



            eqBus='';
            isBusNameAuto=strcmpi(getBusSource(obj,busIdx),'Auto');
            if isBusNameAuto||~isToplevel
                eqBus=findBusEquivalentToStruct(st);
            end

            if~isempty(eqBus)
                eqFound=true;
                busNameOut=eqBus;
            else
                if isBusNameAuto





                    if checkIfVarExist(baseBusName)
                        baseBusName=findUniqueVarName(obj,baseBusName(1:end-1));
                    end
                end



                busFlds=fieldnames(st);
                numFlds=numel(busFlds);
                subBusVals=cell(numFlds,1);
                for m=1:numFlds
                    thisFld=busFlds{m};
                    thisVal=st.(thisFld);
                    if isstruct(thisVal)
                        subBusVals{m}=thisVal;





                        [st(:).(thisFld)]=deal(ones(size(thisVal)));
                    end
                end


                createVar(baseBusName,st);
                busDescription=localevalin(['Simulink.Bus.createObject(',baseBusName,')']);
                tmpBusName=busDescription.busName;





                updateVar(baseBusName,getVar(tmpBusName));
                removeVar(tmpBusName);

                needSubBus=find(~cellfun(@isempty,subBusVals));
                if~isempty(needSubBus)

                    busObj=getVar(baseBusName);

                    for m=1:numel(needSubBus)
                        iElmt=needSubBus(m);
                        thisName=[baseBusName,busFlds{iElmt}];
                        thisStruct=subBusVals{iElmt};
                        busNameUsed=localOpenBus(obj,thisName,thisStruct,false,busIdx);
                        busObj.Elements(iElmt).DataType=['Bus: ',busNameUsed];
                    end


                    updateVar(baseBusName,busObj);
                end
                eqFound=false;
                busNameOut=baseBusName;
            end
        end

        function busName=uniqueBusName(obj,busIdx)







            if nargin<2
                busIdx=1;
            end

            prefix=obj.pBusPrefix;
            if iscell(prefix)
                prefix=prefix{busIdx};
            end
            busName=findUniqueVarName(obj,prefix);
        end

        function uniqueName=findUniqueVarName(~,name)
            idx=1;
            notUnique=true;
            while notUnique
                uniqueName=[name,num2str(idx)];
                notUnique=checkIfVarExist(uniqueName);
                idx=idx+1;
            end
        end
    end

    methods(Static,Access=private)
        function flag=existBus(busName)




            flag=false;


            if~isvarname(busName)
                return
            end



            if~checkIfVarExist(busName)
                return
            end


            var=getVar(busName);
            if~isa(var,'Simulink.Bus')
                return
            end


            flag=~isempty(var.Elements);
            for m=1:numel(var.Elements)
                dt=var.Elements(m).DataType;


                [isBus,subName]=isBusDataType(dt);
                if isBus

                    flag=matlabshared.tracking.internal.SimulinkBusPropagation.existBus(subName);
                    if~flag
                        return
                    end
                end
            end
        end

        function busName=blockBusName(blkName,busIdx)



            if nargin<1
                blkName=gcb;
            end
            if nargin<2
                busIdx=1;
            end

            busNameSource=matlabshared.tracking.internal.SimulinkBusPropagation.blockBusNameSource(blkName,busIdx);
            if strcmp(busNameSource,'Auto')
                busName=matlabshared.tracking.internal.SimulinkBusPropagation.blockBusNameAuto(blkName,busIdx);
            else
                busName=matlabshared.tracking.internal.SimulinkBusPropagation.blockBusNameProperty(blkName,busIdx);
            end
        end

        function busName=blockBusNameAuto(blkName,busIdx)



            if nargin<1
                blkName=gcb;
            end
            if nargin<2
                busIdx=1;
            end


            sysobj=matlabshared.tracking.internal.SimulinkBusPropagation.blockConstructor(blkName);
            busName=uniqueBusName(sysobj,busIdx);
        end

        function busName=blockBusNameProperty(blkName,busIdx)



            if nargin<1
                blkName=gcb;
            end
            if nargin<2
                busIdx=1;
            end

            if busIdx==1
                busName=get_param(blkName,'BusName');
            else
                busName=get_param(blkName,['BusName',num2str(busIdx)]);
            end
        end

        function busNameSource=blockBusNameSource(blkName,busIdx)




            if nargin<1
                blkName=gcb;
            end
            if nargin<2
                busIdx=1;
            end

            if busIdx==1
                busNameSourceProp='BusNameSource';
            else
                busNameSourceProp=['BusName',num2str(busIdx),'Source'];
            end

            try %#ok<EMTC>
                busNameSource=get_param(blkName,busNameSourceProp);
            catch

                params=get_param(blkName,'ObjectParameters');

                if~isfield(params,busNameSourceProp)




                    open_system(blkName,'parameter');
                    close_system(blkName,0);
                end
                busNameSource=get_param(blkName,busNameSourceProp);
            end
        end
    end

    methods(Static,Access=private)
        function sysObj=blockConstructor(blkName)






            if nargin<1||isempty(blkName)
                blkName=gcb;
            end
            blkHndl=getSimulinkBlockHandle(blkName);


            objClass=get(blkHndl,'System');
            sysObj=feval(objClass);
            sysObj.setExecPlatformIndex(true);
            sysObj.pBlockName=blkName;

            sysObj=matlabshared.tracking.internal.setBlockMaskParamsOnObject(blkHndl,sysObj);
        end
    end

    methods(Static)
        function busName=createBus(blkPath,busName,busIdx)
























            narginchk(1,3);

            busNameProvided=nargin>1&&ischar(busName);
            if nargin==2&&~ischar(busName)
                busIdx=busName;
            elseif nargin<3
                busIdx=1;
            end


            [loadedModels,resolvedBlkPath]=matlabshared.tracking.internal.SimulinkUtilities.loadModels(blkPath);
            mkClean=onCleanup(@()matlabshared.tracking.internal.SimulinkUtilities.closeModels(loadedModels));


            if~strcmp(get_param(resolvedBlkPath,'BlockType'),'MATLABSystem')
                error(message('shared_tracking:SimulinkBusUtilities:mustBeMATLABSystemBlock'));
            end


            objClass=get_param(resolvedBlkPath,'System');
            sysObj=feval(objClass);
            if~isa(sysObj,'matlabshared.tracking.internal.SimulinkBusPropagation')
                error(message('shared_tracking:SimulinkBusUtilities:blockBusCreationNotSupported'));
            end


            if~busNameProvided&&~strcmp(matlabshared.tracking.internal.SimulinkBusPropagation.blockBusNameSource(resolvedBlkPath),'Property')
                error(message('shared_tracking:SimulinkBusUtilities:nameSourceMustBeProperty'));
            end


            sysObj=matlabshared.tracking.internal.SimulinkBusPropagation.blockConstructor(resolvedBlkPath);
            sysObj.pCurrentBusIdx=busIdx;
            if busNameProvided
                busName=openBus(sysObj,resolvedBlkPath,busName);
            else
                busName=openBus(sysObj,resolvedBlkPath);
            end
        end
    end

    methods(Static,Access=protected)
        function st=bus2struct(busName)

            bus=getVar(busName);
            st=elements2struct(bus.Elements);
        end
    end

    methods(Access=private)
        function[srcBlk,srcPort]=getConnectedSource(obj,destBlk,destPortNum)








            if nargin<2
                destPortNum=0;
            end

            srcBlk='';
            srcPort=0;

            if isempty(destBlk)
                return
            end

            blkType=get_param(destBlk,'BlockType');
            switch blkType
            case 'ModelReference'


                if strcmp(get_param(destBlk,'ProtectedModel'),'on')
                    msg=message('shared_tracking:SimulinkBusUtilities:cannotDirectConnectToProtectedModel',destBlk);
                    error(msg);
                end

                mdlName=get_param(destBlk,'ModelName');
                loadedModel=false;
                if~bdIsLoaded(mdlName)
                    load_system(mdlName);
                    loadedModel=true;
                end
                fndSys=find_system(mdlName,'SearchDepth',1,'BlockType','Outport','Port',num2str(destPortNum));


                if isempty(fndSys)
                    return
                end

                nextBlk=fndSys{1};
                nextPortNum=destPortNum;


                [srcBlk,srcPort]=getConnectedSource(obj,nextBlk,nextPortNum);

                if loadedModel
                    rootModel=get_param(mdlName,'Handle');
                    close_system(mdlName,0);
                    daClean=onCleanup(@()matlabshared.tracking.internal.getSBUDataAccessor(rootModel,'clear'));
                end
            case 'SubSystem'






                hasVariant=strcmp(get_param(destBlk,'Variant'),'on');
                if hasVariant

                    varBlk=get_param(destBlk,'ActiveVariantBlock');
                    if isempty(varBlk)
                        return
                    end
                end



                subBlks=get_param(destBlk,'Blocks');
                for m=1:numel(subBlks)
                    thisBlk=[destBlk,'/',subBlks{m}];


                    blkType=get_param(thisBlk,'BlockType');
                    if~strcmp(blkType,'Outport')
                        continue
                    end


                    thisPort=str2double(get_param(thisBlk,'Port'));
                    if thisPort==destPortNum
                        if hasVariant

                            if strcmp(get_param(varBlk,'BlockType'),'ModelReference')&&strcmp(get_param(varBlk,'ProtectedModel'),'on')





                                srcBlk=thisBlk;
                                srcPort=1;
                            else
                                varPort=findVariantPortNumber(varBlk,get_param(thisBlk,'PortName'));
                                [srcBlk,srcPort]=getConnectedSource(obj,varBlk,varPort);
                            end
                        else
                            [srcBlk,srcPort]=getConnectedSource(obj,thisBlk,thisPort);
                        end
                        return
                    end
                end
            case 'Inport'



                if isBusDataType(get_param(destBlk,'OutDataTypeStr'))
                    srcBlk=destBlk;
                    srcPort=destPortNum;
                    return
                end





                inportNum=str2double(get_param(destBlk,'Port'));



                subSys=get_param(destBlk,'Parent');

                if strcmp(get_param(subSys,'Type'),'block_diagram')

                    [nextBlk,nextPortNum]=findConnectedReference(subSys,destPortNum);
                else

                    parentBlk=get_param(subSys,'Parent');
                    if~strcmp(get_param(parentBlk,'Type'),'block_diagram')&&...
                        strcmp(get_param(parentBlk,'BlockType'),'SubSystem')&&strcmp(get_param(parentBlk,'Variant'),'on')


                        portBlk=find_system(parentBlk,'SearchDepth',1,'BlockType','Inport','Name',get_param(destBlk,'Name'));



                        if isempty(portBlk)
                            return
                        end


                        subSys=parentBlk;
                        inportNum=str2double(get_param(portBlk{1},'Port'));
                    end


                    portHndls=get_param(subSys,'PortHandles');
                    inHndls=portHndls.Inport;
                    inportHndl=-1;
                    for k=1:numel(inHndls)
                        thisPort=inHndls(k);
                        thisPortNum=get(thisPort,'PortNumber');
                        if thisPortNum==inportNum
                            inportHndl=thisPort;
                            break
                        end
                    end


                    if isempty(inportHndl)||~ishandle(inportHndl)
                        return
                    end



                    lineHndl=get(inportHndl,'Line');
                    [nextBlk,nextPortNum]=getSrcBlockFromLine(lineHndl);
                end

                [srcBlk,srcPort]=getConnectedSource(obj,nextBlk,nextPortNum);
            case 'Outport'



                if isBusDataType(get_param(destBlk,'OutDataTypeStr'))
                    srcBlk=destBlk;
                    srcPort=destPortNum;
                    return
                end

                [connBlk,connPort]=getSourceBlockFromPortConnectivity(destBlk,destPortNum);


                if isempty(connBlk)
                    return
                end



                if strcmp(get_param(connBlk,'BlockType'),'ModelReference')&&...
                    strcmp(get_param(connBlk,'ProtectedModel'),'on')



                    srcBlk=destBlk;
                    srcPort=destPortNum;
                    return
                else

                    [srcBlk,srcPort]=getConnectedSource(obj,connBlk,connPort);
                end
            case 'From'





                gotoTag=get_param(destBlk,'GotoTag');
                gotoBlk=find_system(bdroot,'BlockType','Goto','GotoTag',gotoTag);
                if isempty(gotoBlk)||numel(gotoBlk)>1
                    return
                end
                gotoBlk=gotoBlk{1};


                lineHndl=get_param(gotoBlk,'LineHandles');
                inHndl=lineHndl.Inport;


                if isempty(inHndl)||~ishandle(inHndl)
                    return
                end

                [nextBlk,nextPortNum]=getSrcBlockFromLine(inHndl);


                [srcBlk,srcPort]=getConnectedSource(obj,nextBlk,nextPortNum);
            case 'BusCreator'
                isDefined=createBusesForBusCreator(destBlk);
                if isDefined
                    srcBlk=destBlk;
                    srcPort=destPortNum;
                end
            otherwise




                srcBlk=destBlk;
                srcPort=destPortNum;
            end
        end

        function[busName,isBus]=getPortBusName(obj,blkName,portNum)










            busName='';
            isBus=true;


            [loadedModels,resolvedBlkName]=matlabshared.tracking.internal.SimulinkUtilities.loadModels(blkName);
            mkClean=onCleanup(@()matlabshared.tracking.internal.SimulinkUtilities.closeModels(loadedModels));

            if~isempty(loadedModels)
                rootModel=bdroot;
                rootModel=get_param(rootModel,'Handle');
                daClean=onCleanup(@()matlabshared.tracking.internal.getSBUDataAccessor(rootModel,'clear'));
            end

            blkType=get_param(resolvedBlkName,'BlockType');

            if strcmp(blkType,'Outport')||strcmp(blkType,'Inport')||strcmp(blkType,'BusCreator')
                dt=get_param(resolvedBlkName,'OutDataTypeStr');
                [isBus,busName]=isBusDataType(dt);
                if isBus
                    return
                end
                portHndls=get_param(resolvedBlkName,'PortHandles');
                hndl=portHndls.Inport(portNum);
            else
                if isThisClassInherited(resolvedBlkName)


                    sysObj=matlabshared.tracking.internal.SimulinkBusPropagation.blockConstructor(resolvedBlkName);
                    sysObj.pBusRecursion=obj.pBusRecursion;
                    sysObj.pCurrentBusIdx=getPortBusIndex(sysObj,resolvedBlkName,portNum);
                    busName=openBus(sysObj);
                    return
                else










                    dt='';
                    try %#ok<TRYNC,EMTC>
                        dt=get_param(resolvedBlkName,'OutDataTypeStr');
                    end



                    if~isempty(dt)&&startsWith(dt,'Bus: ')
                        [flag,busName]=isBusDataType(dt);
                        if~flag
                            error(message('shared_tracking:SimulinkBusUtilities:busDoesNotExist',strrep(dt,'Bus: ',''),blkName));
                        end
                        return
                    end





                    blks=regexp(resolvedBlkName,'[^/]+','match');
                    blkMdl=blks{1};
                    blkMdlFile=get_param(blkMdl,'Filename');
                    [~,~,ext]=fileparts(blkMdlFile);
                    copyMdlFile=[tempname,ext];
                    [~,copyMdl]=fileparts(copyMdlFile);


                    copyfile(blkMdlFile,copyMdlFile);



                    wkspcFile=[tempname,'.mat'];
                    localevalin(['save(''',wkspcFile,''')']);
                    clnUp=onCleanup(@()getPortBusNameCleanUp(copyMdl,copyMdlFile,wkspcFile));




                    load_system(copyMdlFile);



                    num=numel(blkMdl);
                    copyBlk=[copyMdl,resolvedBlkName(num+1:end)];


                    portHndls=get_param(copyBlk,'PortHandles');
                    hndl=portHndls.Outport(portNum);
                end
            end


            sigHier=get(hndl,'SignalHierarchy');
            if~isempty(sigHier)&&isfield(sigHier,'BusObject')&&~isempty(sigHier.BusObject)
                busName=sigHier.BusObject;
            else
                isBus=false;
            end
        end

        function flag=isInfiniteBusRecursion(obj)

            flag=numel(obj.pBusRecursion)~=numel(unique(obj.pBusRecursion));
        end
    end
end

function getPortBusNameCleanUp(copyMdl,copyMdlFile,wkspcFile)

    wksBeforeClose=localevalin('whos');
    close_system(copyMdl,0);
    wksAfterClose=localevalin('whos');
    delete(copyMdlFile);


    if~isempty(wksBeforeClose)&&...
        (isempty(wksAfterClose)||~isequal(wksBeforeClose,wksAfterClose))
        localevalin(['load(''',wkspcFile,''')']);
    end
    delete(wkspcFile);
end

function[isDefined,busName]=createBusesForBusCreator(destBlk)



    if strcmp(get_param(destBlk,'OutDataTypeStr'),'Inherit: auto')
        error(message('shared_tracking:SimulinkBusUtilities:inheritedModeNotSupportedForBusCreator',destBlk));
    end

    dataType=get_param(destBlk,'OutDataTypeStr');
    [isDefined,busName]=isBusDataType(dataType);
    if~isDefined
        error(message('shared_tracking:SimulinkBusUtilities:busDoesNotExist',busName,destBlk));
    end
end

function[connBlk,connPort,isConnDefined]=getSourceBlockFromPortConnectivity(destBlk,destPortNum)





    connBlk='';
    connPort=0;


    conn=get_param(destBlk,'PortConnectivity');
    srcBlks=[conn.SrcBlock];
    isConnDefined=~isempty(srcBlks)&&any(ishandle(srcBlks));


    if isempty(srcBlks)
        return
    end


    for m=1:numel(conn)


        thisSrcBlkHndl=conn(m).SrcBlock;
        if isempty(thisSrcBlkHndl)||~ishandle(thisSrcBlkHndl)
            continue
        end


        thisType=conn(m).Type;
        if~isCharInteger(thisType)
            continue
        end


        lineHndls=get(thisSrcBlkHndl,'LineHandles');
        outHndls=lineHndls.Outport;
        [isConnected,tryBlk,tryPort]=isDestConnected(outHndls,destBlk,destPortNum);
        if isConnected
            connBlk=tryBlk;
            connPort=tryPort;
            return
        end
    end
end

function[flag,srcName,srcPort]=isDestConnected(lineHndls,destBlk,destPortNum)











    flag=false;
    srcName='';
    srcPort=0;

    for m=1:numel(lineHndls)
        thisLineHndl=lineHndls(m);



        if~ishandle(thisLineHndl)


            continue
        end

        destBlkHndls=get(thisLineHndl,'DstBlockHandle');
        destPortHndls=get(thisLineHndl,'DstPortHandle');
        for k=1:numel(destBlkHndls)
            thisBlkHndl=destBlkHndls(k);


            if~ishandle(thisBlkHndl)
                continue
            end


            thisBlk=getFullBlockName(thisBlkHndl);
            if~strcmp(thisBlk,destBlk)
                continue
            end


            blkType=get(thisBlkHndl,'BlockType');
            switch blkType
            case{'Inport','Outport'}
                portNum=str2double(get(thisBlkHndl,'Port'));
            otherwise
                thisPortHndl=destPortHndls(k);
                portNum=get(thisPortHndl,'PortNumber');
            end

            if portNum==destPortNum
                [srcName,srcPort]=getSrcBlockFromLine(thisLineHndl);
                flag=srcPort>0;
                return
            end
        end
    end
end

function[blkName,portNum]=getSrcBlockFromLine(lineHndl)




    blkHndl=get(lineHndl,'SrcBlockHandle');
    blkName=getFullBlockName(blkHndl);

    blkType=get(blkHndl,'BlockType');
    switch blkType
    case{'Inport','Outport'}
        portNum=str2double(get(blkHndl,'Port'));
    case 'BusCreator'
        isDefined=createBusesForBusCreator(blkName);
        if isDefined
            portNum=1;
        else
            blkName='';
            portNum=0;
        end
    otherwise
        srcPort=get(lineHndl,'SourcePort');
        iFnd=strfind(srcPort,':');


        portNum=str2double(srcPort(iFnd(end)+1:end));
    end
end

function blkName=getBlockName(blkHndl)







    blkName=get(blkHndl,'Name');
    blkName=strrep(blkName,'/','//');
end

function blkPath=getFullBlockName(blkHndl)



    blkName=getBlockName(blkHndl);
    blkPath=[get(blkHndl,'Path'),'/',blkName];
end

function flag=isCharInteger(ch)



    flag=all(ch>='0')&&all(ch<='9');
end

function maskObject=getBlockMaskObject(hBlock)



    maskObject=Simulink.Mask.get(hBlock);




    if~isempty(maskObject.BaseMask)
        maskObject=maskObject.BaseMask;
    end
end

function[busNameOut,found]=findEquivalentBus(busNameIn)







    busIn=getVar(busNameIn);
    busNameOut=busNameIn;


    allBuseNames=getAllBuses();
    found=false;
    for m=1:numel(allBuseNames)

        thisBusName=allBuseNames{m};
        thisBus=getVar(thisBusName);


        if~strcmp(busNameIn,thisBusName)&&isBusEquivalent(busIn,thisBus)
            found=true;
            break
        end
    end


    if found
        busNameOut=thisBusName;
    end
end

function busNames=getAllBuses()



    da=matlabshared.tracking.internal.getSBUDataAccessor(bdroot);
    vars=da.identifyVisibleVariablesByClass('Simulink.Bus');
    busNames={vars.Name};
end

function flag=isBusEquivalent(bus1,bus2)










    flag=true;


    numEl1=numel(bus1.Elements);
    numEl2=numel(bus2.Elements);
    if numEl1~=numEl2
        flag=false;
        return
    end
    numEl=numEl1;

    if numEl==0
        return
    end




    busprops=properties(bus1.Elements(1));
    busprops=busprops(~strcmp(busprops,'DataType'));
    busprops=busprops(~strcmp(busprops,'DimensionsMode'));
    for m=1:numel(busprops)
        thisProp=busprops{m};
        for n=1:numEl
            if~isequal(bus1.Elements(n).(thisProp),bus2.Elements(n).(thisProp))
                flag=false;
                return
            end
        end
    end




    for n=1:numEl
        dt1=bus1.Elements(n).DataType;
        dt2=bus2.Elements(n).DataType;
        [isBus1,subBusName1]=isBusDataType(dt1);
        [isBus2,subBusName2]=isBusDataType(dt2);


        if isBus1~=isBus2
            flag=false;
            return
        end
        isBus=isBus1;


        if isBus
            if~strcmp(subBusName1,subBusName2)


                subbus1=getVar(subBusName1);
                subbus2=getVar(subBusName2);
                flag=isBusEquivalent(subbus1,subbus2);
                if~flag
                    return
                end
            end
        else

            if~strcmp(dt1,dt2)
                flag=false;
                return
            end
        end
    end
end

function[flag,busName]=isBusDataType(dt)



    busName='';
    flag=false;

    dt=strtrim(strrep(dt,'Bus:',''));
    if checkIfVarExist(dt)
        tmp=getVar(dt);
        flag=isa(tmp,'Simulink.Bus');
        if flag
            busName=dt;
        end
    end
end

function[flag,enumClass,enum]=isEnumeratedType(dt)





    flag=false;
    enumClass='';
    enum='';

    dt=strtrim(strrep(dt,'Enum:',''));
    [~,names]=enumeration(dt);
    if~isempty(names)
        flag=true;
        enumClass=dt;
        enum=names{1};
    end
end

function flag=isThisClassInherited(blkName)

    flag=false;

    blkType=get_param(blkName,'BlockType');
    if~strcmp(blkType,'MATLABSystem')
        return
    end

    className=get_param(blkName,'System');
    sysObj=feval(className);
    flag=isa(sysObj,'matlabshared.tracking.internal.SimulinkBusPropagation');
end

function out=localevalin(evalstr)





    if nargout>0
        out=evalinGlobalScope(bdroot,evalstr);

    else
        evalinGlobalScope(bdroot,evalstr);

    end
end

function localassignin(varname,value)





    assigninGlobalScope(bdroot,varname,value);

end

function[srcBlk,srcPort]=findConnectedReference(destMdl,destPortNum)



    srcBlk='';
    srcPort=0;


    blkName='';
    mdls=find_system('type','block_diagram');
    for m=1:numel(mdls)
        fndSys=find_system(mdls{m},'MatchFilter',@Simulink.match.allVariants,'BlockType',...
        'ModelReference','ModelName',destMdl);


        if~isempty(fndSys)


            blkName=fndSys{1};
            break
        end
    end


    if isempty(blkName)
        return
    end


    varSubSysBlk=get_param(blkName,'Parent');
    if~isempty(varSubSysBlk)
        if(isfield(get_param(varSubSysBlk,'ObjectParameters'),'Variant'))
            variantOnOff=get_param(varSubSysBlk,'Variant');
            if strcmp('on',variantOnOff)


                destPortName=getModelRefPortName(destMdl,destPortNum,'Inport');


                if isempty(destPortName)
                    return
                end

                varPortNum=findVariantPortNumber(varSubSysBlk,destPortName,'Inport');


                if varPortNum<1
                    return
                end

                blkName=varSubSysBlk;
                destPortNum=varPortNum;
            end
        end
    end


    lineHndls=get_param(blkName,'LineHandles');
    lineHndl=lineHndls.Inport(destPortNum);
    [srcBlk,srcPort]=getSrcBlockFromLine(lineHndl);
end

function portName=getModelRefPortName(refMdl,refMdlPortNum,portType)








    portName='';

    if nargin<3
        portType='Outport';
    end


    wasLoaded=~bdIsLoaded(refMdl);
    if wasLoaded
        load_system(refMdl);
        clnUp=onCleanup(@()close_system(refMdl,0));
    end

    ports=find_system(refMdl,'BlockType',portType);
    for m=1:numel(ports)
        thisPort=ports{m};


        thisPortNum=str2double(get_param(thisPort,'Port'));
        if thisPortNum==refMdlPortNum
            portName=get_param(thisPort,'PortName');
            break
        end
    end


    if wasLoaded
        delete(clnUp);
    end
end

function varPortNum=findVariantPortNumber(varBlk,portName,portType)



    if nargin<3
        portType='Outport';
    end

    varPortNum=-1;

    isMdlRef=strcmp(get_param(varBlk,'BlockType'),'ModelReference');
    if isMdlRef

        refMdl=get_param(varBlk,'ModelName');
        wasLoaded=~bdIsLoaded(refMdl);
        if wasLoaded
            load_system(refMdl);
            clnUp=onCleanup(@()close_system(refMdl,0));
        end
        thisBlk=refMdl;
    else

        thisBlk=varBlk;
    end


    blks=get_param(thisBlk,'Blocks');
    ports={};
    for m=1:numel(blks)
        thisPort=[thisBlk,'/',blks{m}];
        if strcmp(get_param(thisPort,'BlockType'),portType)
            ports{end+1,1}=thisPort;
        end
    end


    portName=strtrim(portName);
    for m=1:numel(ports)
        thisPort=ports{m};


        if strcmp(strtrim(get_param(thisPort,'PortName')),portName)
            varPortNum=str2double(get_param(thisPort,'Port'));
            break
        end
    end


    if isMdlRef&&wasLoaded
        delete(clnUp);
    end
end

function st=elements2struct(elmnts)


    st=struct;
    for m=1:numel(elmnts)
        this=elmnts(m);
        fldName=this.Name;
        [isBus,busName]=isBusDataType(this.DataType);
        if isBus
            dt=matlabshared.tracking.internal.SimulinkBusPropagation.bus2struct(busName);
            st.(fldName)=repmat(dt,this.Dimensions);
        else
            [isEnum,enumClass,enum]=isEnumeratedType(this.DataType);
            if isEnum
                dt=eval([enumClass,'.',enum]);
                dt=repmat(dt,this.Dimensions);
            else
                switch this.DataType
                case 'boolean'

                    classType='logical';
                otherwise
                    classType=this.DataType;
                end
                dt=zeros(this.Dimensions,classType);
                if~strcmp(this.Complexity,'real')
                    dt=complex(dt);
                end
            end
            st.(fldName)=dt;
        end
    end
end

function flag=isvarnamecg(name)











    if coder.target('MATLAB')
        flag=isvarname(name);
    else
        flag=~isempty(name)&&...
        (ischar(name)||isstring(name))&&...
        isstrprop(name(1),'alpha')&&all(isstrprop(name(2:end),'alphanum')|name(2:end)=='_')&&...
        ~iskeywordcg(name);
    end
end

function flag=iskeywordcg(name)




    if coder.target('MATLAB')
        flag=iskeyword(name);
    else
        flag=any(strcmp(name,matlabshared.tracking.internal.SimulinkBusPropagation.pKeywordList));
    end
end

function tf=checkIfVarExist(varName)


    da=matlabshared.tracking.internal.getSBUDataAccessor(bdroot);
    tf=da.hasVariable(varName);
end

function var=getVar(varName)


    da=matlabshared.tracking.internal.getSBUDataAccessor(bdroot);
    varID=da.identifyByName(varName);
    var=da.getVariable(varID(1));
end

function removeVar(varName)


    da=matlabshared.tracking.internal.getSBUDataAccessor(bdroot);
    da.deleteVariable(da.identifyByName(varName));
end

function createVar(varname,value)


    da=matlabshared.tracking.internal.getSBUDataAccessor(bdroot);
    da.createVariableAsExternalData(varname,value);
end

function updateVar(varname,value)


    da=matlabshared.tracking.internal.getSBUDataAccessor(bdroot);
    da.updateVariable(da.identifyByName(varname),value);
end

function flag=isBusEquivalentToStruct(busName,st)

    flag=true;
    busName=removePrefix(busName,'Bus:');
    simBus=getVar(busName);
    if isempty(simBus)
        flag=false;
        return
    end


    st=st(1);


    numEl1=numElements(simBus);
    structFieldNames=fieldnames(st);
    numEl2=numel(structFieldNames);
    if numEl1~=numEl2
        flag=false;
        return
    end
    numEl=numEl1;

    if numEl==0
        return
    end





    if~all(strcmpi(structFieldNames,elementNames(simBus)))
        flag=false;
        return
    end

    if~isequal(cellfun(@(x)size(st.(x)),structFieldNames,'UniformOutput',false),dimensions(simBus))
        flag=false;
        return
    end


    for i=1:numEl
        if isstruct(st.(structFieldNames{i}))
            flag=isBusEquivalentToStruct(simBus.Elements(i).DataType,st.(structFieldNames{i}));
        elseif islogical(st.(structFieldNames{i}))
            flag=any(strcmpi(simBus.Elements(i).DataType,{'boolean','logical'}));
        else
            flag=strcmpi(elementDataType(simBus.Elements(i)),class(st.(structFieldNames{i})));
        end

        if~flag
            return
        end
    end
end

function busName=findBusEquivalentToStruct(st)







    narginchk(1,2);
    busName='';



    sz=size(st);
    flds=fieldnames(st);
    numFlds=numel(flds);
    dimsFlds=dimensions(st);
    stFlds=structfun(@isstruct,st(1));
    buses=getAllBuses();
    for m=1:numel(buses)
        thisBusName=buses{m};
        thisBus=getVar(thisBusName);

        if isa(thisBus,'Simulink.Bus')
            sz=size(st(1));
        end

        if isempty(thisBus)

            continue
        end


        if~isequal(sz,busSize(thisBus))
            continue
        end


        num=numElements(thisBus);
        if numFlds~=num
            continue
        end


        names=elementNames(thisBus);
        if~all(cellfun(@strcmp,names,flds))
            continue
        end


        dims=dimensions(thisBus);
        if~all(cellfun(@isequal,dims,dimsFlds))
            continue
        end


        elBus=isElementBus(thisBus);
        if~all(stFlds(:)==elBus(:))
            continue
        end


        isSame=true;
        iNotBus=find(~elBus);
        for k=1:numel(iNotBus)
            iEl=iNotBus(k);
            thisName=names{iEl};
            thisVal=st.(thisName);
            thisEl=element(thisBus,iEl);


            dt=elementDataType(thisEl);
            if~isa(thisVal,dt)
                isSame=false;
                break
            end


            if isnumeric(thisVal)&&...
                (isreal(thisVal)==isComplex(thisEl))
                isSame=false;
                break
            end
        end
        if~isSame
            continue
        end


        isSame=true;
        iBus=find(elBus);
        for k=1:numel(iBus)
            iEl=iBus(k);
            thisName=names{iEl};
            thisVal=st.(thisName);
            thisEl=element(thisBus,iEl);
            elType=elementDataType(thisEl);
            if~isBusEquivalentToStruct(elType,thisVal)
                isSame=false;
                break
            end
        end

        if isSame
            busName=thisBusName;
            break
        end
    end
end


function flags=isElementBus(in)
    num=numElements(in);
    flags=false(num,1);

    for m=1:num
        el=element(in,m);
        dt=el.DataType;
        flags(m)=isBusDataType(dt);
    end
end

function dims=dimensions(in)
    if isstruct(in)
        flds=fieldnames(in);
        num=numel(flds);
    else
        num=numElements(in);
    end
    dims=cell(num,1);

    for m=1:num
        dims{m}=elementDimensions(in,m);
    end
end

function sz=busSize(in)
    if isa(in,'Simulink.Bus')
        sz=[1,1];
    else
        sz=in.Dimensions();
    end
    if isscalar(sz)
        sz=[sz,1];
    end
end

function dims=elementDimensions(in,iEl)
    el=element(in,iEl);
    if isa(el,'Simulink.Bus')
        dims=[];
    elseif isa(el,'Simulink.BusElement')
        dims=el.Dimensions;
    else
        dims=size(el);
    end
    if isscalar(dims)
        dims=[dims,1];
    end

end

function el=element(in,iEl)
    if isstruct(in)
        flds=fieldnames(in);
        thisFld=flds{iEl};
        el=in.(thisFld);
    else
        el=in.Elements(iEl);
    end
end

function names=elementNames(thisBus)
    num=numElements(thisBus);
    names=cell(num,1);
    for m=1:num
        names{m}=thisBus.Elements(m).Name;
    end
end

function num=numElements(thisBus)
    num=numel(thisBus.Elements);
end

function flag=isComplex(el)
    flag=el.Complexity;
    flag=strcmp(flag,'complex');
end

function dt=elementDataType(el)
    dt=el.DataType;
    dt=removePrefix(dt,'Bus:');
    dt=removePrefix(dt,'Enum:');

    if strcmp(dt,'boolean')

        dt='logical';
    end
end

function str=removePrefix(str,prefix)




    if startsWith(str,prefix)
        str=strtrim(str(length(prefix)+1:end));
    end
end




