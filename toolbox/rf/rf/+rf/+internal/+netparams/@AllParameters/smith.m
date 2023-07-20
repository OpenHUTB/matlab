function varargout=smith(obj,m,n)


    narginchk(3,3)

    validateattributes(m,{'numeric'},...
    {'integer','scalar','positive','<=',obj.NumPorts},'smith','I',2)
    validateattributes(n,{'numeric'},...
    {'integer','scalar','positive','<=',obj.NumPorts},'smith','J',3)

    lgndtxt={obj.calculateLegendText(m,n)};
    if ishold
        hlgnd=get(gca,'Legend');
        lgndtxt=horzcat(get(hlgnd,'String'),lgndtxt);
    end


    gamma=rfparam(obj,m,n);
    hsm=[];


    if nargin==0
        if nargout==0
            rfchart.smith;
        else
            varargout{1}=rfchart.smith;
            if nargout==2
                varargout{2}=hsm;
            end
        end
        return
    end


    hold_state=ishold;
    if~hold_state
        hsm=rfchart.smith('NeedReset',false);
    end


    hold on;
    if isreal(gamma)
        gamma=complex(gamma);
    end
    hlines=plot(gamma);
    if~hold_state
        hold off
    end

    if nargout>0
        varargout{1}=hlines;
        if nargout==2
            varargout{2}=hsm;
        end
    end


    legend(lgndtxt)

    if nargout
        varargout{1}=hlines;
    end

