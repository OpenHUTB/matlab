classdef SWSystem<handle&matlab.mixin.SetGet&matlab.mixin.CustomDisplay




    properties

Root

ShortName

Instances

NumInstances

        InstanceNames string

        HasVariantProps logical
    end

    properties(Hidden=true)

SystemInstanceTable
    end

    methods
        function obj=SWSystem(root,swsys)



            obj.Root=root;
            obj.ShortName=string(swsys.SHORT_NAME.elementValue);
            obj.HasVariantProps=strcmpi(swsys.SW_INSTANCE_SPEC.SW_INSTANCE_TREE.CATEGORY.elementValue,"VCD");


            instanceArray=swsys.SW_INSTANCE_SPEC.SW_INSTANCE_TREE.SW_INSTANCE.toArray;


            obj.SystemInstanceTable=table('Size',[0,7],'VariableTypes',{'string','string','string','cell','string','string','cell'},'VariableNames',{'ShortName','System','Category','Value','Units','FeatureReference','ObjectHandles'});


            for idx=1:numel(instanceArray)
                obj.Instances=[obj.Instances,asam.cdfx.SWInstanceFactory(root,obj,instanceArray(idx))];
                obj.InstanceNames=[obj.InstanceNames,obj.Instances(idx).ShortName];


                shortNames=obj.Instances(idx).ShortName;
                sysNames=obj.ShortName;
                instCategories=obj.Instances(idx).Category;
                values=obj.Instances(idx).Value;
                units=obj.Instances(idx).Units;
                featureRefs=obj.Instances(idx).FeatureReference;
                objectHandles=obj.Instances(idx);
                cellInstance={shortNames,sysNames,instCategories,{values},units,featureRefs,objectHandles};


                obj.SystemInstanceTable=[obj.SystemInstanceTable;cellInstance];
            end


            obj.NumInstances=numel(instanceArray);


            for idx=1:obj.NumInstances
                if any(obj.SystemInstanceTable.Category{idx}==["CURVE","CURVE_AXIS","MAP","CUBOID","CUBE_4","CUBE_5"])
                    obj.SystemInstanceTable.ObjectHandles(idx).resolveAxisValues();
                end
            end

        end

    end
end

