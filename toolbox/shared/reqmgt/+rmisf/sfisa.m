function out=sfisa(in)





    persistent sfIsaStruct;
    persistent sfObjTypes;
    persistent isaFilter;

    if isempty(sfIsaStruct)
        sfIsaStruct.chart=sf('get','default','chart.isa');
        sfIsaStruct.state=sf('get','default','state.isa');
        sfIsaStruct.junction=sf('get','default','junction.isa');
        sfIsaStruct.transition=sf('get','default','transition.isa');
        sfIsaStruct.machine=sf('get','default','machine.isa');
        sfIsaStruct.target=sf('get','default','target.isa');
        sfIsaStruct.event=sf('get','default','event.isa');
        sfIsaStruct.data=sf('get','default','data.isa');
        sfIsaStruct.instance=sf('get','default','instance.isa');
        sfIsaStruct.port=sf('get','default','port.isa');

        sfObjTypes={'Stateflow.Chart',...
        'Stateflow.EMChart',...
        'Stateflow.StateTransitionTableChart',...
        'Stateflow.ReactiveTestingTableChart',...
        'Stateflow.TruthTableChart',...
        'Stateflow.TruthTable',...
        'Stateflow.State',...
        'Stateflow.Transition',...
        'Stateflow.Box',...
        'Stateflow.EMFunction',...
        'Stateflow.Function',...
        'Stateflow.SLFunction',...
        'Stateflow.AtomicSubchart',...
        'Stateflow.AtomicBox',...
        'Stateflow.SimulinkBasedState',...
        };


        isaFilter=makeFilter(sfObjTypes);
    end

    if nargin==0
        out=sfIsaStruct;
    elseif strcmp(in,'supportedTypes')
        out=sfObjTypes;
    elseif strcmp(in,'isaFilter')
        out=isaFilter;
    end
end

function filter=makeFilter(allTypes)
    totalTypes=length(allTypes);
    filter=cell(1,totalTypes*3-1);
    filter(1:3:totalTypes*3-2)={'-isa'};
    filter(2:3:totalTypes*3-1)=allTypes;
    filter(3:3:totalTypes*3-3)={'-or'};
end

