classdef ProfileFinder<mlreportgen.finder.Finder





















    properties(Constant,Hidden)
        InvalidPropertyNames={};
    end

    properties(Access=private)
ProfileObj
        ProfileList=[]
        ProfileCount{mustBeInteger}=0
        NextProfileIndex{mustBeInteger}=0
        IsIterating{mlreportgen.report.validators.mustBeLogical}=false
    end

    methods(Static,Access=private,Hidden)





        function profileStruct=createProfileStruct(profile)
            profileStruct.obj=profile.getImpl.UUID;
            profileStruct.Name=profile.Name;
            profileStruct.Description=profile.Description;
            stereotypes=profile.Stereotypes;
            stereotypeNames=[];
            for stereotype=stereotypes
                stereotypeNames=[stereotypeNames,string(stereotype.FullyQualifiedName)];
            end
            profileStruct.Stereotypes=stereotypeNames;
        end

        function validateInput(this,profileName)
            profiles=systemcomposer.profile.Profile.load(this.Container);
            profileNamesList=[];
            for p=profiles
                profileNamesList=[profileNamesList,string(p.Name)];
            end
            for profile=profileName
                if~ismember(profile,profileNamesList)
                    msgObj=message('SystemArchitecture:ReportGenerator:ProfileNotFound',profile);
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
                results(i)=systemcomposer.rptgen.finder.ProfileResult(temp.obj);
                results(i).Name=temp.Name;
                results(i).Description=temp.Description;
                results(i).Stereotypes=temp.Stereotypes;
            end
            this.ProfileList=results;
            this.ProfileCount=numel(results);
        end

        function results=findProfilesInModel(this)
            profilesInformation=[];
            profiles=systemcomposer.profile.Profile.load(this.Container);
            if~isempty(profiles)
                for profile=profiles
                    profilesInformation=[profilesInformation,systemcomposer.rptgen.finder.ProfileFinder.createProfileStruct(profile)];
                end
            end
            results=getResultsArrayFromStruct(this,profilesInformation);
        end
    end

    methods
        function this=ProfileFinder(varargin)
            this@mlreportgen.finder.Finder(varargin{:});
            reset(this);
        end

        function results=find(this)










            results=findProfilesInModel(this);
        end

        function tf=hasNext(this)





















            if this.IsIterating
                if this.NextProfileIndex<=this.ProfileCount
                    tf=true;
                else
                    tf=false;
                end
            else
                findProfilesInModel(this);
                if this.ProfileCount>0
                    this.NextProfileIndex=1;
                    this.IsIterating=true;
                    tf=true;
                else
                    tf=false;
                end
            end
        end

        function result=next(this)













            if hasNext(this)

                result=this.ProfileList(this.NextProfileIndex);

                this.NextProfileIndex=this.NextProfileIndex+1;
            else
                result=systemcomposer.rptgen.finder.ProfileResult.empty();
            end
        end
    end

    methods(Access=protected)
        function reset(this)






            this.IsIterating=false;
            this.ProfileCount=0;
            this.ProfileList=[];
            this.NextProfileIndex=0;
        end

        function tf=isIterating(this)






            tf=this.IsIterating;
        end
    end
end