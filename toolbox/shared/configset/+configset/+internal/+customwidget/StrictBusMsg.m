function out=StrictBusMsg(cs,~,direction,widgetVals)

...
...
...
...
...
...
...
...






    if direction==0
        paramVal=cs.getProp('StrictBusMsg');
        switch paramVal
        case 'None'
            out={'none'};
        case 'Warning'
            out={'none'};
        case 'ErrorLevel1'
            out={'none'};
        case 'WarnOnBusTreatedAsVector'
            out={'warning'};
        case 'ErrorOnBusTreatedAsVector'
            out={'error'};
        end
    elseif direction==1
        val=widgetVals{1};
        if strcmp(val,'none')
            out='ErrorLevel1';
        elseif strcmp(val,'warning')
            out='WarnOnBusTreatedAsVector';
        elseif strcmp(val,'error')
            out='ErrorOnBusTreatedAsVector';
        end
    end

