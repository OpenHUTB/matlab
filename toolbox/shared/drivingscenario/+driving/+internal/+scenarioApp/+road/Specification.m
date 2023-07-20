classdef Specification<driving.internal.scenarioApp.Specification




    properties(Access=protected,Transient)
Scenario
RoadBoundaries
    end

    methods
        function this=Specification(varargin)
            this@driving.internal.scenarioApp.Specification(...
            'Name',getString(message('driving:scenarioApp:DefaultRoadName')),...
            varargin{:});
        end
    end

    methods(Hidden,Static)
        function w=getDefaultWidth
            w=6;
        end
    end

    methods(Hidden)
        function scenario=getScenario(this)



            scenario=this.Scenario;
            if isempty(scenario)
                scenario=drivingScenario;
                applyToScenario(this,scenario);
                this.Scenario=scenario;
            end
        end



        function rbs=getRoadBoundaries(this)


            rbs=this.RoadBoundaries;
            if isempty(rbs)
                scenario=getScenario(this);
                rbs=roadBoundaries(scenario);
                this.RoadBoundaries=rbs;
            end
        end

        function b=isPointInRoad(this,point)


            rbs=getRoadBoundaries(this);
            inCount=0;
            for indx=1:numel(rbs)
                inCount=inCount+inpolygon(point(1),point(2),rbs{indx}(:,1),rbs{indx}(:,2));
            end
            b=rem(inCount,2)==1;
        end

        function nPoints=getNumAddPoints(~)







            nPoints=[1,1];
        end

        function addPoints=getStartingAddPoints(~)




            addPoints=[];
        end

        function pvPairs=getPvPairsForAddPoints(~,addPoints)%#ok<*INUSD>




            pvPairs={};
        end

        function pvPairs=getPvPairsForDrag(~,offset)


            pvPairs={};
        end

        function pvPairs=getPvPairsForDoubleClick(~,point)


            pvPairs={};
        end

        function pvPairs=getPvPairsCacheForEditPointDrag(this,id)




            pvPairs={};
        end

        function pvPairs=getPvPairsForEditPointDrag(this,id,point,varargin)

            pvPairs={};
        end

        function pvPairs=getPvPairsForPaste(this,location)

            pvPairs={};
        end

        function id=getEditPointId(this,point,hEdit,metersPerPixel,nPoints)







            id=1;
        end

        function schema=getRoadContextMenuSchema(this,location)







            schema=[];
        end

        function schema=getEditPointContextMenuSchema(this,id)





            schema=[];
        end
    end

    methods(Hidden,Sealed)
        function[spec,index]=findRoadWithPoint(these,point)

            for index=numel(these):-1:1
                if isPointInRoad(these(index),point)
                    spec=these(index);
                    return;
                end
            end

            spec=[];
            index=[];
        end
    end

    methods(Access=protected)
        function clearScenario(this)
            this.Scenario=[];
            this.RoadBoundaries=[];
        end
    end

    methods(Abstract)
        applyToScenario(this,scenario)
        str=generateMatlabCode(this,scenarioName)
    end
end


