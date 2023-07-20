classdef(Sealed=true)ProcRegistry<handle






    properties(SetAccess='private')
        tag;
        pit_default;
        pit_custom;
    end

    properties(Constant)
        pitTypeEnum={'default','custom'};
    end























    methods(Access='private')

        function this=ProcRegistry
        end
    end

    methods(Static=true)
        function singleObj=manageInstance(action,tag)



            mlock;
            persistent localStaticObj;

            idx=0;
            tagIsSpecified=exist('tag','var');

            if tagIsSpecified
                for i=1:length(localStaticObj)
                    if strcmp(tag,localStaticObj(i).handle.tag)
                        idx=i;
                        break;
                    end
                end
            end

            switch action
            case{'create','get'}
                if idx==0
                    idx=length(localStaticObj)+1;
                    localStaticObj(idx).handle=linkfoundation.pjtgenerator.ProcRegistry;
                    localStaticObj(idx).handle.tag=tag;
                end
                singleObj=localStaticObj(idx).handle;

            case 'destroy'
                if idx~=0
                    delete(localStaticObj(idx).handle);
                    localStaticObj(idx)=[];
                elseif~tagIsSpecified




                    for k=1:numel(localStaticObj)
                        delete(localStaticObj(k).handle);
                    end
                    localStaticObj=[];
                end
                if isempty(localStaticObj)
                    clear localStaticObj;
                end
                singleObj=[];

            otherwise

                singleObj=[];
                return;
            end
        end
    end


    methods(Access='private')

        function insertProc(reg,pitType,pitFile,procName,procDefFile,toolDefFile,procType)






            if(nargin>6)
                pit.procType=procType;
            end
            pit.procName=procName;
            [pitPath,pitName,pitExt]=fileparts(procDefFile);
            pit.procDefFile=[pitName,pitExt];
            [pitPath,pitName,pitExt]=fileparts(toolDefFile);
            pit.toolDefFile=[pitName,pitExt];



            pitIdx=getPITRegIdx(reg,pitFile);
            if isempty(pitIdx)
                registerPIT(reg,pitFile,pitType);
                pitIdx=getPITRegIdx(reg,pitFile);
            end


            procIdx=getProcRegIdx(reg,procName);
            if isempty(procIdx)
                switch pitType
                case 'default'
                    len=length(reg.pit_default(pitIdx).pit);

                    if len==0
                        reg.pit_default(pitIdx).pit=pit;
                    else
                        reg.pit_default(pitIdx).pit(len+1)=pit;
                    end
                case 'custom'
                    len=length(reg.pit_custom(pitIdx).pit);

                    if len==0
                        reg.pit_custom(pitIdx).pit=pit;
                    else
                        reg.pit_custom(pitIdx).pit(len+1)=pit;
                    end
                otherwise
                    DAStudio.error('ERRORHANDLER:pjtgenerator:InvalidPITFileType',pitType);
                end
            end
        end


        function removeProc(reg,pitType,pitIdx,procIdx)

            switch pitType
            case 'default'
                reg.pit_default(pitIdx).pit(procIdx)=[];
            case 'custom'
                reg.pit_custom(pitIdx).pit(procIdx)=[];
            otherwise
                DAStudio.error('ERRORHANDLER:pjtgenerator:InvalidPITFileType',pitType);
            end
        end



        function[procIdx,pitIdx,pitType]=getProcRegIdx(reg,procName,pitType)


            procIdx=[];
            pitIdx=[];
            if(nargin==2)
                pitType=[];
            end

            if(nargin<3)

                for t=1:length(reg.pitTypeEnum)
                    eval(['pitArray = reg.pit_',reg.pitTypeEnum{t},';']);
                    for i=1:length(pitArray)
                        for j=1:length(pitArray(i).pit)
                            if~isempty(strmatch(procName,pitArray(i).pit(j).procName,'exact'))

                                procIdx=j;
                                pitIdx=i;
                                pitType=reg.pitTypeEnum{t};
                                return;
                            end
                        end
                    end
                end
            else
                eval(['pitArray = reg.pit_',pitType,';']);
                for i=1:length(pitArray)
                    for j=1:length(pitArray(i).pit)
                        if~isempty(strmatch(procName,pitArray(i).pit(j).procName,'exact'))

                            procIdx=j;
                            pitIdx=i;
                            return;
                        end
                    end
                end
            end
        end


        function[pitIdx,pitType]=getPITRegIdx(reg,pitFile)

            pitIdx=[];
            pitType=[];


            for t=1:length(reg.pitTypeEnum)

                pitArray=reg.(['pit_',reg.pitTypeEnum{t}]);

                for i=1:length(pitArray)
                    if~isempty(strmatch(pitFile,pitArray(i).pitFileName,'exact'))
                        pitIdx=i;
                        pitType=reg.pitTypeEnum(t);
                        return;
                    end
                end
            end
        end


        function pit=loadPIT(reg,pitFile)

            validatePIT(reg,pitFile);


            ret=load(pitFile,'-mat');
            if~isfield(ret,'pit')

                pit=[];
                return;
            end
            pit=ret.pit;
        end


        function savePIT(reg,pitFile)


            pitFileFound=0;
            pit=[];


            for t=1:length(reg.pitTypeEnum)

                pitArray=reg.(['pit_',reg.pitTypeEnum{t}]);

                for i=1:length(pitArray)
                    if~isempty(strmatch(pitFile,pitArray(i).pitFileName,'exact'))
                        pitFileFound=1;
                        pit=pitArray(i).pit;
                        break;
                    end
                end

                if pitFileFound

                    break;
                end
            end


            if~pitFileFound
                return;
            end


            try
                save(pitFile,'pit','-mat');
            catch me
                arg=strrep(pitFile,'\','\\');
                DAStudio.error('ERRORHANDLER:pjtgenerator:PITFileNotSaved',arg,me.message);
            end
        end


        function validateProcRegFiles(reg,procDefFile,toolDefFile)

            if~exist(procDefFile,'file')
                arg=strrep(procDefFile,'\','\\');
                DAStudio.error('ERRORHANDLER:pjtgenerator:ProcDefFileNotFound',arg);
            end


            if~exist(toolDefFile,'file')
                arg=strrep(toolDefFile,'\','\\');
                DAStudio.error('ERRORHANDLER:pjtgenerator:ToolDefFileNotFound',arg);
            end
        end


        function validatePIT(reg,pitFile)
            if~exist(pitFile,'file')
                arg=strrep(pitFile,'\','\\');
                DAStudio.error('ERRORHANDLER:pjtgenerator:PITFileNotFound',arg);
            end
        end


        function info=loadDefFiles(reg,procDefFileName,toolDefFileName)



            info=[];

            data=load(procDefFileName);
            procInfo=data.procInfo;
            fields=fieldnames(procInfo);
            for i=1:length(fields)
                val=procInfo.(fields{i});
                info.(fields{i})=val;
            end


            data=load(toolDefFileName);
            toolInfo=data.toolInfo;
            fields=fieldnames(toolInfo);
            for i=1:length(fields)
                val=toolInfo.(fields{i});
                info.(fields{i})=val;
            end
        end

    end
end
