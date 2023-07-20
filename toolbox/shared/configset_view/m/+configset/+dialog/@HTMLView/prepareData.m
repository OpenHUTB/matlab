function prepareData(obj,varargin)




    adp=obj.Source;
    cs=adp.Source;
    if~isa(cs,'Simulink.BaseConfig')&&~isa(cs,'qe.BaseConfig')
        return;
    end

    obj.params={};

    if nargin>1
        lazy=varargin{1};
    else
        lazy=true;
    end

    parameterOverrides=[];
    if isa(cs,'Simulink.ConfigSetRef')

        if~isa(cs.LocalConfigSet,'Simulink.BaseConfig')

            return;
        end
        parameterOverrides=cs.CurrentParameterOverrides;
        cs.LocalConfigSet.CurrentDlgPage=cs.CurrentDlgPage;
        cs=cs.LocalConfigSet;
    end



    [compJSON,compLF]=obj.getComponentJSON(cs,'',lazy);
    compJSON=['[',compJSON,']'];

    hdlcc=cs.getComponent('HDL Coder');
    if~isempty(hdlcc)
        hdlcc.hasDialogEverOpened(true);
    end


    customized=configset.dialog.Customizer.getCustomizationResults(obj.Dlg);
    if isempty(customized)
        customizedJSON='null';
    else
        customizedJSON=jsonencode(customized);
    end


    cfg=obj.cfg;
    if isstruct(cfg)


        if isfield(cfg,'custom')
            cfg.custom=loc_getCustomization(cfg.custom);
        end
    else


        cfg=[];
        cfg.custom=loc_getCustomization(obj.cfg);
    end


    layoutFeature=configset.htmlview.custom_functions.getLayoutFeatures();

    layoutFeature=configset.dialog.HTMLView.mergeStructs(layoutFeature,compLF);


    obj.data=['{"components":',compJSON,...
    ',"customized":',customizedJSON,...
    ',"cfg":',jsonencode(cfg),...
    ',"done":',jsonencode(lazy),...
    ',"layoutFeature":',jsonencode(layoutFeature),...
    ',"parameterOverrides":',jsonencode(parameterOverrides),'}'];


    toRemove={'showGroup','highlight'};
    for i=1:length(toRemove)
        action=toRemove{i};
        if isfield(obj.cfg,action)
            obj.cfg=rmfield(obj.cfg,action);
        end
    end

    function out=loc_getCustomization(input)
        out='';
        if~isempty(input)

            if ischar(input)||isStringScalar(input)
                if exist(input,'file')==2

                    fid=fopen(input);
                    if fid~=-1
                        out=fscanf(fid,'%c');
                    end
                    fclose(fid);
                else

                    if isStringScalar(input)
                        cstr=input.char;
                    else
                        cstr=input;
                    end
                    if cstr(1)=='<'
                        out=input;
                    else
                        out={input};
                    end
                end
            else

                out=input;
            end
        end


