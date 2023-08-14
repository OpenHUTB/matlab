function lock(obj,varargin)




    if nargin==1
        src=simulinkcoder.internal.util.getSource();
    else
        input=varargin{1};
        src=simulinkcoder.internal.util.getSource(input);
    end

    mdl=src.modelName;
    data=mdl;

    if nargin==3
        data=varargin{2};
    end

    obj.publish(mdl,'lock',data);









