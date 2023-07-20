

classdef MatchingNetworkHistoryManager<handle



    properties(Access=public)

        AutoNetworkHistory rf.internal.apps.matchnet.AutoMNContainer


        UserNetworkHistory rf.internal.apps.matchnet.AutoMNContainer
    end

    methods(Access=public)
        function this=MatchingNetworkHistoryManager
            this.UserNetworkHistory=rf.internal.apps.matchnet.AutoMNContainer();
        end

        function addMNContainer(this,mncnt)
            if isempty(this.AutoNetworkHistory)
                this.AutoNetworkHistory=mncnt;
            else
                this.AutoNetworkHistory(end+1)=mncnt;
            end
        end


        function[names,sparams,circuits,failedtests,freq,loadedq,sourcez,loadz]=retrieveCircuits(this,circuitnames)
            [names,sparams,circuits,failedtests,freq,loadedq,sourcez,loadz]=this.UserNetworkHistory.retrieveCircuits(circuitnames);
            for j=1:length(this.AutoNetworkHistory)
                [tempnames,tempsparams,tempcircuits,tempfailedtests,...
                tempfreq,temploadedq,tempsourcez,temploadz]=this.AutoNetworkHistory(j).retrieveCircuits(circuitnames);
                names=[names;tempnames];
                sparams=[sparams;tempsparams];
                circuits=[circuits;tempcircuits];
                failedtests=[failedtests;tempfailedtests];
                freq=[freq;tempfreq];
                loadedq=[loadedq;temploadedq];
                sourcez=[sourcez;tempsourcez];
                loadz=[loadz;temploadz];
            end
        end


        function c=getMNContainer(this,index)
            if(index==0)
                c=this.UserNetworkHistory;
            else
                c=this.AutoNetworkHistory(index);
            end
        end


        function replaceMNContainer(this,index,newContainer)
            if(index==0)
                delete(this.UserNetworkHistory)
                this.UserNetworkHistory=newContainer;
            else
                delete(this.AutoNetworkHistory(index));
                this.AutoNetworkHistory(index)=newContainer;
            end
        end
    end

    methods(Access=protected)

    end


    methods(Access=public)
        function delete(this)
            if(~isempty(this.AutoNetworkHistory))
                delete(this.AutoNetworkHistory);
            end
            if(~isempty(this.UserNetworkHistory))
                delete(this.UserNetworkHistory);
            end
        end
    end
end
