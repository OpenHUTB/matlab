classdef IviLibManager<handle









    properties(Access=private)
        libMap;
    end

    methods(Access=private)

        function obj=IviLibManager()


            obj.libMap=containers.Map();
        end


        function delete(~)


        end


        function localLoadIviCLibrary(obj,libName)

            prefix=instrgate('privateGetIviPath');

            binary=fullfile(prefix,'Bin',[libName,'_32.dll']);

            if(~exist(binary,'file'))
                binary=fullfile(prefix,'Bin',[libName,'.dll']);
            end

            if(~exist(binary,'file'))
                binary=fullfile(prefix,'Bin',[libName,'_64.dll']);
            end

            if(~exist(binary,'file'))
                errorID='instrument:ivic:NoSharedLibrary';
                e=MException(errorID,getString(message(errorID,binary)));
                throwAsCaller(e);
            end

            includePath=fullfile(prefix,'Include');
            includeFile=fullfile(includePath,[libName,'.h']);

            visaIncludePath=obj.localToolboxVisaPath;

            if(~libisloaded(libName))
                try
                    errFlag=instrgate('privateIviCLoadlibrary',libName,binary,includeFile,includePath,visaIncludePath);
                    if errFlag
                        errorID='instrument:ivic:FailedToloadSharedLibrary';
                        exp=MException(errorID,getString(message(errorID)));
                        throwAsCaller(exp);
                    end
                catch e
                    if strcmpi(e.identifier,'MATLAB:CompilerConfiguration:NoSelectedOptionsFile')
                        throwAsCaller(e);
                    end
                    errorID='instrument:ivic:FailedToloadSharedLibrary';
                    exp=MException(errorID,getString(message(errorID)));
                    exp=exp.addCause(e);
                    throwAsCaller(exp);
                end
            end
        end



        function visaIncludePath=localToolboxVisaPath(obj)%#ok<MANU>

            visaIncludePath={};
            visaPath=instrgate('privateGetVXIPNPPath');

            if(~isempty(visaPath))
                visaIncludePath(end+1)={fullfile(visaPath,'include')};
                visaIncludePath(end+1)={fullfile(visaPath,'agvisa','include')};

            end
        end

    end

    methods

        function loadLibrary(obj,libName)
            narginchk(2,2);


            if~isempty(obj.libMap)&&ismember(libName,obj.libMap.keys)
                refCount=obj.libMap(libName);
                refCount=refCount+1;
                obj.libMap(libName)=refCount;

            else
                obj.libMap(libName)=1;
            end
            obj.localLoadIviCLibrary(libName);

        end

        function unloadLibrary(obj,libName)
            narginchk(2,2);

            if isempty(libName)
                return;
            end


            if ismember(obj.libMap.keys,libName)
                refCount=obj.libMap(libName);
                if refCount>0
                    refCount=refCount-1;
                end
                if refCount==0

                    isSafe2Unload=instrgate('privateIviCLibSafe2Unload',libName);
                    if isSafe2Unload
                        unloadlibrary(libName);
                        obj.libMap.remove(libName);

                    end
                end

                obj.libMap(libName)=refCount;

            end

        end

        function unloadAll(obj)

            keys=obj.libMap.keys;
            for idx=1:numel(obj.libMap.keys)
                key=keys{idx};
                obj.unloadLibrary(key);
            end
        end
    end


    methods(Static=true)
        function obj=getInstance()
            persistent instance;
            if isempty(instance)||~isvalid(instance)
                instance=instrument.ivic.IviLibManager();
            end
            obj=instance;

        end

        function releaseInstance()

            instrument.ivic.IviCLibManager.getInstance().unloadAll();
            delete(instrument.ivic.IviLibManager.getInstance());
        end


    end
end


