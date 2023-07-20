
classdef AlgorithmRepository<handle

    properties(Abstract,Constant)


PackageRoot

    end

    properties(Constant)

        BaseClass='AutomationAlgorithm';
    end

    properties


AlgorithmList


Names


Fullpath
    end

    properties(Access=private)
ImportedAlgorithms
    end

    properties(Dependent)

Count
    end

    methods(Static,Abstract)



        repo=getInstance()
    end

    methods



        function refresh(this)


            packageRoot=string(this.PackageRoot);
            pkg=cell(numel(packageRoot),1);
            for n=1:numel(packageRoot)
                pkg{n}=meta.package.fromName(packageRoot(n));
            end

            this.AlgorithmList={};
            this.Names=string.empty;
            this.Fullpath=string.empty;
            for n=1:numel(pkg)
                if~isempty(pkg{n})
                    for i=1:numel(pkg{n}.ClassList)

                        metaClass=pkg{n}.ClassList(i);

                        if isAutomationAlgorithm(this,metaClass)&&hasSupportedSignalType(this,metaClass)
                            this.AlgorithmList{end+1}=metaClass.Name;
                            this.Names(end+1)=getNameFromAlgorithm(this,metaClass);
                            this.Fullpath(end+1)=which(metaClass.Name);
                        end

                    end
                end
            end


            for i=1:numel(this.ImportedAlgorithms)
                s=this.ImportedAlgorithms{i};
                this.AlgorithmList{end+1}=s.AlgorithmName;
                this.Fullpath(end+1)=s.FullPath;



                metaClass=meta.class.fromName(s.AlgorithmName);
                if~isempty(metaClass)
                    this.Names(end+1)=this.getNameFromAlgorithm(metaClass);
                else
                    this.Names(end+1)=s.Name;
                end
            end
        end




        function appendImportedAlgorithm(this,className,fullpath)
            if~any(ismember(this.AlgorithmList,className))
                metaClass=meta.class.fromName(className);
                if isAutomationAlgorithm(this,metaClass)

                    s.AlgorithmName=className;
                    s.Name=getNameFromAlgorithm(this,metaClass);
                    s.FullPath=fullpath;




                    this.ImportedAlgorithms{end+1}=s;
                else
                    errorMessage=vision.getMessage('vision:labeler:NotAnAutomationAlgorithm',className);
                    dialogName=getString(message('vision:labeler:NotAnAutomationAlgorithmDlg'));
                    errordlg(errorMessage,dialogName,'modal');
                    return;
                end
            end
        end


        function n=get.Count(this)
            n=numel(this.AlgorithmList);
        end


        function name=getAlgorithmNameByIndex(this,idx)
            name=char(this.Names(idx));
        end


        function desc=getAlgorithmDescription(this,idx)
            try
                desc=eval([this.AlgorithmList{idx},'.Description']);
                if ischar(desc)||isstring(desc)
                    isValid=true;
                else
                    isValid=false;
                end
            catch
                isValid=false;
            end

            if~isValid
                desc='';
            end
        end





        function cls=getAlgorithmName(this,className)
            idx=string(this.AlgorithmList)==className;
            if any(idx)
                cls=this.Names{idx};
            else
                errorMessage=vision.getMessage('vision:labeler:AlgorithmNotFoundMessage',className);
                dialogName=getString(message('vision:labeler:AlgorithmNotFoundTitle'));
                errordlg(errorMessage,dialogName,'modal');
                cls='';
                return;
            end
        end


        function fullpath=getAlgorithmFolder(this,classname)

            idx=string(this.AlgorithmList)==classname;
            fullpath=char(this.Fullpath(idx));

            packageRoot=string(this.PackageRoot);
            match={};
            for n=1:numel(packageRoot)
                str=strsplit(packageRoot{n},'.');
                str=strcat(regexptranslate('escape','+'),str);
                escapedFilesep=regexptranslate('escape',filesep);
                str=strjoin(str,regexptranslate('escape',escapedFilesep));
                expr=strcat('(.*',escapedFilesep,')',str,escapedFilesep);

                attemptedMatch=regexp(fullpath,expr,'tokens');
                if~isempty(attemptedMatch)
                    match=attemptedMatch;
                end
            end

            if~isempty(match)
                fullpath=match{1}{1};
            else
                fullpath=char(this.Fullpath(idx));
            end
        end


        function tf=isAutomationAlgorithm(this,metaClass)



            metaSuperclass=metaClass.SuperclassList;
            superclasses={metaSuperclass.Name};

            packageRoot=string(this.PackageRoot);
            tf=false;
            for n=1:numel(packageRoot)
                expectedClass=[char(packageRoot(n)),'.',this.BaseClass];
                tf=tf||ismember(expectedClass,superclasses)&&~metaClass.Abstract;
            end
        end





        function name=getNameFromAlgorithm(this,metaClass)
            try
                name=eval([metaClass.Name,'.Name']);
                if ischar(name)||(~isempty(strtrim(name))&&(isstring(name)))
                    isValidName=true;
                else
                    isValidName=false;
                end
            catch
                isValidName=false;
            end
            if~isValidName

                name=strrep(metaClass.Name,[metaClass.ContainingPackage.Name,'.'],'');
            end

            name=string(name);
        end
    end


    methods(Access=protected)



        function this=AlgorithmRepository()
            refresh(this)
        end


        function TF=hasSupportedSignalType(~,metaClass)




            signalfun=str2func(['@(x)',metaClass.Name,'.checkSignalType(x)']);
            TF=signalfun(vision.labeler.loading.SignalType.Image);
        end

    end


    methods(Hidden)



        function retval=getImportedAlgorithms(this)
            retval=this.ImportedAlgorithms;
        end




        function setImportedAlgorithms(this,val)
            this.ImportedAlgorithms=val;
        end
    end
end