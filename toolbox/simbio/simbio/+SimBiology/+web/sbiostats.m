function out=sbiostats(data,varargin)

    if nargin==1

        out=calculate(data,'all','all');
    elseif nargin==2

        out=calculate(data,varargin{1},'all');
    elseif nargin==3

        out=calculate(data,varargin{1},varargin{2});
    else

        out=[];
        for i=1:2:nargin-1
            next=calculate(data,varargin{i},varargin{i+1});
            if isempty(out)
                out=next;
            else
                out=outerjoin(out,next,'key','State','MergeKeys',true);
            end
        end
    end

end

function out=calculate(data,calculations,states)

    if strcmp(calculations,'all')
        calculations=getCalculations;
    end

    if strcmp(states,'all')
        states=data.DataNames;
    end

    if~iscell(calculations)
        calculations={calculations};
    end

    if~iscell(states)
        states={states};
    end

    if size(states,1)==1
        states=states';
    end


    out=table;
    out.State=states;


    for i=1:length(calculations)
        next=zeros(length(states),1);
        for j=1:length(states)
            next(j)=doCalculation(data,calculations{i},states{j});
        end
        out.(calculations{i})=next;
    end

end

function names=getCalculations


    names=SimBiology.web.postprocesshandler('getCalculations');





end

function value=doCalculation(data,calculation,state)


    value=SimBiology.web.calculations.(calculation)(data,state);


end

