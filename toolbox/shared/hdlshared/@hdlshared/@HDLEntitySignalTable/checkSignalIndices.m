function checkSignalIndices(this,indices)


    if any(indices<1)||any(indices>this.NextSignalIndex-1)
        error(message('HDLShared:directemit:internalsignalerror'))
    end
