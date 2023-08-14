classdef DataDictionaryFinder<mlreportgen.finder.Finder


































































    properties(Constant,Hidden)
        InvalidPropertyNames={};
    end

    properties









        Name string
    end

    properties(Access=private)

        NodeList=[]


        NodeCount{mustBeInteger}=0


        NextNodeIndex{mustBeInteger}=0


        IsIterating{mlreportgen.report.validators.mustBeLogical}=false
    end

    methods
        function this=DataDictionaryFinder(varargin)
            if nargin==1
                varargin=[{"Container"},varargin];
            elseif~any(strcmp(string(varargin(1:2:end)),"Container"))
                varargin=["Container","MATLABPath",varargin];
            end
            this=this@mlreportgen.finder.Finder(varargin{:});
            reset(this);
        end

        function results=find(this)













            mlreportgen.report.validators.mustBeVectorOf(["char","string"],this.Container);

            findImpl(this);

            results=this.NodeList;
        end
    end

    methods
        function result=next(this)















            if hasNext(this)

                result=this.NodeList(this.NextNodeIndex);

                this.NextNodeIndex=this.NextNodeIndex+1;
            else
                result=slreportgen.finder.DataDictionaryResult.empty();
            end
        end

        function tf=hasNext(this)
























            if this.IsIterating
                if this.NextNodeIndex<=this.NodeCount
                    tf=true;
                else
                    tf=false;
                end
            else
                findImpl(this);
                if this.NodeCount>0
                    this.NextNodeIndex=1;
                    this.IsIterating=true;
                    tf=true;
                else
                    tf=false;
                end
            end
        end
    end

    methods(Access=protected)
        function tf=isIterating(this)






            tf=this.IsIterating;
        end

        function reset(this)







            this.NodeList=[];
            this.IsIterating=false;
            this.NodeCount=0;
            this.NextNodeIndex=0;
        end
    end

    methods(Access=private,Hidden)
        function findImpl(this)

            if~isempty(this.Name)

                [~,name,ext]=fileparts(this.Name);
                if isempty(ext)||ext==""
                    ext=".sldd";
                elseif~strcmpi(ext,".sldd")
                    error(message("slreportgen:report:error:invalidDataDictionary",this.Name));
                end
                name=name+ext;
            else

                name="*.sldd";
            end


            if strcmp(this.Container,"MATLABPath")

                searchDirs=[pwd,strsplit(string(path),pathsep)];
            else

                searchDirs=string(this.Container);
            end


            ddList=[];
            nDirs=numel(searchDirs);
            for k=1:nDirs
                currDir=searchDirs(k);
                ddList=[ddList;dir(fullfile(currDir,name))];%#ok<AGROW>
            end

            if~isempty(ddList)

                ddPaths=fullfile({ddList.folder}',{ddList.name}');
                ddPaths=string(unique(ddPaths));

                ddPaths=filterByPropertiesList(this,ddPaths);

                nDicts=numel(ddPaths);
                nodes=slreportgen.finder.DataDictionaryResult.empty(0,nDicts);
                for k=1:nDicts
                    nodes(k)=slreportgen.finder.DataDictionaryResult(ddPaths(k));
                end


                this.NodeList=nodes;
                this.NodeCount=nDicts;
            else

                this.NodeList=slreportgen.finder.DataDictionaryResult.empty();
                this.NodeCount=0;
            end

        end

        function filteredList=filterByPropertiesList(this,ddPaths)





            filteredList=ddPaths;

            props=this.Properties;

            if~isempty(props)
                nPaths=numel(ddPaths);
                toKeep=true(1,nPaths);
                nProps=numel(props);



                for pathIdx=1:nPaths
                    try
                        dd=Simulink.data.dictionary.open(ddPaths(pathIdx));
                    catch


                        toKeep(pathIdx)=false;
                        continue
                    end



                    for i=1:2:nProps
                        propName=props{i};
                        value=props{i+1};
                        try
                            if~isequal(dd.(propName),value)
                                toKeep(pathIdx)=false;
                                break
                            end
                        catch
                            toKeep(pathIdx)=false;
                            break
                        end
                    end
                    close(dd);
                end


                filteredList=filteredList(toKeep);
            end
        end
    end

end