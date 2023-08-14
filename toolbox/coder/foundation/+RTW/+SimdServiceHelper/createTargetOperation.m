function operation=createTargetOperation(varargin)

    p=inputParser;
    p.addParameter('Name','None');
    p.addParameter('RoundingModes',{'ROUND_UNSPECIFIED'});
    p.addParameter('OverflowMode','OVERFLOW_UNSPECIFIED');
    p.addParameter('SupportNonFinite',true);

    p.parse(varargin{:});
    result=p.Results;

    operation=target.internal.create('Operation','Name',result.Name);

    fn=fieldnames(result);
    for i=1:numel(fn)
        parName=fn{i};
        parValue=result.(parName);
        operation.(parName)=parValue;
    end

    if isempty(operation.Name)
        error('Operation must have a Name');
    end

    if isempty(operation.RoundingModes)
        operation.RoundingModes={'ROUND_UNSPECIFIED'};
    end

end