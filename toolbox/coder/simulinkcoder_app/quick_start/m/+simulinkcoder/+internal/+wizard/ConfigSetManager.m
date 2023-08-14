


classdef ConfigSetManager<handle
    properties
ModelHandle






OldMdlRefConfigSetMap
OldConfigSet
CSRefWSVarMap
CSRefDDVarMap
        SubModels={}



        UpdatedModels={}



Dirty








UpdateLogOptional
UpdateLogRequired
HardwareDevice
    end

    methods

        function obj=ConfigSetManager(modelHandle)
            obj.ModelHandle=simulinkcoder.internal.wizard.Wizard.getModelHandle(modelHandle);
            modelHandle=obj.ModelHandle;
            obj.OldMdlRefConfigSetMap=containers.Map;
            csOrig=getActiveConfigSet(modelHandle);
            obj.OldConfigSet=csOrig;
            obj.Dirty=false;
            obj.CSRefWSVarMap=containers.Map;
            obj.CSRefDDVarMap=containers.Map;
        end
        function out=ModelName(obj)
            out=get_param(obj.ModelHandle,'Name');
        end

        function name=getNonClashingName(~,name,nameset)
            timestamp=strrep(num2str(clock),'.','');
            underscoredTimeStamp=strjoin(strsplit(timestamp),'_');

            while~isempty(intersect({name},nameset))
                name=sprintf('%s%d','QuickStart_',underscoredTimeStamp);
                underscoredTimeStamp=strjoin(strsplit(timestamp),'_');


                pause(0.001);
            end
        end

        function setParamInBaseNonDirty(obj,modelHandle,param,value)

            preserveDirty=Simulink.PreserveDirtyFlag(modelHandle,'blockDiagram');%#ok<NASGU>

            cs=obj.getNormalActiveCS(modelHandle);
            set_param(cs,param,value);
        end



        function cs=getNormalActiveCS(~,modelHandle)
            cs=getActiveConfigSet(modelHandle);
            if isa(cs,'Simulink.ConfigSetRef')
                cs=cs.getRefConfigSet();
            end
        end

        function applyChanges(obj)
            obj.applyChangesToTopModel();
            obj.applyChangesToSubModels();
        end

        function applyChangesToTopModel(obj)
            if obj.Dirty
                obj.updateCSInModel(obj.ModelHandle);
            end
        end

        function out=ddHasCSVar(obj,dd_name,ddvar)
            if~isKey(obj.CSRefDDVarMap,dd_name)
                out=false;
                return;
            end
            ddvar_array=obj.CSRefDDVarMap(dd_name);
            hasCSVar=false;
            for i=1:length(ddvar_array)
                hasCSVar=strcmp(ddvar_array{i,1},ddvar);
                if hasCSVar
                    break;
                end
            end
            out=hasCSVar;
        end

        function out=getDDVarName(obj,dd_name,ddvar)
            if~isKey(obj.CSRefDDVarMap,dd_name)
                out=false;
                return;
            end
            ddvar_array=obj.CSRefDDVarMap(dd_name);
            out='';
            for i=1:length(ddvar_array)
                if strcmp(ddvar_array{i,1},ddvar)
                    out=ddvar_array{i,2};
                    break;
                end
            end
        end


        function switchReferencedVar(obj,modelHandle)


            oldCS=obj.getOldConfigSet(modelHandle);
            assert(isa(oldCS,'Simulink.ConfigSetRef'));

            if strcmp(oldCS.getSourceLocation,'Base Workspace')
                wsvar=oldCS.WSVarName;



                if~isKey(obj.CSRefWSVarMap,wsvar)

                    nameset=evalin('base','who');
                    name=obj.getNonClashingName(wsvar,nameset);
                    basecs=oldCS.getRefConfigSet();
                    basecs=basecs.copy;
                    basecs.Name=name;
                    obj.applyUpdatesToModel(basecs);
                    assignin('base',name,basecs);




                    obj.CSRefWSVarMap(wsvar)=name;
                end

                newCS=oldCS.copy;
                newCS.SourceName=obj.CSRefWSVarMap(wsvar);
                set_param(newCS,'Name',newCS.SourceName);
                attachConfigSet(modelHandle,newCS,false);
            else
                dd_name=get_param(modelHandle,'DataDictionary');
                dd=Simulink.dd.open(dd_name);
                ddvar=oldCS.SourceName;

                if~obj.ddHasCSVar(dd_name,ddvar)

                    nameset=dd.evalin('who','Configurations');
                    name=obj.getNonClashingName(ddvar,nameset);

                    basecs=oldCS.getRefConfigSet();
                    basecs=basecs.copy;
                    basecs.Name=name;
                    obj.applyUpdatesToModel(basecs);
                    dd.insertEntry('Configurations',name,basecs,'Configuration');




                    if isKey(obj.CSRefDDVarMap,dd_name)
                        obj.CSRefDDVarMap(dd_name)=[obj.CSRefDDVarMap(dd_name);{ddvar,name}];
                    else
                        obj.CSRefDDVarMap(dd_name)={ddvar,name};
                    end
                end

                newCS=oldCS.copy;
                newCS.SourceName=obj.getDDVarName(dd_name,ddvar);
                set_param(newCS,'Name',newCS.SourceName);
                attachConfigSet(modelHandle,newCS,false);
            end


            setActiveConfigSet(modelHandle,newCS.Name);
        end


        function hasChanged=configSetChanged(obj)


            hasChanged=obj.Dirty||~isempty(obj.HardwareDevice);
        end

        function updateCSInModel(obj,currentM)

            currentCSorig=getActiveConfigSet(currentM);
            obj.setOldConfigSet(currentM,currentCSorig);
            if isa(currentCSorig,'Simulink.ConfigSetRef')
                obj.switchReferencedVar(currentM);
            else
                currentCS=obj.getNormalActiveCS(currentM);
                currentCSCopy=currentCS.copy;
                currentCSCopy.Name=obj.getNonClashingName(currentCS.Name,getConfigSets(currentM));
                attachConfigSet(currentM,currentCSCopy,false);
                setActiveConfigSet(currentM,currentCSCopy.Name);
                obj.applyUpdatesToModel(currentCSCopy);
            end
        end

        function applyUpdatesToModel(obj,currentCSCopy,varargin)

            nothrow=false;
            if nargin==3
                nothrow=varargin{1};
            end


            if~strcmp(obj.getParam('SystemTargetFile'),get_param(currentCSCopy,'SystemTargetFile'))
                set_param(currentCSCopy,'SystemTargetFile',obj.getParam('SystemTargetFile'));
            end



            if~isempty(obj.HardwareDevice)

                hwCC=currentCSCopy.find('-isa','Simulink.HardwareCC');
                slprivate('setHardwareDevice',hwCC,'Production',obj.HardwareDevice);
            end


            adaptor=configset.internal.data.ConfigSetAdapter(currentCSCopy);
            for j=1:length(obj.UpdateLogRequired)
                currentP=obj.UpdateLogRequired{j};

                try
                    set_param(currentCSCopy,currentP.Parameter,currentP.Value);
                catch me
                    if~nothrow
                        if adaptor.getParamStatus(currentP.Parameter)==configset.internal.data.ParamStatus.Normal||...
                            (adaptor.getParamStatus(currentP.Parameter)==configset.internal.data.ParamStatus.UnAvailable&&...
                            ~currentCSCopy.isValidParam(currentP.Parameter))
                            error(message('RTW:wizard:CannotSetParameter',currentP.Parameter,me.message));
                        end
                    end
                end
            end

            if~isempty(obj.UpdateLogOptional)&&~iscell(obj.UpdateLogOptional)
                obj.UpdateLogOptional={obj.UpdateLogOptional};
            end
            for j=1:length(obj.UpdateLogOptional)
                currentP=obj.UpdateLogOptional{j};


                try
                    set_param(currentCSCopy,currentP.Parameter,currentP.Value);
                catch
                end
            end
        end


        function applyChangesToSubModels(obj)

            if~obj.configSetChanged()||isempty(obj.SubModels)
                return;
            end


            for i=1:length(obj.SubModels)
                currentM=obj.SubModels{i};
                wasLoaded=bdIsLoaded(currentM);

                load_system(currentM);
                oc=onCleanup(@()obj.closeSystem(currentM,wasLoaded));


                obj.updateCSInModel(currentM);


                simulinkcoder.internal.wizard.Wizard.saveModel(currentM);


                obj.UpdatedModels{end+1}=currentM;
            end
        end


        function out=getOldConfigSet(obj,model)
            modelHandle=simulinkcoder.internal.wizard.Wizard.getModelHandle(model);
            model=get_param(modelHandle,'name');

            if modelHandle==obj.ModelHandle
                out=obj.OldConfigSet;
            else
                out=[];
                if obj.OldMdlRefConfigSetMap.isKey(model)
                    out=obj.OldMdlRefConfigSetMap(model);
                end
            end
        end
        function out=getOldConfigSetDeepCopy(obj,model)
            model=simulinkcoder.internal.wizard.Wizard.getModelHandle(model);
            cs=obj.getOldConfigSet(model);
            if isa(cs,'Simulink.ConfigSetRef')
                base=cs.getRefConfigSet();
                out=base.copy;
            else
                out=cs.copy;
            end

        end
        function setOldConfigSet(obj,model,cs)

            modelHandle=simulinkcoder.internal.wizard.Wizard.getModelHandle(model);
            model=get_param(modelHandle,'name');
            if modelHandle==obj.ModelHandle
                obj.OldConfigSet=cs;
            else
                obj.OldMdlRefConfigSetMap(model)=cs;
            end
        end






        function revertConfigSet(obj,varargin)
            function locRevertCSForModel(model)
                try

                    currentCS=getActiveConfigSet(model);





                    if ischar(model)&&...
                        ~obj.OldMdlRefConfigSetMap.isKey(model)
                        return;
                    end

                    oldCS=obj.getOldConfigSet(model);



                    if strcmp(currentCS.Name,oldCS.Name)
                        return;
                    end


                    if isempty(intersect(getConfigSets(model),{oldCS.Name}))
                        attachConfigSet(model,oldCS,false);
                    end

                    setActiveConfigSet(model,oldCS.Name);
                    detachConfigSet(model,currentCS.Name);
                catch me
                    Simulink.output.warning(me.message);
                end
            end


            locRevertCSForModel(obj.ModelHandle);

            obj.setOldConfigSet(obj.ModelHandle,getActiveConfigSet(obj.ModelHandle));


            updatedSubModels=setdiff(obj.UpdatedModels,{obj.ModelName});
            for i=1:length(updatedSubModels)
                currentM=updatedSubModels{i};
                wasLoaded=bdIsLoaded(currentM);
                load_system(currentM);
                oc=onCleanup(@()obj.closeSystem(currentM,wasLoaded));
                locRevertCSForModel(currentM);


                if strcmp(get_param(currentM,'Dirty'),'on')
                    simulinkcoder.internal.wizard.Wizard.saveModel(currentM);
                end
                clear('oc');
            end

            if~(nargin==2&&varargin{1})
                obj.Dirty=false;
                obj.UpdateLogOptional={};
                obj.UpdateLogRequired={};
            end


            csKeys=keys(obj.CSRefWSVarMap);
            for i=1:length(csKeys)
                currentValue=obj.CSRefWSVarMap(csKeys{i});
                evalin('base',['clear (''',currentValue,''')']);
            end



            dds=keys(obj.CSRefDDVarMap);
            for i=1:length(dds)
                currentDDCSVars=obj.CSRefDDVarMap(dds{i});
                [nRows,~]=size(currentDDCSVars);
                dd=Simulink.dd.open(dds{i});
                if dd.isvalid&&dd.isOpen
                    for j=1:nRows
                        [~,newName]=currentDDCSVars{j,:};
                        fullname=['Configurations.',newName];
                        if dd.entryExists(fullname,false)
                            dd.deleteEntry(fullname);
                        end
                    end
                end
            end


            obj.UpdatedModels={};


            if~(nargin==2&&varargin{1})
                obj.HardwareDevice=[];
            end


            obj.CSRefWSVarMap=containers.Map;
            obj.CSRefDDVarMap=containers.Map;
        end

        function setParamRequired(obj,name,value)
            obj.UpdateLogRequired{end+1}=struct('Parameter',name,'Value',value);

            obj.setDirty(name,value)
        end
        function setParamOptional(obj,name,value)
            obj.UpdateLogOptional{end+1}=struct('Parameter',name,'Value',value);

            obj.setDirty(name,value)
        end

        function setDirty(obj,name,value)

            try
                sameValue=isequal(get_param(obj.ModelHandle,name),value);
            catch me
                if strcmp(me.identifier,'Simulink:Commands:ParamUnknown')||...
                    strcmp(me.identifier,'Simulink:Commands:ParamUnknownInGroup')||...
                    strcmp(me.identifier,'Simulink:ConfigSet:IgnoredParam')
                    sameValue=false;
                else
                    rethrow(me);
                end
            end
            if~sameValue
                obj.Dirty=true;
            end
        end

        function setHardwareDevice(obj,hwDevice)
            obj.HardwareDevice=hwDevice;
            obj.Dirty=true;
        end



        function out=getHWCC(obj)
            cs=obj.getNormalActiveCS(obj.ModelHandle);
            hwcc=cs.find('-isa','Simulink.HardwareCC');
            out=hwcc.copy();
        end



        function out=getSolverInfo(obj)


            csOrig=obj.getNormalActiveCS(obj.ModelHandle);
            cs=csOrig.copy;
            obj.applyUpdatesToModel(cs,true);


            out=configset.getParameterInfo(cs,'Solver');
        end

        function cs=getUpdatedTempCS(obj)
            csOrig=obj.getNormalActiveCS(obj.ModelHandle);
            cs=csOrig.copy;
            obj.applyUpdatesToModel(cs,true);
        end




        function out=getParam(obj,name)
            out=obj.getParamByType(name,'required');
            if~isempty(out)
                return;
            end
            out=obj.getParamByType(name,'optional');
            if isempty(out)
                out=get_param(obj.ModelHandle,name);
            end
        end

        function out=getParamByType(obj,name,type)
            if strcmp(type,'required')
                log=obj.UpdateLogRequired;
            else
                log=obj.UpdateLogOptional;
            end
            out=[];
            if~isempty(log)&&~iscell(log)
                log={log};
            end
            for i=1:length(log)
                if strcmpi(log{i}.Parameter,name)
                    out=log{i}.Value;
                end
            end
        end


        function out=getProdDevice(obj,hh)

            currentDevice=get_param(obj.ModelHandle,'ProdHWDeviceType');
            out=hh.getDevice(currentDevice);
        end


        function SwitchToGRT(obj)


            if strcmp(get_param(obj.ModelHandle,'IsERTTarget'),'on')
                obj.setParamRequired('SystemTargetFile','grt.tlc');
            end
        end

        function SwitchToERT(obj)


            if~strcmp(get_param(obj.ModelHandle,'IsERTTarget'),'on')||strcmp(get_param(obj.ModelHandle,'SystemTargetFile'),'autosar.tlc')
                obj.setParamRequired('SystemTargetFile','ert.tlc');
            end
        end
    end
    methods(Static)
        function closeSystem(modelHandle,wasLoaded)
            if~wasLoaded
                close_system(modelHandle);
            end
        end
        function switchTarget(cs,target)
            if~isa(cs,'Simulink.ConfigSetRef')
                cs.switchTarget(target,[]);
            else
                evalin('base',[cs.WSVarName,'.switchTarget(''',target,''', []);']);
            end
        end

    end
end

