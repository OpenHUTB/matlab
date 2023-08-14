classdef AlgorithmDispatcher<handle




    properties

Algorithm



        AlgorithmClass='';


AlgorithmName

    end

    properties(Dependent)


Fullpath




FolderFromRepository
    end

    methods(Abstract,Static,Hidden)

        repo=getRepository()
    end

    methods

        function configure(this,classname)
            repo=this.getRepository();

            this.AlgorithmClass=classname;
            this.AlgorithmName=repo.getAlgorithmName(classname);

        end


        function tf=isAlgorithmOnPath(this)

            if isempty(this.Fullpath)
                tf=false;
            else
                tf=true;
            end
        end






        function[tf,msg]=isAlgorithmValid(this)

            metaClass=meta.class.fromName(this.AlgorithmClass);
            methodList=metaClass.MethodList;
            methodNames={methodList.Name};


            classStrings=strsplit(this.AlgorithmClass,'.');
            constructorName=classStrings{end};

            constructor=methodList(strcmpi(constructorName,methodNames));


            if isa(constructor,'meta.method')&&numel(constructor.InputNames)>0
                tf=false;
                msg=vision.getMessage('vision:labeler:NoArgConstructorNeeded');
            else
                tf=true;
                msg=string.empty();
            end

        end









        function algorithms=getInstance(this,algorithms)
            classes=cellfun(@(x)class(x),algorithms,'UniformOutput',false);
            match=strcmp(this.AlgorithmClass,classes);
            if~any(match)
                instantiate(this);


                algorithms{end+1}=this.Algorithm;
            else
                this.Algorithm=algorithms{match};
            end
        end





        function instantiate(this)
            assert(not(isempty(this.AlgorithmClass)),'Call configure first!');
            this.Algorithm=eval(this.AlgorithmClass);

        end




        function p=get.Fullpath(this)
            assert(not(isempty(this.AlgorithmClass)),'Call configure first!');
            p=which(this.AlgorithmClass);
        end





        function p=get.FolderFromRepository(this)
            repo=this.getRepository();
            p=repo.getAlgorithmFolder(this.AlgorithmClass);
        end

    end
end
