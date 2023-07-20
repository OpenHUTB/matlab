function unlock(obj,varargin)




    if nargin==1
        src=simulinkcoder.internal.util.getSource();
    else
        input=varargin{1};
        src=simulinkcoder.internal.util.getSource(input);
    end

    mdl=src.modelName;
    obj.publish(mdl,'unlock','');









