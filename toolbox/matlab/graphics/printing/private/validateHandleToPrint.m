function pj=validateHandleToPrint(pj)
















    if isempty(pj.Handles)

        h=gcbf;
        if isempty(h)

            h=findobj(get(0,'children'),'flat','type','figure');
        end
        if isempty(h)
            error(message('MATLAB:print:ValidateNoFigure'))
        else
            pj.Handles={h(1)};
        end
    else
        if~iscell(pj.Handles)
            error(message('MATLAB:print:ValidateMustBeCell'))
        end

        if length(pj.Handles)>1
            error(message('MATLAB:print:ValidateOnlyPrintOnePage'))
        end
    end

    h=pj.Handles{1};
    pj.ParentFig=ancestor(h,'figure');
    if ishghandle(h)
        if~isfigure(h)
            error(message('MATLAB:print:HGFigure'))
        else

            pj.UseOriginalHGPrinting=useOriginalHGPrinting(h);
        end



        if~matlab.graphics.internal.mlprintjob.usesJava(pj)
            canvas=findobj(pj.ParentFig.NodeChildren,'-depth',0,'-class','matlab.graphics.primitive.canvas.HTMLCanvas');
            if isempty(canvas)

                error(message('MATLAB:print:EmptyFigureNotSupported'));
            end
        end

    end


end

