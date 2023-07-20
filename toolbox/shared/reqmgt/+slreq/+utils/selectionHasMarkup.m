




function tf=selectionHasMarkup(cbinfo)
    tf=false;
    if isa(cbinfo,'SLM3I.CallbackInfo')
        tf=cbinfo.selectionContains({'markupM3I.MarkupItem','markupM3I.MarkupConnector'});
    elseif isa(cbinfo,'GLUE2.ImmutableSequenceOfDiagramElement')

        for i=1:cbinfo.size
            menuItem=cbinfo.at(i);
            if isa(menuItem,'markupM3I.MarkupItem')||...
                isa(menuItem,'markupM3I.MarkupConnector')
                tf=true;
                return;
            end
        end
    end
end

