function entryContainMatrix=getEntryContainMatrix(h)

    thisEnt=h.object;
    entryContainMatrix=h.activeconceptargIsMatrix||thisEnt.containMatrix();

end

