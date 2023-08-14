



function prepareModuleInstrumentation(this,incrementalBuild)

    if nargin<2
        incrementalBuild=false;
    end
    this.InstrumImpl.prepareModuleInstrumentation(incrementalBuild);