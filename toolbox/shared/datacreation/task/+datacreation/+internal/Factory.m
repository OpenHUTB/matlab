classdef Factory<handle




    properties

TaskContributorsList

    end


    methods(Static)


        function aFactory=getInstance()

            persistent instance;
            mlock;


            if isempty(instance)
                instance=datacreation.internal.Factory();
                instance.updateFactoryRegistry();
            else



                if any(~cellfun(@isvalid,instance.TaskContributorsList))
                    instance.updateFactoryRegistry();
                end
            end

            aFactory=instance;
        end


        function subClassList=getSubClasses()
            subClassList=internal.findSubClasses('datacreation.plugin',...
            'datacreation.internal.DataCreationPluggable',true);
        end
    end


    methods(Access='protected')


        function aFactory=Factory()


            aFactory.TaskContributorsList=datacreation.internal.Factory.getSubClasses();
        end
    end


    methods


        function supportedContributor=getSupportedContributor(aFactory,inKey)

            supportedContributor=[];

            if isStringScalar(inKey)
                inKey=char(inKey);
            end

            if~ischar(inKey)
                error(message('datacreation:datacreation:pluginFactoryInputForKey'));
            end

            NUM_TYPES=length(aFactory.TaskContributorsList);

            for kType=1:NUM_TYPES

                try
                    IS_THIS_PLUGIN=feval([aFactory.TaskContributorsList{kType}.Name,'.isSupported'],inKey);

                    if IS_THIS_PLUGIN

                        supportedContributor=feval(aFactory.TaskContributorsList{kType}.Name);
                        return;
                    end

                catch


                end



            end

        end


        function updateFactoryRegistry(aFactory)
            aFactory.TaskContributorsList=...
            datacreation.internal.Factory.getSubClasses();
        end


        function allContributors=getAllContributors(aFactory)

            allContributors=...
            datacreation.internal.DataCreationPluggable.empty(0,...
            length(aFactory.TaskContributorsList));

            for k=1:length(aFactory.TaskContributorsList)
                allContributors(k)=feval(aFactory.TaskContributorsList{k}.Name);
            end

            [~,idx]=sort([allContributors(:).PRIORITY]);
            allContributors=allContributors(idx);
        end
    end

end
