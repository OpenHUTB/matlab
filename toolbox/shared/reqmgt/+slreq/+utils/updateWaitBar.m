function updateWaitBar(varargin)






























    persistent barH
    persistent progressTotal
    persistent progressIdx

    if isempty(progressIdx)
        progressIdx=0;
    end

    if isempty(progressTotal)
        progressTotal=1;
    end

    switch varargin{1}
    case 'Indeterminate'
        barH=waitbar(0,varargin{2});
        barH.CloseRequestFcn='';
        wbch=allchild(barH);
        jp=wbch(1).JavaPeer;
        jp.setIndeterminate(1);


    case 'start'
        barH=waitbar(0,varargin{2});
        progressIdx=0;
        if nargin>2
            progressTotal=varargin{3};
        end


        ah=get(barH,'CurrentAxes');
        ah.Title.Interpreter='none';
    case 'reset'
        progressTotal=varargin{3};
        percentage=sprintf('%.0f%%',100*progressIdx/progressTotal);
        waitbar(progressIdx/progressTotal,barH,...
        [varargin{2},'(',percentage,')']);
    case 'update'
        if~isempty(barH)&&ishandle(barH)
            percentage=sprintf('%.0f%%',100*progressIdx/progressTotal);
            progressIdx=progressIdx+1;
            waitbar(progressIdx/progressTotal,barH,...
            [varargin{2},'(',percentage,')']);
        else


            if nargin~=3||~varargin{3}
                ME=MException(message('Slvnv:slreq:ReportGenProgressBarCancelled'));
                throw(ME);
            end
        end
    case 'updateText'

        if~isempty(barH)&&ishandle(barH)
            percentage=sprintf('%.0f%%',100*progressIdx/progressTotal);
            waitbar(progressIdx/progressTotal,barH,...
            [varargin{2},'(',percentage,')']);
        else


            if nargin~=3||~varargin{3}
                ME=MException(message('Slvnv:slreq:ReportGenProgressBarCancelled'));
                throw(ME);
            end
        end
    case 'clear'
        delete(barH);
    otherwise
        error('Wrong option')
    end
end

function disableCancel(progressBarHandle,progressBarLabel)

end
