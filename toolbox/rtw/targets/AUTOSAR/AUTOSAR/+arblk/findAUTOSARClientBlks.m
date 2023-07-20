function blks=findAUTOSARClientBlks(aPath,varargin)







    p=inputParser;
    p.addParameter('OperationName','');
    p.KeepUnmatched=true;
    p.parse(varargin{:});

    operationName=p.Results.OperationName;

    if isempty(operationName)
        regExp='off';
        args=varargin;
    else
        regExp='on';

        args={};
        unmatched=p.Unmatched;
        fields=fieldnames(unmatched);
        for fieldIdx=1:length(fields)

            args=[args,fields{fieldIdx},['^',unmatched.(fields{fieldIdx}),'$']];%#ok<AGROW>
        end

        if~isempty(operationName)
            args=[args,'operationPrototype',['^',operationName,'($|\(.*\))']];
        end
    end


    blks=find_system(aPath,'RegExp',regExp,'FollowLinks','on',...
    'LookUnderMasks','on',...
    'MatchFilter',@Simulink.match.activeVariants,...
    'MaskType','Invoke AUTOSAR Server Operation',args{:});


