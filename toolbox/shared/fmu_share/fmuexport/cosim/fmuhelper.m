classdef(Hidden=true)fmuhelper<handle
    properties
isMATLABVisible

resourceObjLocation
workDir
modelDescription
modelPathName
modelName
projectName
projectHandle

input
output
parameter

realMap
intMap
boolMap
stringMap

noWksNameVRmap
ndimMap
vrlist
dtlist
valuelist

mexPath

systemType

bdWarnState
bdWarnObj
bdDataObj
    end

    methods

        function out=getRelease(obj)
            r=ver('Simulink');
            out=r.Release(2:end-1);
        end

        function ret=isStringDataType(this,dtStr)
            try
                dtObj=Simulink.data.evalinGlobal(this.modelName,dtStr);
                ret=false;
            catch
                if isempty(Simulink.internal.getStringDTExprFromDTName(dtStr))
                    ret=false;
                else
                    ret=true;
                end
            end
        end

        function ret=getCoSimVar(obj,scope,varName,varElement)
            if isempty(scope)
                var=Simulink.fmuexport.internal.getSetCoSimVar(obj.modelName,varName);
                ret=eval(['var',varElement]);
            else
                ret=evalin(scope,[varName,varElement]);
            end
        end

        function setCoSimVarStr(obj,scope,varName,varElement,varValueStr)
            if isempty(scope)
                var=Simulink.fmuexport.internal.getSetCoSimVar(obj.modelName,varName);
                eval(['var',varElement,'=',varValueStr,';']);
                Simulink.fmuexport.internal.getSetCoSimVar(obj.modelName,varName,var);
            else
                evalin(scope,[varName,varElement,'=',varValueStr,';']);
            end
        end


        function obj=fmuhelper()
            obj.isMATLABVisible=~isempty(Simulink.fmuexport.internal.getSetCoSimVar('','IsVisible'));

            obj.bdWarnState=warning('backtrace','off');
            obj.bdWarnObj=onCleanup(@()warning(obj.bdWarnState));



            obj.resourceObjLocation=pwd;


            parser=internal.fmudialog.xmlParser.load(...
            fullfile(obj.resourceObjLocation,'modelDescription.xml'));
            obj.modelDescription=parser.xmlFile;




            verNode=obj.modelDescription.getElementsByTagName('ImportCompatibility').item(0);
            if isempty(verNode)
                throwAsCaller(MSLException([],message('FMUShare:FMU:IncompatibleMATLABRelease',obj.getRelease)));
            elseif~strcmp(char(verNode.getAttribute('requireRelease')),obj.getRelease)
                throwAsCaller(MSLException([],message('FMUShare:FMU:IncompatibleMATLABRelease2',obj.getRelease,char(verNode.getAttribute('requireRelease')))));
            end

            spNode=obj.modelDescription.getElementsByTagName('SimulinkProject').item(0);
            if~isempty(spNode)


                obj.systemType='SimulinkProject';
                obj.modelPathName=char(spNode.getAttribute('modelName'));
                [~,obj.modelName,~]=fileparts(obj.modelPathName);
                obj.projectName=char(spNode.getAttribute('projectName'));


                randStr=strrep(char(matlab.lang.internal.uuid),'-','_');
                mkdir(randStr);cd(randStr);
                obj.workDir=pwd;


                unzip(fullfile('..',obj.projectName),obj.workDir);
                try

                    if(obj.isMATLABVisible)
                        obj.projectHandle=openProject('.');
                    else
                        obj.projectHandle=matlab.internal.project.api.makeProjectAvailable('.');
                    end

                catch ME

                    if(strcmp(ME.identifier,'MATLAB:project:api:LoadFail'))
                        if(obj.isMATLABVisible)
                            obj.projectHandle=openProject(fullfile('main','.'));
                        else
                            obj.projectHandle=matlab.internal.project.api.makeProjectAvailable(fullfile('main','.'));
                        end
                    else
                        rethrow(ME);
                    end
                end

                bdclose all

                if obj.isMATLABVisible
                    open_system(obj.modelPathName);
                else
                    load_system(obj.modelPathName);
                end
            end




            smiNode=obj.modelDescription.getElementsByTagName('SimulinkModelInterface').item(0);
            ilist=smiNode.getElementsByTagName('Inport');
            obj.input=containers.Map;
            for i=1:ilist.getLength
                node=ilist.item(i-1);
                tag=char(node.getAttribute('tag'));
                s=struct(...
                'index',i,...
                'bPath',char(node.getAttribute('blockPath')),...
                'ts',char(node.getAttribute('sampleTime')),...
                'dim',char(node.getAttribute('dimension')),...
                'dt',char(node.getAttribute('dataType')),...
                'unit',char(node.getAttribute('unit')));

                obj.input(tag)=s;
            end

            olist=smiNode.getElementsByTagName('Outport');
            obj.output=containers.Map;
            for i=1:olist.getLength
                node=olist.item(i-1);
                tag=char(node.getAttribute('tag'));
                s=struct(...
                'index',i,...
                'bPath',char(node.getAttribute('blockPath')),...
                'ts',char(node.getAttribute('sampleTime')),...
                'dim',char(node.getAttribute('dimension')),...
                'dt',char(node.getAttribute('dataType')),...
                'unit',char(node.getAttribute('unit')));

                obj.output(tag)=s;
            end

            plist=smiNode.getElementsByTagName('ModelArgument');
            obj.parameter=containers.Map;
            for i=1:plist.getLength
                node=plist.item(i-1);
                tag=char(node.getAttribute('tag'));
                s=struct(...
                'index',i,...
                'dim',char(node.getAttribute('dimension'))...
                );
                obj.parameter(tag)=s;
            end


            obj.realMap=containers.Map('KeyType','uint32','ValueType','any');
            obj.intMap=containers.Map('KeyType','uint32','ValueType','any');
            obj.boolMap=containers.Map('KeyType','uint32','ValueType','any');
            obj.stringMap=containers.Map('KeyType','uint32','ValueType','any');
            obj.noWksNameVRmap=containers.Map('KeyType','char','ValueType','uint32');
            obj.ndimMap=containers.Map('KeyType','char','ValueType','uint32');
            svNodeList=obj.modelDescription.getElementsByTagName('ModelVariables').item(0).getElementsByTagName('ScalarVariable');
            for i=1:svNodeList.getLength
                node=svNodeList.item(i-1);
                dataNode=node.getElementsByTagName('Annotations').item(0).getElementsByTagName('Data').item(0);

                s=struct('tag',char(dataNode.getAttribute('tag')),...
                'elementAccess',char(dataNode.getAttribute('elementAccess')));
                vr=str2double(node.getAttribute('valueReference'));


                if strcmp(node.getAttribute('causality'),'parameter')
                    s.wks=get_param(obj.modelName,'ModelWorkspace');
                    s.isParameter=1;
                    s.isInput=0;
                    s.isOutput=0;
                else


                    s.wks=[];
                    s.isParameter=0;
                    if strcmp(node.getAttribute('causality'),'input')
                        s.isInput=1;
                        s.isOutput=0;
                    else
                        s.isInput=0;
                        s.isOutput=1;
                    end


                    obj.noWksNameVRmap([s.tag,s.elementAccess])=uint32(vr);
                end

                if node.getElementsByTagName('Real').getLength>0
                    obj.realMap(vr)=s;
                    vNode=node.getElementsByTagName('Real').item(0);

                    if vNode.hasAttribute('start')
                        startVal=char(vNode.getAttribute('start'));
                    else
                        startVal='0';
                    end
                elseif node.getElementsByTagName('Integer').getLength>0||node.getElementsByTagName('Enumeration').getLength
                    obj.intMap(vr)=s;
                    vNode=node.getElementsByTagName('Integer').item(0);

                    if vNode.hasAttribute('start')
                        startVal=['int32(',char(vNode.getAttribute('start')),')'];
                    else
                        startVal='int32(0)';
                    end

                elseif node.getElementsByTagName('Boolean').getLength>0
                    obj.boolMap(vr)=s;
                    vNode=node.getElementsByTagName('Boolean').item(0);

                    if vNode.hasAttribute('start')
                        startVal=['boolean(',char(vNode.getAttribute('start')),')'];
                    else
                        startVal='boolean(0)';
                    end

                elseif node.getElementsByTagName('String').getLength>0
                    if strcmp(node.getAttribute('causality'),'input')
                        s.isStringInput=1;
                    else
                        s.isStringInput=0;
                    end

                    obj.stringMap(vr)=s;
                    vNode=node.getElementsByTagName('String').item(0);

                    if vNode.hasAttribute('start')
                        startVal=['"',char(vNode.getAttribute('start')),'"'];
                    else
                        startVal='""';
                    end

                else
                    assert(false,'Unknown scalar variable data type.');
                end

                obj.setCoSimVarStr(s.wks,s.tag,s.elementAccess,startVal);
                if isempty(s.wks)


                    key=s.tag;
                    fieldVect=split(s.elementAccess,'.')';
                    val=sum(ismember(fieldVect{1},'(,'));
                    obj.ndimMap(key)=val;

                    for fieldStr=fieldVect(2:end)
                        fieldName=split(fieldStr{1},'(');fieldName=fieldName{1};
                        key=[key,'.',fieldName];
                        val=sum(ismember(fieldStr{1},'(,'));
                        obj.ndimMap(key)=val;
                    end
                end
            end




            set_param(obj.modelName,'EnablePauseTimes','off');


        end


        function[rList,iList,bList,sList]=getPreInitVariableListAndValue(obj)





            rList=struct('vr',cell(1,0),'value',cell(1,0),'causality',cell(1,0));
            for i=obj.realMap.keys
                vr=i{1};
                s=obj.realMap(i{1});
                if s.isInput==1
                    causality=0;
                    value=obj.getCoSimVar(s.wks,s.tag,s.elementAccess);
                elseif s.isOutput==1
                    causality=1;
                    value=0;
                elseif s.isParameter==1
                    causality=2;
                    value=obj.getCoSimVar(s.wks,s.tag,s.elementAccess);
                end
                rList=[rList,struct('vr',uint32(vr),'value',value,'causality',int32(causality))];%#ok
            end

            iList=struct('vr',cell(1,0),'value',cell(1,0),'causality',cell(1,0));
            for i=obj.intMap.keys
                vr=i{1};
                s=obj.intMap(i{1});
                if s.isInput==1
                    causality=0;
                    value=obj.getCoSimVar(s.wks,s.tag,s.elementAccess);
                elseif s.isOutput==1
                    causality=1;
                    value=0;
                elseif s.isParameter==1
                    causality=2;
                    value=obj.getCoSimVar(s.wks,s.tag,s.elementAccess);
                end
                iList=[iList,struct('vr',uint32(vr),'value',int32(value),'causality',int32(causality))];%#ok
            end

            bList=struct('vr',cell(1,0),'value',cell(1,0),'causality',cell(1,0));
            for i=obj.boolMap.keys
                vr=i{1};
                s=obj.boolMap(i{1});
                if s.isInput==1
                    causality=0;
                    value=obj.getCoSimVar(s.wks,s.tag,s.elementAccess);
                elseif s.isOutput==1
                    causality=1;
                    value=0;
                elseif s.isParameter==1
                    causality=2;
                    value=obj.getCoSimVar(s.wks,s.tag,s.elementAccess);
                end
                bList=[bList,struct('vr',uint32(vr),'value',int32(value),'causality',int32(causality))];%#ok
            end

            sList=struct('vr',cell(1,0),'value',cell(1,0),'causality',cell(1,0));
            for i=obj.stringMap.keys
                vr=i{1};
                s=obj.stringMap(i{1});
                value=uint8(unicode2native(obj.getCoSimVar(s.wks,s.tag,s.elementAccess),'UTF-8'));
                if s.isInput==1
                    causality=0;
                    value=unicode2native(obj.getCoSimVar(s.wks,s.tag,s.elementAccess),'UTF-8');
                elseif s.isOutput==1
                    causality=1;
                    value=[];
                elseif s.isParameter==1
                    causality=2;
                    value=unicode2native(obj.getCoSimVar(s.wks,s.tag,s.elementAccess),'UTF-8');
                end
                sList=[sList,struct('vr',uint32(vr),'value',uint8(value),'causality',int32(causality))];%#ok
            end
        end


        function expand(obj,var,name,ndimKey)
            if isa(var,'double')
                obj.vrlist=[obj.vrlist;obj.noWksNameVRmap(name)];
                obj.dtlist=[obj.dtlist;int32(0)];
                obj.valuelist=[obj.valuelist;var];
            elseif isa(var,'int32')
                obj.vrlist=[obj.vrlist;obj.noWksNameVRmap(name)];
                obj.dtlist=[obj.dtlist;int32(1)];
                obj.valuelist=[obj.valuelist;var];
            elseif isa(var,'logical')
                obj.vrlist=[obj.vrlist;obj.noWksNameVRmap(name)];
                obj.dtlist=[obj.dtlist;int32(2)];
                obj.valuelist=[obj.valuelist;var];
            elseif isa(var,'char')
                assert(false,'unsupported data type.');
            elseif isstruct(var)
                fields=fieldnames(var);
                for i=1:length(fields)
                    obj.expandArray(var.(fields{i}),[name,'.',fields{i}],[ndimKey,'.',fields{i}]);
                end
            end
        end

        function expandArray(obj,var,name,ndimKey)

            ndim=obj.ndimMap(ndimKey);
            if ndim==0

                obj.expand(var,name,ndimKey);
            else
                if ndim==1
                    dimension=length(var);
                else
                    varDim=size(var);
                    dimension=[varDim,ones(1,ndim-length(varDim))];
                end


                dims=ones(1,length(dimension));
                for iter=1:numel(var)
                    dimsStr=['(',strjoin(arrayfun(@(x)num2str(x),dims,'UniformOutput',false),','),')'];
                    obj.expand(var(iter),[name,dimsStr],ndimKey);


                    j=1;
                    while 1
                        dims(j)=dims(j)+1;
                        if(j==length(dims)||dims(j)<=dimension(j))
                            break;
                        end
                        dims(j)=1;j=j+1;
                    end
                end
            end
        end


        function setPostInitVariableValue(obj,rValue,iValue,bValue,sValue)





            for i=1:length(rValue)
                vr=rValue(i).vr;
                value=rValue(i).value;
                s=obj.realMap(vr);

                obj.setCoSimVarStr(s.wks,s.tag,s.elementAccess,...
                ['double(',num2str(value,'%.18g'),')']);
            end
            for i=1:length(iValue)
                vr=iValue(i).vr;
                value=iValue(i).value;
                s=obj.intMap(vr);

                obj.setCoSimVarStr(s.wks,s.tag,s.elementAccess,...
                ['int32(',num2str(value),')']);
            end
            for i=1:length(bValue)
                vr=bValue(i).vr;
                value=bValue(i).value;
                s=obj.boolMap(vr);

                obj.setCoSimVarStr(s.wks,s.tag,s.elementAccess,...
                ['boolean(',num2str(value),')']);
            end
            for i=1:length(sValue)
                vr=sValue(i).vr;
                value=sValue(i).value;
                s=obj.stringMap(vr);

                obj.setCoSimVarStr(s.wks,s.tag,s.elementAccess,...
                ['"',native2unicode(uint8(value),'UTF-8'),'"']);
            end



            inputs=cell(obj.input.Count,1);
            for i=1:obj.input.Count
                tag=['cosimTransformedInput_',num2str(i)];
                var=Simulink.fmuexport.internal.getSetCoSimVar(obj.modelName,tag);

                obj.vrlist={};obj.dtlist={};obj.valuelist={};
                obj.expandArray(var,tag,tag);

                inputs{i}=struct('vr',obj.vrlist,'dt',obj.dtlist,'value',obj.valuelist);
            end

            outputs=cell(obj.output.Count,1);
            for i=1:obj.output.Count
                tag=['cosimTransformedOutput_',num2str(i)];
                var=Simulink.fmuexport.internal.getSetCoSimVar(obj.modelName,tag);

                obj.vrlist={};obj.dtlist={};obj.valuelist={};
                obj.expandArray(var,tag,tag);

                outputs{i}=struct('vr',obj.vrlist,'dt',obj.dtlist,'value',obj.valuelist);
            end

            Simulink.fmuexport.internal.getSetCoSimVar(...
            obj.modelName,'CoSimCommunicationSignalLayout',...
            struct('inputs',{inputs},'outputs',{outputs}));
        end
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...

        function setPostStartParameterVariableValue(obj,rVR,iVR,bVR,sVR,rValue,iValue,bValue,sValue)







            hasParameterUpdate=false;


            for i=1:length(rValue)
                vr=rVR(i);
                value=rValue(i);
                s=obj.realMap(vr);
                if s.isParameter==1
                    hasParameterUpdate=true;
                end

                obj.setCoSimVarStr(s.wks,s.tag,s.elementAccess,...
                ['double(',num2str(value,'%.18g'),')']);
            end
            for i=1:length(iValue)
                vr=iVR(i);
                value=iValue(i);
                s=obj.intMap(vr);
                if s.isParameter==1
                    hasParameterUpdate=true;
                end

                obj.setCoSimVarStr(s.wks,s.tag,s.elementAccess,...
                ['int32(',num2str(value),')']);
            end
            for i=1:length(bValue)
                vr=bVR(i);
                value=bValue(i);
                s=obj.boolMap(vr);
                if s.isParameter==1
                    hasParameterUpdate=true;
                end

                obj.setCoSimVarStr(s.wks,s.tag,s.elementAccess,...
                ['boolean(',num2str(value),')']);
            end
            for i=1:length(sValue)
                vr=sVR(i);
                value=sValue(i);
                s=obj.stringMap(vr);
                if s.isParameter==1
                    hasParameterUpdate=true;
                end

                obj.setCoSimVarStr(s.wks,s.tag,s.elementAccess,...
                ['"',native2unicode(uint8(value),'UTF-8'),'"']);
            end

            if hasParameterUpdate




                set_param(obj.modelName,'SimulationCommand','update');
            end
        end


        function delete(obj)

            try

                while~strcmp(get_param(obj.modelName,'simulationstatus'),'stopped')
                    pause(0.1)
                end

                if strcmp(obj.systemType,'SimulinkModel')

                    close_system(obj.modelName,0);
                elseif strcmp(obj.systemType,'SimulinkProject')

                    close_system(obj.modelName,0);
                    bdclose('all');
                    obj.projectHandle.close;

                    cd(obj.resourceObjLocation);

                    rmdir(obj.workDir,'s');
                end
            catch
            end

            try

                if~isempty(obj.modelName)
                    Simulink.fmuexport.internal.getSetCoSimVar(obj.modelName,'');
                end
            catch
            end

            try

                if~isempty(obj.bdDataObj)&&obj.bdDataObj.isvalid
                    obj.bdDataObj.delete;
                end
            catch
            end















            try
                if~isempty(obj.bdWarnObj)&&obj.bdWarnObj.isvalid
                    obj.bdWarnObj.delete;
                end
            catch
            end
        end


        function startCheckForSimulationServerMode(obj)




            fprintf('%s\n',DAStudio.message('FMUShare:FMU:StartingCoSimulation'));
            try
                startStr=num2str(Simulink.fmuexport.internal.getSetCoSimVar(obj.modelName,'cosimStartTime'),'%.18g');
                if isempty(startStr)

                    startStr=get_param(obj.modelName,'StartTime');
                end

                stopStr=num2str(Simulink.fmuexport.internal.getSetCoSimVar(obj.modelName,'cosimStopTime'),'%.18g');
                if isempty(stopStr)

                    stopStr=get_param(obj.modelName,'StopTime');
                end





                set_param(obj.modelName,'StartTime',startStr,'StopTime',stopStr,...
                'ReturnWorkspaceOutputs','on','ReturnWorkspaceOutputsName','CoSimOutputsObj');

                obj.bdDataObj=onCleanup(@()evalin('base','clear(''CoSimOutputsObj'')'));


                set_param(obj.modelName,'CompileForCoSimTarget','FMUCoSim');

                set_param(obj.modelName,'simulationcommand','update');
            catch ex

                fprintf('%s\n',DAStudio.message('FMUShare:FMU:SimulationTerminatedCompileTimeError',ex.message));

                throwAsCaller(MSLException([],message('FMUShare:FMU:SimulationTerminatedCompileTimeError',ex.message)));
            end
        end

        function terminationCheckForSimulationServerMode(obj)












            try

                while~strcmp(get_param(obj.modelName,'simulationstatus'),'stopped')
                    pause(0.1)
                end
                data=evalin('base','CoSimOutputsObj');
            catch

                fprintf('%s\n',DAStudio.message('FMUShare:FMU:SimulationTerminatedGenericRuntimeError'));

                throwAsCaller(MSLException([],message('FMUShare:FMU:SimulationTerminatedGenericRuntimeError')));
            end

            if isempty(data.ErrorMessage)

                fprintf('%s\n',DAStudio.message('FMUShare:FMU:SimulationTerminatedLocal'));
            else

                fprintf('%s\n',DAStudio.message('FMUShare:FMU:SimulationTerminatedRuntimeError',MSLDiagnostic.getMsgToDisplay(true,data.ErrorMessage)));

                throwAsCaller(MSLException([],message('FMUShare:FMU:SimulationTerminatedRuntimeError',MSLDiagnostic.getMsgToDisplay(true,data.ErrorMessage))));
            end


        end

    end

end
