function widget=makeWidget(prop,hDialog,source)




    ;




    widget=feval(['l_',prop.WidgetType],prop);
    widget.Tag=prop.Name;


    isModelStopped=true;
    if~isempty(hDialog.getModel())
        isModelStopped=strcmpi(get_param(hDialog.getModel(),'SimulationStatus'),'stopped');
    end

    widget.Enabled=lGetValue(hDialog,prop,'Enabled')&&isModelStopped&&~hDialog.isObjectLocked;

    widget.ObjectProperty=prop.Name;
    configset=hDialog.getConfigSet;



    if isa(configset,'Simulink.ConfigSet')&&strcmp(configset.IsDialogCache,'on')
        widget.Mode=1;
    end



    if isprop(prop,'MatlabMethod')&&~isempty(prop.MatlabMethod)
        widget.Mode=1;
        widget.MatlabMethod=prop.MatlabMethod;
        if strcmp(widget.Type,'pushbutton')



            widget.MatlabArgs={'%source'};
        else
            widget.MatlabArgs={'%dialog','%source','%value','%tag'};
        end
    end

    if nargin>2
        widget=l_add_extras(widget,source);
    end

    function widget=l_edit(prop)


        widget=struct('Type','edit',...
        'Name',[prop.getLabel,':']);

        function widget=l_checkbox(prop)


            widget=struct('Type','checkbox',...
            'Name',prop.getLabel);

            function widget=l_pushbutton(prop)


                widget=struct('Type','pushbutton',...
                'Name',prop.getLabel);

                function widget=l_combobox(prop)


                    widget=struct('Type',{'combobox'},...
                    'Name',{[prop.getLabel,':']},...
                    'Entries',{prop.Entries'});

                    function widget=l_units(prop)


                        widget=struct('Type',{'combobox'},...
                        'Name',{''},...
                        'Entries',{prop.Entries'});

                        function widget=l_add_extras(widget,source)


                            widget.MatlabMethod='updateDialog';
                            widget.MatlabArgs={source,'%dialog',widget.Type,'%tag'};
                            if strcmp(widget.Type,'combobox')
                                widget.MatlabArgs{end+1}=widget.Entries;
                            end




                            function v=lGetValue(hDialog,prop,field)


                                v=prop.(field);
                                if isa(v,'function_handle')
                                    v=v(hDialog,prop);
                                end
