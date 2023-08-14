function show(obj,input,pinned)






    if nargin<3
        pinned=true;
    end

    src=simulinkcoder.internal.util.getSource(input);


    if isempty(src.modelName)
        return;
    end


    studio=src.studio;
    if isempty(studio)
        return;
    end

    cps=simulinkcoder.internal.CodePerspectiveInStudio.getFromStudio(studio);
    if isempty(cps.cv)
        cps.cv=simulinkcoder.internal.CodeView_C(studio);
    end
    cv=cps.cv;
    cv.open([],pinned);

