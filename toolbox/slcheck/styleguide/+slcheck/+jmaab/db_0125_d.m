classdef db_0125_d<slcheck.subcheck
    methods
        function obj=db_0125_d(inputParam)
            obj.CompileMode='None';
            obj.Licenses={'Stateflow'};
            obj.ID=inputParam.Name;
        end

        function result=run(this)

            result=false;

            SFChartObj=this.getEntity();


            if~(isa(SFChartObj,'Stateflow.Chart')||isa(SFChartObj,'Stateflow.StateTransitionTableChart'))
                return;
            end


            sfData=SFChartObj.find('-isa','Stateflow.Data',...
            'Scope','Local');


            if isempty(sfData)
                return;
            end


            sfDataName=cell(1,numel(sfData));


            sfDataPath=cell(1,numel(sfData));

            for eventCount=1:numel(sfData)

                sfDataName{eventCount}=sfData(eventCount).Name;

                sfDataPath{eventCount}=sfData(eventCount).Path;
            end





            [~,uniqueIndex,~]=unique(sfDataName,'stable');

            repeatedIndex=setdiff((1:length(sfDataName)),uniqueIndex);

            repeatedDataNames=unique(sfDataName(repeatedIndex));






            if isempty(repeatedDataNames)
                return;
            end

            vObjVector=[];

            for count=1:length(repeatedDataNames)


                sfIndex=find(contains(sfDataName,repeatedDataNames{count}));


                if isempty(sfIndex)
                    continue;
                end


                sfDataRep=sfData(sfIndex);






                sfPath=sfDataPath(sfIndex);


                groups=findSFHierarchy(sfPath);


                if isempty(groups)
                    continue;
                end

                for groupCount=1:numel(groups)


                    groupIndex=groups{groupCount};




                    sfDataFlagged=sfDataRep(groupIndex);

                    if isempty(sfDataFlagged)
                        continue;
                    end


                    dataName=sfDataFlagged(1).Name;

                    vObj=ModelAdvisor.ResultDetail;
                    ModelAdvisor.ResultDetail.setData(vObj,'Custom',...
                    DAStudio.message('ModelAdvisor:jmaab:db_0125_col1'),...
                    dataName,...
                    DAStudio.message('ModelAdvisor:jmaab:db_0125_col2'),...
                    sfDataFlagged);

                    vObjVector=[vObjVector;vObj];

                end

            end

            if~isempty(vObjVector)
                result=this.setResult(vObjVector);
            end
        end
    end
end


function group=findSFHierarchy(sfPath)




    group=[];


    if isempty(sfPath)
        return;
    end

    for pathCount=1:numel(sfPath)











        index=contains(sfPath,[sfPath{pathCount},'/']);




        if isempty(index)||~any(index)
            continue;
        end



        index(pathCount)=true;


        group=[group;{index}];
    end

end