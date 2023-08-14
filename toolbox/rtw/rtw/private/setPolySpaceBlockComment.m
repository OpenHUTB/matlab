function setPolySpaceBlockComment(blockname,action,startString,varargin)





    if(nargin==3||nargin==4)
        if(strcmp(action,'-append'))
            locAppendComment(blockname,startString,'start');
            if(nargin==4)
                locAppendComment(blockname,varargin{1},'end');
            end
        elseif(strcmp(action,'-replace'))
            set_param(blockname,'PolySpaceStartComment',startString);
            if(nargin==4)
                set_param(blockname,'PolySpaceEndComment',varargin{1});
            end
        else
            error(message('Simulink:utility:invalidOptionDetailed',...
            'setPolySpaceBlockComment',action));
        end
    end


    function locAppendComment(blockname,startString,position)
        if strcmp(position,'start')
            paramName='PolySpaceStartComment';
        elseif strcmp(position,'end')
            paramName='PolySpaceEndComment';
        else
            assert(false,'Incorrect position for polyspace comment');
        end

        old=get_param(blockname,paramName);
        if isempty(old)
            set_param(blockname,paramName,startString);
        else
            pString=sprintf('%s\n%s',old,startString);
            set_param(blockname,paramName,pString);
        end

