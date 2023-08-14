function changeLinesToMarkers(h)








    for i=1:numel(h)
        if(h(i).LineStyleMode=="auto")&&(h(i).MarkerMode=="auto")
            h(i).Marker='o';
            h(i).LineStyle='none';
        end
    end

end