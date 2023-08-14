classdef DictionaryFinder<mlreportgen.finder.Finder






















    properties(Constant,Hidden)
        InvalidPropertyNames={};
    end

    properties(Access=private)
DictObj
        DictList=[]
        DictCount{mustBeInteger}=0
        NextDictIndex{mustBeInteger}=0
        IsIterating{mlreportgen.report.validators.mustBeLogical}=false
    end

    properties


        Type="Model";
    end

    methods(Static,Access=private,Hidden)
        function dictionaryInformation=createDictionaryStruct(type,name,interfaceNames)%#ok<*INUSL>




            dictionaryObject=systemcomposer.openDictionary(string(name));
            dictionaryInformation.obj=dictionaryObject;
            dictionaryInformation.Type=type;
            dictionaryInformation.Name=string(name);
            dictionaryInformation.Interfaces=string(interfaceNames);
        end

        function scope=isModelScope(this)


            model=systemcomposer.loadModel(this.Container);
            scope=true;
            for interface=model.InterfaceDictionary.Interfaces
                if isequal(interface.Owner.getImpl.getStorageContext,systemcomposer.architecture.model.interface.Context.DICTIONARY)
                    scope=false;
                end
            end
        end
    end

    methods(Hidden)
        function results=getResultsArrayFromStruct(this,dictionaryInformation)
            import systemcomposer.query.*;
            n=numel(dictionaryInformation);
            results=mlreportgen.finder.Result.empty(0,n);
            for i=1:n
                temp=dictionaryInformation(i);
                results(i)=systemcomposer.rptgen.finder.DictionaryResult(temp.obj.UUID);
                results(i).Type=temp.Type;
                results(i).Name=temp.Name;
                results(i).Interfaces=temp.Interfaces;
            end
            this.DictList=results;
            this.DictCount=numel(results);
        end


        function results=findDictionaries(this)
            dictionariesInformation=[];
            import systemcomposer.rptgen.finder.*
            model=systemcomposer.loadModel(this.Container);

            referenceDictionariesInterfaceNames=[];
            if~isempty(model.InterfaceDictionary.get('ddConn'))
                referenceDictionaries=model.InterfaceDictionary.get('ddConn').DataSources;
                numel=length(referenceDictionaries);
                for i=1:numel

                    referenceDictionary=systemcomposer.openDictionary(string(referenceDictionaries(i)));
                    referenceDictionaryInterfaceNames=referenceDictionary.getInterfaceNames;
                    referenceDictionaryInterfaces=referenceDictionary.Interfaces;
                    referenceDictionaryInterfaceNamesInUse=[];
                    len=length(referenceDictionaryInterfaces);
                    for j=1:len
                        if~isempty(referenceDictionaryInterfaces(j).getImpl.getUsages)
                            referenceDictionaryInterfaceNamesInUse=[referenceDictionaryInterfaceNamesInUse,string(referenceDictionaryInterfaces(j).Name)];
                            for elem=referenceDictionaryInterfaces(j).Elements
                                if~isempty(elem.Type.Name)
                                    referenceDictionaryInterfaceNamesInUse=[referenceDictionaryInterfaceNamesInUse,string(elem.Type.Name)];%#ok<*AGROW>
                                end
                            end
                        end
                    end
                    dictionariesInformation=[dictionariesInformation,systemcomposer.rptgen.finder.DictionaryFinder.createDictionaryStruct("Reference",referenceDictionaries(i),referenceDictionaryInterfaceNamesInUse)];
                    referenceDictionariesInterfaceNames=[referenceDictionariesInterfaceNames,referenceDictionaryInterfaceNames];
                end
            end


            modelDictionary=model.InterfaceDictionary.getImpl.getStorageSource;
            allInterfaceNames=model.InterfaceDictionary.getInterfaceNames;
            scope=systemcomposer.rptgen.finder.DictionaryFinder.isModelScope(this);
            if~scope
                interfaces=model.InterfaceDictionary.Interfaces;
                allInterfaceNamesInUse=[];
                for interface=interfaces
                    if~isempty(interface.getImpl.getUsages)
                        allInterfaceNamesInUse=[allInterfaceNamesInUse,string(interface.Name)];
                        for elem=interface.Elements
                            if~isempty(elem.Type.Name)
                                allInterfaceNamesInUse=[allInterfaceNamesInUse,string(elem.Type.Name)];
                            end
                        end
                    end
                end


                modelDictionaryInterfaceNames=setdiff(allInterfaceNames,referenceDictionariesInterfaceNames);
                if isempty(modelDictionaryInterfaceNames)
                    modelDictionaryInterfaceNames="";
                end
                modelDictionaryInterfaceNamesInUse=[];
                for interfaceName=allInterfaceNamesInUse
                    if ismember(interfaceName,modelDictionaryInterfaceNames)
                        modelDictionaryInterfaceNamesInUse=[modelDictionaryInterfaceNamesInUse,interfaceName];
                    end
                end
                dictionariesInformation=[dictionariesInformation,systemcomposer.rptgen.finder.DictionaryFinder.createDictionaryStruct("Model",modelDictionary+".sldd",unique(modelDictionaryInterfaceNamesInUse))];
            end
            results=getResultsArrayFromStruct(this,dictionariesInformation);
        end

        function results=helper(this)
            dictionaries=findDictionaries(this);
            switch this.Type(1)
            case "Model"
                if length(dictionaries)==1
                    results=dictionaries(1);
                else
                    results=[];
                    disp("No Dictionaries present in the Model")
                end
            case "Reference"
                if length(dictionaries)~=1
                    results=dictionaries(2:end);
                else
                    results=[];
                end
            end
        end
    end

    methods
        function this=DictionaryFinder(varargin)
            this@mlreportgen.finder.Finder(varargin{:});
            reset(this)
        end

        function results=find(this)










            results=helper(this);
        end

        function tf=hasNext(this)





















            if this.IsIterating
                if this.NextDictIndex<=this.DictCount
                    tf=true;
                else
                    tf=false;
                end
            else
                helper(this)
                if this.DictCount>0
                    this.NextDictIndex=1;
                    this.IsIterating=true;
                    tf=true;
                else
                    tf=false;
                end
            end
        end

        function result=next(this)









            if hasNext(this)

                result=this.DictList(this.NextDictIndex);

                this.NextDictIndex=this.NextDictIndex+1;
            else
                result=systemcomposer.rptgen.finder.DictionaryResult.empty();
            end
        end
    end

    methods(Access=protected)
        function reset(this)






            this.IsIterating=false;
            this.DictCount=0;
            this.DictList=[];
            this.NextDictIndex=0;
        end

        function tf=isIterating(this)






            tf=this.IsIterating;
        end
    end
end