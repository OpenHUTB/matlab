function target=getTarget(~,varargin)





    if nargin==1
        src=simulinkcoder.internal.util.getSource();
    else
        src=simulinkcoder.internal.util.getSource(varargin{1});
    end
    mdl=src.modelH;

    cp=simulinkcoder.internal.CodePerspective.getInstance;
    [~,target]=cp.getInfo(mdl);
