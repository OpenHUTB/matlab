function msg=i_convertMExceptionHierarchyToMessage(excep,varargin)








    if isempty(excep)
        msg=[];
        return;
    end
    if nargin==1
        recursionLevel=1;
    else
        recursionLevel=varargin{1};
    end

    msg=excep.message;
    if isempty(excep.cause)
        return;
    end


    if recursionLevel==1

        msg=[msg,newline,getString(message('Simulink:Variants:CausedBy'))];
    end
    for i=1:numel(excep.cause)
        subMsg=Simulink.variant.utils.i_convertMExceptionHierarchyToMessage(excep.cause{i},(recursionLevel+1));

        msg=[msg,newline,repmat(' ',1,4*recursionLevel),subMsg];%#ok<AGROW>
    end
end
