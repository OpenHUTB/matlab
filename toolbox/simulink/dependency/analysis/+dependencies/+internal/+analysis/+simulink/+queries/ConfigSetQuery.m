classdef ConfigSetQuery<dependencies.internal.analysis.simulink.queries.AdvancedQuery




    properties(GetAccess=public,SetAccess=immutable)
        Class(1,1)string;
        Parameter(1,1)string;
    end

    methods
        function queries=ConfigSetQuery(class,parameter)
            queries.Class=class;
            queries.Parameter=parameter;
        end

        function[loadSaveQuery,numMatches]=createLoadSaveQueries(this)

            slx=Simulink.loadsave.Query('/ConfigSet/Object[ClassName="Simulink.ConfigSet"]/Array/Object[ClassName="'+this.Class+'"]/'+this.Parameter);
            slxName=Simulink.loadsave.Query('/ConfigSet/Object[ClassName="Simulink.ConfigSet" and Array/Object/'+this.Parameter+'=*]/Name');


            mdl=Simulink.loadsave.Query('/Model/Array/Simulink.ConfigSet/Array/'+this.Class+'/'+this.Parameter);
            mdlName=Simulink.loadsave.Query('/Model/Array/Simulink.ConfigSet[Array/'+this.Class+'/'+this.Parameter+'=*]/Name');

            loadSaveQuery={[slx;slxName;mdl;mdlName],...
            {'slx';'slx';'mdl';'mdl'}};

            numMatches=2;
        end

        function match=createMatch(~,~,~,rawMatches)
            match.Value={rawMatches{1}.Value};
            match.Configset={rawMatches{2}.Value};
        end

    end

end
