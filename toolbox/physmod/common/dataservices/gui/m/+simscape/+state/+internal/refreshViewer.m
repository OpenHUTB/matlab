function refreshViewer(name)




    if~isempty(which('simscape.state.openViewer'))
        simulateModel=true;
        simscape.state.openViewer(name,true,simulateModel);
    end

end
