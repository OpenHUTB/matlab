function newh=line2chartline(h,varargin)






















    narginchk(1,Inf);
    if isempty(h)||~ishghandle(h,'line')
        error(message('stats:line2chartline:InvalidLineHandle'));
    end


    cls=meta.class.fromName('matlab.graphics.primitive.Line');
    lineprops=cls.Properties;


    numprops=numel(lineprops);
    hiddenprops(numprops)=false;
    for i=1:numprops
        hiddenprops(i)=lineprops{i}.Hidden==true;
    end
    lineprops(hiddenprops)=[];


    numprops=numel(lineprops);
    fields=cell(numprops,1);
    for i=1:numprops
        fields{i}=lineprops{i}.Name;
    end


    [~,ia]=intersect(fields,{'BeingDeleted','Children','Type','UIContextMenu','Annotation'});
    fields(ia)=[];



    fields(~ismember(fields,properties(h)))=[];
    vals=get(h,fields);


    pvpairs=[fields(:).';vals(:).'];
    newh=matlab.graphics.chart.primitive.Line(pvpairs{:},varargin{:});
    delete(h);
end
