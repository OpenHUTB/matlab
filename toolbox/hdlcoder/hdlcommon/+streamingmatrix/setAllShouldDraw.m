
function setAllShouldDraw(p)
    for i=1:numel(p.Networks)
        p.Networks(i).renderCodegenPir(true);
    end
end
