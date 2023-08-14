

function[flag,portNum]=isMLFunctionCallEvent(mtreeNode,aAstObj)

    flag=false;
    portNum=-1;
    assert(isa(mtreeNode,'mtree'));
    if~isa(aAstObj.ParentChart,'slci.matlab.EMChart')
        return;
    end

    if any(strcmpi(mtreeNode.kind,{'CALL','LP'}))
        fnode=mtreeNode.Left;
        if strcmp(fnode.kind,'ID')
            fname=fnode.string;

            chart=aAstObj.ParentChart;
            chartObj=chart.getUDDObject;
            fcnCallSignals=chartObj.find('-isa','Stateflow.FunctionCall');


            for i=1:numel(fcnCallSignals)
                fcnCall=fcnCallSignals(i);
                if strcmpi(fname,fcnCall.Name)
                    flag=true;
                    portNum=fcnCall.Port;
                    return;
                end
            end
        end

    end
end