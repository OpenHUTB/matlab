function updateTextBar(varargin)
















    persistent progressTotal
    persistent progressIdx
    persistent backspaceCount

    if isempty(progressIdx)
        progressIdx=0;
    end

    if isempty(progressTotal)
        progressTotal=1;
    end

    if isempty(backspaceCount)
        backspaceCount=0;
    end



    totalLength=50;
    totalBack=repmat(sprintf('\b'),1,totalLength+6);
    switch varargin{1}
    case 'start'
        progressIdx=0;
        if nargin>2
            progressTotal=varargin{3};
        end
        backspaceCount=0;
        fprintf('%s\n',varargin{2});
        fprintf(1,'%s%s%s','0%',repmat('.',1,totalLength),'100%')
    case 'reset'
        progressTotal=varargin{3};
        backspaceCount=0;
        fprintf(1,'%s%s%s%s',...
        totalBack,'0%',...
        repmat('.',1,totalLength),...
        '100%');
    case 'update'
        progressIdx=progressIdx+1;
        totalStars=floor(totalLength*progressIdx/progressTotal);
        totalDots=totalLength-totalStars;
        fprintf(1,'%s%s%s%s%s',...
        totalBack,'0%',...
        repmat('*',1,totalStars),...
        repmat('.',1,totalDots),...
        '100%')
    case 'clear'
        fprintf('\n');
    otherwise
        error('Wrong option')
    end
end