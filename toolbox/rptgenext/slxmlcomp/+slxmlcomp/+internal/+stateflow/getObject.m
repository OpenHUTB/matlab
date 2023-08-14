function[sfObject,sfObjectId]=getObject(path)




















    [sfObject,~,~,sfObjectId]=sfprivate('ssIdToHandle',path);

    if isempty(sfObject)

        sfObject=getSubChart(path);
        if isempty(sfObject)
            root=sfroot;
            sfObject=root.find('-isa','Stateflow.Chart','Path',path);
            if(~isempty(sfObject))
                sfObjectId=sfObject.Id;
            end
        end
    end
end

function subChart=getSubChart(path)
    subChart=[];
    tokens=strsplit(path,'/');
    subChartName=tokens{end};
    subChartPath=path(1:end-numel(subChartName)-1);
    if~isempty(subChartPath)
        root=sfroot;
        subChart=root.find('Path',subChartPath,'Name',subChartName,'-isa','Stateflow.AtomicSubchart');
    end
end
