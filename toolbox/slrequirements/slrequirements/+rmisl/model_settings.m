function out=model_settings(modelH,method,value)





    switch(lower(method))
    case 'get'
        out=get_settings(modelH);
        if isempty(out)
            out=default_model_settings;
        end

    case 'set'
        set_settings(modelH,value);

    otherwise
        error(message('Slvnv:reqmgt:model_settings:UnknownMethod',method));
    end

    function out=default_model_settings

        doorsSettings=struct(...
        'surrogatepath','./$ModelName$',...
        'savemodel',1,...
        'savesurrogate',1,...
        'updateLinks',0,...
        'doorsLinks2sl',0,...
        'slLinks2Doors',0,...
        'purgeSimulink',0,...
        'purgeDoors',0,...
        'detaillevel',1,...
        'surrogateId','',...
        'synctime','');

        misc=struct(...
        'mode','generic',...
        'pathStorage','modelRelative');

        out=struct(...
        'doors',doorsSettings,...
        'misc',misc);


        function out=get_settings(modelH)
            try
                str=get_param(modelH,'reqMgrSettings');
            catch Mex %#ok<NASGU>
                str=[];
            end

            if isempty(str)
                out=[];
            else
                out=sf('Private','str2mx',str);

                if~isfield(out.doors,'updateLinks')
                    out.doors.purgeSimulink=0;
                    out.doors.purgeDoors=0;
                    out.doors.updateLinks=0;
                end
            end


            function set_settings(modelH,value)
                value=recursiveLogical2Double(value);
                str=sf('Private','mx2str',value);

                try
                    set_param(modelH,'reqMgrSettings',str);
                catch Mex %#ok<NASGU>
                    add_param(modelH,'reqMgrSettings',str);
                end


                function data=recursiveLogical2Double(data)
                    if iscell(data)
                        for idx=1:length(data(:))
                            data{idx}=recursiveLogical2Double(data{idx});
                        end
                    end

                    if isstruct(data)
                        fields=fieldnames(data);
                        cnt=length(data(:));
                        for idx=1:cnt
                            for field=fields'
                                value=getfield(data,{idx},field{1});
                                value=recursiveLogical2Double(value);
                                data=setfield(data,{idx},field{1},value);
                            end
                        end
                    end


                    if islogical(data)
                        data=data+0;
                    end

