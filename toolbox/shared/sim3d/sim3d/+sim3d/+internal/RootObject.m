classdef RootObject<sim3d.AbstractActor

    methods
        function self=RootObject()
            self@sim3d.AbstractActor('Scene Origin',0,[0,0,0],[0,0,0],[1,1,1]);
        end
    end


    methods(Hidden)

        function actorType=getActorType(~)
            actorType=sim3d.utils.ActorTypes.Custom;
        end

        function setupTree(self)
            childList=self.getChildList();
            if~isempty(childList)
                for i=1:numel(childList)
                    self.Children.(childList{i}).setupTree();
                end
            else
                warning(message("shared_sim3d:sim3dAbstractActor:NoActorsInScene"));
            end
        end


        function output(self)
            childList=self.getChildList();
            if~isempty(childList)
                for i=1:numel(childList)
                    self.Children.(childList{i}).output();
                end
            end
        end


        function update(self)
            childList=self.getChildList();
            if~isempty(childList)
                for i=1:numel(childList)
                    self.Children.(childList{i}).update();
                end
            end
        end


        function remove(self)
            childList=self.getChildList();
            if~isempty(childList)
                for i=1:numel(childList)
                    self.Children.(childList{i}).remove(false);
                end
            end
        end


        function actorS=getAttributes(self)
            actorS=[];
        end
    end
end
