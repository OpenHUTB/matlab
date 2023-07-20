classdef CustomTpRegistry<handle




    properties(Dependent,Access=private)

SpPkgName
    end

    properties(SetAccess=immutable)

SpRoot
    end

    properties(Access=private)

TpToolDataFile
    end

    methods
        function obj=CustomTpRegistry(spPkgName)

            validateattributes(spPkgName,{'char'},{'nonempty'});

            obj.SpRoot=matlabshared.supportpkg.getSupportPackageRoot();
            obj.SpPkgName=spPkgName;


            obj.createTpToolDataFile();
        end

        function set.SpPkgName(obj,name)
            spPkgNameTag=obj.getPkgTag(name);
            tpToolDataDir=fullfile(obj.SpRoot,'thirdpartytools');
            if~exist(tpToolDataDir,'dir')
                mkdir(tpToolDataDir);
            end
            obj.TpToolDataFile=fullfile(obj.SpRoot,'thirdpartytools',...
            [spPkgNameTag,'_tpdata.mat']);
        end

        function addTpToolInfo(obj,tpToolName,tpToolInfo)



            validateattributes(tpToolName,{'char'},{'nonempty'});
            validateattributes(tpToolInfo,{'char'},{'nonempty'});

            data=load(obj.TpToolDataFile);
            assert(isfield(data,'tpData'),['File ',obj.TpToolDataFile,' is corrupt']);

            data.tpData(tpToolName)=tpToolInfo;
            tpData=data.tpData;

            save(obj.TpToolDataFile,'tpData');
        end

        function out=isTpToolInstalled(obj,name)



            validateattributes(name,{'char'},{'nonempty'});
            data=load(obj.TpToolDataFile);%#ok<*NASGU>
            if~isfield(data,'tpData')

                out=false;
                return;
            end
            out=isKey(data.tpData,name);
        end

        function out=getTpToolInfo(obj,name)


            validateattributes(name,{'char'},{'nonempty'});
            data=load(obj.TpToolDataFile);
            if~isfield(data,'tpData')||~isKey(data.tpData,name)


                out='';
                return;
            end
            out=data.tpData(name);
        end
    end
    methods(Access=private)
        function createTpToolDataFile(obj)
            if exist(obj.TpToolDataFile,'file')==2
                return
            end
            tpData=containers.Map;
            save(obj.TpToolDataFile,'tpData');
        end

        function pkgTag=getPkgTag(obj,name)

            pkgTag=regexprep(name,'\(R\)','');
            pkgTag=regexprep(pkgTag,'\W','');
            pkgTag=lower(pkgTag);
        end
    end
end