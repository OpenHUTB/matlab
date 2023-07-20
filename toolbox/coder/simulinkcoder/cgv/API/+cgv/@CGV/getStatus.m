



























function result=getStatus(this,varargin)

    if this.RunHasBeenCalled==0
        result='none';
        return;
    end
    if nargin>2
        DAStudio.error('RTW:cgv:InvalidNumberOfArgs');
    end

    if nargin==2

        [Index,labelOut]=getInputIndex(this,varargin{1});
        if Index==0
            DAStudio.error('RTW:cgv:BadOutputIndex',labelOut);
        end
        result=this.MetaData(Index).status;
    elseif isempty(this.MetaData)
        result='error';
    else

        statusList={};
        for i=1:length(this.MetaData)

            if~isempty(this.MetaData(i).status)
                statusList{end+1}=this.MetaData(i).status;%#ok<AGROW>
            end
        end

        if isempty(statusList)
            result='none';
        elseif ismember('error',statusList)
            result='error';
        elseif ismember('failed',statusList)
            result='failed';
        elseif ismember('pending',statusList)
            result='none';
        elseif all(ismember(statusList,'passed'))
            result='passed';
        else



            result='completed';
        end
    end
end

