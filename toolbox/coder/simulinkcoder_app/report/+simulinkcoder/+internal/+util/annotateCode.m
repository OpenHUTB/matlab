function annotateCode(model,varargin)












...
...
...
...
...
...
...
...
...
...
...
...

    src=simulinkcoder.internal.util.getSource(model);
    mdl=src.modelName;
    action='annotate';
    cr=simulinkcoder.internal.Report.getInstance;

    if nargin==1
        cr.publish(mdl,action,'');
    else
        input=varargin{1};
        loc_checkInput(input);
        cr.publish(mdl,action,input);
    end

    function loc_checkInput(input)
