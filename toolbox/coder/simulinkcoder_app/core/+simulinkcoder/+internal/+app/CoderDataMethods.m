classdef CoderDataMethods<handle





    methods(Static=true,Access=private)
        function[name,n]=generateNextName(cellArray,nameTemplate,startN)
            n=startN;
            names=cellfun(@(c)c.Name,cellArray,'uni',false);
            foundName=false;
            while~foundName
                name=sprintf(nameTemplate,n);
                foundName=isempty(find(strcmp(names,name),1));
                n=n+1;
            end
        end
    end

    methods(Static,Hidden)
        function refreshDropDownList(sourceHandle,field)

            if isa(sourceHandle,'Simulink.ConfigSet')||...
                isa(sourceHandle,'Simulink.ConfigSetDialogController')
                simulinkcoder.internal.app.notifyOptionListChanged(sourceHandle,field);
            else
                simulinkcoder.internal.app.notifyOptionListChanged(...
                get_param(sourceHandle,'Handle'),field);
            end
        end

        function out=getMemorySectionNames(cs)
            import simulinkcoder.internal.app.CoderDataMethods.*;
            out={};
            if strcmp(cs.get_param('IsERTTarget'),'on')
                currentPkg=get_param(cs,'MemSecPackage');
                if~strcmp(currentPkg,'--- None ---')
                    memsecs=processcsc('GetMemorySectionDefns',currentPkg);
                    for i=1:length(memsecs)
                        out=[out,memsecs(i).Name];%#ok<AGROW>
                    end
                end
            end
        end

        function showHelp(topic)
            mapFile=fullfile(docroot,'ecoder','helptargets.map');
            helpview(mapFile,topic);
        end

        function result=ValidateInput(storeID,field,value)
            persistent am;
            persistent cg;
            result='';
            if isempty(cg)
                cg=Simulink.CoderGroup;
            end
            if isempty(am)
                am=Simulink.AccessMethod;
            end
            switch storeID
            case 'coderdata_coder_group_table'
                data=cg;
            case 'coderdata_access_method_table'
                data=am;
            otherwise

                return;
            end
            switch field
            case 'name'
                field='Name';
            end
            try
                data.(field)=value;
                result='success';
            catch me
                result=me.message;
            end
        end

        function result=setProperty(model,storeHandler,storeIndex,propertyName,value)
            result='';
            if strcmp(storeHandler,'coderdata_coder_group_table')
                configSetParamName='CoderGroups';
            elseif strcmp(storeHandler,'coderdata_access_method_table')
                configSetParamName='AccessMethods';
            end
            if~isempty(configSetParamName)
                cs=hGetConfigSet(model);
                cellArray=get_param(cs,configSetParamName);
                cellIndex=storeIndex+1;
                try
                    cellArray{cellIndex}.(propertyName)=value;
                catch me
                    result=me.message;
                    return;
                end
                configSetCache=cs.getConfigSetCache;
                if~isempty(configSetCache)


                    cacheArray=configSetCache.get_param(configSetParamName);
                    cacheArray{cellIndex}.(propertyName)=value;
                end
            end
        end

        function deleteCoderData(model,objectID,storeIndices)
            import simulinkcoder.internal.app.CoderDataMethods.*;
            if strcmp(objectID,'groupTable_tableStore')
                deleteCoderGroup(model,storeIndices);
            elseif strcmp(objectID,'accessMethodTable_tableStore')
                deleteAccessMethod(model,storeIndices);
            end
        end

        function createCoderGroup(model)
            persistent n;
            if isempty(n)
                n=1;
            end
            cs=hGetConfigSet(model);
            coderGroups=cs.get_param('CoderGroups');
            if isempty(coderGroups)
                coderGroups={};
            end
            [newName,n]=simulinkcoder.internal.app.CoderDataMethods.generateNextName(...
            coderGroups,'CoderGroup%d',n);
            newCoderGroup=Simulink.CoderGroup;
            newCoderGroup.Name=newName;
            coderGroups{end+1}=newCoderGroup;
            hSetParam(cs,'CoderGroups',coderGroups);
        end

        function deleteCoderGroup(model,storeIndex)
            cs=hGetConfigSet(model);
            cgs=get_param(cs,'CoderGroups');
            if~isempty(cgs)&&~isempty(storeIndex)

                storeIndex=sort(storeIndex);
                for i=length(storeIndex):-1:1
                    cgs(storeIndex(i)+1)=[];
                end
                hSetParam(cs,'CoderGroups',cgs);
            end
        end

        function cloneCoderGroup(model,storeIndex)

            cs=hGetConfigSet(model);
            cgs=get_param(cs,'CoderGroups');
            if~isempty(cgs)&&~isempty(storeIndex)
                for i=1:length(storeIndex)
                    newEntry=cgs{storeIndex(i)+1}.copy;
                    cgs{end+1}=newEntry;
                end
                hSetParam(cs,'CoderGroups',cgs);
            end
        end

        function createAccessMethod(model)
            import simulinkcoder.internal.app.CoderDataMethods.*;
            persistent n;
            if isempty(n)
                n=1;
            end
            cs=hGetConfigSet(model);
            accessMethods=get_param(cs,'AccessMethods');
            if isempty(accessMethods)
                accessMethods={};
            end
            [newName,n]=generateNextName(accessMethods,'AccessMethod%d',n);
            newAccessMethod=Simulink.AccessMethod;
            newAccessMethod.Name=newName;
            accessMethods{end+1}=newAccessMethod;
            hSetParam(cs,'AccessMethods',accessMethods);
            controller=cs.getDialogController;
            refreshDropDownList(controller,'AccessMethod');
        end

        function deleteAccessMethod(model,storeIndex)
            import simulinkcoder.internal.app.CoderDataMethods.*;
            cs=hGetConfigSet(model);
            cgs=get_param(cs,'AccessMethods');
            if~isempty(cgs)&&~isempty(storeIndex)

                storeIndex=sort(storeIndex);
                for i=length(storeIndex):-1:1
                    cgs(storeIndex(i)+1)=[];
                end
                hSetParam(cs,'AccessMethods',cgs);
                controller=cs.getDialogController;
                refreshDropDownList(controller,'AccessMethod');
            end
        end

        function cloneAccessMethod(model,storeIndex)
            import simulinkcoder.internal.app.CoderDataMethods.*;

            cs=hGetConfigSet(model);
            cgs=get_param(cs,'AccessMethods');
            if~isempty(cgs)&&~isempty(storeIndex)
                for i=1:length(storeIndex)
                    newEntry=cgs{storeIndex(i)+1}.copy;
                    cgs{end+1}=newEntry;%#ok<AGROW>
                end
                hSetParam(cs,'AccessMethods',cgs);
                controller=cs.getDialogController;
                refreshDropDownList(controller,'AccessMethod');
            end
        end
        function cs=getConfigSet(sourceHandle)
            cs=hGetConfigSet(sourceHandle);
        end
        function msg=getStorageClassInNonBuiltinPkgMsg(ddConnection,refreshPkg)

            pkgs=coder.internal.CoderDataStaticAPI.getPackageList(refreshPkg);
            pkgs=pkgs(~ismember(pkgs,'SimulinkBuiltin'));
            classInDict=cell(1,length(pkgs));
            classInPkg=cell(1,length(pkgs));
            for i=1:length(pkgs)
                pkg=pkgs{i};
                classInDict{i}=coder.internal.CoderDataStaticAPI.getLegacyStorageClassInDictByPackage(...
                ddConnection,pkg);
                x=processcsc('GetAllDefns',pkg);
                idx=1;
                for j=1:length(x{1})
                    currentName=x{1}(j).Name;
                    if~strcmp(currentName,'Default')
                        y{idx}=x{1}(j).Name;%#ok<AGROW>
                        idx=idx+1;
                    end
                end
                classInPkg{i}=setdiff(y,classInDict{i});
            end
            curr_pkgs=coder.internal.CoderDataStaticAPI.getCurrentNonBuiltinPackages(ddConnection);



            for i=1:length(curr_pkgs)
                curr_pkg=curr_pkgs{i};
                if~ismember(curr_pkg,pkgs)
                    pkgs{end+1}=curr_pkg;%#ok
                end
            end
            msg.data.pkgs=pkgs;
            if isempty(pkgs)
                msg.data.currentPkg='';
            else
                msg.data.currentPkg=curr_pkgs;
            end
            msg.data.classInPkg=classInPkg;
            msg.data.classInDict=classInDict;
        end
        function getStorageClassInNonBuiltinPkg(ddConnection,clientID,channel,refreshPkg)
            import simulinkcoder.internal.app.CoderDataMethods.*;
            if refreshPkg
                data.SpinnerText=message('SimulinkCoderApp:ui:RefreshPackageSpinnerText').getString;
                simulinkcoder.internal.app.CoderDataMethods.sendCommand(channel,'start_spin',clientID,data);
                c=onCleanup(@()simulinkcoder.internal.app.CoderDataMethods.sendCommand(channel,'stop_spin',clientID));
            end
            msg=getStorageClassInNonBuiltinPkgMsg(ddConnection,refreshPkg);
            msg.clientID=clientID;
            msg.messageID='responseStorageClassInPackage';
            message.publish(channel,msg);
        end
        function sendCommand(channel,msgId,clientID,data)
            msg.messageID=msgId;
            if nargin==4
                msg.data=data;
            end
            msg.clientID=clientID;
            message.publish(channel,msg);
        end
    end
end

function cs=hGetConfigSet(sourceHandle)
    if isa(sourceHandle,'Simulink.ConfigSetDialogController')
        cs=sourceHandle.getSourceObject;
    elseif isa(sourceHandle,'Simulink.ConfigSet')
        cs=sourceHandle;
    elseif isa(sourceHandle,'Simulink.ConfigSetRef')
        cs=sourceHandle.getRefConfigSet();
    else
        try
            cs=getActiveConfigSet(sourceHandle);
        catch
            cs=[];
        end
        if isa(cs,'Simulink.ConfigSetRef')
            cs=cs.getRefConfigSet();
        end
    end
end

function hSetParam(model,param,value)

    try
        cs=hGetConfigSet(model);
        set_param(cs,param,value);
        csc=cs.getConfigSetCache;
        if~isempty(csc)


            csc.set_param(param,value);
        end
    catch ME
        if strcmp(ME.identifier,'Simulink:Data:InValid_DuplicateNamePropertyForParam')
            MSLDiagnostic(ME.identifier,class(value{1})).reportAsWarning;
        else
            rethrow(ME);
        end
    end
end


