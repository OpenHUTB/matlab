function[sortedchartArray,allChartInstances]=find_LinkChart(systemObj,varargin)













    nameValues=cell(length(varargin)/2,1);
    for n=1:2:length(varargin)
        nameValues{(n+1)/2}={varargin{n},varargin{n+1}};
    end

    chartArray=[];

    alllinkChartObjs=systemObj.find('-isa','Stateflow.LinkChart');

    for i=1:length(alllinkChartObjs)
        lcHndl=sf('get',alllinkChartObjs(i).Id,'.handle');
        cId=sfprivate('block2chart',lcHndl);
        c=idToHandle(sfroot,cId);



        if~isempty(c)&&c.isa('Stateflow.Chart')&&~isa(c.getParent(),'Stateflow.Chart')

            if(nargin==1)
                chartArray=[chartArray,c];%#ok<AGROW>
            else

                match=true;
                for n=1:length(nameValues)
                    if strcmp(nameValues{n}{1},'Commented')













                        chartPathInModel=alllinkChartObjs(i).Path;


                        p=get_param(chartPathInModel,'Object');
                        if isa(p,'Simulink.SubSystem')&&...
                            (Advisor.Utils.Simulink.isBlockCommented(p)~=nameValues{n}{2})
                            match=false;
                            break;
                        end
                    elseif ischar(nameValues{n}{2})&&...
                        ~strcmp(c.(nameValues{n}{1}),nameValues{n}{2})
                        match=false;
                        break;
                    end
                end

                if match
                    chartArray=[chartArray,c];%#ok<AGROW>
                end
            end
        end
    end

    allChartInstances=chartArray;
    chartArray=unique(chartArray);




    sortedchartArray=[];
    sortMatrix=cell(length(chartArray),1);
    for i=1:length(chartArray)
        sortMatrix{i}=chartArray(i).Path;
    end
    [~,index]=sortrows(sortMatrix);
    for i=1:length(index)
        sortedchartArray=[sortedchartArray,chartArray(index(i))];
    end
end