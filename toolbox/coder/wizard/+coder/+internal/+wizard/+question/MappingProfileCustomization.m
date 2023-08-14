


classdef MappingProfileCustomization<coder.internal.wizard.QuestionBase
    properties(Constant)
        profiles=loc_getProfiles();
        categories=loc_getCategories();
    end

    methods
        function obj=MappingProfileCustomization(env)
            id='MappingProfileCustomization';
            topic='Custosmization';
            obj@coder.internal.wizard.QuestionBase(id,topic,env);

            obj.getAndAddOption(env,'MappingProfileOptions');
            obj.setDefaultValue('MappingProfileOptions','Choose ...');

            obj.HintMessage='';

            obj.TrailTable.Title='';
            obj.TrailTable.Content='';
        end

        function onChange(obj)
            env=obj.Env;
            option=obj.Options{1};
            option.Value=obj.getProfileNames();

            obj.TrailTable.Title=['<table class="mapping-table"><tr><th id="MappingCategory" class="left-col">','Model Element Category','</th>'...
            ,'<th id="MappingValue" class="right-col">','Storage Class','</th></tr></table>'];

            profile=[];
            for i=1:length(obj.profiles)
                p=obj.profiles{i};
                if strcmp(option.Answer,p.Name)
                    profile=p;
                    break;
                end
            end
            obj.TrailTable.Content=obj.createTable(profile);

            env.Gui.send_question(obj);
        end

        function out=createTable(obj,profile)
            n=length(obj.categories);
            lines=cell(1,n);
            for i=1:n
                cat=obj.categories{i};
                if isfield(profile.Mapping,cat)
                    value=profile.Mapping.(cat);
                    set=true;
                else
                    value='Default';
                    set=false;
                end

                if set
                    lines{i}=['<tr class="mapping-row set"><td class="mapping-category-cell left-col">',cat,'</td>'...
                    ,'<td class="mapping-value-cell right-col">',value,'</td></tr>'];
                else
                    lines{i}=['<tr class="mapping-row"><td class="mapping-category-cell left-col">',cat,'</td>'...
                    ,'<td class="mapping-value-cell right-col">',value,'</td></tr>'];
                end

            end
            lines=['<table id="MappingTable" class="mapping-table">',lines,'</table>'];
            out=strjoin(lines);
        end
    end


    methods(Static=true)
        function out=getNextQuestionId(env)
            if coder.internal.wizard.isDeviceEditable(env.ModelHandle)
                out='Wordsize';
            else
                out='Optimization';
            end
        end

        function out=getProfileNames()
            ps=coder.internal.wizard.question.MappingProfileCustomization.profiles;
            n=length(ps);
            out=cell(1,n);
            for i=1:n
                p=ps{i};
                out{i}=p.Name;
            end
        end
    end
end

function out=loc_getProfiles()

    out={};


    p=[];mapping=[];
    p.Name='Import inputs and export outputs for a top model';
    mapping.Inports='ImportedExtern';
    mapping.Outports='ExportedGlobal';
    mapping.Internals='FileScope';
    p.Mapping=mapping;
    out{end+1}=p;


    p=[];mapping=[];
    p.Name='Use global variables for inputs and outputs in referenced model';
    mapping.Inports='ExportedGlobal';
    mapping.Outports='ExportedGlobal';
    p.Mapping=mapping;
    out{end+1}=p;


    p=[];mapping=[];
    p.Name='Use multi-instanced data as arguments in referenced model';
    p.Mapping=mapping;
    out{end+1}=p;


    p=[];mapping=[];
    p.Name='All default';
    p.Mapping=mapping;
    out{end+1}=p;

end

function out=loc_getCategories()
    out={...
    'Inports',...
    'Outports',...
    'Constants',...
    'Internals',...
    'Parameters',...
    'GlobalParameters',...
    'SharedLocalDataStores',...
'GlobalDataStores'...
    };
end


