classdef StereotypeFinder<mlreportgen.finder.Finder






















    properties(Constant,Hidden)
        InvalidPropertyNames={};
    end

    properties(Access=private)
StereotypeObj
        StereotypeList=[]
        StereotypeCount{mustBeInteger}=0
        NextStereotypeIndex{mustBeInteger}=0
        IsIterating{mlreportgen.report.validators.mustBeLogical}=false
    end

    properties



        StereotypeName="All";
    end

    methods(Static,Access=private,Hidden)








        function stereotypeStruct=createStereotypeStruct(stereotypes)
            import mlreportgen.dom.Image;
            stereotypeStruct=[];
            if~isempty(stereotypes)
                for i=1:length(stereotypes)
                    stereotypeStruct(i).obj=stereotypes(i).getImpl.UUID;%#ok<*AGROW>
                    stereotypeStruct(i).Name=string(stereotypes(i).Name);
                    iconPath=stereotypes(i).getImpl.iconPath;
                    if~isempty(iconPath)
                        imgObj=Image(iconPath);
                    else
                        imgObj=Image.empty(0,0);
                    end
                    stereotypeStruct(i).Icon=imgObj;
                    if isempty(stereotypes(i).Description)
                        stereotypeStruct(i).Description="-";
                    else
                        stereotypeStruct(i).Description=stereotypes(i).Description;
                    end
                    stereotypeStruct(i).Parent=stereotypes(i).Parent;
                    if isempty(stereotypes(i).AppliesTo)
                        stereotypeStruct(i).AppliesTo="-";
                    else
                        stereotypeStruct(i).AppliesTo=stereotypes(i).AppliesTo;
                    end
                    stereotypeStruct(i).Properties=systemcomposer.rptgen.finder.StereotypeFinder.createStereotypePropertiesStruct(stereotypes(i));
                end
            end
        end


        function propertiesStruct=createStereotypePropertiesStruct(stereotype)
            propertiesStruct=[];
            for i=1:length(stereotype.Properties)
                propertiesStruct(i).Name=stereotype.Properties(i).Name;
                propertiesStruct(i).Type=stereotype.Properties(i).Type;
                propertiesStruct(i).Index=stereotype.Properties(i).Index;
                if isempty(stereotype.Properties(i).Units)
                    propertiesStruct(i).Unit="-";
                else
                    propertiesStruct(i).Unit=stereotype.Properties(i).Units;
                end
                if isempty(stereotype.Properties(i).DefaultValue)
                    propertiesStruct(i).DefaultValue="-";
                else
                    propertiesStruct(i).DefaultValue=stereotype.Properties(i).DefaultValue;
                end
            end
        end

        function validateInput(this,stereotypeName)
            profile=systemcomposer.profile.Profile.load(this.Container);
            stereotypes=profile.Stereotypes;
            stereotypeNamesList=[];
            for s=stereotypes
                stereotypeNamesList=[stereotypeNamesList,string(s.FullyQualifiedName)];
            end
            for stereotype=stereotypeName
                if~ismember(stereotype,stereotypeNamesList)
                    msgObj=message('SystemArchitecture:ReportGenerator:StereotypeNotFound',stereotype);
                    warning(msgObj);
                end
            end
        end
    end

    methods(Hidden)



        function results=getResultsArrayFromStruct(this,profilesInformation)
            n=numel(profilesInformation);
            results=mlreportgen.finder.Result.empty(0,n);
            for i=1:n
                temp=profilesInformation(i);
                results(i)=systemcomposer.rptgen.finder.StereotypeResult(temp.obj);
                results(i).Name=temp.Name;
                results(i).Icon=temp.Icon;
                results(i).Description=temp.Description;
                results(i).Parent=temp.Parent;
                results(i).AppliesTo=temp.AppliesTo;
                results(i).Properties=temp.Properties;
            end
            this.StereotypeList=results;
            this.StereotypeCount=numel(results);
        end

        function results=findStereotypesInProfile(this)
            stereotypesInformation=[];
            profiles=systemcomposer.profile.Profile.load(this.Container);
            if this.StereotypeName=="All"
                if~isempty(profiles)
                    for profile=profiles
                        stereotypesInformation=[stereotypesInformation,systemcomposer.rptgen.finder.StereotypeFinder.createStereotypeStruct(profile.Stereotypes)];
                    end
                end
            else
                systemcomposer.rptgen.finder.StereotypeFinder.validateInput(this,this.StereotypeName);
                stereotypes=profiles.Stereotypes;
                stereotypeNamesList=[];
                for s=stereotypes
                    stereotypeNamesList=[stereotypeNamesList,string(s.FullyQualifiedName)];
                end
                query=this.StereotypeName;
                index=contains(stereotypeNamesList,query);
                if index==0
                    stereotypesInformation=[];
                else
                    stereotypesInformation=[stereotypesInformation,systemcomposer.rptgen.finder.StereotypeFinder.createStereotypeStruct(profiles.Stereotypes(index))];
                end
            end
            results=getResultsArrayFromStruct(this,stereotypesInformation);
        end

        function results=helper(this)
            results=findStereotypesInProfile(this);
        end
    end

    methods
        function this=StereotypeFinder(varargin)
            this@mlreportgen.finder.Finder(varargin{:});
            reset(this);
        end

        function results=find(this)










            results=helper(this);
        end

        function tf=hasNext(this)





















            if this.IsIterating
                if this.NextStereotypeIndex<=this.StereotypeCount
                    tf=true;
                else
                    tf=false;
                end
            else
                helper(this);
                if this.StereotypeCount>0
                    this.NextStereotypeIndex=1;
                    this.IsIterating=true;
                    tf=true;
                else
                    tf=false;
                end
            end
        end

        function result=next(this)













            if hasNext(this)

                result=this.StereotypeList(this.NextStereotypeIndex);

                this.NextStereotypeIndex=this.NextStereotypeIndex+1;
            else
                result=systemcomposer.rptgen.finder.StereotypeResult.empty();
            end
        end
    end

    methods(Access=protected)
        function reset(this)






            this.IsIterating=false;
            this.StereotypeCount=0;
            this.StereotypeList=[];
            this.NextStereotypeIndex=0;
        end

        function tf=isIterating(this)






            tf=this.IsIterating;
        end
    end
end