function out=InstructionSetExtensions_values(cs,~,direction,widgetVals)




    if direction==0
        value=cs.get_param('InstructionSetExtensions');
        if isempty(value)
            firstName='None';
        else
            assert(iscell(value));
            len=length(value);
            if len==0
                firstName='None';
            else
                firstName=value{1};
            end
        end
        newValueString=firstName;

        out={newValueString,''};
    elseif direction==1
        out=widgetVals{1};%#ok<CCAT1>
    end
