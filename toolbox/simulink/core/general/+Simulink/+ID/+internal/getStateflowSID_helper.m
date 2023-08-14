function[out,blockH,varargout]=getStateflowSID_helper(h)




    import Simulink.ID.internal.getReferenceBlock

    nout=nargout;
    nargoutchk(2,3);

    if isa(h,'Stateflow.Chart')||isa(h,'Stateflow.EMChart')||isa(h,'Stateflow.TruthTableChart')||isa(h,'Stateflow.StateTransitionTableChart')||isa(h,'Stateflow.ReactiveTestingTableChart')
        blockH=sfprivate('getActiveInstance',h.Id);
        if nout>2
            varargout{1}=[];
            chartH=idToHandle(sfroot,sfprivate('getChartOf',h.Id));
            refBlockH=get_param(chartH.Path,'Handle');
            if refBlockH~=blockH
                varargout{1}=refBlockH;
            end
        end
        out='';
    elseif isa(h,'Stateflow.LinkChart')
        blockH=get_param(h.Path,'handle');
        if nout>2,varargout{1}=getReferenceBlock(blockH);end
        out='';
    else
        [out,blockH]=sfprivate('handleTossId',h);
        if nout>2,varargout{1}=getReferenceBlock(blockH);end
    end
