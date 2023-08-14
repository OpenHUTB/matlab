function bool=isInPerspective(input)





    try

        if nargin<1
            src=simulinkcoder.internal.util.getSource();
        else
            src=simulinkcoder.internal.util.getSource(input);
        end

        cp=simulinkcoder.internal.CodePerspective.getInstance;
        bool=cp.getStatus(src.studio);

    catch
        bool=false;
    end