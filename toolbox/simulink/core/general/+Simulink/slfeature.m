function retVal=slfeature(varargin)







    if nargin==0
        MSLException([],message('Simulink:tools:SLFeatureNotEnoughArgs')).throw;
    end

    start_simulink;

    if strcmp(varargin{1},'query')&&nargin>=2
        content=slf_feature('report');
        retVal=[];
        fieldName='Name';
        key=varargin{2};
        if nargin==3
            fieldName=varargin{2};
            key=varargin{3};
        end
        for i=1:length(content)
            if~isempty(strfind(lower(content(i).(fieldName)),lower(key)))
                if isempty(retVal)
                    retVal=content(i);
                else
                    retVal(end+1)=content(i);%#ok<AGROW>
                end
            end
        end
    elseif nargin==1

        retVal=slf_feature('get',varargin{1});
    elseif nargin==2

        retVal=slf_feature('set',varargin{1},varargin{2});
    else

        MSLException.throw(message('Simulink:tools:SLFeatureInvalidCall'));
    end

end







