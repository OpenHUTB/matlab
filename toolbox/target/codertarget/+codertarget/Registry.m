classdef(Sealed=true,Hidden)Registry<matlab.mixin.SetGet





    properties(SetAccess='private')
    end

    properties(SetAccess='private')
        AttributeRegEntries;
        ParameterRegEntries;
        SchedulerRegEntries;
        RTOSRegEntries;
        TargetBoardRegEntries;
        TargetRegEntries;
    end

    methods(Access='private')
        function this=Registry
            this.AttributeRegEntries=codertarget.RegistryEntry('codertarget.attributes.AttributeInfo');
            this.ParameterRegEntries=codertarget.RegistryEntry('codertarget.parameter.ParameterInfo');
            this.SchedulerRegEntries=codertarget.RegistryEntry('codertarget.scheduler.SchedulerInfo');
            this.RTOSRegEntries=codertarget.RegistryEntry('codertarget.rtos.RTOSInfo');
            this.TargetBoardRegEntries=codertarget.RegistryEntry('codertarget.targethardware.TargetHardwareInfo');
            this.TargetRegEntries=codertarget.RegistryEntry('matlabshared.targetsdk.Target');
        end
    end

    methods(Static=true,Hidden)
        function returnObj=manageInstance(action,type,defFile)


            mlock;
            persistent LocalStaticObj;
            if isempty(LocalStaticObj)
                LocalStaticObj=codertarget.Registry();
            end
            returnObj=[];
            switch action
            case 'get'
                defFile=codertarget.Registry.reducePath(defFile);
                switch lower(type)
                case 'attributes'
                    returnObj=LocalStaticObj.getRegEntry('AttributeRegEntries',defFile);
                case 'parameters'
                    returnObj=LocalStaticObj.getRegEntry('ParameterRegEntries',defFile);
                case 'rtos'
                    returnObj=LocalStaticObj.getRegEntry('RTOSRegEntries',defFile);
                case 'scheduler'
                    returnObj=LocalStaticObj.getRegEntry('SchedulerRegEntries',defFile);
                case 'targethardware'
                    returnObj=LocalStaticObj.getRegEntry('TargetBoardRegEntries',defFile);
                case 'target'
                    returnObj=LocalStaticObj.getTargetRegEntry('TargetRegEntries',defFile);
                case 'targethardware_v2'
                    targetName=defFile{1};
                    hwName=defFile{2};
                    returnObj=LocalStaticObj.getInfoEntry('TargetBoardRegEntries',targetName,hwName);
                otherwise
                    assert(false,'not a recognized coder target XML type');
                end
            case{'set','reset'}
                defFile=codertarget.Registry.reducePath(defFile);
                switch lower(type)
                case 'attributes'
                    returnObj=LocalStaticObj.setRegEntry('AttributeRegEntries',defFile);
                case 'parameters'
                    returnObj=LocalStaticObj.setRegEntry('ParameterRegEntries',defFile);
                case 'rtos'
                    returnObj=LocalStaticObj.setRegEntry('RTOSRegEntries',defFile);
                case 'scheduler'
                    returnObj=LocalStaticObj.setRegEntry('SchedulerRegEntries',defFile);
                case 'targethardware'
                    returnObj=LocalStaticObj.setRegEntry('TargetBoardRegEntries',defFile);
                case 'target'
                    returnObj=LocalStaticObj.setTargetRegEntry('TargetRegEntries',defFile);
                otherwise
                    assert(false,'not a recognized coder target XML type');
                end
            case 'destroy'
                LocalStaticObj.AttributeRegEntries.clean();
                LocalStaticObj.ParameterRegEntries.clean();
                LocalStaticObj.SchedulerRegEntries.clean();
                LocalStaticObj.RTOSRegEntries.clean();
                LocalStaticObj.TargetBoardRegEntries.clean();
                LocalStaticObj.TargetRegEntries.clean();
            otherwise
            end
        end
    end

    methods(Access=private,Static=true)
        function opath=reducePath(ipath)
            if iscell(ipath)
                opath=ipath;
            else
                ipath=regexprep(ipath,'\\','/');
                rexp='[\\/][^\\/\:\*\?\"\<\>\|]+[\\/]\.\.';
                opath=regexprep(ipath,rexp,'','ONCE');


                while~strcmp(opath,ipath)
                    ipath=opath;
                    opath=regexprep(ipath,rexp,'','ONCE');
                end


                trailpat='[\\/]$';
                opath=regexprep(opath,trailpat,'');
                opath=regexprep(opath,'^\./',regexprep([pwd,'/'],'\\','/'),'ONCE');
                opath=regexprep(opath,'^\../',regexprep([pwd,'/../'],'\\','/'),'ONCE');
            end
        end
    end

    methods(Access=private)
        function returnObj=getRegEntry(h,fieldName,defFile)
            assert(ismember(fieldName,properties('codertarget.Registry')));
            if~isempty(h.(fieldName))&&...
                ismember(h.(fieldName),defFile)
                returnObj=h.(fieldName).get(defFile);
            else

                obj=feval(h.(fieldName).Type,fullfile(defFile));
                h.(fieldName).set(defFile,obj);
                returnObj=obj;
            end
        end
        function returnObj=getTargetRegEntry(h,fieldName,defFile)
            assert(ismember(fieldName,properties('codertarget.Registry')));
            if~isempty(h.(fieldName))&&...
                ismember(h.(fieldName),defFile)
                returnObj=h.(fieldName).get(defFile);
            else
                obj=matlabshared.targetsdk.loadTarget(fullfile(defFile));
                h.(fieldName).set(defFile,obj);
                returnObj=obj;
            end
        end
        function returnObj=setRegEntry(h,fieldName,defFile)
            assert(ismember(fieldName,properties('codertarget.Registry')));
            obj=feval(h.(fieldName).Type,fullfile(defFile));
            h.(fieldName).set(defFile,obj);
            returnObj=getRegEntry(h,fieldName,defFile);
        end
        function returnObj=setTargetRegEntry(h,fieldName,defFile)
            assert(ismember(fieldName,properties('codertarget.Registry')));
            obj=matlabshared.targetsdk.loadTarget(fullfile(defFile));
            h.(fieldName).set(defFile,obj);
            returnObj=getTargetRegEntry(h,fieldName,defFile);
        end
        function returnObj=getInfoEntry(h,fieldName,targetName,hwName,varargin)
            returnObj=[];
            if~isempty(h.(fieldName))&&...
                ismember(h.(fieldName),hwName)
                returnObj=h.(fieldName).get(hwName);
            else
                tgtObj=h.manageInstance('get','target',targetName);
                if~isempty(tgtObj)
                    switch(fieldName)
                    case 'TargetBoardRegEntries'
                        obj=codertarget.DataModelAdapter.getHwInfo(tgtObj,hwName);

                        h.TargetBoardRegEntries.set(obj.Name,obj);
                        [attributeInfo,schedulerInfos,rtosInfos]=codertarget.DataModelAdapter.getFeatures(tgtObj,hwName,obj);

                        h.AttributeRegEntries.set(attributeInfo.getDefinitionFileName,attributeInfo);

                        for i=1:numel(schedulerInfos)
                            h.SchedulerRegEntries.set(schedulerInfos{i}.getDefinitionFileName,schedulerInfos{i})
                        end

                        for i=1:numel(rtosInfos)
                            h.RTOSRegEntries.set(rtosInfos{i}.getDefinitionFileName,rtosInfos{i});
                        end
                    end
                    returnObj=obj;
                end
            end
        end
    end
    methods
        function set.AttributeRegEntries(h,val)
            if isa(val,'codertarget.RegistryEntry')
                h.AttributeRegEntries=val;
            end
        end
        function set.ParameterRegEntries(h,val)
            if isa(val,'codertarget.RegistryEntry')
                h.ParameterRegEntries=val;
            end
        end
        function set.RTOSRegEntries(h,val)
            if isa(val,'codertarget.RegistryEntry')
                h.RTOSRegEntries=val;
            end
        end
        function set.SchedulerRegEntries(h,val)
            if isa(val,'codertarget.RegistryEntry')
                h.SchedulerRegEntries=val;
            end
        end
        function set.TargetBoardRegEntries(h,val)
            if isa(val,'codertarget.RegistryEntry')
                h.TargetBoardRegEntries=val;
            end
        end
        function set.TargetRegEntries(h,val)
            if isa(val,'codertarget.RegistryEntry')
                h.TargetRegEntries=val;
            end
        end
    end
end
