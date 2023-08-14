classdef RMExclusionMgr<handle




    properties
myInstallDir
cachedFlags

checkTestroot
myTestroot
checkTestrootLength

demodirPattern1
demodirPattern2

checkQualkit
myQualkit
checkQualkitLength
    end

    methods(Access=private)
        function obj=RMExclusionMgr()
            obj.myInstallDir=matlabroot;
            obj.cachedFlags=containers.Map('KeyType','char','ValueType','logical');

            obj.cachedFlags('simulink')=true;
            obj.cachedFlags('reqmanage')=true;
            obj.cachedFlags('vnvdemowidgets')=true;
            obj.cachedFlags('eml_lib')=true;


            obj.myTestroot=fullfile(obj.myInstallDir,'test');
            obj.checkTestroot=(exist(obj.myTestroot,'dir')==7);
            obj.checkTestrootLength=length(obj.myTestroot);


            obj.demodirPattern1=[strrep(fullfile(obj.myInstallDir,'toolbox'),filesep,''),'\w+demos'];
            obj.demodirPattern2=[strrep(obj.myInstallDir,filesep,''),'\w*examples\w+'];


            obj.myQualkit=fullfile(obj.myInstallDir,'toolbox','qualkits');
            obj.checkQualkit=(exist(obj.myQualkit,'dir')==7);
            obj.checkQualkitLength=length(obj.myQualkit);
        end

        function yesno=isqualkitFile(this,pathToFile)
            yesno=this.checkQualkit&&strncmpi(pathToFile,this.myQualkit,this.checkQualkitLength);
        end

        function yesno=isTestsuiteFile(this,pathToFile)
            yesno=this.checkTestroot&&strncmpi(pathToFile,this.myTestroot,this.checkTestrootLength);
        end

        function yesno=isExampleFile(this,pathToFile)
            pathToFile(pathToFile==filesep)='';
            yesno=~isempty(regexp(pathToFile,this.demodirPattern1,'once'))||...
            ~isempty(regexp(pathToFile,this.demodirPattern2,'once'));
        end

    end

    methods(Static)
        function obj=getInstance()
            persistent exclusionMgr
            if isempty(exclusionMgr)
                exclusionMgr=rmiut.RMExclusionMgr();
            end
            obj=exclusionMgr;
        end
    end

    methods

        function out=checkCached(this,in)
            if isKey(this.cachedFlags,in)
                out=this.cachedFlags(in);
            else
                out=[];
            end
        end

        function value=cache(this,name,value)
            this.cachedFlags(name)=value;
        end

        function out=check(this,pathToFile,shortName)
            isSL=(nargin==3);
            if~isSL

                if~startsWith(pathToFile,this.myInstallDir)
                    out=false;
                    this.cachedFlags(pathToFile)=false;
                    return;
                end
            end

            out=~this.isTestsuiteFile(pathToFile)...
            &&~this.isExampleFile(pathToFile)...
            &&~this.isqualkitFile(pathToFile);


            if isSL
                this.cachedFlags(shortName)=out;
            else
                this.cachedFlags(pathToFile)=out;
            end
        end

    end

end
