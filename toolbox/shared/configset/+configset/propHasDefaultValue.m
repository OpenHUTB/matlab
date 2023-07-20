function[b,def]=propHasDefaultValue(obj,name)










    def=[];

    logger=Simulink.loadsave.internal.logger('configset::defaults','debug');
    if logger.enabled



        cls=class(obj);
        [pkg,rem]=strtok(cls,'.');
        p=findpackage(pkg);
        c=p.findclass(strtok(rem,'.'));
        prop=c.findprop(name);
        type=prop.DataType;
        logger.log(...
        sprintf('Check prop: %s :: %s (%s)',class(obj),name,type));
    end

    if name=="Components"

        b=isempty(obj.Components);
        return;
    end

    persistent component_cache;

    if isempty(component_cache)


        component_cache=containers.Map;
    end

    obj_class=class(obj);
    if isKey(component_cache,obj_class)
        obj_def_instance=component_cache(obj_class);
    else

        try
            obj_def_instance=eval(obj_class);
        catch
            if obj_class=="Simulink.RTWCC"


                cs=Simulink.ConfigSet;
                obj_def_instance=cs.getComponent('Code Generation');
                obj_def_instance.DisabledProps=[];
            else



                obj_def_instance=struct;
            end
        end
        component_cache(obj_class)=obj_def_instance;
    end

    if isstruct(obj_def_instance)

        def='!!ObjectConstructionFailed!!';
    else
        def=obj_def_instance.(name);
    end

    b=isequal(obj.(name),def);
